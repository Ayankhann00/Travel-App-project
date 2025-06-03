import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/services/database.dart';
import 'package:travel_app/services/shared_pref.dart';
import 'package:travel_app/pages/add_page.dart';
import 'package:travel_app/pages/comment.dart';
import 'package:travel_app/pages/top_places.dart';
import 'package:travel_app/pages/notifications.dart'; // Create this file
import 'package:travel_app/pages/signup.dart'; // Your sign-up screen

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? postStream;
  String? currentUserId;
  final Color primaryGreen = const Color(0xFF4CAF50);
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    super.initState();
    postStream = _databaseMethods.getPosts();
    loadCurrentUserId();
  }

  Future<void> loadCurrentUserId() async {
    String? userId = await SharedPrefHelper().getUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to sign-up screen and clear the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Signup()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  void toggleLike(String postId, List<dynamic> likes) async {
    if (currentUserId == null) return;

    final isLiked = likes.contains(currentUserId);

    try {
      if (isLiked) {
        await _databaseMethods.removeLike(postId, currentUserId!);
      } else {
        await _databaseMethods.addLike(postId, currentUserId!);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update like: $e')));
    }
  }

  Widget allPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: postStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error loading posts: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No posts available"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final ds = docs[index];
            final data = ds.data() as Map<String, dynamic>? ?? {};
            final postId = ds.id;

            String username = data["username"] ?? "Anonymous";
            String imageUrl = data["imageUrl"] ?? "";
            String location = data["location"] ?? "Unknown location";
            String description = data["description"] ?? "";
            List<dynamic> likes = data["Like"] ?? [];

            final isLiked =
                currentUserId != null && likes.contains(currentUserId);

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 10,
              ),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              "images/me.jpg",
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                            child: Text(
                              username,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            imageUrl,
                            width: MediaQuery.of(context).size.width - 60,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => toggleLike(postId, likes),
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.black54,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${likes.length}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => Comment(postId: postId),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Comment",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  "images/background.jpeg",
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TopPlaces(),
                            ),
                          );
                        },
                        child: Material(
                          borderRadius: BorderRadius.circular(25),
                          elevation: 3.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.explore_rounded,
                                color: Colors.deepPurple,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddPost(),
                                ),
                              );
                            },
                            child: Material(
                              borderRadius: BorderRadius.circular(25),
                              elevation: 3.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Notifications Icon
                          Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(25),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const NotificationsScreen(),
                                    ),
                                  );
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications,
                                    color: Colors.black54,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Profile Icon with Sign Out
                          Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(25),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PopupMenuButton<String>(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.black54,
                                    size: 30,
                                  ),
                                ),
                                onSelected: (value) {
                                  if (value == 'logout') {
                                    _signOut();
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem<String>(
                                      value: 'logout',
                                      child: Text('Sign Out'),
                                    ),
                                  ];
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                "Travel app",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 10, right: 20),
              child: Text(
                "Explore the beautiful places and share your memories",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 40),
            allPosts(),
          ],
        ),
      ),
    );
  }
}
