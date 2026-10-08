import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // In-memory store for Flutter Web where sqflite is not supported natively
  List<User>? _webUsers;
  List<TaskModel>? _webTasks;

  // Singleton pattern so we only have one instance of the database helper
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal() {
    if (kIsWeb) {
      _initWebStorage();
    }
  }

  void _initWebStorage() {
    _webUsers = List<User>.from(getInitialUsers());
    _webTasks = List<TaskModel>.from(getInitialTasks());
  }

  static List<User> getInitialUsers() {
    return [
      User(id: 1, name: 'John Doe', role: 'Project Manager', initials: 'JD', avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg'),
      User(id: 2, name: 'Sarah Lee', role: 'UI/UX Designer', initials: 'SL', avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg'),
      User(id: 3, name: 'Michael Kim', role: 'Mobile Developer', initials: 'MK', avatarUrl: 'https://randomuser.me/api/portraits/men/75.jpg'),
      User(id: 4, name: 'Emily Wong', role: 'QA Tester', initials: 'EW', avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg'),
      User(id: 5, name: 'David Liu', role: 'Documentation', initials: 'DL', avatarUrl: 'https://randomuser.me/api/portraits/men/46.jpg'),
    ];
  }

  static List<TaskModel> getInitialTasks() {
    DateTime now = DateTime.now();
    String inDays(int days) => now.add(Duration(days: days)).toIso8601String();

    return [
      // On Track
      TaskModel(
        id: 1,
        title: 'Design Login Screen',
        description: 'Create a clean and modern login screen for the application.',
        assignedToId: 2, // Sarah Lee
        dueDate: inDays(5),
        priority: 'High',
        status: 'In Progress',
        notes: 'Waiting for final logo assets.',
      ),
      TaskModel(
        id: 2,
        title: 'Team Members Screen',
        description: 'Show every team member with their role and initials.',
        assignedToId: 2, // Sarah Lee
        dueDate: inDays(7),
        priority: 'Medium',
        status: 'In Progress',
      ),
      TaskModel(
        id: 3,
        title: 'Write User Guide',
        description: 'Document how to create, track and complete tasks in the app.',
        assignedToId: 5, // David Liu
        dueDate: inDays(8),
        priority: 'Low',
        status: 'In Progress',
      ),
      TaskModel(
        id: 4,
        title: 'Test Application',
        description: 'Test every screen and report any bugs found.',
        assignedToId: 4, // Emily Wong
        dueDate: inDays(10),
        priority: 'Medium',
        status: 'To Do',
      ),
      TaskModel(
        id: 5,
        title: 'Prepare Demo',
        description: 'Prepare the slides and the demo script for the presentation.',
        assignedToId: 5, // David Liu
        dueDate: inDays(13),
        priority: 'Low',
        status: 'To Do',
      ),
      // At Risk
      TaskModel(
        id: 6,
        title: 'Implement Local Storage',
        description: 'Use sqflite to persist data locally.',
        assignedToId: 3, // Michael Kim
        dueDate: inDays(1),
        priority: 'High',
        status: 'In Progress',
      ),
      TaskModel(
        id: 7,
        title: 'Build Task List Screen',
        description: 'List all tasks with search, filters and SLA badges.',
        assignedToId: 3, // Michael Kim
        dueDate: inDays(2),
        priority: 'High',
        status: 'In Progress',
      ),
      TaskModel(
        id: 8,
        title: 'Define SLA Rules',
        description: 'Decide when a task becomes At Risk or Overdue.',
        assignedToId: 1, // John Doe
        dueDate: inDays(1),
        priority: 'Medium',
        status: 'In Progress',
      ),
      // Overdue
      TaskModel(
        id: 9,
        title: 'Create Task Model',
        description: 'Define the data models for the application.',
        assignedToId: 1, // John Doe
        dueDate: inDays(-2),
        priority: 'Medium',
        status: 'In Progress',
      ),
      TaskModel(
        id: 10,
        title: 'Fix Profile Screen Bugs',
        description: 'Fix the layout overflow on small screens.',
        assignedToId: 4, // Emily Wong
        dueDate: inDays(-1),
        priority: 'High',
        status: 'In Progress',
      ),
      // Completed
      TaskModel(
        id: 11,
        title: 'Setup Project Repository',
        description: 'Create the Flutter project and the GitHub repository.',
        assignedToId: 1, // John Doe
        dueDate: inDays(-6),
        priority: 'High',
        status: 'Completed',
      ),
      TaskModel(
        id: 12,
        title: 'Design App Icon',
        description: 'Create the launcher icon for Android and iOS.',
        assignedToId: 2, // Sarah Lee
        dueDate: inDays(-3),
        priority: 'Low',
        status: 'Completed',
      ),
    ];
  }

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Version 2 added profile pictures and more sample tasks. The app only holds
  // sample data so far, so we simply rebuild the tables with the new seed data.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS tasks');
    await db.execute('DROP TABLE IF EXISTS users');
    await _onCreate(db, newVersion);
  }

  // Creates the database tables and populates initial dummy data
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        initials TEXT,
        avatarUrl TEXT
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
    for (var user in getInitialUsers()) {
      await db.insert('users', user.toMap());
    }
    for (var task in getInitialTasks()) {
      await db.insert('tasks', task.toMap());
    }
  }

  // --- User CRUD Operations ---
  Future<int> insertUser(User user) async {
    if (kIsWeb) {
      if (_webUsers == null) _initWebStorage();
      final id = (_webUsers!.isEmpty ? 1 : (_webUsers!.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1));
      final newUser = User(
        id: id,
        name: user.name,
        role: user.role,
        initials: user.initials,
        avatarUrl: user.avatarUrl,
      );
      _webUsers!.add(newUser);
      return id;
    }
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    if (kIsWeb) {
      if (_webUsers == null) _initWebStorage();
      return List<User>.from(_webUsers!);
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<User?> getUser(int id) async {
    if (kIsWeb) {
      if (_webUsers == null) _initWebStorage();
      try {
        return _webUsers!.firstWhere((u) => u.id == id);
      } catch (_) {
        return null; // Return null if user not found
      }
    }
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
    if (kIsWeb) {
      if (_webTasks == null) _initWebStorage();
      final nextId = _webTasks!.isEmpty
          ? 1
          : (_webTasks!.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final newTask = TaskModel(
        id: nextId,
        title: task.title,
        description: task.description,
        assignedToId: task.assignedToId,
        dueDate: task.dueDate,
        priority: task.priority,
        status: task.status,
        notes: task.notes,
      );
      _webTasks!.insert(0, newTask);
      return nextId;
    }
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getTasks() async {
    if (kIsWeb) {
      if (_webTasks == null) _initWebStorage();
      return List<TaskModel>.from(_webTasks!);
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]);
    });
  }
  
  Future<int> updateTask(TaskModel task) async {
    if (kIsWeb) {
      if (_webTasks == null) _initWebStorage();
      final index = _webTasks!.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _webTasks![index] = task;
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
