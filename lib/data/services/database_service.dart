import 'package:mongo_dart/mongo_dart.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static const String connectionString =
      'mongodb://root:Nero12345@176.100.36.172:8888/?directConnection=true';
  static const String databaseName = 'todo';
  static const String tasksCollectionName = 'tasks';
  static const String usersCollectionName = 'users';

  static Db? _db;
  static DbCollection? _taskCollection;
  static DbCollection? _userCollection;

  // Initialize database connection
  static Future<void> connect() async {
    try {
      _db = await Db.create(connectionString);
      await _db!.open();
      _taskCollection = _db!.collection(tasksCollectionName);
      _userCollection = _db!.collection(usersCollectionName);
      print('✅ Successfully connected to MongoDB');
    } catch (e) {
      print('❌ Error connecting to MongoDB: $e');
      throw Exception('Failed to connect to database: $e');
    }
  }

  // ========== USER METHODS ==========

  // Create new user
  static Future<User?> createUser(String email, String password) async {
    try {
      if (_userCollection == null) await connect();

      final user = User(
        email: email.toLowerCase(),
        password: password, // In production, hash this password
        createdAt: DateTime.now(),
      );

      final userMap = user.toMap();
      userMap.remove('_id'); // Let MongoDB generate the ID

      final result = await _userCollection!.insertOne(userMap);
      final createdUser = user.copyWith(id: result.id);

      print('✅ User created successfully: ${createdUser.email}');
      return createdUser;
    } catch (e) {
      print('❌ Error creating user: $e');
      return null;
    }
  }

  // Login user
  static Future<User?> loginUser(String email, String password) async {
    try {
      if (_userCollection == null) await connect();

      final userMap = await _userCollection!.findOne({
        'email': email.toLowerCase(),
        'password': password, // In production, compare hashed passwords
      });

      if (userMap != null) {
        final user = User.fromMap(userMap);
        print('✅ User logged in successfully: ${user.email}');
        return user;
      }
      return null;
    } catch (e) {
      print('❌ Error logging in user: $e');
      return null;
    }
  }

  // Get user by email
  static Future<User?> getUserByEmail(String email) async {
    try {
      if (_userCollection == null) await connect();

      final userMap = await _userCollection!.findOne({
        'email': email.toLowerCase(),
      });

      if (userMap != null) {
        return User.fromMap(userMap);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  // Get user by ID
  static Future<User?> getUserById(String userId) async {
    try {
      if (_userCollection == null) await connect();

      final userMap = await _userCollection!
          .findOne(where.id(ObjectId.fromHexString(userId)));

      if (userMap != null) {
        return User.fromMap(userMap);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  // ========== TASK METHODS (Updated to include userId) ==========

  // Get all tasks for a specific user
  static Future<List<Task>> getAllTasks({String? userId}) async {
    try {
      if (_taskCollection == null) await connect();

      final query = userId != null ? {'userId': userId} : <String, dynamic>{};
      final List<Map<String, dynamic>> results =
          await _taskCollection!.find(query).toList();

      return results.map((taskMap) => Task.fromMap(taskMap)).toList();
    } catch (e) {
      print('❌ Error fetching tasks: $e');
      return []; // Return empty list if error
    }
  }

  // Create new task (Updated to include userId)
  static Future<Task?> createTask(Task task) async {
    try {
      if (_taskCollection == null) await connect();

      final taskMap = task.toMap();
      taskMap.remove('_id'); // Let MongoDB generate the ID

      final result = await _taskCollection!.insertOne(taskMap);
      final insertedTask = task.copyWith(id: result.id);

      print('✅ Task created successfully: ${insertedTask.title}');
      return insertedTask;
    } catch (e) {
      print('❌ Error creating task: $e');
      throw Exception('Failed to create task: $e');
    }
  }

  // Update task
  static Future<bool> updateTask(Task task) async {
    try {
      if (_taskCollection == null) await connect();

      final result = await _taskCollection!.replaceOne(
        where.id(task.id!),
        task.toMap(),
      );

      if (result.isSuccess) {
        print('✅ Task updated successfully: ${task.title}');
        return true;
      } else {
        print('❌ Failed to update task: ${task.title}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating task: $e');
      return false;
    }
  }

  // Delete task
  static Future<bool> deleteTask(ObjectId taskId) async {
    try {
      if (_taskCollection == null) await connect();

      final result = await _taskCollection!.deleteOne(where.id(taskId));

      if (result.isSuccess) {
        print('✅ Task deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete task');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting task: $e');
      return false;
    }
  }

  // Get tasks by completion status for a specific user
  static Future<List<Task>> getTasksByStatus(bool isCompleted,
      {String? userId}) async {
    try {
      if (_taskCollection == null) await connect();

      final query = {
        'isCompleted': isCompleted,
        if (userId != null) 'userId': userId,
      };

      final List<Map<String, dynamic>> results =
          await _taskCollection!.find(query).toList();

      return results.map((taskMap) => Task.fromMap(taskMap)).toList();
    } catch (e) {
      print('❌ Error fetching tasks by status: $e');
      return [];
    }
  }

  // Close database connection
  static Future<void> close() async {
    await _db?.close();
    _db = null;
    _taskCollection = null;
    _userCollection = null;
    print('✅ Database connection closed');
  }

  // Check connection status
  static bool get isConnected => _db?.isConnected ?? false;
}
