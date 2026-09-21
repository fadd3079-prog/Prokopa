import 'package:flutter/material.dart';
import 'package:prokopa/src/app/prokopa_logo.dart';
import 'package:prokopa/src/core/constants/brand_constants.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:prokopa/src/app/app_theme.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onComplete});

  final Future<void> Function(LocalProfile profile) onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _name = TextEditingController();
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
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
          avatar: 'primary',
          appearance: AppAppearance.system,
          focus: null,
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
          padding: const EdgeInsets.symmetric(horizontal: ProkopaSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProkopaLogo(
                asset: dark ? BrandConstants.logoDark : BrandConstants.logoLight,
                height: 48,
              ),
              const SizedBox(height: ProkopaSpacing.xxxl),
              Text(
                'Selamat datang.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: ProkopaSpacing.sm),
              Text(
                'Prokopa hanya menyimpan data di perangkat ini. Siapa namamu?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: ProkopaSpacing.huge),
              TextField(
                controller: _name,
                enabled: !_saving,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                maxLength: 40,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: InputDecoration(
                  hintText: 'Panggilan kamu',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                onSubmitted: (_) => _complete(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: ProkopaSpacing.huge),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _complete,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(_saving ? 'Memulai...' : 'Mulai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
