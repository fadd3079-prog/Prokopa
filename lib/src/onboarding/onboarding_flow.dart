import 'package:flutter/material.dart';
import 'package:prokopa/src/app/prokopa_logo.dart';
import 'package:prokopa/src/core/constants/brand_constants.dart';
import 'package:prokopa/src/profile/local_profile.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onComplete});

  final Future<void> Function(LocalProfile profile) onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pages = PageController();
  final _name = TextEditingController();
  var _page = 0;
  var _focus = '';
  var _avatar = 'primary';
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page == 3) {
      await _complete();
      return;
    }
    await _pages.nextPage(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _complete() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(
        () => _error = 'Masukkan nama yang ingin digunakan di perangkat ini.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onComplete(
        LocalProfile(
          id: 'local',
          name: name,
          avatar: _avatar,
          appearance: AppAppearance.system,
          focus: _focus.isEmpty ? null : _focus,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Profil belum tersimpan. Coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_page + 1} dari 4',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (value) => setState(() => _page = value),
                  children: [
                    _WelcomePage(
                      logo: dark
                          ? BrandConstants.logoDark
                          : BrandConstants.logoLight,
                    ),
                    const _IntentPage(),
                    _FocusPage(
                      value: _focus,
                      onChanged: (value) => setState(() => _focus = value),
                    ),
                    _ProfilePage(
                      name: _name,
                      avatar: _avatar,
                      saving: _saving,
                      error: _error,
                      onAvatarChanged: (value) =>
                          setState(() => _avatar = value),
                    ),
                  ],
                ),
              ),
              if (_page > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _saving
                        ? null
                        : () => _pages.previousPage(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                          ),
                    child: const Text('Kembali'),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _next,
                  child: Text(_page == 3 ? 'Mulai' : 'Lanjutkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.logo});

  final String logo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProkopaLogo(asset: logo, height: 56),
        const SizedBox(height: 32),
        Text(
          'Ruang kecil untuk kebiasaan dan refleksi.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        const Text(
          'Data Prokopa tersimpan di perangkat ini. Tidak perlu membuat akun.',
        ),
      ],
    );
  }
}

class _IntentPage extends StatelessWidget {
  const _IntentPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mulai dari yang penting bagimu.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        const Text(
          'Kebiasaan dapat dimulai dari langkah ringan. Kamu dapat mencatat dan menyesuaikannya nanti.',
        ),
      ],
    );
  }
}

class _FocusPage extends StatelessWidget {
  const _FocusPage({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      'Kesehatan',
      'Produktivitas',
      'Pikiran',
      'Tidur',
      'Keseimbangan',
      'Pertumbuhan pribadi',
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apa yang ingin kamu rawat?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Pilihan ini opsional dan dapat diubah nanti.'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: value == option,
                onSelected: (_) => onChanged(value == option ? '' : option),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.name,
    required this.avatar,
    required this.saving,
    required this.error,
    required this.onAvatarChanged,
  });

  final TextEditingController name;
  final String avatar;
  final bool saving;
  final String? error;
  final ValueChanged<String> onAvatarChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 64),
        Text('Profil lokal', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Nama ini hanya digunakan di perangkat ini.'),
        const SizedBox(height: 24),
        TextField(
          controller: name,
          enabled: !saving,
          textCapitalization: TextCapitalization.words,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'Nama'),
        ),
        const SizedBox(height: 8),
        Text('Tampilan avatar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final option in ['primary', 'secondary', 'tertiary'])
              ChoiceChip(
                label: Text(_avatarLabel(option)),
                selected: avatar == option,
                onSelected: saving ? null : (_) => onAvatarChanged(option),
              ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  String _avatarLabel(String value) => switch (value) {
    'primary' => 'Indigo',
    'secondary' => 'Abu',
    _ => 'Aksen',
  };
}
