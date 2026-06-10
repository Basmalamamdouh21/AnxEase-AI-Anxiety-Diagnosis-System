import 'package:flutter/material.dart';
import 'package:anxease/shared/widgets/button.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';
import 'package:anxease/core/models/user_profile.dart';
import 'package:anxease/core/services/profile_service.dart';
import 'package:anxease/core/theme/_colors.dart';
import 'package:anxease/features/reports/screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String userId;

  const PersonalInfoScreen({super.key, required this.userId});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final jobController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  DateTime? selectedDate;
  String gender = "Male";
  String maritalStatus = "Single";
  bool hasInsurance = false;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService().getProfile(widget.userId);
    if (profile == null) return;

    setState(() {
      nameController.text = profile.name;
      usernameController.text = profile.username;
      phoneController.text = profile.phone;
      jobController.text = profile.job;
      weightController.text = profile.weight.toString();
      heightController.text = profile.height.toString();
      selectedDate = profile.date;
      gender = profile.gender;
      maritalStatus = profile.maritalStatus;
      hasInsurance = profile.hasInsurance;
    });
  }

  Future<void> _save() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter your name")));
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select birth date")));
      return;
    }

    setState(() => loading = true);

    final profile = UserProfile(
      userId: widget.userId,
      name: nameController.text,
      date: selectedDate!,
      username: usernameController.text,
      phone: phoneController.text,
      country: "Egypt",
      city: "Cairo",
      job: jobController.text,
      weight: double.tryParse(weightController.text) ?? 0,
      height: double.tryParse(heightController.text) ?? 0,
      gender: gender,
      maritalStatus: maritalStatus,
      hasInsurance: hasInsurance,
    );

    await ProfileService().saveProfile(profile);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReportScreen(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),

        child: AppGradientBackground(
          child: SafeArea(
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Row(
                      children: [
                        _modernBackButton(),

                        const SizedBox(width: 12),

                        const Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _glassCard(
                        child: Column(
                          children: [
                            _input("Full Name", nameController),
                            _datePicker(),
                            _input("Username", usernameController),
                            _input("Phone", phoneController),
                            _input("Job", jobController),

                            Row(
                              children: [
                                Expanded(
                                  child: _input("Weight", weightController),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _input("Height", heightController),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _section("Gender"),

                            const SizedBox(height: 10),

                            _selector(
                              ["Male", "Female"],
                              gender,
                              (v) => setState(() => gender = v),
                            ),

                            const SizedBox(height: 20),

                            _section("Marital Status"),

                            const SizedBox(height: 10),

                            _selector(
                              ["Single", "Married", "Divorced", "Widowed"],
                              maritalStatus,
                              (v) => setState(() => maritalStatus = v),
                            ),

                            const SizedBox(height: 20),

                            SwitchListTile(
                              value: hasInsurance,
                              activeColor: AppColors.primary,
                              title: const Text("Health Insurance"),
                              onChanged: (v) =>
                                  setState(() => hasInsurance = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      AppButton(
                        text: loading ? "Saving..." : "Save",
                        width: double.infinity,
                        onPressed: loading ? () {} : _save,
                      ),

                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernBackButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .85),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: .9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _section(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }

  Widget _selector(
    List<String> options,
    String selected,
    Function(String) onTap,
  ) {
    return Wrap(
      spacing: 10,
      children: options.map((option) {
        final active = option == selected;

        return GestureDetector(
          onTap: () => onTap(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: active ? Colors.white : AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );

        if (date != null) {
          setState(() => selectedDate = date);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? "Select Date"
                  : selectedDate.toString().split(" ").first,
            ),
            const Icon(Icons.calendar_today_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
