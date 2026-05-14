import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../provider/image_provider.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片展示器'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 120,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),
              Text(
                '选择一个文件夹',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '浏览您电脑上的图片文件',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: _pickFolder,
                icon: const Icon(Icons.folder_open),
                label: const Text('选择文件夹'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickFolder,
                icon: const Icon(Icons.drive_folder_upload_outlined),
                label: const Text('选择包含图片的文件夹'),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.getDirectoryPath(
      dialogTitle: '请选择包含图片的文件夹',
    );
    if (selectedDirectory != null && mounted) {
      final provider = context.read<GalleryProvider>();
      await provider.loadFolder(selectedDirectory);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GalleryScreen(folderPath: selectedDirectory),
          ),
        );
      }
    }
  }
}
