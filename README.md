# lab4_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

use of ai - 
// ---- fallback: local JSON ----
    final local = await _fetchLocal();
    local.shuffle();
    final picked = local.take(2).toList();
    final fallbackCards = picked.map((c) {
      final hp = _hpFromId(c.name);
      return PokemonBattleCard(
        name: c.name,
        smallImage: c.smallImage,
        largeImage: c.largeImage,

        used ai for this code and i have edited my code in this as per need 
        used ai for refrence for lab - 4 and lab - 5 
        some codes i have matched with ai and edited by myself 

        class _BattlePageState extends State<BattlePage> {
  PokemonBattleCard? _left;
  PokemonBattleCard? _right;
  bool _loading = true;
  String? _error;
  bool _usedFallback = false;
        hp: hp,
      );
    }).toList();

    
