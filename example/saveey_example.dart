import 'package:saveey/saveey.dart';

void main() async {
  // Initialize Saveey by providing encryption key and file name
  await Saveey.initialize(
    encryptionKey: 'encryption_key',
    fileName: 'file_name',
  );

  // Store a key-value pair
  await Saveey.setValue('username', 'john_doe');

  // Retrieve the value associated with the key
  final username = Saveey.getValue('username');
  print('Username: $username');

  // Store a list of models (e.g., User models) with optional expiration time
  final List<User> newUsers = await fetchUsersFromApi();
  await Saveey.storeModelList<User>('users_key', newUsers,
      expiration: const Duration(hours: 1));

  // Retrieve the list of users
  final List<User>? storedUsers = Saveey.getModelList<User>('users_key');
  print('Stored Users: $storedUsers');

  // Remove a key-value pair
  await Saveey.removeValue('username');

  // Clear all stored key-value pairs
  await Saveey.clear();
}

// Mock User class for demonstration purposes
class User {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  String toString() {
    return 'User{name: $name, age: $age}';
  }
}

// Mock function to fetch users from an API
Future<List<User>> fetchUsersFromApi() async {
  // Simulate fetching users from an API
  await Future.delayed(const Duration(seconds: 2));
  return [
    User('Alice', 25),
    User('Bob', 30),
    User('Charlie', 22),
  ];
}
