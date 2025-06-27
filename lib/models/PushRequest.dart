class PushRequest {
  final String fromSlotId;
  final String toTherapistId;

  PushRequest({
    required this.fromSlotId,
    required this.toTherapistId,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromSlotId': fromSlotId,
      'toTherapistId': toTherapistId,
    };
  }
}
