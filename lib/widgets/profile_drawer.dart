import 'package:flutter/material.dart';
import 'package:movietube/services/auth_service.dart';
import 'package:movietube/screens/settings_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.redAccent),
            child: Text(
              'アカウント',
              style: TextStyle(color: Colors.white, fontSize: 24),
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
