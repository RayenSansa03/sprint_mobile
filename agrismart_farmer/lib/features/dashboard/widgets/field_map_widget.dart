import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../dashboard_provider.dart';
import '../dashboard_models.dart';
import '../../../core/theme/app_colors.dart';

// ─── Sensor type configuration ──────────────────────────────────────────────

class _SensorStyle {
  final IconData icon;
  final Color color;
  final String label;

  const _SensorStyle({
    required this.icon,
    required this.color,
    required this.label,
  });
}

final _sensorStyles = <String, _SensorStyle>{
  'temperature': _SensorStyle(
    icon: Icons.thermostat_rounded,
    color: const Color(0xFFFF6B35),
    label: 'Température',
  ),
  'humidity': _SensorStyle(
    icon: Icons.water_drop_rounded,
    color: const Color(0xFF29B6F6),
    label: 'Humidité',
  ),
  'soil_moisture': _SensorStyle(
    icon: Icons.grass_rounded,
    color: const Color(0xFF66BB6A),
    label: 'Humidité Sol',
  ),
  'ph': _SensorStyle(
    icon: Icons.science_rounded,
    color: const Color(0xFFAB47BC),
    label: 'pH',
  ),
  'nitrogen': _SensorStyle(
    icon: Icons.eco_rounded,
    color: const Color(0xFF26A69A),
    label: 'Azote',
  ),
  'light': _SensorStyle(
    icon: Icons.wb_sunny_rounded,
    color: const Color(0xFFFFCA28),
    label: 'Lumière',
  ),
  'wind': _SensorStyle(
    icon: Icons.air_rounded,
    color: const Color(0xFF78909C),
    label: 'Vent',
  ),
  'rainfall': _SensorStyle(
    icon: Icons.umbrella_rounded,
    color: const Color(0xFF42A5F5),
    label: 'Précipitations',
  ),
};

_SensorStyle _styleFor(String type) {
  final key = type.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  return _sensorStyles[key] ??
      const _SensorStyle(
        icon: Icons.sensors_rounded,
        color: Color(0xFFFF5252),
        label: 'Capteur',
      );
}

// ─── Widget ─────────────────────────────────────────────────────────────────

class FieldMapWidget extends ConsumerStatefulWidget {
  const FieldMapWidget({super.key});

  @override
  ConsumerState<FieldMapWidget> createState() => _FieldMapWidgetState();
}

class _FieldMapWidgetState extends ConsumerState<FieldMapWidget> {
  final MapController _mapController = MapController();
  PlotSensor? _selectedSensor;
  String? _selectedPlotName;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitToBounds(List<Plot> plots) {
    final allPoints = plots
        .expand((p) => p.boundary ?? <GeoPoint>[])
        .map((g) => LatLng(g.lat, g.lng))
        .toList();
    if (allPoints.isEmpty) return;
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(allPoints),
          padding: const EdgeInsets.all(48),
        ),
      );
    } catch (_) {}
  }

  void _showSensorPopup(PlotSensor sensor, String plotName) {
    setState(() {
      _selectedSensor = sensor;
      _selectedPlotName = plotName;
    });
  }

  void _closeSensorPopup() {
    setState(() {
      _selectedSensor = null;
      _selectedPlotName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plots = ref.watch(dashboardProvider).plots;

    // Auto-fit on first load
    if (plots.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fitToBounds(plots);
      });
    }

    // Build polygons
    final polygons = plots
        .where((p) => p.boundary != null && p.boundary!.length >= 3)
        .map((plot) {
      final pts = plot.boundary!.map((g) => LatLng(g.lat, g.lng)).toList();
      final isAlert = plot.status == 'alert';
      return Polygon(
        points: pts,
        color: (isAlert ? Colors.red : const Color(0xFF4CAF50)).withOpacity(0.4),
        borderColor: Colors.white,
        borderStrokeWidth: 2.5,
        label: plot.name,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      );
    }).toList();

    // Build sensor markers with type-specific icons
    final sensorMarkers = <Marker>[];
    for (final plot in plots) {
      for (final sensor in plot.sensors ?? []) {
        final style = _styleFor(sensor.type);
        final isSelected = _selectedSensor?.id == sensor.id;

        sensorMarkers.add(Marker(
          point: LatLng(sensor.position.lat, sensor.position.lng),
          width: isSelected ? 46 : 38,
          height: isSelected ? 46 : 38,
          child: GestureDetector(
            onTap: () => _showSensorPopup(sensor, plot.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: style.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: style.color.withOpacity(0.5),
                    blurRadius: isSelected ? 16 : 8,
                    spreadRadius: isSelected ? 4 : 1,
                  ),
                ],
              ),
              child: Icon(
                style.icon,
                color: Colors.white,
                size: isSelected ? 22 : 18,
              ),
            ),
          ),
        ));
      }
    }

    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // ─── Map ────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(36.75, 10.2),
                initialZoom: 7.0,
                onTap: (_, __) => _closeSensorPopup(),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.agrismart.farmer',
                ),
                PolygonLayer(polygons: polygons),
                MarkerLayer(markers: sensorMarkers),
              ],
            ),

            // ─── Sensor popup ────────────────────────────────────
            if (_selectedSensor != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _SensorInfoCard(
                  sensor: _selectedSensor!,
                  plotName: _selectedPlotName ?? '',
                  onClose: _closeSensorPopup,
                ),
              ),

            // ─── Plot count badge ────────────────────────────────
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${plots.length} Zones de Culture',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Fit button ──────────────────────────────────────
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  if (plots.isNotEmpty) _fitToBounds(plots);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.center_focus_strong_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sensor info popup card ──────────────────────────────────────────────────

class _SensorInfoCard extends StatelessWidget {
  final PlotSensor sensor;
  final String plotName;
  final VoidCallback onClose;

  const _SensorInfoCard({
    required this.sensor,
    required this.plotName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(sensor.type);
    final isOnline = sensor.status.toLowerCase() == 'online';
    final hasReading = sensor.lastValue != null;

    String lastReadingStr = '—';
    if (sensor.lastReadingAt != null) {
      lastReadingStr = DateFormat('dd/MM/yyyy HH:mm').format(sensor.lastReadingAt!);
    }

    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: style.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(style.icon, color: style.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        style.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: style.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'En ligne' : 'Hors ligne',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                ),
              ],
            ),

            const Divider(height: 20),

            // Data rows
            _InfoRow(
              icon: Icons.location_on_rounded,
              label: 'Parcelle',
              value: plotName,
            ),
            if (hasReading) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: style.icon,
                iconColor: style.color,
                label: 'Dernière valeur',
                value:
                    '${sensor.lastValue!.toStringAsFixed(1)} ${sensor.unit ?? ''}',
                valueStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: style.color,
                ),
              ),
            ],
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: 'Dernière lecture',
              value: lastReadingStr,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.badge_rounded,
              label: 'ID Capteur',
              value: sensor.id,
              valueStyle: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label : ',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
