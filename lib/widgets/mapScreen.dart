import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';

class EnhancedRoutePlanner extends StatefulWidget {
  const EnhancedRoutePlanner({super.key});

  @override
  State<EnhancedRoutePlanner> createState() => _EnhancedRoutePlannerState();
}

class _EnhancedRoutePlannerState extends State<EnhancedRoutePlanner> {
  final MapController _mapController = MapController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final Location _locationService = Location();
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _endFocusNode = FocusNode();

  LatLng? _currentLocation;
  LatLng? _startPoint;
  LatLng? _endPoint;
  List<LatLng> _routePoints = [];
  double _distance = 0.0;
  bool _isLoading = false;
  bool _useCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await _locationService.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _locationService.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    _locationService.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        if (_useCurrentLocation && _startPoint == null) {
          _startPoint = _currentLocation;
          _startController.text = "My Current Location";
        }
      });
    });
  }

  Future<void> _fetchRoute() async {
    if (_startPoint == null || _endPoint == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/'
              '${_startPoint!.longitude},${_startPoint!.latitude};'
              '${_endPoint!.longitude},${_endPoint!.latitude}'
              '?overview=full&geometries=geojson',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _routePoints = (data['routes'][0]['geometry']['coordinates'] as List)
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
          _distance = data['routes'][0]['distance'] / 1000;
        });

        _zoomToRoute();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch route: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _zoomToRoute() {
    if (_startPoint == null || _endPoint == null) return;

    final center = LatLng(
      (_startPoint!.latitude + _endPoint!.latitude) / 2,
      (_startPoint!.longitude + _endPoint!.longitude) / 2,
    );

    final distance = const Distance().distance(_startPoint!, _endPoint!);
    double zoom;
    if (distance < 1000) zoom = 16.0;
    else if (distance < 5000) zoom = 14.0;
    else if (distance < 20000) zoom = 12.0;
    else zoom = 10.0;

    _mapController.move(center, zoom);
  }

  Future<List<Map<String, dynamic>>> _getLocationSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&addressdetails=1&limit=5',
        ),
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Suggestion error: $e');
    }
    return [];
  }

  void _handleMapTap(LatLng point) {
    if (_startFocusNode.hasFocus) {
      setState(() {
        _startPoint = point;
        _startController.text = "Selected Location (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})";
      });
      _startFocusNode.unfocus();
    } else if (_endFocusNode.hasFocus) {
      setState(() {
        _endPoint = point;
        _endController.text = "Selected Location (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})";
      });
      _endFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Route Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 15.0);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _useCurrentLocation,
                      onChanged: (value) {
                        setState(() {
                          _useCurrentLocation = value ?? false;
                          if (_useCurrentLocation && _currentLocation != null) {
                            _startPoint = _currentLocation;
                            _startController.text = "My Current Location";
                          } else {
                            _startPoint = null;
                            _startController.clear();
                          }
                        });
                      },
                    ),
                    const Text('Use my current location'),
                  ],
                ),
                TypeAheadField(
                  controller: _startController,
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Start Location',
                        prefixIcon: Icon(Icons.location_pin, color: Colors.green),
                      ),
                      onTap: () => setState(() => _useCurrentLocation = false),
                    );
                  },
                  suggestionsCallback: (pattern) => _getLocationSuggestions(pattern),
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion['display_name'] ?? 'Unknown'),
                    );
                  },
                  onSelected: (suggestion) {
                    setState(() {
                      _startPoint = LatLng(
                        double.parse(suggestion['lat']),
                        double.parse(suggestion['lon']),
                      );
                      _startController.text = suggestion['display_name'];
                      _useCurrentLocation = false;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TypeAheadField(
                  controller: _endController,
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        prefixIcon: Icon(Icons.location_pin, color: Colors.red),
                      ),
                    );
                  },
                  suggestionsCallback: (pattern) => _getLocationSuggestions(pattern),
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion['display_name'] ?? 'Unknown'),
                    );
                  },
                  onSelected: (suggestion) {
                    setState(() {
                      _endPoint = LatLng(
                        double.parse(suggestion['lat']),
                        double.parse(suggestion['lon']),
                      );
                      _endController.text = suggestion['display_name'];
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _fetchRoute,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Get Route'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? const LatLng(51.505, -0.09),
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onTap: (tapPosition, latLng) => _handleMapTap(latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.enhancedrouteplanner',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null && _useCurrentLocation)
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
                      ),
                    if (_startPoint != null)
                      Marker(
                        point: _startPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, color: Colors.green, size: 40),
                      ),
                    if (_endPoint != null)
                      Marker(
                        point: _endPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_distance > 0)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: Text(
                'Distance: ${_distance.toStringAsFixed(2)} km',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _startFocusNode.dispose();
    _endFocusNode.dispose();
    super.dispose();
  }
}