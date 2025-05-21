import '../models/user_model.dart';
import '../widgets/video_card.dart';
import '../models/video_model.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final authService = AuthService();
  final databaseService = DatabaseService();
  late Future<UserModel> _futureUser;
  String _UserId = ""; // Future型のフィールドとしてクラスに定義しておく
  bool _isSelected = false;
  @override
  void initState() {
    super.initState();
    _futureUser = authService.getUserData(
      authService.currentUser!.uid,
    ); // 非同期処理をフィールドに入れる
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel>(
        future: _futureUser,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return Center(child: Text('エラー: ${userSnapshot.error}'));
          }

          final user = userSnapshot.data!;

          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80,
                  child: FutureBuilder<List<UserModel>>(
                    future: databaseService.getSubscribedChannel(
                      user.subscribedTo,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('エラー: ${snapshot.error}'));
                      }
                      final channels = snapshot.data!;
                      if (channels.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('登録しているチャンネルがありません'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: channels.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              IconButton(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 8,
                                ),
                                icon: CircleAvatar(
                                  radius: 26,
                                  backgroundImage: NetworkImage(
                                    channels[index].photoUrl,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _UserId = channels[index].id;
                                    _isSelected = true;
                                  });
                                },
                              ),
                              Text(
                                channels[index].channelName.length <= 5
                                    ? channels[index].channelName
                                    : '${channels[index].channelName.substring(0, 4)}…',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 2),
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        Chip(
                          label: const Text('All'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Chip(label: Text('Music')),
                        const SizedBox(width: 8),
                        const Chip(label: Text('Gaming')),
                        const SizedBox(width: 8),
                        const Chip(label: Text('Live')),
                        const SizedBox(width: 8),
                        const Chip(label: Text('News')),
                        const SizedBox(width: 8),
                        const Chip(label: Text('Comedy')),
                      ],
                    ),
                  ),
                ),
                subscribedList(_isSelected, user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget subscribedList(bool isSelected, UserModel user) {
    final databaseService = DatabaseService();

    if (isSelected == false) {
      return Flexible(
        child: FutureBuilder<List<VideoModel>>(
          future: databaseService.getSubscriptionVideos(user.subscribedTo),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('エラー: ${snapshot.error}'));
            }

            final videos = snapshot.data ?? [];

            if (videos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('登録したチャンネルには動画が投稿されていません'),
              );
            }

            // return Text(_UserId);
            return ListView.builder(
              itemCount: videos.length > 5 ? 5 : videos.length,
              itemBuilder: (context, index) {
                return VideoCard(video: videos[index]);
              },
            );
          },
        ),
      );
    } else {
      return Flexible(
        child: FutureBuilder<List<VideoModel>>(
          future: databaseService.getVideosByUser(_UserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('エラー: ${snapshot.error}'));
            }

            final Videos = snapshot.data ?? [];

            if (Videos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('登録したチャンネルには動画が投稿されていません'),
              );
            }

            return ListView.builder(
              itemCount: Videos.length > 5 ? 5 : Videos.length,
              itemBuilder: (context, index) {
                return VideoCard(video: Videos[index]);
              },
            );
          },
        ),
      );
    }
  }
}
