import 'package:flutter/cupertino.dart';
import '../../../core/theme/apple_theme.dart';
import '../../../core/webrtc/webrtc_manager.dart';

class DiagnosticsView extends StatelessWidget {
  final WebRTCManager webrtcManager;

  const DiagnosticsView({super.key, required this.webrtcManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: webrtcManager,
      builder: (context, _) {
        final metrics = webrtcManager.metrics;
        final isConnected =
            webrtcManager.status == ConnectionStateStatus.connected;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppleTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Diagnostics & Performance', style: AppleTheme.title1.copyWith(color: AppleTheme.resolvedLabel(context))),
              const SizedBox(height: AppleTheme.spacing4),
              Text(
                'Real-time stream telemetry, round-trip latency, and WebRTC metrics.',
                style: AppleTheme.callout.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    AppleTheme.secondaryLabel,
                    context,
                  ),
                ),
              ),

              const SizedBox(height: AppleTheme.spacing24),

              // Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'STREAM FRAMERATE',
                      value: isConnected
                          ? '${metrics.fps.toStringAsFixed(1)} FPS'
                          : '-- FPS',
                      statusColor: isConnected && metrics.fps >= 55
                          ? AppleTheme.systemGreen
                          : AppleTheme.systemOrange,
                      subtitle: 'Target: ${webrtcManager.qualityConfig.effectiveFps} FPS',
                      icon: CupertinoIcons.speedometer,
                    ),
                  ),
                  const SizedBox(width: AppleTheme.spacing16),
                  Expanded(
                    child: _MetricCard(
                      title: 'NETWORK LATENCY',
                      value: isConnected
                          ? '${metrics.latencyMs.toStringAsFixed(0)} ms'
                          : '-- ms',
                      statusColor: isConnected && metrics.latencyMs < 25
                          ? AppleTheme.systemGreen
                          : AppleTheme.systemOrange,
                      subtitle: isConnected ? 'Local LAN Ultra-Low' : 'Standby',
                      icon: CupertinoIcons.stopwatch,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppleTheme.spacing16),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'BANDWIDTH CONSUMPTION',
                      value: isConnected
                          ? '${metrics.bitrateMbps.toStringAsFixed(1)} Mbps'
                          : '-- Mbps',
                      statusColor: AppleTheme.systemBlue,
                      subtitle:
                          'Allocated: ${webrtcManager.qualityConfig.effectiveBitrateKbps ~/ 1000} Mbps',
                      icon: CupertinoIcons.arrow_up_down,
                    ),
                  ),
                  const SizedBox(width: AppleTheme.spacing16),
                  Expanded(
                    child: _MetricCard(
                      title: 'PACKET LOSS',
                      value: isConnected ? '${metrics.packetLossCount}' : '0',
                      statusColor: metrics.packetLossCount == 0
                          ? AppleTheme.systemGreen
                          : AppleTheme.systemRed,
                      subtitle: metrics.packetLossCount == 0
                          ? 'Zero Dropped Packets'
                          : 'Congestion Detected',
                      icon: CupertinoIcons.layers,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppleTheme.spacing24),

              // Pipeline Details
              Text('STREAMING PIPELINE', style: AppleTheme.caption.copyWith(color: AppleTheme.resolvedTertiaryLabel(context))),
              const SizedBox(height: AppleTheme.spacing8),
              Container(
                padding: const EdgeInsets.all(AppleTheme.spacing16),
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                    AppleTheme.secondarySystemBackground,
                    context,
                  ),
                  borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                  border: Border.all(
                    color: CupertinoDynamicColor.resolve(
                      AppleTheme.separator,
                      context,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Screen Capture Pipeline',
                      value: 'Apple ScreenCaptureKit (macOS 12.3+)',
                    ),
                    const _Divider(),
                    _InfoRow(
                      label: 'Video Codec',
                      value: metrics.codec,
                    ),
                    const _Divider(),
                    _InfoRow(
                      label: 'Hardware Acceleration',
                      value: webrtcManager.qualityConfig.enableHardwareAcceleration
                          ? 'Enabled (Apple VideoToolbox / NVENC)'
                          : 'Disabled',
                    ),
                    const _Divider(),
                    _InfoRow(
                      label: 'Signaling Protocol',
                      value: 'WebSocket JSON-RPC (Port 8989)',
                    ),
                    const _Divider(),
                    _InfoRow(
                      label: 'Local Network Discovery',
                      value: 'mDNS (Bonjour) + UDP Multicast Fallback',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color statusColor;
  final String subtitle;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.statusColor,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppleTheme.spacing16),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          AppleTheme.secondarySystemBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
            AppleTheme.separator,
            context,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppleTheme.caption.copyWith(color: AppleTheme.resolvedTertiaryLabel(context))),
              const Spacer(),
              Icon(icon, size: 16, color: statusColor),
            ],
          ),
          const SizedBox(height: AppleTheme.spacing12),
          Text(
            value,
            style: AppleTheme.monoNumber.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          const SizedBox(height: AppleTheme.spacing4),
          Text(subtitle, style: AppleTheme.footnote.copyWith(color: AppleTheme.resolvedTertiaryLabel(context))),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppleTheme.spacing4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppleTheme.body.copyWith(color: AppleTheme.resolvedLabel(context))),
          Text(
            value,
            style: AppleTheme.footnote.copyWith(
              fontWeight: FontWeight.w500,
              color: CupertinoDynamicColor.resolve(
                AppleTheme.secondaryLabel,
                context,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppleTheme.spacing8),
      height: 0.5,
      color: CupertinoDynamicColor.resolve(AppleTheme.separator, context),
    );
  }
}
