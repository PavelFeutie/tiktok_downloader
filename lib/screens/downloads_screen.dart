import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadsScreen extends StatefulWidget {
  @override
  _DownloadsScreenState createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<File> _videos = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadVideos();
  }
  
  Future<void> _loadVideos() async {
    final dir = await getApplicationDocumentsDirectory();
    final tiktokDir = Directory('${dir.path}/TikTokDownloads');
    
    if (await tiktokDir.exists()) {
      final files = tiktokDir.listSync();
      setState(() {
        _videos = files.whereType<File>().toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes téléchargements'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    final video = _videos[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.video_file, size: 40),
                        title: Text(video.path.split('\\').last),
                        trailing: IconButton(
                          icon: const Icon(Icons.info, color: Colors.blue),
                          onPressed: () => _showVideoInfo(video),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
  
  void _showVideoInfo(File video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information vidéo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${video.path.split('\\').last}'),
            const SizedBox(height: 8),
            Text('Taille: ${_formatFileSize(video.lengthSync())}'),
            const SizedBox(height: 8),
            Text('Chemin: ${video.path}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune vidéo téléchargée',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}