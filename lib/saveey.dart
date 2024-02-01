import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

/// A simple key-value store with encryption support using the AES algorithm.
class Saveey {
  static late File _file;
  static late Map<String, Completer> _listeners;

  static String? _encryptionKey; // Updated to be nullable
  static String? _fileName; // Updated to be nullable

  /// Initializes the key-value store with encryption key and file name.
  ///
  /// Must be called before using any other methods of this class.
  static Future<void> initialize(
      {required String encryptionKey, required String fileName}) async {
    _encryptionKey = encryptionKey;
    _fileName = fileName;

    if (_encryptionKey == null || _fileName == null) {
      throw ArgumentError('Encryption key and file name are required.');
    }

    final directory = await getApplicationDocumentsDirectory();
    _file = File('${directory.path}/$_fileName.json');
    _listeners = {};
  }

  /// Stores a key-value pair with optional expiration time.
  static Future<void> setValue(String key, dynamic value,
      {Duration? expiration}) async {
    _checkInitialization();

    final Map<String, dynamic> store = _readFromFile() ?? {};

    final expirationTime =
        expiration != null ? DateTime.now().add(expiration) : null;

    store[key] = {
      'value': _encrypt(value),
      'expiration': expirationTime?.millisecondsSinceEpoch,
    };

    await _writeToFile(store);

    _notifyListeners(key, value);
  }

  /// Retrieves the value associated with the given key.
  static dynamic getValue(String key) {
    _checkInitialization();

    final Map<String, dynamic>? store = _readFromFile();
    final storedValue = store?[key];

    if (storedValue != null) {
      final expiration = storedValue['expiration'] as int?;
      if (expiration == null ||
          DateTime.now().millisecondsSinceEpoch < expiration) {
        return _decrypt(storedValue['value']);
      } else {
        // Remove expired value
        removeValue(key);
      }
    }

    return null;
  }

  /// Removes the value associated with the given key.
  static Future<void> removeValue(String key) async {
    _checkInitialization();

    final Map<String, dynamic> store = _readFromFile() ?? {};

    store.remove(key);
    await _writeToFile(store);

    _notifyListeners(key, null);
  }

  /// Clears all stored key-value pairs.
  static Future<void> clear() async {
    _checkInitialization();

    await _writeToFile({});

    // Notify listeners about the clear operation
    _notifyListeners(null, null);
  }

  /// Stores a list of models with optional expiration time.
  ///
  /// If [append] is `true`, the new models will be appended to the existing list.
  /// If [append] is `false`, the existing list will be replaced with the new models.
  static Future<void> storeModelList<T>(
    String key,
    List<T> modelList, {
    Duration? expiration,
    bool append = true, // Default behavior is to append
  }) async {
    _checkInitialization();

    final List<T> existingList = (getModelList<T>(key) ?? []);

    final List<T> updatedList =
        append ? [...existingList, ...modelList] : modelList;

    await setValue(key, {'data': updatedList, 'expiration': expiration});
  }

  /// Retrieves a list of models associated with the given key.
  static List<T>? getModelList<T>(String key) {
    _checkInitialization();

    final storedValue = getValue(key);

    if (storedValue != null) {
      final expiration = storedValue['expiration'] as int?;
      if (expiration == null ||
          DateTime.now().millisecondsSinceEpoch < expiration) {
        return (storedValue['data'] as List?)?.cast<T>();
      } else {
        // Remove expired value
        removeValue(key);
      }
    }

    return null;
  }

  /// Reads key-value pairs from the file.
  static Map<String, dynamic>? _readFromFile() {
    try {
      final jsonString = _file.readAsStringSync();
      return jsonDecode(jsonString);
    } catch (_) {
      return null;
    }
  }

  /// Writes key-value pairs to the file.
  static Future<void> _writeToFile(Map<String, dynamic> store) async {
    await _file.writeAsString(jsonEncode(store));
  }

  /// Encrypts the given data using AES algorithm.
  static String _encrypt(dynamic data) {
    final key = encrypt.Key.fromUtf8(_encryptionKey!);
    final iv = encrypt.IV.fromLength(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr));

    final plainText = utf8.encode(jsonEncode(data));
    final encrypted =
        encrypter.encryptBytes(Uint8List.fromList(plainText), iv: iv);

    return base64.encode(encrypted.bytes);
  }

  /// Decrypts the given encrypted data using AES algorithm.
  static dynamic _decrypt(String encryptedData) {
    final key = encrypt.Key.fromUtf8(_encryptionKey!);
    final iv = encrypt.IV.fromLength(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr));

    final encryptedBytes = base64.decode(encryptedData);
    final decryptedBytes =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
    final decryptedText = utf8.decode(decryptedBytes);

    return jsonDecode(decryptedText);
  }

  /// Notifies listeners about changes in the key-value store.
  static void _notifyListeners(String? key, dynamic value) {
    final listener = _listeners[key];

    if (listener != null && !listener.isCompleted) {
      listener.complete(value);
      _listeners.remove(key);
    }

    // Notify listeners about a clear operation
    for (final entry in _listeners.entries) {
      if (entry.value.isCompleted) {
        entry.value.complete(null);
      }
    }
  }

  /// Listens for changes in the value associated with the given key.
  static Future<dynamic> listen(String key) async {
    final completer = Completer<dynamic>();
    _listeners[key] = completer;
    return completer.future;
  }

  /// Checks if the class has been initialized with encryption key and file name.
  static void _checkInitialization() {
    if (_encryptionKey == null || _fileName == null) {
      throw StateError(
          'Saveey has not been initialized. Call initialize method first.');
    }
  }
}
