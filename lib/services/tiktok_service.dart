import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class TikTokService {
  static const String userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
  
  Future<TikTokVideo> getVideoInfo(String videoUrl) async {
    try {
      // Utiliser l'API publique tikwm.com (gratuite, sans clé)
      final apiUrl = 'https://tikwm.com/api/?url=${Uri.encodeComponent(videoUrl)}';
      
      print('Appel API: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'User-Agent': userAgent},
      );
      
      if (response.statusCode != 200) {
        throw Exception('API non disponible (code: ${response.statusCode})');
      }
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['code'] != 0 || data['data'] == null) {
        throw Exception('Erreur API: ${data['msg'] ?? 'Vidéo non trouvée'}');
      }
      
      final videoData = data['data'];
      
      // Récupérer l'URL de téléchargement sans watermark
      String downloadUrl = '';
      if (videoData['play'] != null) {
        downloadUrl = videoData['play'];
      } else if (videoData['wmplay'] != null) {
        downloadUrl = videoData['wmplay'];
      } else if (videoData['hdplay'] != null) {
        downloadUrl = videoData['hdplay'];
      }
      
      if (downloadUrl.isEmpty) {
        throw Exception('URL de téléchargement non trouvée');
      }
      
      // Nettoyer l'URL (enlever les paramètres inutiles)
      if (downloadUrl.contains('?')) {
        downloadUrl = downloadUrl.split('?')[0];
      }
      
      print('URL téléchargement trouvée: $downloadUrl');
      
      return TikTokVideo(
        id: videoData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        url: videoUrl,
        downloadUrl: downloadUrl,
        thumbnailUrl: videoData['cover'] ?? '',
        description: videoData['title'] ?? 'TikTok Video',
        author: videoData['author']?['unique_id'] ?? 'Unknown',
        authorAvatar: videoData['author']?['avatar'] ?? '',
        duration: videoData['duration'] ?? 0,
        likes: videoData['digg_count'] ?? 0,
        comments: videoData['comment_count'] ?? 0,
        shares: videoData['share_count'] ?? 0,
      );
      
    } catch (e) {
      print('Erreur détaillée: $e');
      throw Exception('Erreur lors de la récupération: $e');
    }
  }
}