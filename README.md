# 🚀 API Model Generator

[![pub package](https://img.shields.io/pub/v/api_model_generator.svg)](https://pub.dev/packages/api_model_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful CLI tool for Flutter and Dart developers that automatically generates type-safe **Models**, **Services**, and **Repositories** directly from JSON API responses. Stop writing boilerplate code and start building features.

---

## ✨ Features

- **Recursive Model Generation**: Handles deeply nested JSON objects automatically.
- **Smart Model Registry**: Detects duplicate structures and reuses existing models to keep your codebase DRY.
- **Clean Architecture**: Generates distinct layers for Models, Services (API calls), and Repositories (Data access).
- **Model Sync & Update**: Safely update existing models when your API response changes without losing structure.
- **Naming Conventions**: Automatically converts `snake_case` JSON keys to `camelCase` Dart variables and uses `PascalCase` for class names.
- **Serialization**: Generates robust `fromJson()` and `toJson()` methods.
- **Interactive CLI**: Easy-to-use guided prompts for quick generation.
- **YAML Configuration**: Support for persistent project settings to automate your workflow.
- **Diff Preview**: See exactly what fields are being added during a sync before committing to changes.

---

## 📦 Installation

Add the package to your `dev_dependencies` in `pubspec.yaml`:

```bash
flutter pub add api_model_generator --dev
```

Or for Dart-only projects:

```bash
dart pub add api_model_generator --dev
```

---

## 🚀 Quick Start

1.  **Save your API response**: Place a file named `response.json` (containing the JSON response from your API) in your project's root directory.
2.  **Run the generator**:
    ```bash
    dart run api_model_generator
    ```
3.  **Follow the prompts**:
    - Enter your desired model name (e.g., `User`).
    - Choose what to generate (Model only, Model + Service, or full Model + Service + Repository).
    - Specify output directories or use defaults.

---

## 🔄 Model Sync (Update Existing Models)

When your API changes (e.g., new fields are added), you don't need to regenerate everything. Use the **Sync** feature:

```bash
dart run api_model_generator
# Then select option 4: Sync Existing Models
```

The tool will:
1.  Compare your new `response.json` with the existing Dart file.
2.  Show a **Diff Preview** of new fields detected.
3.  Safely inject new fields into the class, constructor, and serialization methods.

---

## 🛠️ Configuration Mode

For power users, create an `api_model_generator.yaml` file in your project root to skip prompts and standardize paths:

```yaml
# api_model_generator.yaml
models_path: lib/models
services_path: lib/services
repositories_path: lib/repositories

generate:
  service: true
  repository: true

http_client: http # Options: http (more coming soon)
```

Now, run the non-interactive generation command:

```bash
dart run api_model_generator generate
```

---

## 📂 Project Structure

### CLI Tool Architecture
```text
lib/
├── cli/         # Interactive user interface
├── config/      # YAML configuration logic
├── generator/   # Core code generation logic
├── utils/       # String manipulation & helpers
└── writer/      # Safe file system operations
```

### Generated Flutter Structure
```text
lib/
├── models/      # Type-safe Dart models
├── services/    # API network layer (http)
└── repositories/# Data abstraction layer
```

---

## 📝 Example Generated Model

**Input JSON:**
```json
{
  "user_id": 1,
  "user_name": "John Doe",
  "contact": {
    "email": "john@example.com"
  }
}
```

**Output `user.dart`:**
```dart
import 'contact.dart';

class User {
  final int userId;
  final String userName;
  final Contact contact;

  User({
    required this.userId,
    required this.userName,
    required this.contact,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      userName: json['user_name'],
      contact: Contact.fromJson(json['contact']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'contact': contact.toJson(),
    };
  }
}
```

---

## 🗺️ Roadmap

- [ ] **Dio Support**: Option to generate services using the Dio HTTP client.
- [ ] **Freezed Integration**: Generate models using the `freezed` package for immutability.
- [ ] **OpenAPI / Swagger**: Support for generating models from Swagger JSON/YAML specs.
- [ ] **Custom Templates**: Allow users to provide their own `.mustache` or template files for code generation.

---

## 🤝 Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request on GitHub.

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
