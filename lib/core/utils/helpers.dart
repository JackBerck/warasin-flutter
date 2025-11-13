int stringIdTo32(String id) {
  final hex = id.replaceAll('-', '');
  final sub = hex.length >= 8 ? hex.substring(0, 8) : hex;
  final int? parsed = int.tryParse(sub, radix: 16);
  // fallback ke hashCode jika parse hex gagal
  final int base = parsed ?? id.hashCode;
  return base & 0x7fffffff; // mask jadi positive 32-bit signed
}
