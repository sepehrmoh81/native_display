import 'dart:convert';

enum SignalingType {
  offer,
  answer,
  candidate,
  ping,
  pong,
  disconnect,
  handshake,
  error;

  static SignalingType fromString(String val) {
    for (final type in SignalingType.values) {
      if (type.name.toLowerCase() == val.toLowerCase()) {
        return type;
      }
    }
    return SignalingType.error;
  }
}

class SignalingMessage {
  final SignalingType type;
  final Map<String, dynamic> data;
  final String senderId;
  final String? targetId;

  const SignalingMessage({
    required this.type,
    required this.data,
    required this.senderId,
    this.targetId,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'data': data,
        'senderId': senderId,
        if (targetId != null) 'targetId': targetId,
      };

  factory SignalingMessage.fromJson(Map<dynamic, dynamic> json) {
    final rawData = json['data'];
    final Map<String, dynamic> safeData;
    if (rawData is Map) {
      safeData = Map<String, dynamic>.from(rawData);
    } else {
      safeData = {};
    }

    return SignalingMessage(
      type: SignalingType.fromString(json['type']?.toString() ?? 'error'),
      data: safeData,
      senderId: json['senderId']?.toString() ?? '',
      targetId: json['targetId']?.toString(),
    );
  }

  String encode() => jsonEncode(toJson());

  factory SignalingMessage.decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return SignalingMessage.fromJson(decoded);
    }
    throw const FormatException('Expected JSON map for SignalingMessage');
  }
}
