import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'data/datasources/book_local_datasource.dart';
import 'presentation/providers/book_provider.dart';
import 'presentation/screens/home_screen.dart';

Future<void> main() async {
  // 1. Keep native splash visible until we call remove()
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // 2. Do all startup work while native splash is still showing
  final prefs = await SharedPreferences.getInstance();
  final dataSource = BookLocalDataSource(prefs);
  await dataSource.seedIfEmpty();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 3. Start the app — SplashScreen shows immediately
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const BookTrackerApp(),
    ),
  );

  // 4. Dismiss the native splash — Flutter splash takes over
  FlutterNativeSplash.remove();
}

// ── App root ──────────────────────────────────────────────────
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
//  FLUTTER SPLASH SCREEN
//  Takes over the moment the native splash is dismissed.
//  Same dark background — no visible seam.
//  Animated logo + pulsing dots while Riverpod loads data.
//  Fades into HomeScreen when ready.
// ═══════════════════════════════════════════════════════════════
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _logoCtrl;
  late final AnimationController _dotsCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Logo: scale up + fade in
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Dots: staggered pulse loop
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dot1 = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: _dotsCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _dot2 = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: _dotsCtrl,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );
    _dot3 = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: _dotsCtrl,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    _logoCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _waitAndNavigate());
  }

  Future<void> _waitAndNavigate() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1800)),
      _waitForBooksReady(),
    ]);
    if (mounted && !_navigated) {
      _navigated = true;
      _goHome();
    }
  }

  Future<void> _waitForBooksReady() async {
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
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
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

  @override
  Widget build(BuildContext context) {
    ref.watch(bookListProvider);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Logo centred in available space
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon container
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: const Center(
                              child: Text('📚',
                                style: TextStyle(fontSize: 50)),
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

                      // Tagline — delayed
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          'Your reading journey',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.45),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated loading dots
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: AnimatedBuilder(
                animation: _dotsCtrl,
                builder: (_, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(opacity: _dot1.value),
                    const SizedBox(width: 10),
                    _Dot(opacity: _dot2.value),
                    const SizedBox(width: 10),
                    _Dot(opacity: _dot3.value),
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

class _Dot extends StatelessWidget {
  final double opacity;
  const _Dot({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
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