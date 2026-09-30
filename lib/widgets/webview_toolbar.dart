import 'package:flutter/material.dart';
import '../config/constants.dart';

class WebViewToolbar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final bool isFullscreen;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onReload;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onOpenExternal;

  const WebViewToolbar({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    required this.isFullscreen,
    required this.isLoading,
    required this.onBack,
    required this.onForward,
    required this.onReload,
    required this.onToggleFullscreen,
    required this.onOpenExternal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.primaryBg.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AppConfig.cardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: canGoBack ? onBack : null,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppConfig.cyan,
                disabledColor: AppConfig.mutedText.withValues(alpha: 0.3),
                tooltip: 'Back',
              ),
              IconButton(
                onPressed: canGoForward ? onForward : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                color: AppConfig.cyan,
                disabledColor: AppConfig.mutedText.withValues(alpha: 0.3),
                tooltip: 'Forward',
              ),
              IconButton(
                onPressed: onReload,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppConfig.magenta),
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 22),
                color: AppConfig.magenta,
                tooltip: 'Reload',
              ),
              IconButton(
                onPressed: onToggleFullscreen,
                icon: Icon(
                  isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  size: 24,
                ),
                color: AppConfig.amber,
                tooltip: isFullscreen ? 'Exit Fullscreen' : 'Fullscreen Reader',
              ),
              IconButton(
                onPressed: onOpenExternal,
                icon: const Icon(Icons.open_in_browser_rounded, size: 22),
                color: AppConfig.mutedText,
                tooltip: 'Open in Browser',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
