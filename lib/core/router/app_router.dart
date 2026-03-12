import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/onboarding/ui/screens/onboarding_screen.dart';
import '../../features/auth/ui/screens/auth_screen.dart';
import '../../features/wardrobe/ui/screens/wardrobe_screen.dart';
import '../../features/wardrobe/ui/screens/add_item_screen.dart';
import '../../features/wardrobe/ui/screens/item_detail_screen.dart';
import '../../features/outfits/ui/screens/outfit_suggestions_screen.dart';
import '../../features/history/ui/screens/history_screen.dart';
import '../../features/sustainability/ui/screens/sustainability_screen.dart';
import '../../features/profile/ui/screens/profile_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!onboardingDone && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
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
          path: '/wardrobe',
          builder: (context, state) => const WardrobeScreen(),
        ),
        GoRoute(
          path: '/outfits',
          builder: (context, state) => const OutfitSuggestionsScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/sustainability',
          builder: (context, state) => const SustainabilityScreen(),
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
