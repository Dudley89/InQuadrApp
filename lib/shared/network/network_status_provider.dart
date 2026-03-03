import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { online, offline }

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) async* {
  final connectivity = Connectivity();

  Future<NetworkStatus> readCurrent() async {
    final result = await connectivity.checkConnectivity();
    return _toStatus(result);
  }

  yield await readCurrent();

  await for (final result in connectivity.onConnectivityChanged) {
    yield _toStatus(result);
  }
});

NetworkStatus _toStatus(List<ConnectivityResult> results) {
  if (results.isEmpty || results.contains(ConnectivityResult.none)) {
    return NetworkStatus.offline;
  }
  return NetworkStatus.online;
}
