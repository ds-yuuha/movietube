import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload video file
  Future<Map<String, String>> uploadVideo(
    File videoFile,
    File imageFile,
  ) async {
    try {
      String videoId = _uuid.v4();
      String videoFileName = '$videoId.mp4';

      // Upload video
      TaskSnapshot videoSnapshot = await _storage
          .ref('videos/$videoFileName')
          .putFile(videoFile);

      // Upload thumbnail
      TaskSnapshot thumbnailSnapshot = await _storage
          .ref('thumbnail/${videoId}_thumbnail.png')
          .putFile(imageFile);

      // Get download URLs
      String videoUrl = await videoSnapshot.ref.getDownloadURL();
      String thumbnailUrl = await thumbnailSnapshot.ref.getDownloadURL();

      return {'videoUrl': videoUrl, 'thumbnailUrl': thumbnailUrl};
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      String fileName = _uuid.v4() + path.extension(imageFile.path);

      TaskSnapshot snapshot = await _storage
          .ref('profile_images/$fileName')
          .putFile(imageFile);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload channel banner
  Future<String> uploadChannelBanner(File imageFile) async {
    try {
      String fileName = _uuid.v4() + path.extension(imageFile.path);

      TaskSnapshot snapshot = await _storage
          .ref('channel_banners/$fileName')
          .putFile(imageFile);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Pick video from gallery
  Future<File?> pickVideo() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Pick image from gallery
  Future<File?> pickImage() async {
    const int width = 600;
    final int height = (600 / 16 * 9).toInt();
    const int quality = 80;
    BuildContext? context;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        img.Image image = img.decodeImage(await imageFile.readAsBytes())!;
        final imageHeight = image.height;
        final imageWidth = image.width;
        final croppedHeight = (imageWidth * 9 / 16).toInt();
        final startY = ((imageHeight - croppedHeight) / 2).toInt();
        img.Image croppedImage = img.copyCrop(
          image,
          x: 0,
          y: startY,
          width: imageWidth,
          height: (imageWidth / 16 * 9).toInt(),
        );
        img.Image resizedImage = img.copyResize(
          croppedImage,
          width: width,
          height: height,
        );
        String tempPath = (await getTemporaryDirectory()).path;
        File compressedImageFile = File('$tempPath/compressed_image.jpg');
        compressedImageFile.writeAsBytesSync(
          img.encodeJpg(resizedImage, quality: quality),
        );
        return compressedImageFile;
      } else {
        ScaffoldMessenger.of(
          context!,
        ).showSnackBar(SnackBar(content: Text('画像の圧縮に失敗しました')));
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
