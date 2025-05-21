import 'package:flutter/material.dart';
import 'package:movietube/services/auth_service.dart';
import 'package:movietube/screens/settings_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 6),
              child: FutureBuilder(
                future: auth.getUserData(auth.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('エラー: ${snapshot.error}'));
                  }
                  final userdata = snapshot.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(userdata.photoUrl),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userdata.username,
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              userdata.channelName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
            child: ListTile(
              leading: Icon(Icons.video_collection_outlined),
              title: Text('作成した動画'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
            child: ListTile(
              leading: Icon(Icons.home),
              title: Text('プロフィールを編集する'),
            ),
          ),
          GestureDetector(
            onTap: () {
              auth.signOut();
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: ListTile(
              leading: Icon(Icons.output_rounded),
              title: Text('ログアウト'),
            ),
          ),
        ],
      ),
    );
  }
}
