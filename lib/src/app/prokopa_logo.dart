import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prokopa/src/core/constants/brand_constants.dart';

class ProkopaLogo extends StatelessWidget {
  const ProkopaLogo({
    super.key,
    this.asset,
    this.height = 48,
    this.width,
    this.semanticsLabel = 'Logo Prokopa',
  });

  final String? asset;
  final double height;
  final double? width;
  final String semanticsLabel;

  static final _sources = <String, Future<String>>{};

  @override
  Widget build(BuildContext context) {
    final effectiveAsset =
        asset ??
        (Theme.of(context).brightness == Brightness.dark
            ? BrandConstants.logoDark
            : BrandConstants.logoLight);

    return FutureBuilder<String>(
      future: _sources.putIfAbsent(effectiveAsset, () => _load(effectiveAsset)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: height, width: width);
        }
        return SvgPicture.string(
          snapshot.data!,
          height: height,
          width: width,
          semanticsLabel: semanticsLabel,
        );
      },
    );
  }

  static Future<String> _load(String asset) async {
    final source = await rootBundle.loadString(asset);
    final styles = RegExp(r'\.(cls-\d+)\s*\{\s*fill:\s*(#[0-9a-fA-F]+);\s*\}')
        .allMatches(source);
    var inline = source.replaceFirst(RegExp(r'<defs>[\s\S]*?</defs>'), '');
    for (final style in styles) {
      inline = inline.replaceAll(
        'class="${style.group(1)}"',
        'fill="${style.group(2)}"',
      );
    }
    return inline;
  }
}
