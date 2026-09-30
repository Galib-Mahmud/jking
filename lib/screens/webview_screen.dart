import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../config/constants.dart';
import '../services/connectivity_service.dart';
import '../widgets/desktop_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/scrollable_nav_bar.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _controller;
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<bool>? _connectivitySub;

  double _loadingProgress = 0.0;
  bool _isInitialLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isOffline = false;

  String _activeTab = 'home';

  DateTime? _lastBackPressTime;

  bool get _isSupportedPlatform => WebViewPlatform.instance != null;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    if (_isSupportedPlatform) {
      _initWebView();
      // Failsafe: Ensure initial loading overlay dismisses after 6 seconds even on slow networks
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && _isInitialLoading) {
          setState(() {
            _isInitialLoading = false;
          });
        }
      });
    }
  }

  Future<void> _initConnectivity() async {
    final hasNet = await _connectivityService.checkInitialConnection();
    if (mounted) {
      setState(() {
        _isOffline = !hasNet;
      });
    }

    _connectivitySub = _connectivityService.connectionStatus.listen((hasConnection) {
      if (mounted) {
        final wasOffline = _isOffline;
        setState(() {
          _isOffline = !hasConnection;
        });

        if (wasOffline && hasConnection && _hasError) {
          _reloadWebView();
        }
      }
    });
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppConfig.primaryBg)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
      )
      ..addJavaScriptChannel(
        'FlutterNavChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (mounted && message.message.isNotEmpty) {
            setState(() {
              _activeTab = message.message;
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100.0;
                // Dismiss loading overlay earlier — the page is ~28MB so
                // even 10% means significant HTML has been parsed and is
                // already rendering in the WebView behind the overlay.
                if (progress >= 10 && _isInitialLoading) {
                  _isInitialLoading = false;
                }
              });
              // Inject styles progressively once we have enough content
              if (progress > 20) {
                _injectCustomStyles();
              }
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _hasError = false;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isInitialLoading = false;
                _loadingProgress = 1.0;
              });
              // Delay injection slightly to let the page's own JS initialize first
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) {
                  _injectCustomStyles();
                  _injectNavSyncObserver();
                }
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only flag strictly main frame failures that occur before any content arrives
            if (error.isForMainFrame == true && _loadingProgress < 0.1) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.description;
                  _isInitialLoading = false;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            } else {
              // mailto, tel, sms, intent schemes
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              } catch (_) {}
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('${AppConfig.initialUrl}/#home'));

    // Android-specific optimizations
    if (controller.platform is AndroidWebViewController) {
      final androidController =
          controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      androidController.setMixedContentMode(MixedContentMode.alwaysAllow);
      androidController.setAllowFileAccess(true);
      androidController.setAllowContentAccess(true);
      androidController.setUseWideViewPort(true);
      // DOM storage (localStorage/sessionStorage) is already enabled by
      // default in AndroidWebViewController — no extra call needed.
      // The WebView's standard HTTP cache handles caching automatically.
    }

    _controller = controller;
  }

  /// Inject CSS to hide the website's top navigation bar (opsnav)
  /// since we replaced it with a Flutter bottom nav bar.
  void _injectCustomStyles() {
    const script = """
      (function() {
        if (document.getElementById('flutter-custom-style')) return;
        var style = document.createElement('style');
        style.id = 'flutter-custom-style';
        style.textContent = [
          '.opsnav { display: none !important; }',
          '.topbar { top: 0 !important; }',
          '.progress-wrap { top: 0 !important; }',
          '.chapter-pill { top: 53px !important; }',
          'body { padding-bottom: 0 !important; }'
        ].join('\\n');
        (document.head || document.documentElement).appendChild(style);
      })();
    """;
    _controller?.runJavaScript(script);
  }

  /// Inject a MutationObserver on the body `data-view` attribute and hashchange
  /// listener so that Flutter always knows the active view.
  void _injectNavSyncObserver() {
    const script = """
      (function() {
        if (window._flutterObserverAttached) return;
        window._flutterObserverAttached = true;

        function syncView() {
          try {
            var v = document.body.getAttribute('data-view');
            if (!v) {
              var h = location.hash ? location.hash.replace('#', '') : '';
              v = h || 'home';
            }
            if (v && window.FlutterNavChannel) {
              window.FlutterNavChannel.postMessage(v);
            }
          } catch(e) {}
        }

        // Observe body data-view attribute changes
        var observer = new MutationObserver(function() {
          syncView();
        });
        observer.observe(document.body, { attributes: true, attributeFilter: ['data-view'] });

        // Also listen for hash changes
        window.addEventListener('hashchange', function() {
          setTimeout(syncView, 100);
        });

        // Initial sync
        syncView();
      })();
    """;
    _controller?.runJavaScript(script);
  }

  void _onTabSelected(String tabId) {
    setState(() {
      _activeTab = tabId;
    });

    if (tabId == 'glossary') {
      // Glossary is a modal button, not a view - click it directly
      _controller?.runJavaScript("""
        (function() {
          var fab = document.querySelector('.glfab') || document.querySelector('button.gltab');
          if (fab) { fab.click(); }
        })();
      """);
      return;
    }

    // Use the website's own go() router function for reliable navigation.
    // The website defines: function go(v) { if (location.hash.slice(1) === v) route(); else location.hash = v; }
    // We call go() directly which triggers show(), route(), and renders the view.
    _controller?.runJavaScript("""
      (function() {
        try {
          if (typeof go === 'function') {
            go('$tabId');
          } else {
            location.hash = '$tabId';
          }
          window.scrollTo(0, 0);
        } catch(e) {
          location.hash = '$tabId';
        }
      })();
    """);
  }

  void _reloadWebView() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _loadingProgress = 0.1;
    });
    _controller?.reload();
  }

  Future<void> _handlePopScope(bool didPop) async {
    if (didPop) return;
    if (_controller != null && await _controller!.canGoBack()) {
      await _controller!.goBack();
    } else {
      final now = DateTime.now();
      if (_lastBackPressTime == null ||
          now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
        _lastBackPressTime = now;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Press back again to exit',
                style: TextStyle(color: AppConfig.lightText),
              ),
              backgroundColor: AppConfig.cardBg,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppConfig.cardBorder),
              ),
            ),
          );
        }
      } else {
        await SystemNavigator.pop();
      }
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupportedPlatform) {
      return const Scaffold(
        backgroundColor: AppConfig.primaryBg,
        body: SafeArea(child: DesktopFallbackView()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _handlePopScope(didPop);
      },
      child: Scaffold(
        backgroundColor: AppConfig.primaryBg,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              // Top slim progress bar during navigation
              if (_loadingProgress > 0 && _loadingProgress < 1.0)
                LinearProgressIndicator(
                  value: _loadingProgress,
                  minHeight: 2.5,
                  backgroundColor: AppConfig.cardBg,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppConfig.cyan),
                ),

              // Offline notification banner
              if (_isOffline)
                Container(
                  width: double.infinity,
                  color: AppConfig.amber.withValues(alpha: 0.9),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 14, color: AppConfig.primaryBg),
                      SizedBox(width: 8),
                      Text(
                        'Working Offline • Connection Lost',
                        style: TextStyle(
                          color: AppConfig.primaryBg,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              // Main WebView Body — no RefreshIndicator wrapping!
              Expanded(
                child: Stack(
                  children: [
                    if (_controller != null)
                      WebViewWidget(controller: _controller!),

                    // Smooth animated initial loading screen
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: !_isInitialLoading,
                        child: AnimatedOpacity(
                          opacity: _isInitialLoading ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 350),
                          child: LoadingOverlay(
                            progress: _loadingProgress,
                            isInitialLoading: true,
                          ),
                        ),
                      ),
                    ),

                    // Error state view
                    if (_hasError)
                      Positioned.fill(
                        child: ErrorView(
                          errorMessage: _errorMessage,
                          isOffline: _isOffline,
                          onRetry: _reloadWebView,
                        ),
                      ),
                  ],
                ),
              ),

              // Scrollable Bottom Navigation Bar
              ScrollableNavBar(
                activeTab: _activeTab,
                onTabSelected: _onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
