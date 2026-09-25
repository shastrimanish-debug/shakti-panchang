import 'package:flutter/material.dart';
import '../data/vrat_katha_data.dart';

class VratKathaScreen extends StatefulWidget {
  const VratKathaScreen({super.key});
  @override
  State<VratKathaScreen> createState() => _VratKathaScreenState();
}

class _VratKathaScreenState extends State<VratKathaScreen> {
  String _cat = 'all';

  @override
  Widget build(BuildContext context) {
    final items = VratKathaData.byCategory(_cat);
    return Scaffold(
      appBar: AppBar(title: const Text('व्रत कथा व आरती')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: VratKathaData.categories
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c.$2),
                          selected: _cat == c.$1,
                          onSelected: (_) => setState(() => _cat = c.$1),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final e = items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${e.subtitle}\n${e.tithiInfo}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.menu_book_outlined),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VratKathaDetailScreen(item: e)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VratKathaDetailScreen extends StatelessWidget {
  final VratKathaItem item;
  const VratKathaDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(item.deity, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7A3E00))),
          const SizedBox(height: 6),
          Text(item.significance),
          const SizedBox(height: 14),
          const Text('पूजा विधि', style: TextStyle(fontWeight: FontWeight.w900)),
          ...item.poojaVidhi.map((s) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('• $s'),
              )),
          if (item.mantra != null) ...[
            const SizedBox(height: 14),
            Text('मन्त्र: ${item.mantra}', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 14),
          const Text('कथा', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(item.fullText, style: const TextStyle(height: 1.45)),
          ...item.chapters.map((c) => Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(c.content, style: const TextStyle(height: 1.45)),
                  ],
                ),
              )),
          if (item.aartiText != null) ...[
            const SizedBox(height: 16),
            const Text('आरती', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(item.aartiText!, style: const TextStyle(height: 1.5)),
          ],
        ],
      ),
    );
  }
}
