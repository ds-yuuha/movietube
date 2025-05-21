import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_model.dart';
import '../models/comment_model.dart';
import '../models/channel_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get trending videos
  Future<List<VideoModel>> getTrendingVideos() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('videos')
              .orderBy('viewCount', descending: true)
              .limit(20)
              .get();

      return snapshot.docs.map((doc) {
        return VideoModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add a new video
  Future<void> addVideo({
    required String videoUrl,
    required String thumbnailUrl,
    required String title,
    required String description,
    required String userId,
    required String channelName,
    required List<String> tags,
  }) async {
    try {
      DocumentReference videoRef = _firestore.collection('videos').doc();

      VideoModel video = VideoModel(
        id: videoRef.id,
        userId: userId,
        title: title,
        description: description,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        viewCount: 0,
        likeCount: 0,
        dislikeCount: 0,
        likedBy: [],
        dislikedBy: [],
        channelName: channelName,
        tags: tags,
        createdAt: DateTime.now(),
      );

      await videoRef.set(video.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Get recent videos
  Future<List<VideoModel>> getRecentVideos() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('videos')
              .orderBy('createdAt', descending: true)
              .limit(20)
              .get();

      return snapshot.docs.map((doc) {
        return VideoModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get videos by user
  Future<List<VideoModel>> getVideosByUser(String userId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('videos')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        return VideoModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get subscription videos
  Future<List<VideoModel>> getSubscriptionVideos(
    List<String> subscribedTo,
  ) async {
    try {
      if (subscribedTo.isEmpty) return [];

      QuerySnapshot snapshot =
          await _firestore
              .collection('videos')
              .where('userId', whereIn: subscribedTo)
              .orderBy('createdAt', descending: true)
              .limit(50)
              .get();

      return snapshot.docs.map((doc) {
        return VideoModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getSubscribedChannel(
    List<String> subscribedTo,
  ) async {
    try {
      if (subscribedTo.isEmpty) return [];

      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('id', whereIn: subscribedTo)
              .orderBy('createdAt', descending: true)
              .limit(50)
              .get();

      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get video by ID
  Future<VideoModel> getVideoById(String videoId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('videos').doc(videoId).get();

      return VideoModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Add view to video
  Future<void> addView(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).update({
        'viewCount': FieldValue.increment(1),
      });

      // Update channel total views
      DocumentSnapshot videoDoc =
          await _firestore.collection('videos').doc(videoId).get();

      String userId = (videoDoc.data() as Map<String, dynamic>)['userId'];

      await _firestore.collection('channels').doc(userId).update({
        'totalViews': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Like/unlike video
  Future<void> toggleLikeVideo(String videoId, String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('videos').doc(videoId).get();

      VideoModel video = VideoModel.fromJson(
        doc.data() as Map<String, dynamic>,
      );

      if (video.likedBy.contains(userId)) {
        // Unlike
        await _firestore.collection('videos').doc(videoId).update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Like and remove from dislikedBy if exists
        if (video.dislikedBy.contains(userId)) {
          await _firestore.collection('videos').doc(videoId).update({
            'dislikedBy': FieldValue.arrayRemove([userId]),
            'dislikeCount': FieldValue.increment(-1),
          });
        }

        await _firestore.collection('videos').doc(videoId).update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Dislike/undislike video
  Future<void> toggleDislikeVideo(String videoId, String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('videos').doc(videoId).get();

      VideoModel video = VideoModel.fromJson(
        doc.data() as Map<String, dynamic>,
      );

      if (video.dislikedBy.contains(userId)) {
        // Undislike
        await _firestore.collection('videos').doc(videoId).update({
          'dislikedBy': FieldValue.arrayRemove([userId]),
          'dislikeCount': FieldValue.increment(-1),
        });
      } else {
        // Dislike and remove from likedBy if exists
        if (video.likedBy.contains(userId)) {
          await _firestore.collection('videos').doc(videoId).update({
            'likedBy': FieldValue.arrayRemove([userId]),
            'likeCount': FieldValue.increment(-1),
          });
        }

        await _firestore.collection('videos').doc(videoId).update({
          'dislikedBy': FieldValue.arrayUnion([userId]),
          'dislikeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get comments for a video
  Future<List<CommentModel>> getComments(String videoId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('comments')
              .where('videoId', isEqualTo: videoId)
              .where('isReply', isEqualTo: false) // Only get top-level comments
              .orderBy('createdAt', descending: true)
              .get();

      List<CommentModel> comments = [];

      for (var doc in snapshot.docs) {
        // Get replies for this comment
        QuerySnapshot repliesSnapshot =
            await _firestore
                .collection('comments')
                .where('parentId', isEqualTo: doc.id)
                .where('isReply', isEqualTo: true)
                .orderBy('createdAt')
                .get();

        List<CommentModel> replies =
            repliesSnapshot.docs.map((replyDoc) {
              return CommentModel.fromJson(
                replyDoc.data() as Map<String, dynamic>,
              );
            }).toList();

        comments.add(
          CommentModel.fromJson(doc.data() as Map<String, dynamic>, replies),
        );
      }

      return comments;
    } catch (e) {
      rethrow;
    }
  }

  // Add a comment
  Future<CommentModel> addComment(
    String videoId,
    String userId,
    String text,
  ) async {
    try {
      DocumentReference commentRef = _firestore.collection('comments').doc();

      CommentModel comment = CommentModel(
        id: commentRef.id,
        videoId: videoId,
        userId: userId,
        text: text,
        likeCount: 0,
        likedBy: [],
        createdAt: DateTime.now(),
        replies: [],
      );

      await commentRef.set({
        ...comment.toJson(),
        'isReply': false,
        'parentId': null,
      });

      return comment;
    } catch (e) {
      rethrow;
    }
  }

  // Add a reply to a comment
  Future<CommentModel> addReply(
    String videoId,
    String userId,
    String text,
    String parentId,
  ) async {
    try {
      DocumentReference replyRef = _firestore.collection('comments').doc();

      CommentModel reply = CommentModel(
        id: replyRef.id,
        videoId: videoId,
        userId: userId,
        text: text,
        likeCount: 0,
        likedBy: [],
        createdAt: DateTime.now(),
        replies: [],
      );

      await replyRef.set({
        ...reply.toJson(),
        'isReply': true,
        'parentId': parentId,
      });

      return reply;
    } catch (e) {
      rethrow;
    }
  }

  // Like/unlike a comment
  Future<void> toggleLikeComment(String commentId, String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('comments').doc(commentId).get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> likedBy = List<String>.from(data['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        // Unlike
        await _firestore.collection('comments').doc(commentId).update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        await _firestore.collection('comments').doc(commentId).update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Subscribe/unsubscribe to a channel
  Future<bool> toggleSubscription(String userId, String channelUserId) async {
    bool isSubscribe = false;
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> subscribedTo = List<String>.from(
        userData['subscribedTo'] ?? [],
      );

      if (subscribedTo.contains(channelUserId)) {
        // Unsubscribe
        await _firestore.collection('users').doc(userId).update({
          'subscribedTo': FieldValue.arrayRemove([channelUserId]),
        });

        await _firestore.collection('users').doc(channelUserId).update({
          'subscribers': FieldValue.arrayRemove([userId]),
        });

        await _firestore.collection('channels').doc(channelUserId).update({
          'subscriberCount': FieldValue.increment(-1),
        });
        isSubscribe = false;
      } else {
        // Subscribe
        await _firestore.collection('users').doc(userId).update({
          'subscribedTo': FieldValue.arrayUnion([channelUserId]),
        });

        await _firestore.collection('users').doc(channelUserId).update({
          'subscribers': FieldValue.arrayUnion([userId]),
        });

        await _firestore.collection('channels').doc(channelUserId).update({
          'subscriberCount': FieldValue.increment(1),
        });

        isSubscribe = true;
      }
      return isSubscribe;
    } catch (e) {
      rethrow;
    }
  }

  // Get channel data
  Future<ChannelModel> getChannelData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('channels').doc(userId).get();

      return ChannelModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isSub(String userId, String channelUserId) async {
    bool isSub = false;
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> subscribedTo = List<String>.from(
        userData['subscribedTo'] ?? [],
      );
      if (subscribedTo.contains(channelUserId)) isSub = true;
      return isSub;
    } catch (e) {
      rethrow;
    }
  }

  // Search videos
  Future<List<VideoModel>> searchVideos(String query) async {
    try {
      // Note: For a real app, you would use Firebase Extensions or Cloud Functions
      // with Algolia or Elasticsearch for proper search functionality
      // This is a simple implementation that searches for videos with titles containing the query

      query = query.toLowerCase();

      QuerySnapshot snapshot =
          await _firestore
              .collection('videos')
              .orderBy('createdAt', descending: true)
              .get();

      List<VideoModel> results = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String title = data['title'].toString().toLowerCase();
        String description = data['description'].toString().toLowerCase();

        if (title.contains(query) || description.contains(query)) {
          results.add(VideoModel.fromJson(data));
        }
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }
}
