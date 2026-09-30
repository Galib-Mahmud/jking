import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signal_app/config/constants.dart';
import 'package:signal_app/main.dart';
import 'package:signal_app/screens/webview_screen.dart';
import 'package:signal_app/widgets/desktop_view.dart';
import 'package:signal_app/widgets/error_view.dart';
import 'package:signal_app/widgets/loading_overlay.dart';
import 'package:signal_app/widgets/scrollable_nav_bar.dart';
import 'package:signal_app/widgets/webview_toolbar.dart';

void main() {
  testWidgets('SignalApp smoke test and widget structure verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SignalApp());

    // Verify WebViewScreen and fallback view (in headless test VM)
    expect(find.byType(WebViewScreen), findsOneWidget);
    expect(find.byType(DesktopFallbackView), findsOneWidget);

    // Verify config constants
    expect(AppConfig.appTitle, 'SIGNAL');
    expect(AppConfig.initialUrl,
        'https://transcendent-donut-73e53f.netlify.app');
  });

  testWidgets('LoadingOverlay renders percentage and title properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingOverlay(
            progress: 0.75,
            isInitialLoading: true,
          ),
        ),
      ),
    );

    expect(find.text(AppConfig.appTitle), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ErrorView renders error message and triggers retry callback',
      (WidgetTester tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            isOffline: true,
            errorMessage: 'Network failed',
            onRetry: () {
              retried = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Signal Disconnected'), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);

    await tester.tap(find.text('RETRY'));
    expect(retried, isTrue);
  });

  testWidgets('WebViewToolbar enables/disables navigation buttons',
      (WidgetTester tester) async {
    bool backTapped = false;
    bool fwdTapped = false;
    bool reloadTapped = false;
    bool fullscreenTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WebViewToolbar(
            canGoBack: true,
            canGoForward: false,
            isFullscreen: false,
            isLoading: false,
            onBack: () => backTapped = true,
            onForward: () => fwdTapped = true,
            onReload: () => reloadTapped = true,
            onToggleFullscreen: () => fullscreenTapped = true,
            onOpenExternal: () {},
          ),
        ),
      ),
    );

    // Back is enabled
    final backFinder = find.byTooltip('Back');
    expect(backFinder, findsOneWidget);
    await tester.tap(backFinder);
    expect(backTapped, isTrue);

    // Forward is disabled
    final fwdFinder = find.byTooltip('Forward');
    expect(fwdFinder, findsOneWidget);
    await tester.tap(fwdFinder);
    expect(fwdTapped, isFalse);

    // Reload is enabled
    final reloadFinder = find.byTooltip('Reload');
    expect(reloadFinder, findsOneWidget);
    await tester.tap(reloadFinder);
    expect(reloadTapped, isTrue);

    // Fullscreen is enabled
    final fsFinder = find.byTooltip('Fullscreen Reader');
    expect(fsFinder, findsOneWidget);
    await tester.tap(fsFinder);
    expect(fullscreenTapped, isTrue);
  });

  testWidgets('ScrollableNavBar renders tabs and handles selection',
      (WidgetTester tester) async {
    String selectedTab = 'home';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: ScrollableNavBar(
            activeTab: selectedTab,
            onTabSelected: (id) => selectedTab = id,
          ),
        ),
      ),
    );

    expect(find.text('Mission Control'), findsOneWidget);
    expect(find.text('Story'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);

    await tester.tap(find.text('Learn'));
    expect(selectedTab, 'learn');
  });
}
