import 'package:flutter/material.dart';
import 'uma_screen.dart';

/// Backward-compatible entry point for older navigation paths.
/// The real UMA experience now lives in UmaScreen so there is only one
/// app-aware conversational implementation.
class UmaChatScreen extends StatelessWidget {
  const UmaChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UmaScreen(date: DateTime.now());
  }
}
