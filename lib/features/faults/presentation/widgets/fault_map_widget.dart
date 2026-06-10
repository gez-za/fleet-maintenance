import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/maintenance_enums.dart';

class FaultMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final PanneCriticite criticality;
  final String? vehicleInfo;
  final double height;

  const FaultMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.criticality,
    this.vehicleInfo,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(latitude, longitude);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: position,
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.fleet_maintenance_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: position,
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    onTap: () {
                      if (vehicleInfo != null) {
                        _showInfoPopup(context);
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            criticality.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: criticality.color,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.location_on,
                          color: criticality.color,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Infos Panne'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Véhicule: $vehicleInfo'),
            const SizedBox(height: 8),
            Text('Criticité: ${criticality.label}'),
            const SizedBox(height: 8),
            Text('Position: $latitude, $longitude'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
