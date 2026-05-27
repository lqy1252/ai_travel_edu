import 'package:flutter/material.dart';
import '../models/location.dart';

class GuideBottomSheet extends StatelessWidget {
  final TourLocation location;
  final VoidCallback? onClose;

  const GuideBottomSheet({
    super.key,
    required this.location,
    this.onClose,
  });

  static Future<void> show(BuildContext context, TourLocation location) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GuideBottomSheet(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖动指示条
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 景点名称
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 讲解文字
          Text(
            location.description,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 20),

          // 语音播放按钮
          if (location.audioUrl.isNotEmpty)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: 接入音频播放
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('语音讲解功能开发中...')),
                  );
                },
                icon: const Icon(Icons.volume_up),
                label: const Text('播放语音讲解'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
