import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../state/settings_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _Intro {
  const _Intro(this.icon, this.color, this.extraA, this.extraB, this.title, this.body);
  final IconData icon, extraA, extraB;
  final Color color;
  final String title, body;
}

const _intro = [
  _Intro(Icons.favorite, AppTheme.brand, Icons.directions_walk, Icons.water_drop, 'Welcome to HealthMate',
      'Your simple, private companion for everyday health. Find your balance, one day at a time.'),
  _Intro(Icons.edit_note, Color(0xFF1B9E6B), Icons.local_fire_department, Icons.water_drop, 'Log your day in seconds',
      'Record your steps, calories burned and water intake. Add, edit or delete entries any time.'),
  _Intro(Icons.insights, Color(0xFF1F6FDB), Icons.emoji_events, Icons.trending_up, 'See your progress',
      'Track goals on your dashboard and spot trends with weekly charts and summaries.'),
];

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pages = PageController();
  final _name = TextEditingController();
  int _page = 0;
  static final int _last = _intro.length;

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  void _go(int i) => _pages.animateToPage(i, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);

  void _next() {
    if (_page == _last) {
      context.read<SettingsProvider>().completeOnboarding(_name.text);
    } else {
      _go(_page + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          SizedBox(
            height: 52,
            child: Align(
              alignment: Alignment.centerRight,
              child: _page == _last
                  ? null
                  : Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(onPressed: () => _go(_last), child: const Text('Skip')),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pages,
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                for (final p in _intro) _IntroPage(p),
                _NamePage(controller: _name, onDone: _next),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i <= _last; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _page ? s.primary : s.outline,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: FilledButton(
              onPressed: _next,
              child: Text(_page == _last ? 'Get started' : 'Next'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Art extends StatelessWidget {
  const _Art({required this.icon, required this.color, required this.extraA, required this.extraB});
  final IconData icon, extraA, extraB;
  final Color color;

  Widget _bubble(IconData i, Color c) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: c,
      shape: BoxShape.circle,
      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
    ),
    child: Icon(i, color: Colors.white, size: 24),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(alignment: Alignment.center, children: [
        Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(24))),
        Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(44))),
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, Colors.black, 0.28)!],
            ),
          ),
          child: Icon(icon, size: 58, color: Colors.white),
        ),
        Positioned(top: 22, right: 30, child: _bubble(extraA, const Color(0xFFDC3545))),
        Positioned(bottom: 26, left: 22, child: _bubble(extraB, const Color(0xFF1F6FDB))),
      ]),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage(this.p);
  final _Intro p;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(children: [
        const SizedBox(height: 12),
        _Art(icon: p.icon, color: p.color, extraA: p.extraA, extraB: p.extraB),
        const SizedBox(height: 36),
        Text(p.title, textAlign: TextAlign.center, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text(p.body,
            textAlign: TextAlign.center,
            style: t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant, height: 1.45)),
      ]),
    );
  }
}

class _NamePage extends StatelessWidget {
  const _NamePage({required this.controller, required this.onDone});
  final TextEditingController controller;
  final VoidCallback onDone;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(children: [
        const SizedBox(height: 12),
        const _Art(icon: Icons.person, color: AppTheme.brand, extraA: Icons.directions_walk, extraB: Icons.water_drop),
        const SizedBox(height: 32),
        Text('What should we call you?',
            textAlign: TextAlign.center, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text('We will use your name to greet you. It is optional and stays on this device.',
            textAlign: TextAlign.center,
            style: t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant, height: 1.45)),
        const SizedBox(height: 22),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 24,
          onSubmitted: (_) => onDone(),
          decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.badge_outlined)),
        ),
      ]),
    );
  }
}
