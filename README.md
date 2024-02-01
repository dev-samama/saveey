# Saveey

![Flutter Version](https://img.shields.io/badge/Flutter-%5E2.0.0-blue.svg)
![Package Version](https://img.shields.io/badge/Version-1.0.0-green.svg)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A comprehensive and secure saveey package for Flutter, providing robust encryption and decryption capabilities for key-value storage.

## Features

- **Advanced Encryption**: Implement advanced cryptographic techniques to secure your data.
- **Seamless Integration**: Easily integrate Saveey Flutter into your Flutter applications.
- **Confidentiality and Integrity**: Ensure the confidentiality and integrity of your sensitive data.
- **Key-Value Storage**: Effortlessly encrypt and decrypt key-value pairs within your application.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Issues and Bugs](#issues-and-bugs)
- [License](#license)

## Installation

To use this package, add `saveey` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  saveey: ^1.0.0

```
## Usage

import 'package:saveey/saveey.dart';

void main() async {
  // Initialize Saveey with your own encryption key and file name
  await Saveey.initialize(
    encryptionKey: 'provide_encryption_key',
    fileName: 'provide_file_name',
  );

  // Store a key-value pair
  await Saveey.setValue('username', 'john_doe');

  // Retrieve the value associated with the key
  final username = Saveey.getValue('username');
  print('Username: $username');

  // Store a list of models (e.g., User models) with optional expiration time
  final List<User> newUsers = await fetchUsersFromApi();
  await Saveey.storeModelList<User>('users_key', newUsers, expiration: Duration(hours: 1));

  // Retrieve the list of users
  final List<User>? storedUsers = Saveey.getModelList<User>('users_key');
  print('Stored Users: $storedUsers');

  // Remove a key-value pair
  await Saveey.removeValue('username');

  // Clear all stored key-value pairs
  await Saveey.clear();
}



- [Instagram](https://www.instagram.com/samama__majeed__/)
- [LinkedIn](https://www.linkedin.com/in/samama-majeed-71883720b/)

Feel free to follow me on Instagram and connect with me on LinkedIn for more updates and collaborations!