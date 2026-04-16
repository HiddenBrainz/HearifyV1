import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../domain/module_program.dart';

/// Port of HearifyV1/Views/ModuleProgramView.swift.
/// Displays the program structure and manual for a training module.
class ModuleProgramScreen extends StatefulWidget {
  const ModuleProgramScreen({
    super.key,
    required this.program,
    required this.onStartTraining,
  });

  final ModuleProgram program;
  final VoidCallback onStartTraining;

  @override
  State<ModuleProgramScreen> createState() => _ModuleProgramScreenState();
}

class _ModuleProgramScreenState extends State<ModuleProgramScreen> {
  final Set<int> _expandedPhases = {};

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final color = AppTheme.primaryBlue(b);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: Text('Module ${widget.program.moduleNumber}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            _header(color, b),
            const SizedBox(height: AppTheme.spacingL),
            _description(b),
            const SizedBox(height: AppTheme.spacingL),
            _objectives(color, b),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Program Structure',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(b),
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            ...widget.program.structure.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: _phaseCard(p, color, b),
                )),
            const SizedBox(height: AppTheme.spacingL),
            _tips(b),
            const SizedBox(height: AppTheme.spacingL),
            _footer(color, b),
            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _header(Color color, Brightness b) => ModernCard(
        child: Row(
          children: [
            Icon(widget.program.icon, size: 50, color: color),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MODULE ${widget.program.moduleNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary(b),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    widget.program.moduleName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(b),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 14, color: AppTheme.textSecondary(b)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.program.estimatedDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary(b),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _description(Brightness b) => ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(Icons.description, 'Program Overview', b),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              widget.program.description,
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary(b)),
            ),
          ],
        ),
      );

  Widget _objectives(Color color, Brightness b) => ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(Icons.gps_fixed, 'Learning Objectives', b),
            const SizedBox(height: AppTheme.spacingM),
            ...widget.program.objectives.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text(
                            '${e.key + 1}.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary(b),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      );

  Widget _phaseCard(ProgramPhase phase, Color color, Brightness b) {
    final isExpanded = _expandedPhases.contains(phase.phaseNumber);
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedPhases.remove(phase.phaseNumber);
              } else {
                _expandedPhases.add(phase.phaseNumber);
              }
            }),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    '${phase.phaseNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHASE ${phase.phaseNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary(b),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        phase.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(b),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: color,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    phase.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary(b),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _chip(Icons.schedule, phase.duration, b),
                  const SizedBox(height: AppTheme.spacingS),
                  _chip(Icons.check_circle_outline, phase.successCriteria, b),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(b),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  ...phase.exercises.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.fiber_manual_record,
                              size: 8, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary(b),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tips(Brightness b) => ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(Icons.lightbulb_outline, 'Tips', b),
            const SizedBox(height: AppTheme.spacingS),
            ...widget.program.tips.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.star_rate,
                        size: 14, color: AppTheme.accentOrange(b)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(b),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _footer(Color color, Brightness b) => FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
        ),
        onPressed: widget.onStartTraining,
        icon: const Icon(Icons.play_arrow),
        label: const Text(
          'Start Training',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );

  Widget _sectionLabel(IconData icon, String label, Brightness b) => Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue(b)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(b),
            ),
          ),
        ],
      );

  Widget _chip(IconData icon, String text, Brightness b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.backgroundSecondary(b),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary(b)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(b),
                ),
              ),
            ),
          ],
        ),
      );
}
