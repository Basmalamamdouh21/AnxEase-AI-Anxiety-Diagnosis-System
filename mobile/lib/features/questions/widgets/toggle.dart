import 'package:flutter/material.dart';
import 'package:anxease/core/theme/_colors.dart';

class YesNoToggle extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool> onChanged;

  const YesNoToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth == double.infinity
            ? 110.0
            : constraints.maxWidth;

        const height = 36.0;
        const padding = 4.0;

        final knobWidth = (width - (padding * 2)) / 2;

        return GestureDetector(
          onTap: () {
            if (value == null) {
              onChanged(true);
            } else {
              onChanged(!value!);
            }
          },
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(height),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: value == true
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: knobWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(height),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: value == true
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "No",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: value == false || value == null
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
