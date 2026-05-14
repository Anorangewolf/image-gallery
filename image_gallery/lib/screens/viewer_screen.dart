import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import '../model/image_item.dart';
import '../provider/image_provider.dart';

class ViewerScreen extends StatefulWidget {
  final int initialIndex;
  const ViewerScreen({super.key, required this.initialIndex});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GalleryProvider>();
    final images = provider.images;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        GestureDetector(
          onTap: () => setState(() => _showOverlay = !_showOverlay),
          child: PhotoViewGallery.builder(
            pageController: _pageController,
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (context, index) {
              final item = images[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(item.path)),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(tag: item.path),
              );
            },
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
        ),
        if (_showOverlay)
          Positioned(top: 0, left: 0, right: 0, child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 8, right: 8, bottom: 8),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent])),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
              const Spacer(),
              Text('${_currentIndex + 1} / ${images.length}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.info_outline, color: Colors.white), onPressed: () => _showImageInfo(context, images[_currentIndex])),
            ]),
          )),
        if (_showOverlay)
          Positioned(bottom: 0, left: 0, right: 0, child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(images[_currentIndex].fileName, style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                _infoChip(Icons.storage, images[_currentIndex].formattedSize),
                const SizedBox(width: 12),
                _infoChip(Icons.access_time, images[_currentIndex].formattedDate),
              ]),
            ]),
          )),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.white70),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }

  void _showImageInfo(BuildContext context, ImageItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('图片信息', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24),
          _infoRow('文件名', item.fileName),
          _infoRow('路径', item.path),
          _infoRow('大小', item.formattedSize),
          _infoRow('修改时间', item.formattedDate),
          _infoRow('格式', item.extension.toUpperCase()),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13))),
    ]));
  }
}
