import 'dart:io';

class ImageItem {
  final String path;
  final String fileName;
  final int fileSize;
  final DateTime lastModified;

  ImageItem({
    required this.path,
    required this.fileName,
    required this.fileSize,
    required this.lastModified,
  });

  String get extension => path.split('.').last.toLowerCase();

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDate {
    final diff = DateTime.now().difference(lastModified);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${lastModified.year}-${lastModified.month.toString().padLeft(2, '0')}-${lastModified.day.toString().padLeft(2, '0')}';
  }

  File get file => File(path);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ImageItem && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
