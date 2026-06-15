import 'package:flutter/material.dart';
import '../models/video_model.dart';

class VideoCard extends StatelessWidget {
  final TikTokVideo video;
  final VoidCallback onDownload;
  
  const VideoCard({
    super.key,
    required this.video,
    required this.onDownload,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: video.thumbnailUrl.isNotEmpty
                ? Image.network(
                    video.thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.videocam, size: 50),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.description,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: video.authorAvatar.isNotEmpty
                          ? NetworkImage(video.authorAvatar)
                          : null,
                      child: video.authorAvatar.isEmpty
                          ? const Icon(Icons.person, size: 15)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${video.author}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(Icons.favorite, video.likes),
                    _buildStat(Icons.comment, video.comments),
                    _buildStat(Icons.share, video.shares),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStat(IconData icon, int value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : value.toString(),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}