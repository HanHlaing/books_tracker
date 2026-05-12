import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'data/datasources/book_local_datasource.dart';
import 'presentation/providers/book_provider.dart';
import 'presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final dataSource = BookLocalDataSource(prefs);
  await dataSource.seedIfEmpty();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const BookTrackerApp(),
    ),
  );
}

class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SPLASH SCREEN
//  Shown immediately — same dark colour as native splash so
//  there is zero visible transition. Fades into HomeScreen once
//  Riverpod has finished loading books from SharedPreferences.
// ═══════════════════════════════════════════════════════════════

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  // ── Animations ───────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _dotsCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;

  // Loading dot pulse offsets
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // ── Logo animation (runs once on entry) ───────────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Dots animation (loops while loading) ──────────────────
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dot1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _dotsCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _dot2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _dotsCtrl,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );
    _dot3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _dotsCtrl,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    // Start logo animation
    _logoCtrl.forward();

    // Start watching for data readiness after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _waitAndNavigate());
  }

  Future<void> _waitAndNavigate() async {
    // Wait at least 1.6s (so the animation completes fully)
    // AND wait for books to finish loading — whichever is longer
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1600)),
      _waitForBooksReady(),
    ]);

    if (mounted && !_navigated) {
      _navigated = true;
      _goHome();
    }
  }

  Future<void> _waitForBooksReady() async {
    // Poll every 50ms until bookListProvider is no longer loading
    while (mounted) {
      final state = ref.read(bookListProvider);
      if (!state.isLoading) return;
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Watch provider so widget knows when loading finishes
    ref.watch(bookListProvider);

    return Scaffold(
      // Exact same colour as launch_background.xml and
      // LaunchScreen.storyboard — no visible flash
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Logo area (centred vertically) ──────────────
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Book icon
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Text('📚',
                                style: TextStyle(fontSize: 48)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // App name
                      FadeTransition(
                        opacity: _logoFade,
                        child: const Text(
                          'Book Tracker',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tagline fades in slightly after logo
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          'Your reading journey',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Animated loading dots at the bottom ─────────
            Padding(
              padding: const EdgeInsets.only(bottom: 56),
              child: AnimatedBuilder(
                animation: _dotsCtrl,
                builder: (_, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LoadingDot(animation: _dot1),
                    const SizedBox(width: 10),
                    _LoadingDot(animation: _dot2),
                    const SizedBox(width: 10),
                    _LoadingDot(animation: _dot3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pulsing loading dot ───────────────────────────────────────
class _LoadingDot extends StatelessWidget {
  final Animation<double> animation;
  const _LoadingDot({required this.animation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}