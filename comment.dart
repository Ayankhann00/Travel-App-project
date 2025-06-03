import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/pages/home.dart';
import 'package:travel_app/services/shared_pref.dart';

class Comment extends StatefulWidget {
  final String postId;
  const Comment({super.key, required this.postId});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final CollectionReference _commentsRef;
  final Color primaryGreen = const Color(0xFF4CAF50);
  String? currentUserId;
  Map<String, bool> _commentLikes = {}; // Track which comments are liked

  @override
  void initState() {
    super.initState();
    _commentsRef = _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('comments');
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    String? userId = await SharedPrefHelper().getUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _commentsRef.add({
        'text': _commentController.text,
        'userId': user.uid,
        'userName': 'Ayan Khan', // Consider getting from user profile
        'userImage': 'images/me.jpg', // Consider getting from user profile
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [], // Initialize with empty likes array
      });
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
    }
  }

  Future<void> _toggleCommentLike(String commentId, List<dynamic> likes) async {
    if (currentUserId == null) return;

    final isLiked = likes.contains(currentUserId);

    try {
      await _commentsRef.doc(commentId).update({
        'likes':
            isLiked
                ? FieldValue.arrayRemove([currentUserId])
                : FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update like: $e')));
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';

    final now = DateTime.now();
    final commentTime = timestamp.toDate();
    final difference = now.difference(commentTime);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryGreen),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              ),
        ),
        title: const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.green.shade50,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _commentsRef
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No comments yet. Be the first to comment!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final commentId = doc.id;
                    final likes = List.from(data['likes'] ?? []);
                    final isLiked =
                        currentUserId != null && likes.contains(currentUserId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              data['userImage'] ?? 'images/me.jpg',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['userName'] ?? 'Ayan Khan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['text'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTimestamp(
                                    data['timestamp'] as Timestamp?,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed:
                                    () => _toggleCommentLike(commentId, likes),
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : primaryGreen,
                                ),
                              ),
                              Text(
                                likes.length.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: const AssetImage('images/me.jpg'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addComment,
                  icon: Icon(Icons.send, color: primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
