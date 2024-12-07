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
        "id": id as int,
        'scientific_name': scientificName as String,
        'common_name': commonName as String,
        'cycle': cycle as String,
        'watering': watering as String,
        'sunlight': sunlight as String,
      } in plantMaps)

      Plant(
        id: id,
        scientificName: scientificName,
        commonName: commonName,
        cycle: cycle,
        watering: watering,
        sunlight: sunlight
      )
    ];
  }

  Future<bool> isFavorite(Plant plant) async {
    final result = await db.query(
      'favorites',
      where: 'plant_id = ?',
      whereArgs: [plant.id],
    );

    return result.isNotEmpty;
  }

  Future<List<Plant>> getFavoritePlants() async {
    final List<Map<String, Object?>> results = await db.rawQuery('''
      SELECT p.id, p.scientific_name, p.common_name, p.cycle, p.watering, p.sunlight
      FROM favorites f
      INNER JOIN plantData p ON f.plant_id = p.id
    ''');

    return results.map((row) {
      return Plant(
        id: row['id'] as int,
        scientificName: row['scientific_name'] as String,
        commonName: row['common_name'] as String,
        cycle: row['cycle'] as String,
        watering: row['watering'] as String,
        sunlight: row['sunlight'] as String,
      );
    }).toList();
  }

  // Insert Queries
  Future<void> addToGarden(Plant plant) async {
    await db.insert(
      'favorites',
      {'plant_id': plant.id},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

  }

  // Drop Queries
  Future<void> removeFromGarden(Plant plant) async {
    await db.delete(
      'favorites',
      where: 'plant_id = ?',
      whereArgs: [plant.id],  
    );
  }

}