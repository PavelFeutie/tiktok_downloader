class TikTokVideo {
  final String id;
  final String url;
  final String downloadUrl;
  final String thumbnailUrl;
  final String description;
  final String author;
  final String authorAvatar;
  final int duration;
  final int likes;
  final int comments;
  final int shares;
  final DateTime? downloadedAt;
  final String? localPath;

  TikTokVideo({
    required this.id,
    required this.url,
    required this.downloadUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.author,
    required this.authorAvatar,
    required this.duration,
    required this.likes,
    required this.comments,
    required this.shares,
    this.downloadedAt,
    this.localPath,
  });

  factory TikTokVideo.fromJson(Map<String, dynamic> json) {
    return TikTokVideo(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? 'Unknown',
      authorAvatar: json['authorAvatar'] ?? '',
      duration: json['duration'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      downloadedAt: json['downloadedAt'] != null 
          ? DateTime.parse(json['downloadedAt']) 
          : null,
      localPath: json['localPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'downloadUrl': downloadUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'author': author,
      'authorAvatar': authorAvatar,
      'duration': duration,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'downloadedAt': downloadedAt?.toIso8601String(),
      'localPath': localPath,
    };
  }
}