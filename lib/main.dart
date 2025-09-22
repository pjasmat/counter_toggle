import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const CW01App());

class CW01App extends StatefulWidget {
  const CW01App({super.key});
  @override
  State<CW01App> createState() => _CW01AppState();
}

class _CW01AppState extends State<CW01App> with TickerProviderStateMixin {
  int _counter = 0;
  bool _useAltImage = false; 

  ThemeMode _themeMode = ThemeMode.light;

  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final Animation<double> _fade;

  static const _kCounterKey = 'counter';
  static const _kImageKey = 'useAltImage';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fade = Tween<double>(begin: 0, end: 1).animate(_curve);
    _controller.forward();

    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(_kCounterKey) ?? 0;
      _useAltImage = prefs.getBool(_kImageKey) ?? false;
    });
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCounterKey, _counter);
  }

  Future<void> _saveImageState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kImageKey, _useAltImage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() => _counter++);
    _saveCounter();
  }

  void _toggleImage() {
    _controller.forward(from: 0);
    setState(() => _useAltImage = !_useAltImage);
    _saveImageState();
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _confirmAndReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App?'),
        content: const Text(
          'This will reset the counter to 0 and revert the image to dog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _counter = 0;
        _useAltImage = false;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kCounterKey);
      await prefs.remove(_kImageKey);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App reset to defaults')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    );
    final dark = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CW01 – Counter & Image Toggle',
      theme: light,
      darkTheme: dark,
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CW01 – Counter & Image Toggle'),
          actions: [
            IconButton(
              tooltip: 'Light / Dark',
              onPressed: _toggleTheme,
              icon: Icon(
                _themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Counter',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '$_counter',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _increment,
                      icon: const Icon(Icons.add),
                      label: const Text('Increment'),
                    ),
                    const SizedBox(height: 28),

                    Text('Image Toggle',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: Image.asset(
                          _useAltImage ? 'assets/img2.png' : 'assets/img1.png',
                          key: ValueKey(_useAltImage),
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleImage,
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Toggle Image'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _toggleTheme,
                          icon: const Icon(Icons.brightness_6),
                          label: const Text('Light / Dark'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _confirmAndReset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
