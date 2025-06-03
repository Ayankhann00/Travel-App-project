import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/services/database.dart';
import 'package:travel_app/pages/add_page.dart';

class PlaceDetailPage extends StatefulWidget {
  final String placeName;
  final String imagePath;
  final String description;

  const PlaceDetailPage({
    super.key,
    required this.placeName,
    required this.imagePath,
    required this.description,
  });

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  late Stream<QuerySnapshot> _postStream;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _postStream = _databaseMethods.getPostsByLocation(widget.placeName);
  }

  void _navigateToAddPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPost(prefilledLocation: widget.placeName),
      ),
    );
  }

  void _retryLoadingPosts() {
    setState(() {
      _postStream = _databaseMethods.getPostsByLocation(widget.placeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(widget.imagePath, fit: BoxFit.cover),
              title: Text(
                widget.placeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
            ),
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Recent Posts",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(thickness: 2),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _postStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          "Database is updating...",
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                        const SizedBox(height: 10),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        if (snapshot.error.toString().contains('index'))
                          const Text(
                            "Please wait while we set up the database",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _retryLoadingPosts,
                          child: const Text("Try Again"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          "No posts yet for this location",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _navigateToAddPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            "Be the first to share!",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ds = docs[index];
                  final data = ds.data() as Map<String, dynamic>;
                  final postId = ds.id;

                  String username = data["username"] ?? "Anonymous";
                  String imageUrl = data["imageUrl"] ?? "";
                  String location = data["location"] ?? "Unknown location";
                  String description = data["description"] ?? "";

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            if (imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            progress.expectedTotalBytes != null
                                                ? progress
                                                        .cumulativeBytesLoaded /
                                                    progress.expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[200],
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
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  location,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: docs.length),
              );
            },
          ),
        ],
      ),
    );
  }
}
