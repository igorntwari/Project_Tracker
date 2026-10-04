import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Singleton pattern so we only have one instance of the database helper
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use the path package to construct the correct path across platforms
    String path = join(await getDatabasesPath(), 'project_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Creates the database tables and populates initial dummy data
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        initials TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        assignedToId INTEGER,
        dueDate TEXT,
        priority TEXT,
        status TEXT,
        notes TEXT,
        FOREIGN KEY(assignedToId) REFERENCES users(id)
      )
    ''');

    // Seed dummy data on initial creation so the app isn't empty
    await _seedDummyData(db);
  }

  Future<void> _seedDummyData(Database db) async {
    // Insert dummy users matching the wireframes
    List<User> dummyUsers = [
      User(name: 'John Doe', role: 'Project Manager', initials: 'JD'),
      User(name: 'Sarah Lee', role: 'UI/UX Designer', initials: 'SL'),
      User(name: 'Michael Kim', role: 'Mobile Developer', initials: 'MK'),
      User(name: 'Emily Wong', role: 'QA Tester', initials: 'EW'),
      User(name: 'David Liu', role: 'Documentation', initials: 'DL'),
    ];

    for (var user in dummyUsers) {
      await db.insert('users', user.toMap());
    }

    // Insert dummy tasks matching the wireframes
    List<TaskModel> dummyTasks = [
      TaskModel(
        title: 'Design Login Screen',
        description: 'Create a clean and modern login screen for the application.',
        assignedToId: 2, // Sarah Lee
        dueDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        priority: 'High',
        status: 'In Progress',
        notes: 'Waiting for final logo assets.',
      ),
      TaskModel(
        title: 'Implement Local Storage',
        description: 'Use sqflite to persist data locally.',
        assignedToId: 3, // Michael Kim
        dueDate: DateTime.now().add(const Duration(days: 1)).toIso8601String(), // At Risk
        priority: 'High',
        status: 'To Do',
      ),
      TaskModel(
        title: 'Create Task Model',
        description: 'Define the data models for the application.',
        assignedToId: 1, // John Doe
        dueDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(), // Overdue
        priority: 'Medium',
        status: 'In Progress',
      ),
    ];

    for (var task in dummyTasks) {
      await db.insert('tasks', task.toMap());
    }
  }

  // --- User CRUD Operations ---
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null; // Return null if user not found
  }

  // --- Task CRUD Operations ---
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]);
    });
  }
  
  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
