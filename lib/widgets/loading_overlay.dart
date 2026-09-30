import 'package:flutter/material.dart';
import '../config/constants.dart';

class LoadingOverlay extends StatefulWidget {
  final double progress;
  final bool isInitialLoading;

  const LoadingOverlay({
    super.key,
    required this.progress,
    this.isInitialLoading = false,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getStatusText(double progress) {
    if (progress < 0.25) return 'INITIALIZING SYSTEM';
    if (progress < 0.6) return 'CONNECTING TO MISSION CONTROL';
    if (progress < 0.9) return 'LOADING GRAPHIC NOVEL ASSETS';
    return 'READY TO LAUNCH';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isInitialLoading) {
      // Top linear progress bar during navigation
      return widget.progress < 1.0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(3.0),
              child: SizedBox(
                height: 3.0,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppConfig.cyan),
                ),
              ),
            )
          : const SizedBox.shrink();
    }

    // Fullscreen Cyberpunk / Sci-Fi initial loading screen
    return Container(
      color: AppConfig.primaryBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Glowing Core / Radar animation
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing radial glow
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppConfig.cyan.withValues(alpha: 0.25),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: AppConfig.magenta.withValues(alpha: 0.15),
                              blurRadius: 48,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rotating dual-color gradient ring
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const SweepGradient(
                            colors: [
                              AppConfig.cyan,
                              Colors.transparent,
                              AppConfig.magenta,
                              Colors.transparent,
                              AppConfig.amber,
                              AppConfig.cyan,
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75, 0.9, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Inner dark masking orb
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConfig.primaryBg,
                      ),
                    ),

                    // Counter-rotating outer dotted ring / glow
                    RotationTransition(
                      turns: Tween<double>(begin: 1.0, end: 0.0)
                          .animate(_rotationController),
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppConfig.cyan.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Center high-precision circular progress indicator
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: CircularProgressIndicator(
                        value: widget.progress > 0.05 ? widget.progress : null,
                        strokeWidth: 3.5,
                        backgroundColor: AppConfig.cardBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppConfig.cyan,
                        ),
                      ),
                    ),

                    // Pulsing center sensor icon
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: const Icon(
                        Icons.sensors_rounded,
                        size: 26,
                        color: AppConfig.cyan,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Title with glowing letter spacing
              Text(
                AppConfig.appTitle,
                style: TextStyle(
                  color: AppConfig.lightText,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                      color: AppConfig.cyan.withValues(alpha: 0.6),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                AppConfig.appSubtitle.toUpperCase(),
                style: const TextStyle(
                  color: AppConfig.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                ),
              ),

              const SizedBox(height: 32),

              // Glowing Progress Bar
              Container(
                width: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.magenta.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: widget.progress > 0 ? widget.progress : null,
                    minHeight: 5,
                    backgroundColor: AppConfig.cardBg,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppConfig.magenta,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dynamic Status Subtitle
              Text(
                _getStatusText(widget.progress),
                style: const TextStyle(
                  color: AppConfig.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 6),

              // Percentage Text
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppConfig.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
