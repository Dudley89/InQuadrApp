import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class StartupRequirementsStatus {
  const StartupRequirementsStatus({
    required this.hasInternet,
    required this.locationServiceEnabled,
    required this.locationPermission,
    required this.cameraPermission,
  });

  final bool hasInternet;
  final bool locationServiceEnabled;
  final PermissionStatus locationPermission;
  final PermissionStatus cameraPermission;

  bool get hasLocationPermission => locationPermission == PermissionStatus.granted;
  bool get hasCameraPermission => cameraPermission == PermissionStatus.granted;

  bool get allSatisfied =>
      hasInternet &&
      locationServiceEnabled &&
      hasLocationPermission &&
      hasCameraPermission;

  List<String> missingRequirements() {
    final items = <String>[];

    if (!hasInternet) {
      items.add('Connessione internet assente (Wi-Fi o dati mobili).');
    }

    if (!locationServiceEnabled) {
      items.add('Servizio posizione/GPS disattivato.');
    }

    if (!hasLocationPermission) {
      if (locationPermission == PermissionStatus.permanentlyDenied) {
        items.add('Permesso posizione negato in modo permanente (abilitalo dalle impostazioni).');
      } else {
        items.add('Permesso posizione non concesso.');
      }
    }

    if (!hasCameraPermission) {
      if (cameraPermission == PermissionStatus.permanentlyDenied) {
        items.add('Permesso fotocamera negato in modo permanente (abilitalo dalle impostazioni).');
      } else {
        items.add('Permesso fotocamera non concesso.');
      }
    }

    return items;
  }
}

class StartupRequirementsChecker {
  const StartupRequirementsChecker();

  Future<StartupRequirementsStatus> check() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResults.any(
      (item) => item == ConnectivityResult.mobile || item == ConnectivityResult.wifi,
    );

    final locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    final locationPermission = await Permission.locationWhenInUse.status;
    final cameraPermission = await Permission.camera.status;

    return StartupRequirementsStatus(
      hasInternet: hasInternet,
      locationServiceEnabled: locationServiceEnabled,
      locationPermission: locationPermission,
      cameraPermission: cameraPermission,
    );
  }
}
