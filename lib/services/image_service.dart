import 'dart:io';
import '../model/image_item.dart';

class ImageService {
  static const List<String> supportedExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'tif', 'ico',
  ];

  static Future<List<ImageItem>> loadImages(String folderPath) async {
    final directory = Directory(folderPath);
    if (!await directory.exists()) {
      return [];
    }

    final files = <ImageItem>[];
    try {
      final entities = directory.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File && _isImageFile(entity.path)) {
          final stat = entity.statSync();
          files.add(ImageItem(
            path: entity.path,
            fileName: entity.path.split(Platform.pathSeparator).last,
            fileSize: stat.size,
            lastModified: stat.modified,
          ));
        }
      }
    } catch (e) {
      // ignore permission errors silently
    }

    files.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return files;
  }

  static bool _isImageFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return supportedExtensions.contains(ext);
  }

  static Future<int> countImages(String folderPath) async {
    final images = await loadImages(folderPath);
    return images.length;
  }
}
