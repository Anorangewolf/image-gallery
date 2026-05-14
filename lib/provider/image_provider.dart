import 'package:flutter/foundation.dart';
import '../model/image_item.dart';
import '../services/image_service.dart';

enum SortOption { dateDesc, dateAsc, nameAsc, nameDesc, sizeDesc, sizeAsc }

class GalleryProvider extends ChangeNotifier {
  String? _currentFolder;
  List<ImageItem> _images = [];
  List<ImageItem> _filteredImages = [];
  bool _isLoading = false;
  String? _error;
  SortOption _sortOption = SortOption.dateDesc;
  String _searchQuery = '';

  String? get currentFolder => _currentFolder;
  List<ImageItem> get images => _filteredImages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;
  int get imageCount => _images.length;

  Future<void> loadFolder(String folderPath) async {
    _currentFolder = folderPath;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final images = await ImageService.loadImages(folderPath);
      _images = images;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = '加载图片失败: $e';
      _images = [];
      _filteredImages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredImages = List.from(_images);
    if (_searchQuery.isNotEmpty) {
      _filteredImages = _filteredImages
          .where(
            (item) => item.fileName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    switch (_sortOption) {
      case SortOption.dateDesc:
        _filteredImages.sort(
          (a, b) => b.lastModified.compareTo(a.lastModified),
        );
        break;
      case SortOption.dateAsc:
        _filteredImages.sort(
          (a, b) => a.lastModified.compareTo(b.lastModified),
        );
        break;
      case SortOption.nameAsc:
        _filteredImages.sort((a, b) => a.fileName.compareTo(b.fileName));
        break;
      case SortOption.nameDesc:
        _filteredImages.sort((a, b) => b.fileName.compareTo(a.fileName));
        break;
      case SortOption.sizeDesc:
        _filteredImages.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case SortOption.sizeAsc:
        _filteredImages.sort((a, b) => a.fileSize.compareTo(b.fileSize));
        break;
    }
  }

  void refresh() {
    if (_currentFolder != null) {
      loadFolder(_currentFolder!);
    }
  }

  bool deleteImage(ImageItem item) {
    try {
      item.file.deleteSync();
      _images.remove(item);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
