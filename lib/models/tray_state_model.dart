class TrayStateModel {
  final String state; // "idle" | "dispensing"
  final String? activeSlot;
  final double weightGrams;
  final int? dispensedAt; // epoch ms
  final int? resolvedAt; // epoch ms
  final String? resolution; // "taken" | "missed"

  const TrayStateModel({
    required this.state,
    this.activeSlot,
    this.weightGrams = 0.0,
    this.dispensedAt,
    this.resolvedAt,
    this.resolution,
  });

  factory TrayStateModel.idle() => const TrayStateModel(state: 'idle');

  factory TrayStateModel.fromJson(Map<dynamic, dynamic> json) {
    return TrayStateModel(
      state: (json['state'] ?? 'idle').toString(),
      activeSlot: json['activeSlot']?.toString(),
      weightGrams: double.tryParse((json['weightGrams'] ?? 0).toString()) ?? 0.0,
      dispensedAt: json['dispensedAt'] != null
          ? int.tryParse(json['dispensedAt'].toString())
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? int.tryParse(json['resolvedAt'].toString())
          : null,
      resolution: json['resolution']?.toString(),
    );
  }

  bool get isDispensing => state == 'dispensing';

  DateTime? get resolvedAtDateTime => resolvedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(resolvedAt!)
      : null;

  DateTime? get dispensedAtDateTime => dispensedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(dispensedAt!)
      : null;
}
