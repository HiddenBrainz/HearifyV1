import 'package:flutter/material.dart';

import '../../../../core/theme/auth_design_system.dart';

/// iOS-style two-segment pill toggle. The track is slightly lighter
/// than the auth card and the selected segment is filled with a muted
/// gray pill — matches the UIKit `UISegmentedControl` look.
class AuthSegmentedToggle extends StatelessWidget {
  const AuthSegmentedToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  }) : assert(labels.length == 2, 'AuthSegmentedToggle expects exactly 2 labels');

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final segmentWidth = trackWidth / 2;
        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.segmentTrack,
            borderRadius: BorderRadius.circular(AppRadii.segment),
          ),
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: selectedIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: segmentWidth - 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.segmentSelected,
                    borderRadius:
                        BorderRadius.circular(AppRadii.segment - 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final selected = i == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!selected) onChanged(i);
                      },
                      child: Center(
                        child: Text(
                          labels[i],
                          style: selected
                              ? AppTextStyles.segmentLabelActive
                              : AppTextStyles.segmentLabelInactive,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
