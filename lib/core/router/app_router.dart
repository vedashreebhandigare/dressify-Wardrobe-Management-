import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/onboarding/ui/screens/onboarding_screen.dart';
import '../../features/auth/ui/screens/auth_screen.dart';
import '../../features/wardrobe/ui/screens/wardrobe_screen.dart';
import '../../features/wardrobe/ui/screens/add_item_screen.dart';
import '../../features/wardrobe/ui/screens/item_detail_screen.dart';
import '../../features/outfit_builder/ui/screens/outfit_builder_screen.dart';
import '../../features/swipe_outfits/ui/screens/swipe_outfits_screen.dart';
import '../../features/profile/ui/screens/profile_screen.dart';
import '../../features/splash/ui/screens/splash_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    
    // Let splash screen show first always
    if (state.matchedLocation == '/splash') return null;

    if (!onboardingDone && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const WardrobeScreen(),
        ),
        GoRoute(
          path: '/outfit-builder',
          builder: (context, state) => const OutfitBuilderScreen(),
        ),
        GoRoute(
          path: '/swipe-outfits',
          builder: (context, state) => const SwipeOutfitsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/add-item',
      builder: (context, state) => const AddItemScreen(),
    ),
    GoRoute(
      path: '/item/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ItemDetailScreen(itemId: id);
      },
    ),
  ],
);
