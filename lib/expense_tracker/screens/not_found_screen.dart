import 'package:flutter/material.dart';
import '../routes.dart';

/// 404 screen displayed when an unrecognized route is navigated to.
class NotFoundScreen extends StatelessWidget {
  final String? routeName;

  const NotFoundScreen({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '404 - Page Not Found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                routeName != null
                    ? 'The requested destination "$routeName" does not exist.'
                    : 'The page you requested could not be located.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.home_rounded),
                label: const Text('Return to Dashboard'),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    ExpenseTrackerRoutes.dashboard,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
