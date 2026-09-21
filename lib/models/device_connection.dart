class DeviceConnection {
  final bool connected;
  final int? lastSeen; // epoch ms

  const DeviceConnection({
    required this.connected,
    this.lastSeen,
  });

  factory DeviceConnection.unknown() =>
      const DeviceConnection(connected: false);

  factory DeviceConnection.fromJson(Map<dynamic, dynamic> json) {
    return DeviceConnection(
      connected: json['connected'] == true,
      lastSeen: json['lastSeen'] != null
          ? int.tryParse(json['lastSeen'].toString())
          : null,
    );
  }

  /// Stale if lastSeen is older than 60 seconds
  bool get isStale {
    if (lastSeen == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(lastSeen!);
    return DateTime.now().difference(last).inSeconds > 60;
  }

  bool get isOnline => connected && !isStale;
}
