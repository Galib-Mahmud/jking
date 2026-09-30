import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';

class ErrorView extends StatelessWidget {
  final String? errorMessage;
  final bool isOffline;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    this.errorMessage,
    this.isOffline = false,
    required this.onRetry,
  });

  Future<void> _launchExternalBrowser() async {
    final uri = Uri.parse(AppConfig.initialUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isOffline ? 'Signal Disconnected' : 'Transmission Interrupted';
    final description = isOffline
        ? 'No active internet connection found. Please check your Wi-Fi or mobile data network.'
        : errorMessage ?? 'Unable to establish a secure link to the server.';

    return Container(
      color: AppConfig.primaryBg,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: (isOffline ? AppConfig.amber : AppConfig.magenta)
                    .withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (isOffline ? AppConfig.amber : AppConfig.red)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOffline ? Icons.wifi_off_rounded : Icons.sync_problem_rounded,
                    color: isOffline ? AppConfig.amber : AppConfig.magenta,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppConfig.lightText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppConfig.mutedText,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('RETRY'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.cyan,
                          foregroundColor: AppConfig.primaryBg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: _launchExternalBrowser,
                      icon: const Icon(Icons.open_in_browser_rounded),
                      tooltip: 'Open in external browser',
                      style: IconButton.styleFrom(
                        backgroundColor: AppConfig.cardBorder,
                        foregroundColor: AppConfig.cyan,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
