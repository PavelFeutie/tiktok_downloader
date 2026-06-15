import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/video_model.dart';

class DownloadService {
  final Dio _dio = Dio();
  
  DownloadService() {
    _dio.options.headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    };
  }
  
  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }
  
  Future<String?> downloadVideo(
    TikTokVideo video,
    Function(double progress) onProgress
  ) async {
    try {
      print('=== DÉBUT TÉLÉCHARGEMENT ===');
      print('URL: ${video.downloadUrl}');
      
      if (video.downloadUrl.isEmpty) {
        print('ERREUR: URL vide');
        return null;
      }
      
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        print('ERREUR: Permissions refusées');
        return null;
      }
      
      // Dossier de destination dans Téléchargements (accessible)
      Directory saveDir;
      
      // Pour Android, utiliser le dossier Téléchargements
      if (Platform.isAndroid) {
        saveDir = Directory('/storage/emulated/0/Download/TikTokDownloader');
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        saveDir = Directory('${appDir.path}/TikTokDownloads');
      }
      
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
        print('Dossier créé: ${saveDir.path}');
      }
      
      final fileName = 'tiktok_${video.id}.mp4';
      final savePath = '${saveDir.path}/$fileName';
      
      print('Sauvegarde vers: $savePath');
      
      await _dio.download(
        video.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      
      print('Téléchargement terminé!');
      print('Fichier sauvegardé dans: ${saveDir.path}');
      print('Nom du fichier: $fileName');
      
      return savePath;
      
    } catch (e) {
      print('Erreur téléchargement: $e');
      return null;
    }
  }
}