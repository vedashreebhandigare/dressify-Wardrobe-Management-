# SmartWardrobe – AI Digital Closet 👗✨

A production-ready Flutter application for managing your digital wardrobe with AI-powered outfit suggestions and sustainability insights.

## Features

| Feature | Description |
|---------|-------------|
| 📸 Digital Wardrobe | Catalog clothes with photos, auto-detect via simulated AI |
| ✨ AI Outfit Generator | Get AI-styled outfit suggestions by occasion & season |
| 📅 Outfit History | Track what you wore and when |
| 🌿 Sustainability Insights | Monitor wardrobe usage, find forgotten items |
| 👤 Profile | Stats, settings, and preferences |

## Technology Stack

- **Flutter 3.x** with Material 3 design
- **Riverpod** state management
- **Hive** local database (offline-first)
- **GoRouter** navigation
- **FL Chart** analytics
- **Google Fonts (DM Sans)** typography
- **flutter_animate** smooth animations

## Folder Structure

```
lib/
├── core/
│   ├── constants/     # App-wide constants
│   ├── router/        # GoRouter configuration
│   ├── theme/         # Material 3 theme
│   └── utils/         # Seed data & utilities
├── features/
│   ├── wardrobe/      # Clothing catalog
│   ├── outfits/       # AI outfit generation
│   ├── history/       # Outfit history tracking
│   ├── sustainability/ # Eco insights
│   ├── onboarding/    # First-launch screens
│   ├── auth/          # Login/signup
│   └── profile/       # User profile
└── shared/
    ├── providers/     # Riverpod providers
    └── widgets/       # Shared UI components
```

## Setup & Run

### Prerequisites
- Flutter 3.x installed
- Android Studio or VS Code

### Steps

```bash
# 1. Clone or navigate to project
cd d:\Wardrobe_management

# 2. Install dependencies
flutter pub get

# 3. Run on web
flutter run -d web-server --web-port 8080

# 4. Run on Android (with device connected)
flutter run -d android

# 5. Run on connected iOS device
flutter run -d ios
```

### Build APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build Web (PWA)

```bash
flutter build web --release
# Output: build/web/
```

## Data Models

### ClothingItem
| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| name | String | Display name |
| imagePath | String | Local image path |
| category | String | Tops/Bottoms/Dresses/etc |
| color | String | Color name |
| colorHex | String | Hex color code |
| brand | String | Brand name |
| season | String | Season suitability |
| occasion | String | Casual/Work/Formal/etc |
| pattern | String | Solid/Striped/etc |
| wearCount | int | Times worn |
| lastWornDate | DateTime? | Last worn date |
| isFavorite | bool | Favorited |

### OutfitModel
| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| clothingItemIds | List\<String\> | Item IDs in outfit |
| date | DateTime | Date created/worn |
| occasion | String | Occasion type |
| name | String | Outfit name |
| isSaved | bool | Saved by user |
| isAIGenerated | bool | AI-suggested |

## AI Outfit Logic

The AI outfit generator:
1. Filters clothes by selected **occasion** and **season**
2. Picks the **least-worn** items to maximize wardrobe use
3. Builds a complete look: Top + Bottom + Shoes + Accessory
4. Falls back to any matching category if filter has no match

## Screens

1. **Onboarding** — 3-slide intro with gradient pages
2. **Auth** — Sign in / Sign up / Guest mode
3. **Wardrobe (Home)** — Hero dashboard + today's outfit + items grid
4. **Add Item** — Photo picker + AI attribute detection + form
5. **Item Detail** — Full details, wear tracking, favorite
6. **Outfit Suggestions** — AI generator with occasion/season filter
7. **History** — Chronological outfit log grouped by month
8. **Sustainability** — Usage donut chart + forgotten items
9. **Profile** — Stats cards + settings + sign out

## Offline First

All data is stored in **Hive** (local database). The app works 100% offline. No internet connection required.

## Demo Data

On first launch, 12 demo clothing items are seeded:
- Classic White Tee (Tops, Casual, 12x worn)
- Slim Black Jeans (Bottoms, 18x worn)
- Floral Summer Dress (unused for 95 days → sustainability flag)
- Silk Blouse (unused for 120 days → sustainability flag)
- And 8 more items...

---

Built with ❤️ and Flutter
