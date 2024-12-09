import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'plant.dart';
import 'plant_repository.dart';

class PlantPage extends StatelessWidget {
  const PlantPage ({
    required this.plants,
    super.key
  });

  final List<Plant> plants;

  // method for displaying the modal for each card
  // and providing it with favorited state
  void showPlantModal(BuildContext context, Plant plant, PlantRepository repository) async {
    bool isFav = await repository.isFavorite(plant);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to allow changing icon on setState
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Center(child: Text(plant.commonName)),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(16.0),
              child: Text("Scientific: ${plant.scientificName}\nCycle: ${plant.cycle}\nWatering Frequency: ${plant.watering}\nSunlight Requirements: ${plant.sunlight}"),
            ),
            actions: [
              ElevatedButton.icon(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                label: Text(isFav ? "Remove from Garden" : "Add to Garden"),
                onPressed: () async {
                  if (isFav) {
                    // Remove from favorites
                    await repository.removeFromGarden(plant);
                    setState(() {
                      isFav = false;
                    });
                  } else {
                    // Add to favorites
                    await repository.addToGarden(plant);
                    setState(() {
                      isFav = true;
                    });
                  }
                },
              )
            ],
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<PlantRepository>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FutureBuilder(
            future: repository.getAllPlants(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"),);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No plants found"),);
              }
              
              return ListView.builder(
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 128, vertical: 8),
                    child: ListTile(
                      title: Text(plant.commonName),
                      subtitle: Text(plant.scientificName),
                      onTap: () {
                        showPlantModal(context, plant, repository);
                      },
                    ),
                  );
                },
              ); 
            }
          ),
        ),
      ],
    );
  }
}