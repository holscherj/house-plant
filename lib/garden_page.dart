import 'package:flutter/material.dart';
import 'package:house_plant/main.dart';
import 'package:house_plant/plant.dart';
import 'package:house_plant/plant_repository.dart';
import 'package:provider/provider.dart';

class GardenPage extends StatelessWidget {
  const GardenPage ({super.key,});

  void showPlantModal(BuildContext context, Plant plant, PlantRepository repository) async {
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
                onPressed: () => Navigator.pop(context),
                label: const Text("Close"),
                icon: const Icon(Icons.close),
              )
            ],
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final repository = Provider.of<PlantRepository>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Here are the plants in your garden:"),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: appState.getFavoritePlants(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"),);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No plants found"),);
              }
              
              final plants = snapshot.data!;
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