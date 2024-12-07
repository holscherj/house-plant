/// This class defines the data model for a Plant object
/// 
/// Used to store data from the plant database in a singular
/// object.
class Plant {
  final String scientificName;
  final String commonName;
  final String cycle;
  final String watering;
  final String sunlight;

  const Plant({
    required this.scientificName,
    required this.commonName,
    required this.cycle,
    required this.watering,
    required this.sunlight,
  });

  @override
  String toString() {
    return 'Plant(scientificName: $scientificName, commonName: $commonName, cycle: $cycle, watering: $watering, sunlight: $sunlight)';
  }
}