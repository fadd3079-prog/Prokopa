import 'dart:math';

String newLocalId() {
  final random = Random.secure();
  return '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${random.nextInt(1 << 32).toRadixString(36)}';
}
