import 'package:flutter/material.dart';
import '../services/uma_prediction_view_model.dart';

class UmaPredictionCard extends StatelessWidget {
  const UmaPredictionCard({super.key, required this.prediction});

  final UmaPredictionViewModel prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(prediction.title,
                    style: theme.textTheme.titleMedium)),
                Text(prediction.level, style: theme.textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(prediction.summary),
            const SizedBox(height: 8),
            Text('Timing: ${prediction.timing}'),
            const SizedBox(height: 8),
            Text(prediction.guidance),
            if (prediction.reasons.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Why', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              ...prediction.reasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('• $r'),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
