import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/bank_location.dart';
import '../services/database_helper.dart';
import '../styles/colors.dart';
import '../styles/typography.dart';

class BankMapScreen extends StatefulWidget {
  const BankMapScreen({super.key});

  @override
  State<BankMapScreen> createState() => _BankMapScreenState();
}

class _BankMapScreenState extends State<BankMapScreen> {
  MapController? _mapController;
  Position? _currentPosition;
  List<BankLocation> _bankLocations = [];
  List<BankLocation> _nearbyLocations = [];
  List<Marker> _markers = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'bank', 'atm'
  double _radius = 5.0; // km

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _requestPermissions();
    await _getCurrentLocation();
    await _loadBankLocations();
    _updateMarkers();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      // Default to Port Louis if location fails
      _currentPosition = Position(
        latitude: -20.1609,
        longitude: 57.5012,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  Future<void> _loadBankLocations() async {
    final dbHelper = DatabaseHelper();
    _bankLocations = await dbHelper.getAllLocations();

    if (_currentPosition != null) {
      _nearbyLocations = await dbHelper.getNearbyLocations(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _radius,
      );
    }
  }

  void _updateMarkers() {
    _markers.clear();

    if (_currentPosition != null) {
      _markers.add(Marker(
        point: latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        width: 40,
        height: 40,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40,
        ),
      ));
    }

    // Filter locations based on current filter
    List<BankLocation> filteredLocations = _bankLocations;
    if (_filter != 'all') {
      filteredLocations = _bankLocations
          .where((location) => location.type == _filter)
          .toList();
    }

    // Add bank/ATM markers
    for (var location in filteredLocations) {
      _markers.add(Marker(
        point: latlong.LatLng(location.latitude, location.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showLocationDetails(location),
          child: Icon(
            Icons.location_pin,
            color: location.type == 'bank' ? Colors.green : Colors.orange,
            size: 40,
          ),
        ),
      ));
    }
  }

  void _showLocationDetails(BankLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationDetailsSheet(location),
    );
  }

  Widget _buildLocationDetailsSheet(BankLocation location) {
    final distance = _currentPosition != null
        ? (location.distanceFrom(
        _currentPosition!.latitude,
        _currentPosition!.longitude) /
        1000)
        .toStringAsFixed(1)
        : 'Unknown';

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: location.type == 'bank'
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          location.type == 'bank'
                              ? Icons.account_balance
                              : Icons.local_atm,
                          color: location.type == 'bank'
                              ? AppColors.success
                              : AppColors.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.name,
                              style: AppTypography.h4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (location.bankName != null)
                              Text(
                                location.bankName!,
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.location_on, location.address),
                  if (location.workingHours != null)
                    _buildDetailRow(Icons.schedule, location.workingHours!),
                  if (location.phoneNumber != null)
                    _buildDetailRow(Icons.phone, location.phoneNumber!),
                  _buildDetailRow(Icons.directions, '$distance km away'),
                  if (location.services != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Services Available',
                      style: AppTypography.h5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: location.services!.map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            service.trim(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openDirections(location),
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body2,
            ),
          ),
        ],
      ),
    );
  }

  void _openDirections(BankLocation location) async {
    // Construct Google Maps URL for directions
    String url;
    if (_currentPosition != null) {
      url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}'
          '&destination=${location.latitude},${location.longitude}'
          '&travelmode=driving';
    } else {
      // Fallback to opening the destination directly if current position is unavailable
      url = 'https://www.google.com/maps/search/?api=1'
          '&query=${location.latitude},${location.longitude}';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open directions')),
      );
    }
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Banks', 'bank'),
          const SizedBox(width: 8),
          _buildFilterChip('ATMs', 'atm'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_nearbyLocations.length} nearby',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = value;
          _updateMarkers();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banks & ATMs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null && _mapController != null) {
                _mapController!.move(
                  latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  15.0,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: latlong.LatLng(
                  _currentPosition?.latitude ?? -20.1609,
                  _currentPosition?.longitude ?? 57.5012,
                ),
                zoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'mu.bom.finlit.app',
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}