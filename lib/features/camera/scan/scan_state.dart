class ScanState {
  const ScanState({
    required this.isEnabled,
    required this.isLocked,
    required this.isBusy,
    required this.lockedMonumentId,
    required this.lockedConfidence,
    required this.message,
  });

  final bool isEnabled;
  final bool isLocked;
  final bool isBusy;
  final String? lockedMonumentId;
  final double lockedConfidence;
  final String message;

  factory ScanState.initial() => const ScanState(
    isEnabled: true,
    isLocked: false,
    isBusy: false,
    lockedMonumentId: null,
    lockedConfidence: 0,
    message: 'Inquadra un monumento',
  );

  ScanState copyWith({
    bool? isEnabled,
    bool? isLocked,
    bool? isBusy,
    Object? lockedMonumentId = _noValue,
    double? lockedConfidence,
    String? message,
  }) {
    return ScanState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      isBusy: isBusy ?? this.isBusy,
      lockedMonumentId: lockedMonumentId == _noValue
          ? this.lockedMonumentId
          : lockedMonumentId as String?,
      lockedConfidence: lockedConfidence ?? this.lockedConfidence,
      message: message ?? this.message,
    );
  }
}

const _noValue = Object();
