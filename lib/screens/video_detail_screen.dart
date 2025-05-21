import 'package:flutter/material.dart';
import 'package:movietube/widgets/comment_list_widget.dart';
import '../models/video_model.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:movietube/models/user_model.dart';
import 'package:movietube/screens/home_screen.dart';
import 'package:movietube/models/comment_model.dart';
import 'package:movietube/services/auth_service.dart';
import 'package:movietube/services/database_service.dart';

class VideoDetailScreen extends StatefulWidget {
  final VideoModel video;

  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  bool _showControls = true;
  late bool initialIsSub;
  int _sub = 0;
  int _comments = 0;
  int _like = 0;
  double _sliderValue = 0.0;
  String _screenMode = "default";
  final _auth = AuthService();
  final _database = DatabaseService();
  late Future<void> _initializeVideoPlayerFuture;
  late Future<List<CommentModel>> _futureComments;
  late Future<UserModel> _futureUser;
  late Future<bool> _futureIsSub;
  late Future<UserModel> _futureCurrentUser; // Future型のフィールドとしてクラスに定義しておく

  @override
  void initState() {
    super.initState();
    _futureComments = _database.getComments(widget.video.id);
    _futureUser = _auth.getUserData(widget.video.userId);
    _futureCurrentUser = _auth.getUserData(_auth.currentUser!.uid);
    _futureIsSub = _database.isSub(_auth.currentUser!.uid, widget.video.userId);
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // 初期化が完了したら定期的に再生位置を更新
      _controller.addListener(() {
        if (_controller.value.isPlaying) {
          setState(() {
            _sliderValue = _controller.value.position.inSeconds.toDouble();
          });
        }
      });
    });
    // ビデオを自動再生
    _controller.play().then((_) {
      setState(() {
        _isPlaying = true;
      });
    });

    // コントロールを自動的に隠すタイマー
    _resetControlsTimer();
  }

  void _resetControlsTimer() {
    setState(() {
      _showControls = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _showControls = true;
      } else {
        _controller.play();
        _isPlaying = true;
        _resetControlsTimer();
      }
    });
  }

  void _enterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  void getSub(String userId) async {
    UserModel userdata = await _auth.getUserData(userId);
    setState(() {
      _sub = userdata.subscribers.length;
    });
  }

  void getComment(String videoId) async {
    List<CommentModel> comments = await _database.getComments(videoId);
    setState(() {
      _comments = comments.length;
    });
  }

  void getLikes(String videoId) async {
    VideoModel video = await _database.getVideoById(videoId);
    setState(() {
      _like = video.likeCount;
    });
  }

  void _update() {
    setState(() {
      _futureComments = _database.getComments(widget.video.id);
    });
  }

  void isSubUpdate() {
    _futureIsSub = _database.isSub(_auth.currentUser!.uid, widget.video.userId);
  }

  void _state() {
    setState(() {
      _screenMode = "default";
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = DatabaseService();
    getSub(widget.video.userId);
    getComment(widget.video.id);
    getLikes(widget.video.id);

    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          _exitFullScreen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            // ビデオプレーヤー部分
            GestureDetector(
              onTap: () {
                _resetControlsTimer();
              },
              onDoubleTap: _togglePlayPause,
              child: Container(
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: _isFullScreen ? 16 / 9 : 16 / 9,
                  child: Stack(
                    children: [
                      FutureBuilder(
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Center(
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              ),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),

                      // ビデオコントロールオーバーレイ
                      if (_showControls)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // トップバー
                                if (!_isFullScreen)
                                  AppBar(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    leading: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    title: Text(
                                      widget.video.title,
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                // 中央の再生/一時停止ボタン
                                IconButton(
                                  icon: Icon(
                                    _isPlaying
                                        ? Icons.pause_circle_outline
                                        : Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  onPressed: _togglePlayPause,
                                ),

                                // 下部のコントロールバー
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _formatDuration(
                                              Duration(
                                                seconds: _sliderValue.toInt(),
                                              ),
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Expanded(
                                            child: Slider(
                                              value: _sliderValue,
                                              min: 0,
                                              max:
                                                  _controller
                                                      .value
                                                      .duration
                                                      .inSeconds
                                                      .toDouble(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _sliderValue = value;
                                                });
                                              },
                                              onChangeEnd: (value) {
                                                _controller.seekTo(
                                                  Duration(
                                                    seconds: value.toInt(),
                                                  ),
                                                );
                                                _resetControlsTimer();
                                              },
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(
                                              _controller.value.duration,
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              _isFullScreen
                                                  ? Icons.fullscreen_exit
                                                  : Icons.fullscreen,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              if (_isFullScreen) {
                                                _exitFullScreen();
                                              } else {
                                                _enterFullScreen();
                                              }
                                              _resetControlsTimer();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // フルスクリーンでない場合のみ詳細情報を表示
            if (!_isFullScreen)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_screenMode == "default")
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.video.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${widget.video.channelName} • ${widget.video.viewCount} 回視聴 • ${widget.video.createdAt}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      database.toggleLikeVideo(
                                        widget.video.id,
                                        _auth.currentUser!.uid,
                                      );
                                    },
                                    icon: _buildActionButton(
                                      Icons.thumb_up_outlined,
                                      _like.toString(),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      database.toggleDislikeVideo(
                                        widget.video.id,
                                        _auth.currentUser!.uid,
                                      );
                                    },
                                    child: _buildActionButton(
                                      Icons.thumb_down_outlined,
                                      '',
                                    ),
                                  ),
                                  _buildActionButton(
                                    Icons.share_outlined,
                                    '共有',
                                  ),
                                  _buildActionButton(
                                    Icons.download_outlined,
                                    'ダウンロード',
                                  ),
                                  _buildActionButton(
                                    Icons.library_add_outlined,
                                    '保存',
                                  ),
                                ],
                              ),
                              Divider(height: 32),
                              Row(
                                children: [
                                  FutureBuilder<UserModel>(
                                    future: _futureUser,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Text('エラー: ${snapshot.error}'),
                                        );
                                      }

                                      final userdata = snapshot.data!;
                                      return CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          userdata.photoUrl,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.video.channelName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'チャンネル登録者数: $_sub',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FutureBuilder(
                                    future: _futureIsSub,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Text('エラー: ${snapshot.error}'),
                                        );
                                      }

                                      final isSub = snapshot.data!;

                                      return ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            if (_auth.currentUser == null) {
                                              throw Exception('認証されていません');
                                            }
                                            final isSubscribe = await database
                                                .toggleSubscription(
                                                  _auth.currentUser!.uid,
                                                  widget.video.userId,
                                                );
                                            isSubUpdate();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              isSubscribe
                                                  ? SnackBar(
                                                    content: Text(
                                                      'このチャンネルを登録しました',
                                                    ),
                                                  )
                                                  : SnackBar(
                                                    content: Text(
                                                      'このチャンネルの登録を解除しました',
                                                    ),
                                                  ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'チャンネル登録に失敗しました: ${e.toString()}',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              isSub ? Colors.grey : Colors.red,
                                        ),
                                        child:
                                            isSub
                                                ? Text(
                                                  '登録済み',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                )
                                                : Text(
                                                  '登録',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _screenMode = "comment";
                            });
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'コメント $_comments',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      FutureBuilder(
                                        future: _futureCurrentUser,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }

                                          if (snapshot.hasError) {
                                            return Center(
                                              child: Text(
                                                'エラー: ${snapshot.error}',
                                              ),
                                            );
                                          }
                                          final userdata = snapshot.data!;
                                          return CircleAvatar(
                                            radius: 14,
                                            backgroundImage: NetworkImage(
                                              userdata.photoUrl,
                                            ),
                                          );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Text(
                                          'コメントする',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (_screenMode == "comment")
                    CommentListWidget(
                      video: widget.video,
                      comments: _futureComments,
                      updateFunc: _update,
                      stateFunc: _state,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
