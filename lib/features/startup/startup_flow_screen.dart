import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simple_notifier/core/l10n/l10n_resolver.dart';
import 'package:simple_notifier/core/theme/app_palette.dart';
import 'package:simple_notifier/features/home/home_screen.dart';
import 'package:simple_notifier/features/home/providers/reminders_provider.dart';
import 'package:simple_notifier/l10n/app_localizations.dart';

class StartupFlowScreen extends ConsumerStatefulWidget {
  const StartupFlowScreen({super.key});

  @override
  ConsumerState<StartupFlowScreen> createState() => _StartupFlowScreenState();
}

class _StartupFlowScreenState extends ConsumerState<StartupFlowScreen> {
  AppLocalizations? _bootstrapL10n;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final l10n = await L10nResolver.load();
    if (!mounted) return;
    setState(() => _bootstrapL10n = l10n);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      final loadingText =
          _bootstrapL10n?.loading ?? AppLocalizations.of(context)?.loading ?? '...';
      return _LoadingScreen(loadingText: loadingText);
    }
    return const _StartupRescheduler(child: HomeScreen());
  }
}

class _StartupRescheduler extends ConsumerStatefulWidget {
  const _StartupRescheduler({required this.child});

  final Widget child;

  @override
  ConsumerState<_StartupRescheduler> createState() =>
      _StartupReschedulerState();
}

class _StartupReschedulerState extends ConsumerState<_StartupRescheduler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remindersProvider.notifier).rescheduleAll();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({required this.loadingText});

  final String loadingText;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: Center(
        child: Text(
          loadingText,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
