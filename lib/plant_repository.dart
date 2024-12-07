import 'package:sqflite/sqflite.dart';
import 'plant.dart';

class PlantRepository {
  final Database db;

  PlantRepository(this.db);

  // Select Queries
  Future<List<Plant>> getAllPlants() async {
    final List<Map<String, Object?>> plantMaps = await db.query('plantData');
    return [
      for (final {
        'scientific_name': scientificName as String,
        'common_name': commonName as String,
        'cycle': cycle as String,
        'watering': watering as String,
        'sunlight': sunlight as String,
      } in plantMaps)

      Plant(
        scientificName: scientificName,
        commonName: commonName,
        cycle: cycle,
        watering: watering,
        sunlight: sunlight
      )
    ];
  }

  // Insert Queries
  // Future<void> addToGarden(Plant plant) async {
  
  // }
}