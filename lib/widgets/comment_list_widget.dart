import 'package:flutter/material.dart';
import 'package:movietube/models/video_model.dart';
import 'package:movietube/models/comment_model.dart';
import 'package:movietube/services/auth_service.dart';
import 'package:movietube/services/database_service.dart';
import 'package:movietube/widgets/comment_widget.dart';

class CommentListWidget extends StatefulWidget {
  final VideoModel video;
  final Future<List<CommentModel>> comments;
  final Function updateFunc;
  final Function stateFunc;

  const CommentListWidget({
    super.key,
    required this.video,
    required this.comments,
    required this.updateFunc,
    required this.stateFunc,
  });

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  bool _commentSubmitted = false;
  final _auth = AuthService();
  final _database = DatabaseService();
  final TextEditingController _commentController = TextEditingController();
  String _screenType = "comment";

  void _comment() async {
    try {
      if (_commentSubmitted) return;
      setState(() {
        _commentSubmitted = true;
      });
      await _database.addComment(
        widget.video.id,
        _auth.currentUser!.uid,
        _commentController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('コメントを送信しました')));
      setState(() {
        _commentSubmitted = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('コメントの送信に失敗しました')));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_screenType == "comment") {
      return Column(
        children: [
          SizedBox(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Row(
                children: [
                  Text("コメント"),
                  IconButton(
                    onPressed: () => widget.stateFunc(),
                    icon: Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              FutureBuilder<List<CommentModel>>(
                future: widget.comments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('エラー: ${snapshot.error}'));
                  }

                  final comments = snapshot.data ?? [];

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return CommentWidget(comment: comments[index]);
                    },
                  );
                },
              ),

              Positioned(
                bottom: 0,
                left: 16,
                height: 80,
                child: Row(
                  children: [
                    Card(
                      child: SizedBox(
                        width: 280,
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(labelText: 'コメント'),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          _comment();
                          widget.updateFunc();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('コメントの更新に失敗しました')),
                          );
                        }
                      },
                      child: const Text('送信'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return SizedBox(height: 100);
    }
  }
}
