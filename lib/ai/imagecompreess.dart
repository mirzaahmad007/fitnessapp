import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

Future<XFile?> compressImage(File file) async {
  final dir = file.parent;
  final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 70, // Adjust 0-100
    minWidth: 800,
    minHeight: 800,
  );

  return result;
}
