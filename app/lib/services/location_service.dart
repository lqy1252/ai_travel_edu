import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/location.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStream;
  static final Set<int> _triggeredLocations = {};
  static Function(TourLocation)? onGeofenceTriggered;

  /// 计算两个经纬度之间的距离（米）
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  /// 检查权限并启动持续定位
  static Future<bool> startTracking(List<TourLocation> locations) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // 每移动5米更新一次
      ),
    ).listen((Position position) {
      _checkGeofences(position, locations);
    });

    return true;
  }

  /// 检查是否进入任何讲解点的围栏范围
  static void _checkGeofences(Position position, List<TourLocation> locations) {
    for (final location in locations) {
      final distance = calculateDistance(
        position.latitude, position.longitude,
        location.latitude, location.longitude,
      );

      if (distance <= location.radius) {
        // 进入围栏范围，且之前未触发过
        if (!_triggeredLocations.contains(location.id)) {
          _triggeredLocations.add(location.id);
          onGeofenceTriggered?.call(location);
        }
      } else {
        // 离开围栏范围，重置触发状态
        _triggeredLocations.remove(location.id);
      }
    }
  }

  /// 停止定位追踪
  static void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _triggeredLocations.clear();
  }

  /// 重置触发状态（允许重新触发）
  static void resetTriggers() {
    _triggeredLocations.clear();
  }

  // ===== WGS-84 转 GCJ-02 坐标转换 =====

  static const double _pi = 3.14159265358979324;
  static const double _a = 6378245.0;
  static const double _ee = 0.00669342162296594323;

  static bool _isOutOfChina(double lat, double lon) {
    return lon < 72.004 || lon > 137.8347 || lat < 0.8293 || lat > 55.8271;
  }

  static double _transformLat(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y +
        0.1 * x * y + 0.2 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * _pi) + 20.0 * sin(2.0 * x * _pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * _pi) + 40.0 * sin(y / 3.0 * _pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * _pi) + 320 * sin(y * _pi / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  static double _transformLon(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x +
        0.1 * x * y + 0.1 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * _pi) + 20.0 * sin(2.0 * x * _pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * _pi) + 40.0 * sin(x / 3.0 * _pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * _pi) + 300.0 * sin(x / 30.0 * _pi)) * 2.0 / 3.0;
    return ret;
  }

  /// WGS-84 坐标转 GCJ-02（火星坐标），用于高德地图瓦片上的标记对齐
  static (double lat, double lon) wgs84ToGcj02(double lat, double lon) {
    if (_isOutOfChina(lat, lon)) return (lat, lon);

    double dLat = _transformLat(lon - 105.0, lat - 35.0);
    double dLon = _transformLon(lon - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * _pi;
    double magic = sin(radLat);
    magic = 1 - _ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtMagic) * _pi);
    dLon = (dLon * 180.0) / (_a / sqrtMagic * cos(radLat) * _pi);
    return (lat + dLat, lon + dLon);
  }
}
