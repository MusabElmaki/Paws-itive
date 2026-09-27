import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Image compression and compatibility with legacy inline photos. New photos use Storage.
class ImageUtil {
  ImageUtil._();

  static const String _prefix = 'data:image/jpeg;base64,';

  /// Decodes, downscales and JPEG-compresses [bytes], returning a data URI
  /// string. Returns null if the image can't be decoded.
  static String? encodeThumbnail(
    Uint8List bytes, {
    int maxWidth = 480,
    int quality = 65,
  }) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final resized = decoded.width >= decoded.height
          ? (decoded.width > maxWidth
                ? img.copyResize(decoded, width: maxWidth)
                : decoded)
          : (decoded.height > maxWidth
                ? img.copyResize(decoded, height: maxWidth)
                : decoded);
      final jpg = img.encodeJpg(resized, quality: quality);
      return '$_prefix${base64Encode(jpg)}';
    } catch (_) {
      return null;
    }
  }

  static bool isDataUri(String? value) =>
      value != null && value.startsWith('data:image');

  static Uint8List? _decodeDataUri(String value) {
    final index = value.indexOf('base64,');
    if (index == -1) return null;
    try {
      return base64Decode(value.substring(index + 7));
    } catch (_) {
      return null;
    }
  }

  /// Returns an [ImageProvider] for either a base64 data URI or an http(s) URL,
  /// or null when there is nothing usable to show.
  static ImageProvider? providerFor(String? value) {
    if (value == null || value.isEmpty) return null;
    if (isDataUri(value)) {
      final bytes = _decodeDataUri(value);
      return bytes == null ? null : MemoryImage(bytes);
    }
    if (value.startsWith('http')) return NetworkImage(value);
    return null;
  }
}
