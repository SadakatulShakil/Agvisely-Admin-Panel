import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_widgets.dart';
import '../../../../models/dashboard.dart';

/// One forecast provider with its health and the "default source" switch.
class DataSourceCard extends StatelessWidget {
  const DataSourceCard({
    super.key,
    required this.source,
    required this.busy,
    required this.onMakeDefault,
  });

  final DataSource source;
  final bool busy;
  final VoidCallback onMakeDefault;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (source.health) {
      SourceHealth.operational => (AppColors.successBg, AppColors.success),
      SourceHealth.degraded => (AppColors.warningBg, AppColors.warning),
      SourceHealth.pilot => (AppColors.infoBg, AppColors.info),
      SourceHealth.down => (AppColors.dangerBg, AppColors.danger),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  source.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Pill(
                label: source.health.label,
                background: bg,
                foreground: fg,
                radius: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: Text(
              source.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Last sync',
                  value: Fmt.timeAgo(source.lastSyncAt),
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Uptime 30d',
                  value: '${source.uptime30d.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child:
                source.isDefault
                    ? DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FilledButton(
                        // Already the default — informational, not clickable.
                        onPressed: null,
                        style: FilledButton.styleFrom(
                          disabledBackgroundColor: AppColors.primary,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Default source in app'),
                      ),
                    )
                    : OutlinedButton(
                      onPressed: busy ? null : onMakeDefault,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 0.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          busy
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Set as default'),
                    ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    ],
  );
}
