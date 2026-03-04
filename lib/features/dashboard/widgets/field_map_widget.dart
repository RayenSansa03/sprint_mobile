import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../core/theme/app_colors.dart';

class FieldMapWidget extends StatefulWidget {
  const FieldMapWidget({super.key});

  @override
  State<FieldMapWidget> createState() => _FieldMapWidgetState();
}

class _FieldMapWidgetState extends State<FieldMapWidget> {
  MapLibreMapController? mapController;

  final String osmStyle = 'data:application/json;base64,eyJ2ZXJzaW9uIjo4LCJzb3VyY2VzIjp7Im9zbS10aWxlcyI6eyJ0eXBlIjoicmFzdGVyIiwidGlsZXMiOlsiaHR0cHM6Ly90aWxlLm9wZW5zdHJlZXRtYXAub3JnL3t6fS97eH0ve3l9LnBuZyJdLCJ0aWxlU2l6ZSI6MjU2LCJhdHRyaWJ1dGlvbiI6IiBPcGVuU3RyZWV0TWFwIGNvbnRyaWJ1dG9ycyJ9fSwibGF5ZXJzIjpbeyJpZCI6Im9zbS1sYXllciIsInR5cGUiOiJyYXN0ZXIiLCJzb3VyY2UiOiJvc20tdGlsZXMiLCJtaW56b29tIjowLCJtYXh6b29tIjoxOX1dfQ==';

  void _onMapCreated(MapLibreMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onStyleLoaded() {
    _addFieldMarkers();
  }

  void _addFieldMarkers() {
    if (mapController == null) return;
    
    // Mornag Field
    mapController!.addSymbol(
      SymbolOptions(
        geometry: const LatLng(36.6775, 10.2878),
        textField: '🌾 Mornag Field (Healthy)',
        textSize: 16.0,
        textAnchor: 'bottom',
        textColor: '#2E7D32',
        textHaloColor: '#FFFFFF',
        textHaloWidth: 2.0,
      ),
    );

    // Sidi Thabet Field
    mapController!.addSymbol(
      SymbolOptions(
        geometry: const LatLng(36.9103, 10.0401),
        textField: '🚜 Sidi Thabet (Alert)',
        textSize: 16.0,
        textAnchor: 'bottom',
        textColor: '#D32F2F',
        textHaloColor: '#FFFFFF',
        textHaloWidth: 2.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            RepaintBoundary(
              child: MapLibreMap(
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoaded,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(36.75, 10.15),
                  zoom: 9.0,
                ),
                styleString: osmStyle,
                myLocationEnabled: false,
                trackCameraPosition: true,
              ),
            ),
            if (mapController == null)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.map_outlined, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Interactive Farm Map',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
