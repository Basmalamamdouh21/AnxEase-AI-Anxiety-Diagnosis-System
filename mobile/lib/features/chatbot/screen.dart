import 'package:anxease/features/home/shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anxease/core/services/chat_service.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/core/theme/_colors.dart';

class ChatbotScreen extends StatefulWidget {
  final String userId;

  const ChatbotScreen({super.key, required this.userId});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();

  final ChatService service = ChatService();

  List<_Message> messages = [];
  List<ChatSession> chats = [];

  String? chatId;

  bool typing = false;
  String emotion = "Stable";

  String get lastChatKey => "last_opened_chat_${widget.userId}";

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadChats();

    final prefs = await SharedPreferences.getInstance();
    final savedChat = prefs.getString(lastChatKey);

    if (savedChat != null) {
      try {
        final history = await service.loadMessages(widget.userId, savedChat);

        setState(() {
          chatId = savedChat;

          messages = history
              .map((m) => _Message(m["content"], m["role"] == "user"))
              .toList();
        });

        scroll();
        return;
      } catch (_) {}
    }

    final id = await service.createChat(widget.userId);

    setState(() {
      chatId = id;
    });

    await _saveLastChat(id);
  }

  Future<void> _loadChats() async {
    final list = await service.listChats(widget.userId);

    setState(() {
      chats = list;
    });
  }

  Future<void> _deleteChat(String id) async {
    await service.deleteChat(widget.userId, id);

    if (chatId == id) {
      messages.clear();
      chatId = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(lastChatKey);
    }

    await _loadChats();

    if (chats.isNotEmpty && chatId == null) {
      final newId = chats.first.chatId;

      final history = await service.loadMessages(widget.userId, newId);

      setState(() {
        chatId = newId;

        messages = history
            .map((m) => _Message(m["content"], m["role"] == "user"))
            .toList();
      });

      await _saveLastChat(newId);

      scroll();
    }

    setState(() {});
  }

  Future<void> _saveLastChat(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastChatKey, id);
  }

  Future<void> _newChat() async {
    final id = await service.createChat(widget.userId);

    await _saveLastChat(id);

    setState(() {
      chatId = id;
      messages.clear();
      emotion = "Stable";
    });

    _loadChats();
  }

  void _openChatHistory() async {
    await _loadChats();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * .6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "Chat History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (_, i) {
                    final chat = chats[i];

                    final selected = chat.chatId == chatId;

                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(chat.title),
                      selected: selected,

                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Chat"),
                              content: const Text(
                                "Are you sure you want to delete this conversation?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _deleteChat(chat.chatId);
                            Navigator.pop(context);
                          }
                        },
                      ),

                      onTap: () async {
                        final history = await service.loadMessages(
                          widget.userId,
                          chat.chatId,
                        );

                        await _saveLastChat(chat.chatId);

                        setState(() {
                          chatId = chat.chatId;

                          messages = history
                              .map(
                                (m) =>
                                    _Message(m["content"], m["role"] == "user"),
                              )
                              .toList();
                        });

                        Navigator.pop(context);

                        scroll();
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _newChat();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("New Chat"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> send() async {
    if (chatId == null) return;

    final text = controller.text.trim();

    if (text.isEmpty) return;

    controller.clear();

    setState(() {
      messages.add(_Message(text, true));
      typing = true;
    });

    scroll();

    try {
      final result = await service.sendMessage(
        userId: widget.userId,
        chatId: chatId!,
        message: text,
      );

      emotion = result.emotion;

      if (result.crisis) {
        _showCrisisAlert();
      }

      await _streamReply(result.response);
    } catch (_) {
      setState(() {
        messages.add(
          _Message("⚠️ Anxease Therapist temporarily unavailable.", false),
        );
        typing = false;
      });
    }
  }

  Future<void> _streamReply(String reply) async {
    String buffer = "";

    messages.add(_Message("", false));

    for (int i = 0; i < reply.length; i++) {
      await Future.delayed(const Duration(milliseconds: 12));

      buffer += reply[i];

      setState(() {
        messages.last.text = buffer;
      });

      scroll();
    }

    setState(() {
      typing = false;
    });
  }

  void scroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCrisisAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Important Support Message"),
        content: const Text(
          "It sounds like you may be going through something very difficult.\n\n"
          "You are not alone. If you're in immediate danger or thinking about harming yourself, "
          "please consider contacting a trusted person or a mental health professional.\n\n"
          "You deserve support and help.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              if (messages.isNotEmpty) _emotionBanner(),
              Expanded(child: _chatArea()),
              if (typing) _typingIndicator(),
              _inputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeShell()),
            ),
            child: const Icon(Icons.arrow_back_ios_new),
          ),

          const SizedBox(width: 10),

          // Title
          const Expanded(
            child: Center(
              child: Text(
                "Anxease Therapist",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // History
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openChatHistory,
          ),

          // New chat
          IconButton(icon: const Icon(Icons.add), onPressed: _newChat),
        ],
      ),
    );
  }

  Widget _emotionBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology),
          const SizedBox(width: 10),
          Text("Detected emotional state: $emotion"),
        ],
      ),
    );
  }

  Widget _chatArea() {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hey there",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 10),
                _WavingHand(size: 32),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "I'm your AI therapist.\nHow are you feeling today?",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: messages.length,
      itemBuilder: (_, i) => bubble(messages[i]),
    );
  }

  Widget bubble(_Message msg) {
    final align = msg.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    final color = msg.isUser
        ? AppColors.primary
        : Colors.white.withValues(alpha: 0.95);

    final textColor = msg.isUser ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: msg.isUser
                ? Text(msg.text, style: TextStyle(color: textColor))
                : MarkdownBody(
                    data: msg.text,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(color: textColor),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        "Anxease is typing...",
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => send(),
                decoration: const InputDecoration(
                  hintText: "Share what's on your mind...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: send,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  String text;
  final bool isUser;

  _Message(this.text, this.isUser);
}

class _WavingHand extends StatefulWidget {
  final double size;

  const _WavingHand({this.size = 32});

  @override
  State<_WavingHand> createState() => _WavingHandState();
}

class _WavingHandState extends State<_WavingHand>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _rotation = Tween<double>(
      begin: -0.2,
      end: 0.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          alignment: Alignment.bottomCenter,
          child: const Icon(
            Icons.waving_hand_rounded,
            size: 48,
            color: Colors.amber,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
