import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    BuildContext? context;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(
          context!,
        ).showSnackBar(SnackBar(content: Text('そのメールアドレスは登録されていません')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(
          context!,
        ).showSnackBar(SnackBar(content: Text('パスワードが間違っています')));
      }
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> register(
    String email,
    String password,
    String username,
    String channelName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create a user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'username': username,
        'email': email,
        'photoUrl': '',
        'channelName': channelName,
        'subscribers': [],
        'subscribedTo': [],
        'createdAt': Timestamp.now(),
      });

      // Create a channel document
      await _firestore
          .collection('channels')
          .doc(userCredential.user!.uid)
          .set({
            'id': userCredential.user!.uid,
            'userId': userCredential.user!.uid,
            'name': channelName,
            'description': '',
            'bannerUrl': '',
            'avatarUrl': '',
            'subscriberCount': 0,
            'videoCount': 0,
            'totalViews': 0,
          });

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Get user data
  Future<UserModel> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String username,
    required String channelName,
    String? photoUrl,
  }) async {
    try {
      if (currentUser == null) throw Exception('認証されていません');

      Map<String, dynamic> userData = {
        'username': username,
        'channelName': channelName,
      };

      if (photoUrl != null) {
        userData['photoUrl'] = photoUrl;
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(userData);

      // Update channel name as well
      await _firestore.collection('channels').doc(currentUser!.uid).update({
        'name': channelName,
      });

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
