import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bank_location.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bank_locations.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bank_locations(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT NOT NULL,
        bank_name TEXT,
        services TEXT,
        working_hours TEXT,
        phone_number TEXT
      )
    ''');

    // Insert sample data for Mauritius banks and ATMs
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final sampleData = [
      // Major Banks in Port Louis
      {
        'id': 1,
        'name': 'MCB Head Office',
        'type': 'bank',
        'latitude': -20.1609,
        'longitude': 57.5012,
        'address': 'Sir William Newton Street, Port Louis',
        'bank_name': 'Mauritius Commercial Bank',
        'services': 'ATM,Counter Service,Foreign Exchange,Loans',
        'working_hours': '09:00-15:00 Mon-Thu, 09:00-17:00 Fri',
        'phone_number': '+230 202 5000'
      },
      {
        'id': 2,
        'name': 'State Bank of Mauritius',
        'type': 'bank',
        'latitude': -20.1615,
        'longitude': 57.5021,
        'address': 'State Bank Tower, Bank Street, Port Louis',
        'bank_name': 'State Bank of Mauritius',
        'services': 'ATM,Counter Service,Business Banking,Personal Banking',
        'working_hours': '09:00-15:00 Mon-Thu, 09:00-17:00 Fri',
        'phone_number': '+230 202 1111'
      },
      // ATMs in Port Louis
      {
        'id': 3,
        'name': 'MCB ATM - Caudan Waterfront',
        'type': 'atm',
        'latitude': -20.1595,
        'longitude': 57.4996,
        'address': 'Caudan Waterfront, Port Louis',
        'bank_name': 'MCB',
        'services': 'Cash Withdrawal,Balance Inquiry,Mini Statement',
        'working_hours': '24/7',
      },
      {
        'id': 4,
        'name': 'SBM ATM - Immigration Square',
        'type': 'atm',
        'latitude': -20.1603,
        'longitude': 57.5008,
        'address': 'Immigration Square, Port Louis',
        'bank_name': 'SBM Bank',
        'services': 'Cash Withdrawal,Balance Inquiry,Top Up',
        'working_hours': '24/7',
      },
      // Banks in other regions
      {
        'id': 5,
        'name': 'MCB Curepipe Branch',
        'type': 'bank',
        'latitude': -20.3162,
        'longitude': 57.5208,
        'address': 'Royal Road, Curepipe',
        'bank_name': 'Mauritius Commercial Bank',
        'services': 'ATM,Counter Service,Loans,Credit Cards',
        'working_hours': '09:00-15:00 Mon-Thu, 09:00-17:00 Fri',
        'phone_number': '+230 674 1234'
      },
      {
        'id': 6,
        'name': 'ABSA Bank - Quatre Bornes',
        'type': 'bank',
        'latitude': -20.2658,
        'longitude': 57.4789,
        'address': 'St Jean Road, Quatre Bornes',
        'bank_name': 'ABSA Bank Mauritius',
        'services': 'ATM,Counter Service,Business Banking',
        'working_hours': '09:30-14:30 Mon-Thu, 09:30-16:30 Fri',
        'phone_number': '+230 401 5000'
      },
      // More ATMs across Mauritius
      {
        'id': 7,
        'name': 'MCB ATM - Grand Baie',
        'type': 'atm',
        'latitude': -20.0156,
        'longitude': 57.5816,
        'address': 'Royal Road, Grand Baie',
        'bank_name': 'MCB',
        'services': 'Cash Withdrawal,Balance Inquiry,Mini Statement',
        'working_hours': '24/7',
      },
      {
        'id': 8,
        'name': 'SBM ATM - Bagatelle Mall',
        'type': 'atm',
        'latitude': -20.2396,
        'longitude': 57.4934,
        'address': 'Bagatelle Mall, Moka',
        'bank_name': 'SBM Bank',
        'services': 'Cash Withdrawal,Balance Inquiry,Top Up,Bill Payment',
        'working_hours': '24/7',
      },
      {
        'id': 9,
        'name': 'MCB Mahebourg Branch',
        'type': 'bank',
        'latitude': -20.4081,
        'longitude': 57.7000,
        'address': 'Royal Road, Mahebourg',
        'bank_name': 'Mauritius Commercial Bank',
        'services': 'ATM,Counter Service,Foreign Exchange',
        'working_hours': '09:00-15:00 Mon-Thu, 09:00-17:00 Fri',
        'phone_number': '+230 631 9000'
      },
      {
        'id': 10,
        'name': 'ABSA ATM - Phoenix Mall',
        'type': 'atm',
        'latitude': -20.2844,
        'longitude': 57.4969,
        'address': 'Phoenix Mall, Vacoas-Phoenix',
        'bank_name': 'ABSA',
        'services': 'Cash Withdrawal,Balance Inquiry,Pin Change',
        'working_hours': '24/7',
      }
    ];

    for (var data in sampleData) {
      await db.insert('bank_locations', data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<BankLocation>> getAllLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bank_locations');
    return List.generate(maps.length, (i) {
      final map = maps[i];
      return BankLocation(
        id: map['id'],
        name: map['name'],
        type: map['type'],
        latitude: map['latitude'],
        longitude: map['longitude'],
        address: map['address'],
        bankName: map['bank_name'],
        services: map['services']?.split(','),
        workingHours: map['working_hours'],
        phoneNumber: map['phone_number'],
      );
    });
  }

  Future<List<BankLocation>> getNearbyLocations(
      double userLat,
      double userLng,
      double radiusKm
      ) async {
    final allLocations = await getAllLocations();
    return allLocations.where((location) {
      final distance = location.distanceFrom(userLat, userLng);
      return distance <= (radiusKm * 1000); // Convert km to meters
    }).toList()
      ..sort((a, b) => a.distanceFrom(userLat, userLng)
          .compareTo(b.distanceFrom(userLat, userLng)));
  }
}