import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_date_controller.dart';
import 'package:prokopa/src/app/app_theme.dart';

class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(padding: padding, child: child),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSettings,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSettings;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: theme.textTheme.headlineLarge),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (trailing case final trailing?) ...[
          const SizedBox(width: AppSpacing.xs),
          trailing,
        ],
        const SizedBox(width: AppSpacing.xs),
        SurfaceIconButton(
          icon: Icons.settings_outlined,
          label: 'Buka pengaturan',
          onPressed: onSettings,
        ),
      ],
    );
  }
}

class SurfaceIconButton extends StatelessWidget {
  const SurfaceIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 18,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorder,
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        icon: ExcludeSemantics(child: Icon(icon, size: size)),
      ),
    );
  }
}

class MonthNavigator extends StatelessWidget {
  const MonthNavigator({super.key, required this.controller, this.onChanged});

  final AppDateController controller;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final gap = constraints.maxWidth < 300 ? 4.0 : 8.0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SurfaceIconButton(
                icon: Icons.chevron_left,
                label: 'Bulan sebelumnya',
                onPressed: () {
                  controller.previousMonth();
                  onChanged?.call();
                },
              ),
              SizedBox(width: gap),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 172),
                  child: _MonthButton(controller: controller),
                ),
              ),
              SizedBox(width: gap),
              SurfaceIconButton(
                icon: Icons.chevron_right,
                label: 'Bulan berikutnya',
                onPressed: () {
                  controller.nextMonth();
                  onChanged?.call();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.controller});

  final AppDateController controller;

  @override
  Widget build(BuildContext context) {
    final month = controller.displayedMonth;
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Pilih bulan, ${formatMonth(month)}',
      child: OutlinedButton.icon(
        onPressed: () => _showMonthPicker(context, controller),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(172, 44),
          backgroundColor: theme.colorScheme.surface,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        ),
        icon: const ExcludeSemantics(
          child: Icon(Icons.calendar_today_outlined, size: 16),
        ),
        label: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.fast,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            formatMonth(month),
            key: ValueKey(month),
            style: theme.textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}

Future<void> _showMonthPicker(
  BuildContext context,
  AppDateController controller,
) async {
  final selected = await showDialog<DateTime>(
    context: context,
    builder: (context) => _MonthPicker(initialMonth: controller.displayedMonth),
  );
  if (selected != null) {
    controller.showMonth(selected);
  }
}

class _MonthPicker extends StatefulWidget {
  const _MonthPicker({required this.initialMonth});

  final DateTime initialMonth;

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 32;
    final width = math.min(280.0, availableWidth);
    final now = DateTime.now();
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SurfaceIconButton(
                    icon: Icons.chevron_left,
                    label: 'Tahun sebelumnya',
                    onPressed: () => setState(() => _year--),
                    size: 16,
                  ),
                  Expanded(
                    child: Text(
                      '$_year',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  SurfaceIconButton(
                    icon: Icons.chevron_right,
                    label: 'Tahun berikutnya',
                    onPressed: () => setState(() => _year++),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.7,
                ),
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected =
                      _year == widget.initialMonth.year &&
                      month == widget.initialMonth.month;
                  final isCurrent = _year == now.year && month == now.month;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: '${shortMonths[index]} $_year',
                    child: InkWell(
                      onTap: () =>
                          Navigator.of(context).pop(DateTime(_year, month)),
                      borderRadius: AppRadius.mdBorder,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : isCurrent
                              ? theme.colorScheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: AppRadius.mdBorder,
                          border: Border.all(
                            color: isCurrent && !isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            shortMonths[index],
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : isCurrent
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoricalMonthBanner extends StatelessWidget {
  const HistoricalMonthBanner({super.key, required this.controller});

  final AppDateController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        return AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.fast,
          curve: AppMotion.curve,
          child: controller.isCurrentMonth
              ? const SizedBox.shrink()
              : Semantics(
                  liveRegion: true,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer,
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(color: scheme.tertiary),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          ExcludeSemantics(
                            child: Icon(
                              Icons.history,
                              size: 18,
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Anda sedang melihat riwayat ${formatMonth(controller.displayedMonth)}.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.onTertiaryContainer),
                            ),
                          ),
                          TextButton(
                            onPressed: controller.showToday,
                            child: const Text('Hari ini'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

const shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const fullMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const fullWeekdays = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

String formatMonth(DateTime date) =>
    '${fullMonths[date.month - 1]} ${date.year}';

String formatFullDate(DateTime date) =>
    '${fullWeekdays[date.weekday - 1]}, ${date.day} ${fullMonths[date.month - 1]} ${date.year}';
