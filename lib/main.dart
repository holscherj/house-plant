import 'plant.dart';

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:house_plant/plant_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart' show rootBundle;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Get the path to the documents directory on the device
  final docsDir = await getApplicationDocumentsDirectory();
  final dbPath = join(docsDir.path, "plant_data.db");

  // Check if the database already exists
  final dbExists = await File(dbPath).exists();
  if (!dbExists) {
    // Copy from assets to the documents directory
    final data = await rootBundle.load('assets/database/plant_data.db');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);
  }

  // Open the database from the documents directory
  final database = await openDatabase(
    dbPath, 
    version: 2,
    onUpgrade: (database, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await database.execute('''
          CREATE TABLE IF NOT EXISTS favorites (
            id INTEGER PRIMARY KEY,
            plant_id TEXT NOT NULL,
            FOREIGN KEY(plant_id) REFERENCES plantData(id)
          )
        ''');
      }
    }
    );

  final plantRepository = PlantRepository(database);
  runApp(
    Provider<PlantRepository>.value(
      value: plantRepository,
      child: const MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<PlantRepository>(context, listen: false);

    return ChangeNotifierProvider(
      create: (context) => MyAppState(repository),
      child: MaterialApp(
        title: "House Plant",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final PlantRepository repository;
  MyAppState(this.repository);

  Future<List<Plant>> getPlants() async {
    return repository.getAllPlants();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of the application.

  // This class is the configuration for the state. It holds the values provided by 
  // the parent (in this case the App widget) and used by the build method of the State.
  // Fields in a Widget subclass are always marked "final".

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {    
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const PlantPage();
      case 1:
        page = const GardenPage();
      default:
        throw UnimplementedError('no widget for ${selectedIndex}');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.local_florist),
                      label: Text("My Garden"),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              )
            ],
          )
        );
      }
    );
  }
}

class PlantPage extends StatelessWidget {
  const PlantPage({super.key,});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Plants:",),
        Expanded(
          child: FutureBuilder(
            future: appState.getPlants(),
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
                  return ListTile(
                    title: Text(plant.commonName),
                    subtitle: Text(plant.scientificName),
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

class GardenPage extends StatelessWidget {
  const GardenPage ({super.key,});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Favorited Plants Coming Soon..."),
        ],
      ),
    );
  }
}