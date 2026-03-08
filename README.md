# 🚀 API Model Generator (AMG)

[![pub package](https://img.shields.io/pub/v/api_model_generator.svg)](https://pub.dev/packages/api_model_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**API Model Generator (AMG)** is a professional CLI tool designed to supercharge your Flutter and Dart development. It automatically transforms JSON API responses into a complete, clean-architecture data layer including **Models**, **Services**, **Repositories**, and **API Clients**.

Stop wasting time on boilerplate. AMG handles nested objects, prevents duplicate models, syncs changes safely, and generates type-safe code in seconds.

---

## ✨ Key Features

- **Recursive Model Generation**: Automatically generates separate Dart files for deeply nested JSON objects.
- **Model Registry (Deduplication)**: Smartly detects identical JSON structures and reuses existing models to keep your code DRY.
- **Clean Architecture Layers**:
  - **Models**: Type-safe Dart classes with `fromJson` and `toJson`.
  - **Services**: Network layer logic using the `http` package.
  - **Repositories**: Data abstraction layer for your UI.
  - **API Client**: A centralized client for all your defined endpoints.
- **Model Sync**: Safely update existing models when API responses change—detects new fields and updates constructors and serialization logic automatically.
- **Batch Generation**: Process an entire folder of JSON files in one command.
- **YAML Configuration**: standardise paths and settings for your project.
- **Multi-Client Support**: Generate API clients for both `http` and `dio`.
- **Interactive & Command Mode**: Use guided prompts or fast CLI commands.
- **Polished UX**: Real-time progress indicators (spinners) and generation summaries.

---

## 📦 Installation

Add AMG to your `dev_dependencies`:

```bash
flutter pub add api_model_generator --dev
```

For global usage (recommended for the `amg` command):

```bash
dart pub global activate api_model_generator
```

---

## 🚀 Quick Start

1.  Place your API response in `response.json` in the root of your project.
2.  Run the interactive generator:
    ```bash
    amg i
    ```
3.  Follow the prompts to generate your Models, Services, and Repositories.

---

## 🛠️ CLI Commands & Aliases

| Command | Alias | Description |
| :--- | :--- | :--- |
| `interactive` | `i` | Start the guided interactive CLI (Default) |
| `generate` | `g` | Generate models/services using `api_model_generator.yaml` |
| `sync` | `s` | Sync an existing model file with a new JSON response |
| `batch <path>`| `b` | Generate models for every `.json` file in a folder |
| `api` | `a` | Generate a centralized `ApiClient` from your config |
| `init` | | Create a default `api_model_generator.yaml` config file |
| `--help` | `-h` | Show usage information |
| `--version` | `-v` | Show current version |

---

## 🔄 Updating Models (Sync)

AMG allows you to safely evolve your models as your backend changes:

```bash
amg sync
```
The tool will compare your existing Dart model with the new JSON, show you a **Diff Preview** of new fields, and update the file without breaking your existing structure.

---

## ⚙️ Configuration (`api_model_generator.yaml`)

Use a configuration file to automate paths and define API endpoints. Run `amg init` to create a template.

```yaml
# Output Paths
models_path: lib/core/models
services_path: lib/core/services
repositories_path: lib/core/repositories
api_path: lib/core/api

# Generation Settings
generate:
  service: true
  repository: true

# API Client Settings
http_client: dio # or 'http'
api:
  base_url: https://api.example.com

endpoints:
  - name: getUsers
    method: GET
    path: /users
    response_model: User
    response_type: list
  - name: createUser
    method: POST
    path: /users
    request_model: User
    response_model: User
    response_type: object
```

After configuring, generate your API Client with:
```bash
amg api
```

---

## 📂 Generated Structure

AMG follows a clean architecture pattern:

```text
lib/
├── api/
│   └── api_client.dart      # Centralized API methods
├── models/
│   ├── user.dart            # Type-safe model
│   └── address.dart         # Reusable nested model
├── services/
│   └── user_service.dart    # Network calls
└── repositories/
    └── user_repository.dart # Data abstraction
```

---

## 🧪 Running Tests

Ensure the generator logic is working correctly in your environment:

```bash
dart test
```

---

## 🤝 Contributing

We welcome contributions! If you have ideas for new features (like Freezed support or OpenAPI integration), please open an issue or submit a pull request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
