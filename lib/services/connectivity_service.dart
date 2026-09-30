import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionChangeController.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<bool> checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasConnection(results);
    } catch (_) {
      return true; // Assume online if check fails
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _connectionChangeController.add(_hasConnection(results));
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return !results.contains(ConnectivityResult.none);
  }

  void dispose() {
    _connectionChangeController.close();
  }
}
