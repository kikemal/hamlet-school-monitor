import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../theme/app_colors.dart';

/// Shown when the app cannot start (missing Supabase keys, init failure, etc.).
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Run from terminal:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    'flutter run -d chrome '
                    '--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co '
                    '--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Get URL and anon key from Supabase → Project Settings → API.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MissingSupabaseConfigApp extends StatelessWidget {
  const MissingSupabaseConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const StartupErrorApp(
      title: '${AppConstants.appName} — setup required',
      message:
          'Supabase is not configured. The app was started without '
          'SUPABASE_URL and SUPABASE_ANON_KEY, so it cannot connect to your database.',
    );
  }
}
