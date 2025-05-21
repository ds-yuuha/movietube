class ChannelModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String bannerUrl;
  final String avatarUrl;
  final int subscriberCount;
  final int videoCount;
  final int totalViews;

  ChannelModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.bannerUrl,
    required this.avatarUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.totalViews,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      bannerUrl: json['bannerUrl'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      subscriberCount: json['subscriberCount'] ?? 0,
      videoCount: json['videoCount'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'bannerUrl': bannerUrl,
      'avatarUrl': avatarUrl,
      'subscriberCount': subscriberCount,
      'videoCount': videoCount,
      'totalViews': totalViews,
    };
  }
}
