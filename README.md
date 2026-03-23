# Dressify – Your AI Digital Closet 👗✨

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Material 3](https://img.shields.io/badge/Material%203-7C6FCD?style=for-the-badge&logo=material-design&logoColor=white)](https://m3.material.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Dressify** is a premium, production-ready Flutter application designed to revolutionize how you interact with your wardrobe. By leveraging AI-powered outfit suggestions and deep sustainability insights, Dressify helps you make the most of what you own while reducing fashion waste.

---

## 🚀 Elevated Features

| Feature | Experience |
|:---|:---|
| **📸 Digital Wardrobe** | Effortlessly catalog your clothes with high-quality photos. Our smart detection system helps categorize items for you. |
| **✨ AI Outfit Stylist** | Stop wondering what to wear. Get curated, perfectly balanced outfit suggestions based on **occasion**, **season**, and **mood**. |
| **🎨 Personal Mannequin** | Visualize your looks on a custom avatar. Perfect for planning outfits without the physical mess. |
| **📊 Sustainability Core** | Monitor your wardrobe's "health." Identify unworn items, track wear frequency, and rediscover forgotten favorites. |
| **🛡️ Privacy First** | 100% offline-first architecture using Hive. Your photos and data stay exactly where they belong: on your device. |

---

## 🎨 Design Philosophy

Dressify is built with a focus on **Rich Aesthetics** and **Visual Excellence**:
- **Modern Typography**: Powered by *DM Sans* for a sleek, contemporary feel.
- **Dynamic Interactions**: Fluid animations and micro-interactions powered by `flutter_animate`.
- **Premium Color Palette**: A harmonious blend of soft violets and rose tones that feels both professional and inviting.
- **Responsive Layouts**: Optimized for a seamless experience across all mobile devices.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter 3.x](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Database**: [Hive](https://docs.hivedb.dev) (Local NoSQL storage)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Analytics**: [FL Chart](https://pub.dev/packages/fl_chart)
- **Animations**: [Flutter Animate](https://pub.dev/packages/flutter_animate)

---

## 📂 Project Architecture

```text
lib/
├── core/
│   ├── constants/     # Global configurations & branding
│   ├── router/        # GoRouter declarative path mapping
│   ├── theme/         # Material 3 Design Tokens
│   └── utils/         # Seed data & business logic helpers
├── features/
│   ├── wardrobe/      # Clothing catalog & smart inventory
│   ├── outfit_builder/# Visual mannequin & outfit construction
│   ├── outfits/       # AI-driven stylist engine
│   ├── history/       # Temporal logging of your style journey
│   ├── sustainability/ # Data-driven eco-insights
│   └── profile/       # Personal stats & customization
└── shared/
    ├── providers/     # Business logic & state observers
    └── widgets/       # Atomic UI components
```

---

## 🏁 Getting Started

```bash
# 1. Clone the repository
git clone https://github.com/vedashreebhandigare/dressify-Wardrobe-Management-.git

# 2. Install dependencies
flutter pub get

# 3. Generate adapters (Hive)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Launch the Experience
flutter run
```

---

## 🌿 Sustainability Goals

We believe the most sustainable garment is the one already in your closet. Dressify helps you:
- **Decrease Waste**: By visualizing what you own, you avoid redundant purchases.
- **Increase Utility**: Track the "Cost-per-Wear" of every item.
- **Style Awareness**: Identifies unused clothes so you can donate or restyle them.

---

<p align="center">
  Built with ✨ and 🎯 by the Dressify Team
</p>
