import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/video_model.dart';
import '../widgets/video_card.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      body: FutureBuilder<List<VideoModel>>(
        future: databaseService.getTrendingVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          }

          final videos = snapshot.data ?? [];

          if (videos.isEmpty) {
            return const Center(child: Text('トレンドの動画がありません'));
          }

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return VideoCard(video: videos[index]);
            },
          );
        },
      ),
    );
  }
}
