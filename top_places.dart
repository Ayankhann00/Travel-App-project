import 'package:flutter/material.dart';
import 'place_detail.dart'; // Make sure to create this file

class TopPlaces extends StatefulWidget {
  const TopPlaces({super.key});

  @override
  State<TopPlaces> createState() => _TopPlacesState();
}

class _TopPlacesState extends State<TopPlaces> {
  // Map of places with their details
  final List<Map<String, dynamic>> places = [
    {
      "name": "New York City",
      "image": "images/nyc.jpg",
      "description": "The Big Apple with iconic skyscrapers and Central Park",
    },
    {
      "name": "London",
      "image": "images/london.jpg",
      "description": "Historic capital with royal palaces and the Thames",
    },
    {
      "name": "Paris",
      "image": "images/paris.jpg",
      "description": "City of Light featuring the Eiffel Tower and Louvre",
    },
    {
      "name": "Dubai",
      "image": "images/dubai.jpg",
      "description": "Modern metropolis with futuristic architecture",
    },
    {
      "name": "Hunza",
      "image": "images/hunza.jpg",
      "description": "Mountain paradise in Pakistan with stunning valleys",
    },
    {
      "name": "Bangkok",
      "image": "images/bangkok.jpg",
      "description": "Vibrant city known for temples and street food",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Material(
                      borderRadius: BorderRadius.circular(30.0),
                      elevation: 3.0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 5),
                  const Text(
                    "Top Places",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            Expanded(
              child: Material(
                elevation: 3.0,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                    top: 30.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: 20.0,
                          crossAxisSpacing: 10.0,
                        ),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      return _buildPlaceCard(
                        places[index]["image"],
                        places[index]["name"],
                        places[index]["description"],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update the _buildPlaceCard method to constrain the height properly
  Widget _buildPlaceCard(String imagePath, String title, String description) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PlaceDetailPage(
                    placeName: title,
                    imagePath: imagePath,
                    description: description,
                  ),
            ),
          );
        },
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 170, // Constrained width
            height: 230, // Constrained height to prevent overflow
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0, // Slightly smaller font
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.0, // Smaller font
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
    );
  }
}
