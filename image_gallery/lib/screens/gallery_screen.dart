import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/image_provider.dart';
import '../widgets/image_grid_tile.dart';
import '../widgets/empty_state.dart';
import 'viewer_screen.dart';
import 'home_screen.dart';

class GalleryScreen extends StatelessWidget {
  final String folderPath;
  const GalleryScreen({super.key, required this.folderPath});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      child: Consumer<GalleryProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                folderPath.split('\\').last.isNotEmpty
                    ? folderPath.split('\\').last
                    : folderPath.split('/').last,
                overflow: TextOverflow.ellipsis,
              ),
              centerTitle: true,
              actions: [
                if (provider.images.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: '刷新',
                    onPressed: provider.refresh,
                  ),
                PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: '排序方式',
                  onSelected: provider.setSortOption,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: SortOption.dateDesc,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 18),
                          SizedBox(width: 8),
                          Text('最新优先'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: SortOption.dateAsc,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 18),
                          SizedBox(width: 8),
                          Text('最早优先'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: SortOption.nameAsc,
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 18),
                          SizedBox(width: 8),
                          Text('名称 A-Z'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: SortOption.nameDesc,
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 18),
                          SizedBox(width: 8),
                          Text('名称 Z-A'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: SortOption.sizeDesc,
                      child: Row(
                        children: [
                          Icon(Icons.photo_size_select_large, size: 18),
                          SizedBox(width: 8),
                          Text('最大优先'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: SortOption.sizeAsc,
                      child: Row(
                        children: [
                          Icon(Icons.photo_size_select_small, size: 18),
                          SizedBox(width: 8),
                          Text('最小优先'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: provider.images.isNotEmpty
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '搜索图片...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: provider.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () =>
                                        provider.setSearchQuery(''),
                                  )
                                : null,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onChanged: provider.setSearchQuery,
                        ),
                      ),
                    )
                  : null,
            ),
            body: _buildBody(context, provider),
            bottomNavigationBar: provider.images.isNotEmpty
                ? BottomAppBar(
                    child: Center(
                      child: Text(
                        '共 ${provider.images.length} 张图片${provider.images.length != provider.imageCount ? "（筛选 ${provider.imageCount} 张中的 ${provider.images.length} 张）" : ""}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, GalleryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
              child: const Text('返回'),
            ),
          ],
        ),
      );
    }
    if (provider.images.isEmpty) {
      return EmptyState(
        icon: Icons.image_not_supported_outlined,
        title: provider.imageCount == 0 ? '未找到图片' : '没有匹配的图片',
        subtitle: provider.imageCount == 0
            ? '该文件夹中没有支持的图片文件（支持 JPG, PNG, GIF, WebP, BMP 等格式）'
            : '尝试修改搜索关键词',
        action: provider.imageCount == 0
            ? ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
                icon: const Icon(Icons.folder_open),
                label: const Text('选择其他文件夹'),
              )
            : null,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 150).floor().clamp(
          2,
          10,
        );
        return RefreshIndicator(
          onRefresh: () => provider.loadFolder(folderPath),
          child: GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: provider.images.length,
            itemBuilder: (context, index) => ImageGridTile(
              item: provider.images[index],
              onTap: () => _openViewer(context, provider, index),
            ),
          ),
        );
      },
    );
  }

  void _openViewer(BuildContext context, GalleryProvider provider, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: ViewerScreen(initialIndex: index),
        ),
      ),
    );
  }
}
