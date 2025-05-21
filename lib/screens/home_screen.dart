import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/video_model.dart';
import '../widgets/video_card.dart';
import '../widgets/profile_drawer.dart';
import 'trending_screen.dart';
import 'subscriptions_screen.dart';
import 'mypage_screen.dart';
import 'search_screen.dart';
import 'upload_video_screen.dart';
import 'package:movietube/models/user_model.dart';
import 'package:movietube/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _screens = [
    const HomeTab(),
    const TrendingScreen(),
    const SizedBox.shrink(), // Upload placeholder
    const SubscriptionsScreen(),
    const LibraryScreen(),
  ];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final authService = AuthService();
  late Future<UserModel> _user;

  @override
  void initState() {
    super.initState();
    _user = authService.getUserData(authService.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          child: Image.asset('assets/youtube_logo.png', height: 24),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.cast), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      endDrawer: const ProfileDrawer(),
      body:
          _selectedIndex == 2
              ? const SizedBox.shrink() // This will be handled by onTap
              : _screens[_selectedIndex],
      bottomNavigationBar: FutureBuilder(
        future: _user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          }

          final userdata = snapshot.data!;
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 2) {
                // Handle upload button
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadVideoScreen(),
                  ),
                );
              } else {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Trending',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(Icons.add_circle_outline, size: 38),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.subscriptions_outlined),
                activeIcon: Icon(Icons.subscriptions),
                label: 'Subscriptions',
              ),
              BottomNavigationBarItem(
                icon: CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(userdata.photoUrl),
                ),
                activeIcon: CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(userdata.photoUrl),
                ),
                label: 'MyPage',
              ),
            ],
          );
        },
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories chips
          SizedBox(
            height: 50,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                Chip(
                  label: const Text('All'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
          // Recent videos section
          FutureBuilder<List<VideoModel>>(
            future: _databaseService.getRecentVideos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('エラー: ${snapshot.error}'));
              }

              final videos = snapshot.data ?? [];

              if (videos.isEmpty) {
                return const Center(child: Text('動画が利用できません'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return VideoCard(video: videos[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
