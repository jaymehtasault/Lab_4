import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ------------------------------------------------------------
/// DATA SOURCE (working link)
/// ------------------------------------------------------------
const String kDataUrl =
    'https://nawazchowdhury.github.io/pokemontcg/api.json';

/// ------------------------------------------------------------
/// THEME PALETTE (Pokédex Red / Pikachu Yellow)
/// ------------------------------------------------------------
const _pokeRed = Color(0xFFE53935);
const _pokeDarkRed = Color(0xFFB71C1C);
const _pokeYellow = Color(0xFFFFD54F);
const _pokeAmber = Color(0xFFFFB300);

const LinearGradient kLightAppBarGradient = LinearGradient(
  colors: [_pokeRed, Color(0xFFF06292)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kLightBgGradient = LinearGradient(
  colors: [_pokeYellow, _pokeAmber],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kDarkAppBarGradient = LinearGradient(
  colors: [_pokeDarkRed, Color(0xFF1F1B24)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kDarkBgGradient = LinearGradient(
  colors: [Color(0xFF0E0D10), Color(0xFF1A171F), Color(0xFF231F2A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

void main() {
  runApp(const MyApp());
}

/// ------------------------------------------------------------
/// APP ROOT (theme toggle built in)
/// ------------------------------------------------------------
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(bool isDark) {
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _pokeRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: shape,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );

    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _pokeRed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1C22),
        elevation: 2,
        shape: shape,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _pokeRed,
        foregroundColor: Colors.white,
      ),
    );

    return MaterialApp(
      title: 'Pokémon Cards',
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: _themeMode,
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => HomePage(onToggleTheme: _toggleTheme, themeMode: _themeMode),
        '/about': (_) => const AboutPage(),
      },
    );
  }
}

/// ------------------------------------------------------------
/// SPLASH
/// ------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();
  late final Animation<double> _scale =
      Tween(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? kDarkBgGradient : kLightBgGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 200,
                  height: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.catching_pokemon, size: 100, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Pokémon Cards', style: TextStyle(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 10),
              const _DotsLoading(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsLoading extends StatefulWidget {
  const _DotsLoading();
  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _c.drive(Tween(begin: 0.0, end: 1.0));
    return AnimatedBuilder(
      animation: t,
      builder: (_, __) {
        final v = t.value;
        double o(int i) => 0.3 + 0.7 * (1 - ((v + i / 3) % 1));
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: o(i).clamp(0.3, 1.0),
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ------------------------------------------------------------
/// MODEL + DATA SERVICE
/// ------------------------------------------------------------
class PokemonCard {
  final String id;
  final String name;
  final String? smallImage;
  final String? largeImage;
  final List<String> types;

  PokemonCard({
    required this.id,
    required this.name,
    required this.smallImage,
    required this.largeImage,
    required this.types,
  });

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] ?? {}) as Map<String, dynamic>;
    final rawTypes = json['types'];
    final types = rawTypes is List ? rawTypes.map((e) => e.toString()).toList() : <String>[];
    return PokemonCard(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      smallImage: images['small'] as String?,
      largeImage: images['large'] as String?,
      types: types,
    );
  }
}

class PokemonLocalData {
  static Future<List<PokemonCard>> fetchAll() async {
    final uri = Uri.parse(kDataUrl);
    const maxAttempts = 3;
    Duration backoff(int a) => Duration(milliseconds: 600 * (1 << a));
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final resp = await http.get(uri).timeout(const Duration(seconds: 10));
        if (resp.statusCode < 200 || resp.statusCode >= 300) {
          throw Exception('HTTP ${resp.statusCode}');
        }
        final parsed = json.decode(resp.body);
        final List<dynamic> list = parsed is List ? parsed : (parsed['data'] as List<dynamic>);
        return list.map((e) => PokemonCard.fromJson(e as Map<String, dynamic>)).toList();
      } on TimeoutException catch (_) {
        if (attempt < maxAttempts - 1) {
          await Future.delayed(backoff(attempt));
          continue;
        }
        rethrow;
      } on SocketException catch (_) {
        if (attempt < maxAttempts - 1) {
          await Future.delayed(backoff(attempt));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Failed after retries');
  }
}

/// ------------------------------------------------------------
/// HOME (fixed RenderSliver issue)
/// ------------------------------------------------------------
class HomePage extends StatefulWidget {
  final void Function(bool isDark) onToggleTheme;
  final ThemeMode themeMode;
  const HomePage({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchC = TextEditingController();
  Timer? _debounce;
  String _search = '';
  String _type = 'All';
  bool _isLoading = true;
  String? _error;
  List<PokemonCard> _all = [];
  List<PokemonCard> _filtered = [];
  final _scrollC = ScrollController();

  static const _types = [
    'All', 'Grass', 'Fire', 'Water', 'Lightning', 'Psychic',
    'Fighting', 'Darkness', 'Metal', 'Fairy', 'Dragon', 'Colorless',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _all = await PokemonLocalData.fetchAll();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final q = _search.trim().toLowerCase();
    Iterable<PokemonCard> items = _all;
    if (q.isNotEmpty) items = items.where((c) => c.name.toLowerCase().contains(q));
    if (_type != 'All') items = items.where((c) => c.types.contains(_type));
    _filtered = items.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(gradient: isDark ? kDarkBgGradient : kLightBgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Pokémon Cards'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: isDark ? kDarkAppBarGradient : kLightAppBarGradient,
            ),
          ),
        ),
        drawer: _AppDrawer(
          isDark: widget.themeMode == ThemeMode.dark,
          onThemeChanged: widget.onToggleTheme,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, textAlign: TextAlign.center))
                : RefreshIndicator(
                    onRefresh: _init,
                    child: ListView(
                      controller: _scrollC,
                      padding: const EdgeInsets.all(12),
                      children: [
                        TextField(
                          controller: _searchC,
                          decoration: InputDecoration(
                            hintText: 'Search by name (e.g., Pikachu, Charizard)',
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (v) {
                            _search = v;
                            _debounce?.cancel();
                            _debounce = Timer(const Duration(milliseconds: 300), _applyFilters);
                          },
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: _types
                              .map((t) => ChoiceChip(
                                    label: Text(t),
                                    selected: _type == t,
                                    onSelected: (_) {
                                      _type = t;
                                      _applyFilters();
                                    },
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3 / 4.2,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final c = _filtered[i];
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  final img = c.largeImage ?? c.smallImage;
                                  if (img == null) return;
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: InteractiveViewer(
                                        child: Image.network(img),
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        c.smallImage ?? '',
                                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Text(c.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(
                                            c.types.isEmpty
                                                ? c.id
                                                : '${c.id} · ${c.types.join(", ")}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// DRAWER + ABOUT
/// ------------------------------------------------------------
class _AppDrawer extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  const _AppDrawer({required this.isDark, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: kLightAppBarGradient),
            child: Row(
              children: [
                const Icon(Icons.catching_pokemon, color: Colors.white, size: 50),
                const SizedBox(width: 10),
                const Text('Pokémon Cards',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            value: isDark,
            onChanged: onThemeChanged,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? kDarkBgGradient : kLightBgGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('About'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: isDark ? kDarkAppBarGradient : kLightAppBarGradient,
            ),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'This app lists Pokémon TCG cards using a static JSON feed.\n\n'
            'Features: search, type filters, grid display, zoomable images, drawer navigation, and Pokédex-inspired theme.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
