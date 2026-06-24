import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';

/// What the picker returns: a precise point plus its human-readable address.
class PickedLocation {
  final double lat;
  final double lng;
  final String address;
  const PickedLocation(this.lat, this.lng, this.address);
}

/// Grab-style map picker: drag the map under a fixed centre pin; the address is
/// reverse-geocoded as you move. Tap "Use this location" to return the point.
/// Uses OpenStreetMap tiles (no API key) and the platform geocoder.
class LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Default to central Algiers when we have no better starting point.
  static const _algiers = LatLng(36.7538, 3.0588);

  final _mapController = MapController();
  final _search = TextEditingController();

  late LatLng _center = widget.initial ?? _algiers;
  String _address = '';
  bool _resolving = false;
  bool _locating = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve(_center));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// Reverse-geocode [p] into a readable address (debounced by the caller).
  Future<void> _resolve(LatLng p) async {
    setState(() => _resolving = true);
    String label;
    try {
      final marks = await placemarkFromCoordinates(p.latitude, p.longitude);
      label = marks.isEmpty ? _coords(p) : _format(marks.first, p);
    } catch (_) {
      label = _coords(p);
    }
    if (!mounted) return;
    setState(() {
      _address = label;
      _resolving = false;
    });
  }

  String _coords(LatLng p) =>
      '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';

  String _format(Placemark m, LatLng p) {
    final parts = <String>[
      if ((m.name ?? '').isNotEmpty && m.name != m.street) m.name!,
      if ((m.street ?? '').isNotEmpty) m.street!,
      if ((m.subLocality ?? '').isNotEmpty) m.subLocality!,
      if ((m.locality ?? '').isNotEmpty) m.locality!,
      if ((m.administrativeArea ?? '').isNotEmpty) m.administrativeArea!,
    ];
    final seen = <String>{};
    final unique = parts.where((s) => seen.add(s)).toList();
    return unique.isEmpty ? _coords(p) : unique.join(', ');
  }

  void _onMove(MapCamera camera, bool hasGesture) {
    _center = camera.center;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 550), () {
      if (mounted) _resolve(_center);
    });
  }

  Future<void> _searchPlace() async {
    final q = _search.text.trim();
    if (q.isEmpty) return;
    final noResults = AppLocalizations.of(context).noResultsYet;
    FocusScope.of(context).unfocus();
    try {
      final results = await locationFromAddress(q);
      if (!mounted || results.isEmpty) return;
      final loc = results.first;
      final p = LatLng(loc.latitude, loc.longitude);
      _mapController.move(p, 16);
      _center = p;
      _resolve(p);
    } catch (_) {
      if (mounted) _snack(noResults);
    }
  }

  Future<void> _locateMe() async {
    final t = AppLocalizations.of(context);
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _snack(t.locationPermissionDenied);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack(t.locationPermissionDenied);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final p = LatLng(pos.latitude, pos.longitude);
      _mapController.move(p, 16);
      _center = p;
      await _resolve(p);
    } catch (_) {
      _snack(t.locationPermissionDenied);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.red));

  void _confirm() {
    Navigator.of(context).pop(
      PickedLocation(_center.latitude, _center.longitude, _address),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.pickLocation)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: _onMove,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.streetfootball.dz',
              ),
            ],
          ),

          // Fixed centre pin (its tip sits on the map centre).
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: const Icon(Icons.location_on,
                    color: AppColors.red, size: 46),
              ),
            ),
          ),

          // Search bar.
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
              elevation: 4,
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchPlace(),
                style: AppTextStyles.body(AppColors.darkTextPrimary),
                decoration: InputDecoration(
                  hintText: t.searchPlace,
                  hintStyle: AppTextStyles.body(AppColors.darkTextMuted),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.darkTextMuted),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                ),
              ),
            ),
          ),

          // Locate-me FAB.
          Positioned(
            right: 16,
            bottom: 168,
            child: FloatingActionButton.small(
              heroTag: 'locate',
              backgroundColor: AppColors.darkSurface,
              onPressed: _locating ? null : _locateMe,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.green))
                  : const Icon(Icons.my_location_rounded,
                      color: AppColors.green),
            ),
          ),

          // Address card + confirm button.
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place_rounded,
                          color: AppColors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _resolving
                            ? Text(t.loading,
                                style: AppTextStyles.body(
                                    AppColors.darkTextMuted))
                            : Text(
                                _address.isEmpty ? t.movePinHint : _address,
                                style: AppTextStyles.body(
                                    AppColors.darkTextPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    label: t.useThisLocation,
                    icon: Icons.check_rounded,
                    onPressed: _resolving || _address.isEmpty ? null : _confirm,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
