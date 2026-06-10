import 'package:flutter/material.dart';
import 'package:anxease/shared/widgets/gradient_background.dart';

class TreatmentDetailsScreen extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;

  const TreatmentDetailsScreen({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _header(context),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  children: data.entries
                      .map((e) => _sectionCard(e.key, e.value))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xff667eea), Color(0xff764ba2)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff764ba2).withValues(alpha: .45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        color: Colors.white.withValues(alpha: .92),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xff4facfe), Color(0xff00f2fe)],
                  ),
                ),
                child: const Icon(
                  Icons.psychology_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  _formatKey(title),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _renderValue(value),
        ],
      ),
    );
  }

  Widget _renderValue(dynamic value) {
    if (value is Map) {
      return Column(
        children: value.entries
            .map((e) => _subSection(e.key, e.value))
            .toList(),
      );
    }

    if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xff4facfe), Color(0xff00f2fe)],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    item.toString(),
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Text(
      value.toString(),
      style: const TextStyle(
        height: 1.6,
        fontSize: 14.5,
        color: Colors.black87,
      ),
    );
  }

  Widget _subSection(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          color: Colors.grey.withValues(alpha: .05),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatKey(key),
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            _renderValue(value),
          ],
        ),
      ),
    );
  }

  String _formatKey(String key) {
    String text = key.replaceAll('_', ' ');

    text = text.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    final words = text.split(' ');

    final formatted = words
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');

    return formatted;
  }
}
