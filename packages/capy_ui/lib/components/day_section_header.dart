import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telemetry_core/telemetry_core.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Sticky / section header for a day's worth of trips.
///
/// Displays the localized day label ("Hoje", "Ontem", or formatted date)
/// and an aggregate statistics pill (trip count, total km, total kWh).
class DaySectionHeader extends StatelessWidget {
  const DaySectionHeader({
    required this.group,
    this.title,
    this.todayLabel = 'Сегодня',
    this.yesterdayLabel = 'Вчера',
    this.distanceUnit = 'км',
    this.energyUnit = 'кВт⋅ч',
    super.key,
  });

  final TripDayGroup group;
  final String? title;
  final String todayLabel;
  final String yesterdayLabel;
  final String distanceUnit;
  final String energyUnit;

  String _formatDayTitle(DateTime date, BuildContext context) {
    if (title != null) return title!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayKey = DateTime(date.year, date.month, date.day);

    final yesterday = DateTime(today.year, today.month, today.day - 1);
    if (dayKey == today) {
      return todayLabel;
    }
    if (dayKey == yesterday) {
      return yesterdayLabel;
    }

    final localeObj = Localizations.maybeLocaleOf(context);
    final localeStr = localeObj?.toString() ?? 'pt_BR';
    try {
      if (date.year == now.year) {
        return DateFormat.MMMMd(localeStr).format(date);
      }
      return DateFormat.yMMMMd(localeStr).format(date);
    } catch (_) {
      if (date.year == now.year) {
        return DateFormat("d 'de' MMMM", 'pt_BR').format(date);
      }
      return DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final dayTitle = _formatDayTitle(group.date, context);
    final localeObj = Localizations.maybeLocaleOf(context);
    final lang = localeObj?.languageCode ?? 'pt';

    final tripLabel = switch (lang) {
      'en' => group.tripCount == 1 ? '1 trip' : '${group.tripCount} trips',
      'es' => group.tripCount == 1 ? '1 viaje' : '${group.tripCount} viajes',
      'ru' => _ruTrips(group.tripCount),
      _ => group.tripCount == 1 ? '1 viagem' : '${group.tripCount} viagens',
    };
    final distStr = group.totalDistanceKm.toStringAsFixed(
      group.totalDistanceKm >= 100 ? 0 : 1,
    );
    final energyStr = group.totalNetKwh.toStringAsFixed(2);
    final summarySubtitle =
        '$tripLabel • $distStr $distanceUnit • $energyStr $energyUnit';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x1,
        vertical: AppSpacing.x2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(dayTitle, style: AppText.cardTitle.copyWith(color: colors.ink)),
          const SizedBox(height: AppSpacing.x1),
          Text(
            summarySubtitle,
            style: AppText.caption.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}

String _ruTrips(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return '$n поездка';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$n поездки';
  }
  return '$n поездок';
}
