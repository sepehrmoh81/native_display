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

  factory SignalingMessage.fromJson(Map<String, dynamic> json) {
    return SignalingMessage(
      type: SignalingType.fromString(json['type'] as String? ?? 'error'),
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      senderId: json['senderId'] as String? ?? '',
      targetId: json['targetId'] as String?,
    );
  }

  String encode() => jsonEncode(toJson());

  factory SignalingMessage.decode(String raw) =>
      SignalingMessage.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
