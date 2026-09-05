import 'package:flutter/material.dart';
import '../services/personalized_upay_engine.dart';

class PersonalizedUpayCard extends StatelessWidget {
  const PersonalizedUpayCard({super.key, required this.upay});
  final PersonalizedUpay upay;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text(upay.title),
        subtitle: Text(upay.reason),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ...upay.steps.map((s) => Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('• $s'),
            ),
          )),
          if (upay.duration.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Duration: ${upay.duration}'),
              ),
            ),
          if (upay.caution.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(upay.caution),
              ),
            ),
        ],
      ),
    );
  }
}
