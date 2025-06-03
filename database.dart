import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserDetails(
    Map<String, dynamic> userInfoMap,
    String id,
  ) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  // ✅ Fixed: Use lowercase "posts" to match AddPost screen
  Future<void> addPosts(Map<String, dynamic> postInfoMap, String id) async {
    await FirebaseFirestore.instance
        .collection("posts") // Changed from "Posts" to "posts"
        .doc(id)
        .set(postInfoMap);
  }

  // ✅ Fixed: Use lowercase "posts" and correct timestamp field
  Stream<QuerySnapshot> getPosts() {
    return FirebaseFirestore.instance
        .collection("posts") // Changed from "Posts" to "posts"
        .orderBy(
          "timestamp",
          descending: true,
        ) // Changed from "time" to "timestamp"
        .snapshots();
  }

  // ✅ Fixed: Use lowercase "posts"
  Future<void> addLike(String postId, String userId) async {
    await FirebaseFirestore.instance.collection("posts").doc(postId).update({
      "Like": FieldValue.arrayUnion([userId]),
    });
  }

  // ✅ Fixed: Use lowercase "posts"
  Future<void> removeLike(String postId, String userId) async {
    await FirebaseFirestore.instance.collection("posts").doc(postId).update({
      "Like": FieldValue.arrayRemove([userId]),
    });
  }

  // In your database.dart file
  Stream<QuerySnapshot> getPostsByLocation(String location) {
    try {
      // Temporary simplified query
      return FirebaseFirestore.instance
          .collection('posts')
          .where('location', isEqualTo: location)
          .snapshots();
    } catch (e) {
      // Handle error or return empty stream
      return const Stream.empty();
    }
  }

  Future<void> sendNotification(Map<String, dynamic> notificationInfo) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notificationInfo);
  }

  // Get notifications for a user
  Stream<QuerySnapshot> getNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('targetUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
