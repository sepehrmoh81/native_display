/// Utility to perform dynamic SDP munging for WebRTC screen streaming.
///
/// Configures high-bitrate thresholds (b=AS / b=TIAS), Google congestion control
/// hints (x-google-*-bitrate), and prioritizes hardware-accelerated H.264 codecs
/// over software encoders for ultra-low latency desktop mirroring.
class SdpOptimizer {
  /// Optimizes a session description protocol string for high-bandwidth, high-fps streaming.
  static String optimize(
    String sdp, {
    required int bitrateKbps,
    required int fps,
    bool preferH264 = true,
  }) {
    if (sdp.isEmpty) return sdp;

    final normalized = sdp.replaceAll('\r\n', '\n');
    final lines = normalized.split('\n');
    final result = <String>[];

    bool inVideoSection = false;
    final h264PayloadTypes = <String>[];

    // First pass: identify H.264 payload types in SDP
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('a=rtpmap:') &&
          trimmed.toUpperCase().contains('H264/90000')) {
        final match = RegExp(r'a=rtpmap:(\d+)\s+H264/90000', caseSensitive: false)
            .firstMatch(trimmed);
        if (match != null) {
          h264PayloadTypes.add(match.group(1)!);
        }
      }
    }

    final minBitrate = (bitrateKbps ~/ 3).clamp(2000, bitrateKbps);
    final startBitrate = (bitrateKbps * 2 ~/ 3).clamp(minBitrate, bitrateKbps);
    final maxBitrate = bitrateKbps;

    for (int i = 0; i < lines.length; i++) {
      var line = lines[i].trimRight();

      if (line.startsWith('m=video')) {
        inVideoSection = true;

        if (preferH264 && h264PayloadTypes.isNotEmpty) {
          // Reorder payload types to place H.264 first
          final parts = line.split(' ');
          if (parts.length > 3) {
            final header = parts.sublist(0, 3);
            final currentPts = parts.sublist(3);
            final remainingPts =
                currentPts.where((pt) => !h264PayloadTypes.contains(pt)).toList();
            line = '${header.join(" ")} ${h264PayloadTypes.join(" ")} ${remainingPts.join(" ")}';
          }
        }

        result.add(line);
        // Inject application-specific bandwidth caps directly into video m-line
        result.add('b=AS:$bitrateKbps');
        result.add('b=TIAS:${bitrateKbps * 1000}');
        continue;
      } else if (line.startsWith('m=audio') || line.startsWith('m=application')) {
        inVideoSection = false;
      }

      // Drop duplicate or conflicting bandwidth lines in video section
      if (inVideoSection &&
          (line.startsWith('b=AS:') || line.startsWith('b=TIAS:'))) {
        continue;
      }

      // Enhance video fmtp lines with google congestion control bitrate parameters
      if (inVideoSection && line.startsWith('a=fmtp:')) {
        if (!line.contains('x-google-max-bitrate')) {
          line =
              '$line;x-google-min-bitrate=$minBitrate;x-google-start-bitrate=$startBitrate;x-google-max-bitrate=$maxBitrate';
        }
      }

      result.add(line);
    }

    return result.join('\r\n');
  }
}
