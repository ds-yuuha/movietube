import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String videoId;
  final String userId;
  final String text;
  final int likeCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.text,
    required this.likeCount,
    required this.likedBy,
    required this.createdAt,
    required this.replies,
  });

  factory CommentModel.fromJson(
    Map<String, dynamic> json, [
    List<CommentModel>? repliesList,
  ]) {
    return CommentModel(
      id: json['id'] ?? '',
      videoId: json['videoId'] ?? '',
      userId: json['userId'] ?? '',
      text: json['text'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      replies: repliesList ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'userId': userId,
      'text': text,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'createdAt': createdAt,
      // replies are stored separately in Firestore
    };
  }
}
