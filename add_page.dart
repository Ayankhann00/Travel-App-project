import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../services/database.dart';
import 'home.dart';

class AddPost extends StatefulWidget {
  final String? prefilledLocation;

  const AddPost({super.key, this.prefilledLocation});

  @override
  State<AddPost> createState() => _AddPostState();
}
class _AddPostState extends State<AddPost> {
  File? selectedImage;
  final picker = ImagePicker();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledLocation != null) {
      final parts = widget.prefilledLocation!.split(',');
      if (parts.length > 1) {
        placeController.text = parts[0].trim();
        cityController.text = parts[1].trim();
      } else {
        cityController.text = widget.prefilledLocation!;
      }
    }
  }

  Future pickImageFromGallery() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<String> uploadImageToFirebase(File imageFile, String postId) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("postImages")
          .child("$postId.jpg");

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> uploadPost() async {
    if (selectedImage == null ||
        descriptionController.text.isEmpty ||
        cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and pick an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Get username from Firestore
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final String username = userDoc.data()?['username'] ?? 'Anonymous';

      final String postId = const Uuid().v1();

      final String location =
          placeController.text.isNotEmpty
              ? "${placeController.text.trim()}, ${cityController.text.trim()}"
              : cityController.text.trim();

      final Map<String, dynamic> postMap = {
        "description": descriptionController.text.trim(),
        "location": location,
        "imageUrl": "placeholder",
        "timestamp": Timestamp.now(),
        "username": username,
        "userId": user.uid,
        "Like": [],
      };
      await DatabaseMethods().addPosts(postMap, postId);

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created! Uploading image...'),
          backgroundColor: Colors.green,
        ),
      );

      final imageUrl = await uploadImageToFirebase(selectedImage!, postId);

      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'imageUrl': imageUrl,
      });

      setState(() {
        descriptionController.clear();
        placeController.clear();
        cityController.clear();
        selectedImage = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              ),
        ),
        title: const Text(
          "Create Travel Post",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImageFromGallery,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                  image:
                      selectedImage != null
                          ? DecorationImage(
                            image: FileImage(selectedImage!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    selectedImage == null
                        ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Tap to add image",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    placeController,
                    "Place Name (Optional)",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(cityController, "City Name*")),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField(descriptionController, "Caption*"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : uploadPost,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
                backgroundColor: Colors.teal,
                elevation: 6,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                      : const Icon(Icons.upload, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 10),
            const Text(
              "Post",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
