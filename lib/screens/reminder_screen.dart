import 'package:flutter/material.dart';
import '../services/reminder_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  DateTime when = DateTime.now().add(const Duration(hours: 1));
  final title = TextEditingController(text: 'उमा का शुभ समय reminder');
  final body = TextEditingController(text: 'Shakti Panchang का याद दिलाना');

  Future<void> pick() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: when,
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
    if (t == null) return;
    setState(() => when = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> schedule() async {
    if (when.isBefore(DateTime.now())) return;
    await ReminderService.instance.schedule(
      id: when.millisecondsSinceEpoch.remainder(2147483647),
      title: title.text.trim().isEmpty ? 'Shakti Panchang' : title.text.trim(),
      body: body.text.trim().isEmpty ? 'उमा का reminder' : body.text.trim(),
      when: when,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder ${when.day}/${when.month} ${when.hour.toString().padLeft(2,'0')}:${when.minute.toString().padLeft(2,'0')} पर सेट है।')),
    );
  }

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🔔 उमा Reminder')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('शुभ समय या यात्रा के लिए reminder लगाएँ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Reminder का नाम', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: body, maxLines: 2, decoration: const InputDecoration(labelText: 'उमा का संदेश', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        Card(child: ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('समय'),
          subtitle: Text('${when.day}/${when.month}/${when.year}  ${when.hour.toString().padLeft(2,'0')}:${when.minute.toString().padLeft(2,'0')}'),
          trailing: const Icon(Icons.edit_calendar),
          onTap: pick,
        )),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: schedule, icon: const Icon(Icons.notifications_active), label: const Text('Reminder लगाएँ')),
        const SizedBox(height: 16),
        const Text('नोट: अभी one-time reminder उपलब्ध है। अगली release में daily/weekly smart reminders जोड़े जा सकते हैं।', style: TextStyle(color: Colors.black54)),
      ],
    ),
  );
}
