import 'package:house_plant/garden_page.dart';
import 'package:house_plant/plant.dart';
import 'package:house_plant/plant_page.dart';

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:house_plant/plant_repository.dart';
import 'package:house_plant/plant_search_delegate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path_utils;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart' show rootBundle;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Get the path to the documents directory on the device
  final docsDir = await getApplicationDocumentsDirectory();
  final dbPath = path_utils.join(docsDir.path, "plant_data.db");

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
        debugShowCheckedModeBanner: false,
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

  Future<void> addToGarden(Plant plant) async {
    repository.addToGarden(plant);
  }

  Future<List<Plant>> getFavoritePlants() async {
    return repository.getFavoritePlants();
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
  List<Plant> plantList = <Plant>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    if (_isLoading) { _getPlants(); }
  }

  Future<void> _getPlants() async {
    final repository = Provider.of<PlantRepository>(context, listen: false);
    var plants = await repository.getAllPlants();

    setState(() {
      plantList = plants;
      _isLoading = false;
    }); 
  }
  
  @override
  Widget build(BuildContext context) {    
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = PlantPage(plants: plantList,);
      case 1:
        page = const GardenPage();
      default:
        throw UnimplementedError('no widget for ${selectedIndex}');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("House Plant"),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => showSearch(
                  context: context,
                  delegate: PlantSearchDelegate(plants: plantList),
                )
              )
            ],
          ),
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
