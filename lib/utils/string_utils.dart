class StringUtils {
  /// Converts snake_case string to camelCase
  static String snakeToCamel(String snake) {
    if (snake.isEmpty) return snake;
    
    final parts = snake.split('_');
    final camel = parts.first + 
        parts.skip(1).map((part) => capitalize(part)).join('');
    
    return camel;
  }

  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Converts a string to snake_case if it's not already
  /// (Useful for filename generation from model name)
  static String camelToSnake(String camel) {
    final exp = RegExp('(?<=[a-z])[A-Z]');
    return camel.replaceAllMapped(exp, (m) => '_${m.group(0)!.toLowerCase()}').toLowerCase();
  }
}
