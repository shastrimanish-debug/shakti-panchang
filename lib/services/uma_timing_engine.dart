/// Provider-neutral time-period domain model for UMA.
class UmaTimePeriod {
  const UmaTimePeriod({
    required this.name,
    required this.start,
    required this.end,
    required this.isActive,
  });

  final String name;
  final DateTime start;
  final DateTime end;
  final bool isActive;

  bool contains(DateTime date) =>
      !date.isBefore(start) && !date.isAfter(end);
}

class UmaTransitSignal {
  const UmaTransitSignal({
    required this.planet,
    required this.fromSign,
    required this.toSign,
    required this.start,
    required this.end,
    required this.areas,
    required this.strength,
  });

  final String planet;
  final String fromSign;
  final String toSign;
  final DateTime start;
  final DateTime end;
  final List<String> areas;
  final String strength;

  bool activeOn(DateTime date) =>
      !date.isBefore(start) && !date.isAfter(end);
}

/// Combines normalized dasha and transit data for UMA.
class UmaTimingEngine {
  const UmaTimingEngine();

  Map<String, dynamic> buildContext({
    required DateTime now,
    UmaTimePeriod? currentDasha,
    UmaTimePeriod? currentAntardasha,
    List<UmaTransitSignal> transits = const <UmaTransitSignal>[],
  }) {
    final activeTransits = transits
        .where((signal) => signal.activeOn(now))
        .map((signal) => <String, dynamic>{
              'planet': signal.planet,
              'fromSign': signal.fromSign,
              'toSign': signal.toSign,
              'areas': signal.areas,
              'strength': signal.strength,
            })
        .toList(growable: false);

    return <String, dynamic>{
      'date': now.toIso8601String(),
      'currentDasha': currentDasha?.name,
      'currentDashaStart': currentDasha?.start.toIso8601String(),
      'currentDashaEnd': currentDasha?.end.toIso8601String(),
      'currentAntardasha': currentAntardasha?.name,
      'currentAntardashaStart': currentAntardasha?.start.toIso8601String(),
      'currentAntardashaEnd': currentAntardasha?.end.toIso8601String(),
      'activeTransits': activeTransits,
    };
  }

  String explainTiming(Map<String, dynamic> context) {
    final dasha = context['currentDasha']?.toString();
    final antar = context['currentAntardasha']?.toString();

    if (dasha == null && antar == null) {
      return 'समय-आधारित संकेत उपलब्ध होने पर UMA अवधि के अनुसार परिणाम बताएगी।';
    }

    if (dasha != null && antar != null) {
      return 'वर्तमान दशा $dasha और अंतरदशा $antar के संकेतों को '
          'गोचर के साथ मिलाकर परिणाम समझाया जाएगा।';
    }

    return 'वर्तमान उपलब्ध दशा संकेतों को गोचर के साथ मिलाकर '
        'समय-अनुसार परिणाम समझाया जाएगा।';
  }
}
