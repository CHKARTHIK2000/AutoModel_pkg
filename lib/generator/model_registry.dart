class ModelRegistry {
  /// Map of canonical structure signature to model name
  /// Example: 'city:String,zip:String' -> 'ShippingAddress'
  final Map<String, String> _structureToName = {};
  
  /// Track which models we've already generated code for
  final Set<String> _processedModels = {};

  /// Registers a model structure with a given name
  void registerModel(String name, Map<String, String> fields) {
    final signature = _getSignature(fields);
    if (!_structureToName.containsKey(signature)) {
      _structureToName[signature] = name;
    }
  }

  /// Finds an existing model name that matches the structure
  String? findExistingModel(Map<String, String> fields) {
    final signature = _getSignature(fields);
    return _structureToName[signature];
  }

  /// Generates a unique canonical signature for a structure
  String _getSignature(Map<String, String> fields) {
    // Sort keys to ensure canonical form
    final sortedKeys = fields.keys.toList()..sort();
    final signature = sortedKeys.map((k) => '$k:${fields[k]}').join(',');
    return signature;
  }

  /// Checks if a model name has already been processed (code generated)
  bool isProcessed(String name) => _processedModels.contains(name);

  /// Marks a model name as processed
  void markProcessed(String name) => _processedModels.add(name);
  
  /// Clears the registry (useful for testing or fresh runs)
  void clear() {
    _structureToName.clear();
    _processedModels.clear();
  }
}
