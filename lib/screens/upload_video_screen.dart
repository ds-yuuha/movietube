import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movietube/services/database_service.dart';
import 'package:movietube/services/auth_service.dart';
import 'package:movietube/services/storage_service.dart';
import 'package:movietube/screens/home_screen.dart';
import 'package:movietube/models/user_model.dart';
import 'dart:io';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  File? _videoFile;
  File? _imageFile;
  bool _isUpload = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _authService = AuthService();
  final _storage = StorageService();
  final _database = DatabaseService();

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

  Future<void> _pickVideo() async {
    final StorageService storage = StorageService();
    final File? video = await storage.pickVideo();
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
    }
  }

  // Future<void> _compress() async {
  //   if (_videoFile == null) {
  //     return;
  //   }
  //   try {
  //     // await VideoCompress.setLogLevel(0);

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('step1')));
  //     final info = await VideoCompress.compressVideo(
  //       _videoFile!.path,
  //       quality: VideoQuality.Res1280x720Quality,
  //       deleteOrigin: false,
  //       includeAudio: true,
  //     );
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('step2')));
  //     setState(() {
  //       _videoFile = File(info!.path!);
  //     });
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  Future<void> _upload() async {
    final UserModel userdata = await _authService.getUserData(currentUser!.uid);
    if (_videoFile == null || _imageFile == null) return;
    if (_isUpload) return;
    setState(() {
      _isUpload = true;
    });

    try {
      Map<String, String> urlList = await _storage.uploadVideo(
        _videoFile!,
        _imageFile!,
      );
      try {
        _database.addVideo(
          videoUrl: urlList["videoUrl"]!,
          thumbnailUrl: urlList["thumbnailUrl"]!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          userId: currentUser!.uid,
          channelName: userdata.channelName,
          tags: ["test", "test"],
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('動画のアップロードが完了しました')));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('動画のアップロードに失敗しました: $e')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('動画のアップロードに失敗しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('動画のアップロード')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: _pickVideo, child: const Text('動画を選ぶ')),
          ElevatedButton(onPressed: _pickImage, child: Text('サムネイルを選ぶ')),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: '動画のタイトル'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: '概要欄'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(labelText: 'タグ'),
          ),
          const SizedBox(height: 32),

          if (_videoFile != null && _imageFile != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _upload, child: const Text('アップロード')),
          ],
          if (_isUpload) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
