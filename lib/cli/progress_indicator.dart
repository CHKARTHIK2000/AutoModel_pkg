import 'package:cli_spin/cli_spin.dart';

class ProgressIndicator {
  CliSpin? _spinner;

  /// Starts a spinner with a message.
  void start(String message) {
    stop(); // Ensure previous spinner is stopped
    _spinner = CliSpin(
      text: message,
    ).start();
  }

  /// Stops the spinner and shows a success message.
  void success(String message) {
    if (_spinner != null) {
      _spinner!.success(message);
      _spinner = null;
    } else {
      print('✔ $message');
    }
  }

  /// Stops the spinner and shows an error message.
  void error(String message) {
    if (_spinner != null) {
      _spinner!.fail(message);
      _spinner = null;
    } else {
      print('✖ $message');
    }
  }

  /// Shows an info message.
  void info(String message) {
    print('ℹ $message');
  }

  /// Shows a warning message.
  void warning(String message) {
    print('⚠ $message');
  }

  /// Stops the spinner immediately without any status.
  void stop() {
    if (_spinner != null) {
      _spinner!.stop();
      _spinner = null;
    }
  }

  /// Prints a summary header.
  void printSummaryHeader() {
    print('\n## Generation Summary');
    print('-----------------------------------------');
  }

  /// Prints a final success message.
  void printFinalSuccess(String message) {
    print('\n🎉 $message');
  }
}
