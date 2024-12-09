import 'package:flutter/material.dart';
import 'package:house_plant/plant.dart';
import 'package:house_plant/plant_page.dart';

class PlantSearchDelegate extends SearchDelegate {
  PlantSearchDelegate({required this.plants});

  final List<Plant> plants;
  List<Plant> results = <Plant>[];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query.isEmpty ? close(context, null) : query = '',
    )];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return results.isEmpty 
    ? const Center(
        child: Text("No Results", style: TextStyle(fontSize: 24),),
      )
    : PlantPage(plants: results,);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    results = plants.where((Plant plant) {
      final String commonName = plant.commonName.toLowerCase();
      final String scientificName = plant.scientificName.toLowerCase();
      final String input = query.toLowerCase();

      return commonName.contains(input) || scientificName.contains(input);
    }).toList();

    return results.isEmpty
      ? const Center (
          child: Text("No Results", style: TextStyle(fontSize: 24)),
        )
      : PlantPage(plants: results);
  }
}