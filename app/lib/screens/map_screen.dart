import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/user.dart';
import '../models/location.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../widgets/guide_bottom_sheet.dart';
import 'login_screen.dart';

class MapScreen extends StatefulWidget {
  final User user;
  const MapScreen({super.key, required this.user});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<TourLocation> _locations = [];
  LatLng? _currentPosition;
  bool _loading = true;
  String? _error;
  StreamSubscription<Position>? _posSub;

  // 西南大学中心坐标
  static const _swuCenter = LatLng(29.8275, 106.4250);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. 加载讲解点
      final locations = await ApiService.getLocations();
      setState(() { _locations = locations; });

      // 2. 尝试获取定位（Web版可能失败，不影响地图显示）
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission != LocationPermission.denied &&
              permission != LocationPermission.deniedForever) {
            final pos = await Geolocator.getCurrentPosition();
            setState(() {
              _currentPosition = LatLng(pos.latitude, pos.longitude);
            });

            // 启动持续定位
            _posSub = Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 5,
              ),
            ).listen((pos) {
              setState(() {
                _currentPosition = LatLng(pos.latitude, pos.longitude);
              });
              _checkGeofences(pos);
            });
          }
        }
      } catch (_) {
        // Web版或定位不可用时，忽略错误，仍然显示地图
      }

      setState(() { _loading = false; });
    } catch (e) {
      setState(() { _error = '加载失败: $e'; _loading = false; });
    }
  }

  final Set<int> _triggered = {};

  void _checkGeofences(Position pos) {
    for (final loc in _locations) {
      final distance = LocationService.calculateDistance(
        pos.latitude, pos.longitude,
        loc.latitude, loc.longitude,
      );
      if (distance <= loc.radius && !_triggered.contains(loc.id)) {
        _triggered.add(loc.id);
        GuideBottomSheet.show(context, loc);
      } else if (distance > loc.radius) {
        _triggered.remove(loc.id);
      }
    }
  }

  void _logout() {
    LocationService.stopTracking();
    _posSub?.cancel();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('西南大学校园导览'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _currentPosition != null
                ? () {
                    final gcj = LocationService.wgs84ToGcj02(_currentPosition!.latitude, _currentPosition!.longitude);
                    _mapController.move(LatLng(gcj.$1, gcj.$2), 17);
                  }
                : null,
            tooltip: '定位到当前位置',
          ),
          PopupMenuButton(
            onSelected: (v) { if (v == 'logout') _logout(); },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'user', enabled: false, child: Text('当前用户: ${widget.user.username}')),
              const PopupMenuItem(value: 'logout', child: Text('退出登录')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _init, child: const Text('重试')),
                  ],
                ))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: () {
                      if (_currentPosition != null) {
                        final gcj = LocationService.wgs84ToGcj02(_currentPosition!.latitude, _currentPosition!.longitude);
                        return LatLng(gcj.$1, gcj.$2);
                      }
                      final gcj = LocationService.wgs84ToGcj02(_swuCenter.latitude, _swuCenter.longitude);
                      return LatLng(gcj.$1, gcj.$2);
                    }(),
                    initialZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
                      subdomains: const ['1', '2', '3', '4'],
                    ),
                    // 讲解点标记（WGS-84 转 GCJ-02 对齐高德瓦片）
                    MarkerLayer(
                      markers: _locations.map((loc) {
                        final gcj = LocationService.wgs84ToGcj02(loc.latitude, loc.longitude);
                        return Marker(
                        point: LatLng(gcj.$1, gcj.$2),
                        width: 80,
                        height: 80,
                        child: GestureDetector(
                          onTap: () => GuideBottomSheet.show(context, loc),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: Text(
                                  loc.name.length > 6 ? '${loc.name.substring(0, 6)}...' : loc.name,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.location_on, color: Colors.red, size: 36),
                            ],
                          ),
                        ),
                        );
                      }).toList(),
                    ),
                    // 当前位置蓝点（也需要转GCJ-02）
                    if (_currentPosition != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: () {
                            final gcj = LocationService.wgs84ToGcj02(_currentPosition!.latitude, _currentPosition!.longitude);
                            return LatLng(gcj.$1, gcj.$2);
                          }(),
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(60),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.blue,
                                child: CircleAvatar(radius: 3, backgroundColor: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ]),
                  ],
                ),
      // 景点列表抽屉
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                child: Center(
                  child: Text('讲解景点列表', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _locations.length,
                  itemBuilder: (_, i) {
                    final loc = _locations[i];
                    return ListTile(
                      leading: const Icon(Icons.place, color: Colors.green),
                      title: Text(loc.name),
                      subtitle: Text('围栏半径: ${loc.radius.toInt()}米'),
                      onTap: () {
                        Navigator.pop(context);
                        final gcj = LocationService.wgs84ToGcj02(loc.latitude, loc.longitude);
                        _mapController.move(LatLng(gcj.$1, gcj.$2), 18);
                        GuideBottomSheet.show(context, loc);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
