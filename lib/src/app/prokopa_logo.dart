import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProkopaLogo extends StatelessWidget {
  const ProkopaLogo({super.key, required this.asset, required this.height});

  final String asset;
  final double height;

  static final _sources = <String, Future<String>>{};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _sources.putIfAbsent(asset, () => _load(asset)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: height);
        }
        return SvgPicture.string(
          snapshot.data!,
          height: height,
          semanticsLabel: 'Logo Prokopa',
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
