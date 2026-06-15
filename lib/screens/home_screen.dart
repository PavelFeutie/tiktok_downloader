import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import '../services/tiktok_service.dart';
import '../services/download_service.dart';
import '../models/video_model.dart';
import '../widgets/video_card.dart';
import 'downloads_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TikTokService _tiktokService = TikTokService();
  final DownloadService _downloadService = DownloadService();
  
  bool _isLoading = false;
  TikTokVideo? _currentVideo;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TikTok Downloader'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _goToDownloads(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildUrlInput(),
            const SizedBox(height: 20),
            _buildButtons(),
            const SizedBox(height: 20),
            if (_isLoading) _buildLoadingIndicator(),
            if (_currentVideo != null && !_isLoading) 
              VideoCard(
                video: _currentVideo!,
                onDownload: _downloadVideo,
              ),
            if (_isDownloading) _buildProgressBar(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUrlInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _urlController,
        decoration: InputDecoration(
          hintText: 'Collez le lien TikTok ici...',
          prefixIcon: const Icon(Icons.link),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
        ),
        maxLines: 1,
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: TextInputType.url,
      ),
    );
  }
  
  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pasteFromClipboard,
            icon: const Icon(Icons.content_paste),
            label: const Text('Coller'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _fetchVideo,
            icon: const Icon(Icons.search),
            label: const Text('Analyser'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text('Chargement de la vidéo...'),
        ],
      ),
    );
  }
  
  Widget _buildProgressBar() {
    return Column(
      children: [
        const SizedBox(height: 20),
        LinearProgressIndicator(value: _downloadProgress),
        const SizedBox(height: 10),
        Text('Téléchargement: ${(_downloadProgress * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
  
  // Nettoie l'URL TikTok des textes ajoutés par TikTok Lite
  String _cleanTikTokUrl(String rawUrl) {
    if (rawUrl.isEmpty) return rawUrl;
    
    // Extraire la première URL du texte
    final match = RegExp(r'https?://[^\s]+').firstMatch(rawUrl);
    if (match != null) {
      String url = match.group(0)!;
      // Supprimer les paramètres inutiles après le ?
      if (url.contains('?')) {
        url = url.split('?')[0];
      }
      return url;
    }
    return rawUrl;
  }
  
  Future<void> _pasteFromClipboard() async {
    String? text = await FlutterClipboard.paste();
    
    print('Contenu du presse-papiers: $text');
    
    if (text != null && text.isNotEmpty) {
      // Nettoyer automatiquement l'URL
      String cleanUrl = _cleanTikTokUrl(text);
      setState(() {
        _urlController.text = cleanUrl;
      });
      _showMessage('Lien collé: $cleanUrl');
      _fetchVideo();
    } else {
      _showMessage('Rien dans le presse-papiers');
    }
  }
  
  Future<void> _fetchVideo() async {
    String rawUrl = _urlController.text.trim();
    String url = _cleanTikTokUrl(rawUrl);
    
    // Vérifications
    if (url.isEmpty) {
      _showMessage('Veuillez entrer un lien TikTok');
      return;
    }
    
    if (!url.contains('tiktok.com')) {
      _showMessage('Le lien doit contenir tiktok.com');
      return;
    }
    
    if (url.contains('tiktoklite')) {
      _showMessage('Détecté: lien TikTok Lite. Nettoyage automatique effectué.');
    }
    
    // Si l'URL est trop courte après nettoyage
    if (url.length < 20) {
      _showMessage('Lien TikTok invalide ou trop court');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _currentVideo = null;
    });
    
    try {
      final video = await _tiktokService.getVideoInfo(url);
      setState(() {
        _currentVideo = video;
        _isLoading = false;
      });
      _showMessage('Vidéo trouvée !');
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Erreur: ${e.toString()}');
    }
  }
  
  Future<void> _downloadVideo() async {
    if (_currentVideo == null) return;
    
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });
    
    final savedPath = await _downloadService.downloadVideo(
      _currentVideo!,
      (progress) {
        setState(() {
          _downloadProgress = progress;
        });
      },
    );
    
    setState(() => _isDownloading = false);
    
    if (savedPath != null) {
      _showMessage('Vidéo téléchargée avec succès!');
    } else {
      _showMessage('Erreur lors du téléchargement');
    }
  }
  
  void _goToDownloads() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DownloadsScreen()),
    );
  }
  
  // Affiche un message temporaire (SnackBar)
  void _showMessage(String message) {
    print('Message: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}