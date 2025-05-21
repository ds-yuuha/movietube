class UserModel {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String channelName;
  final List<String> subscribers;
  final List<String> subscribedTo;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.channelName,
    required this.subscribers,
    required this.subscribedTo,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      channelName: json['channelName'] ?? '',
      subscribers: List<String>.from(json['subscribers'] ?? []),
      subscribedTo: List<String>.from(json['subscribedTo'] ?? []),
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt']).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'channelName': channelName,
      'subscribers': subscribers,
      'subscribedTo': subscribedTo,
      'createdAt': createdAt,
    };
  }
}
