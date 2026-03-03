import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationState {
  const LocationState({
    required this.enabled,
    required this.isLoading,
    required this.serviceEnabled,
    required this.permissionGranted,
    required this.permanentlyDenied,
    required this.latitude,
    required this.longitude,
    required this.errorMessage,
  });

  factory LocationState.initial() => const LocationState(
        enabled: true,
        isLoading: false,
        serviceEnabled: false,
        permissionGranted: false,
        permanentlyDenied: false,
        latitude: null,
        longitude: null,
        errorMessage: null,
      );

  final bool enabled;
  final bool isLoading;
  final bool serviceEnabled;
  final bool permissionGranted;
  final bool permanentlyDenied;
  final double? latitude;
  final double? longitude;
  final String? errorMessage;

  LocationState copyWith({
    bool? enabled,
    bool? isLoading,
    bool? serviceEnabled,
    bool? permissionGranted,
    bool? permanentlyDenied,
    Object? latitude = _unset,
    Object? longitude = _unset,
    Object? errorMessage = _unset,
  }) {
    return LocationState(
      enabled: enabled ?? this.enabled,
      isLoading: isLoading ?? this.isLoading,
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      permanentlyDenied: permanentlyDenied ?? this.permanentlyDenied,
      latitude: latitude == _unset ? this.latitude : latitude as double?,
      longitude: longitude == _unset ? this.longitude : longitude as double?,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }
}

const _unset = Object();

class LocationController extends StateNotifier<LocationState> {
  LocationController() : super(LocationState.initial());

  Future<void> bootstrap() async {
    if (!state.enabled) {
      return;
    }
    await _resolveLocation(triggerOpenSettingsOnPermanentDeny: false);
  }

  Future<void> enable() async {
    state = state.copyWith(enabled: true);
    await _resolveLocation(triggerOpenSettingsOnPermanentDeny: true);
  }

  void disable() {
    state = state.copyWith(
      enabled: false,
      isLoading: false,
      latitude: null,
      longitude: null,
      errorMessage: null,
    );
  }

  Future<void> _resolveLocation({
    required bool triggerOpenSettingsOnPermanentDeny,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        enabled: false,
        isLoading: false,
        serviceEnabled: false,
        permissionGranted: false,
        latitude: null,
        longitude: null,
        errorMessage: 'Servizio posizione disattivato',
      );
      return;
    }

    var permission = await Permission.locationWhenInUse.status;
    if (permission.isDenied) {
      permission = await Permission.locationWhenInUse.request();
    }

    if (permission.isPermanentlyDenied) {
      if (triggerOpenSettingsOnPermanentDeny) {
        await openAppSettings();
      }
      state = state.copyWith(
        enabled: false,
        isLoading: false,
        serviceEnabled: true,
        permissionGranted: false,
        permanentlyDenied: true,
        latitude: null,
        longitude: null,
        errorMessage: 'Permesso posizione negato permanentemente',
      );
      return;
    }

    if (!permission.isGranted) {
      state = state.copyWith(
        enabled: false,
        isLoading: false,
        serviceEnabled: true,
        permissionGranted: false,
        permanentlyDenied: false,
        latitude: null,
        longitude: null,
        errorMessage: 'Permesso posizione non concesso',
      );
      return;
    }

    Position? position = await Geolocator.getLastKnownPosition();
    position ??= await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    state = state.copyWith(
      enabled: true,
      isLoading: false,
      serviceEnabled: true,
      permissionGranted: true,
      permanentlyDenied: false,
      latitude: position.latitude,
      longitude: position.longitude,
      errorMessage: null,
    );
  }
}

final locationControllerProvider =
    StateNotifierProvider<LocationController, LocationState>(
  (ref) => LocationController(),
);
