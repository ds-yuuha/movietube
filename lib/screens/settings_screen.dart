import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movietube/services/auth_service.dart';
import 'package:movietube/services/storage_service.dart';
import 'package:movietube/screens/home_screen.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _channelNameController = TextEditingController();
  File? _imageFile;
  bool _isUpload = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  User? get currentUser => _auth.currentUser;

  Future<void> _pickImage() async {
    final StorageService storage = StorageService();
    final File? image = await storage.pickImage();
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _upload() async {
    if (_isUpload) return;
    setState(() {
      _isUpload = true;
    });

    try {
      if (_imageFile != null) {
        final String profUrl = await _storage.uploadProfileImage(_imageFile!);
        _authService.updateProfile(
          username: _usernameController.text.trim(),
          channelName: _channelNameController.text.trim(),
          photoUrl: profUrl,
        );
      } else {
        _authService.updateProfile(
          username: _usernameController.text.trim(),
          channelName: _channelNameController.text.trim(),
        );
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('プロフィールを変更しました')));
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('プロフィールの変更に失敗しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィールの編集')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: _pickImage, child: Text('プロフィール写真を選ぶ')),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'ユーザー名'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _channelNameController,
            decoration: const InputDecoration(labelText: 'チャンネル名'),
          ),

          const SizedBox(height: 20),
          ElevatedButton(onPressed: _upload, child: const Text('プロフィールを更新する')),
          if (_isUpload) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
