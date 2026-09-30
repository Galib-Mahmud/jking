import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';

class DesktopFallbackView extends StatelessWidget {
  const DesktopFallbackView({super.key});

  Future<void> _openBrowser() async {
    final uri = Uri.parse(AppConfig.initialUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConfig.primaryBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(36.0),
              decoration: BoxDecoration(
                color: AppConfig.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppConfig.cyan.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0x3322D3EE), Colors.transparent],
                      ),
                      border: Border.all(
                        color: AppConfig.cyan,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: AppConfig.cyan,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppConfig.appTitle,
                    style: TextStyle(
                      color: AppConfig.lightText,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppConfig.appSubtitle,
                    style: TextStyle(
                      color: AppConfig.mutedText,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConfig.primaryBg.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppConfig.cardBorder,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.devices_rounded,
                            color: AppConfig.cyan, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Public Webview Target: Android, iOS, Chrome & Web.\nFor Desktop Linux, click below to open the live experience.',
                            style: TextStyle(
                              color: AppConfig.mutedText,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openBrowser,
                      icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                      label: const Text('OPEN WEB EXPERIENCE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.cyan,
                        foregroundColor: AppConfig.primaryBg,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    AppConfig.initialUrl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppConfig.mutedText.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
