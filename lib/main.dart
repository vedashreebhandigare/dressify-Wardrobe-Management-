import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/wardrobe/data/models/clothing_item.dart';
import 'features/outfits/data/models/outfit_model.dart';
import 'features/wardrobe/data/repositories/wardrobe_repository.dart';
import 'features/outfits/data/repositories/outfit_repository.dart';
import 'shared/providers/wardrobe_providers.dart';
import 'shared/providers/outfit_providers.dart';
import 'core/utils/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(ClothingItemAdapter());
  Hive.registerAdapter(OutfitModelAdapter());

  // Open repos
  final wardrobeRepo = WardrobeRepository();
  final outfitRepo = OutfitRepository();
  await wardrobeRepo.init();
  await outfitRepo.init();

  // Seed demo data on first launch
  await SeedData.seedIfEmpty(wardrobeRepo);

  runApp(
    ProviderScope(
      overrides: [
        wardrobeRepositoryProvider.overrideWithValue(wardrobeRepo),
        outfitRepositoryProvider.overrideWithValue(outfitRepo),
      ],
      child: const SmartWardrobeApp(),
    ),
  );
}

class SmartWardrobeApp extends ConsumerWidget {
  const SmartWardrobeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SmartWardrobe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
