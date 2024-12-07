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
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Plants:"),
            ElevatedButton(
              onPressed: () async {
                final plants = await appState.getPlants();
                // ignore: avoid_print
                print(plants);
              },
              child: const Text("Print"),
            ),
          ],
        ),
      ),
    );
  }
}