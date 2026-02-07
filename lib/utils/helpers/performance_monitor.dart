import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance Monitor
/// Tracks app performance metrics and provides insights
/// Use in development to identify performance bottlenecks
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<Duration> _frameDurations = [];
  final Map<String, int> _widgetRebuildCounts = {};
  int _totalFrames = 0;
  int _droppedFrames = 0;
  DateTime? _sessionStart;

  /// Initialize performance monitoring
  void initialize() {
    _sessionStart = DateTime.now();
    
    if (kDebugMode) {
      SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
      debugPrint('📊 PerformanceMonitor: Initialized');
    }
  }

  /// Frame timing callback
  void _onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      _totalFrames++;
      
      final buildDuration = timing.buildDuration;
      final rasterDuration = timing.rasterDuration;
      final totalDuration = buildDuration + rasterDuration;
      
      _frameDurations.add(totalDuration);
      
      // Keep only last 100 frames
      if (_frameDurations.length > 100) {
        _frameDurations.removeAt(0);
      }
      
      // Check if frame was dropped (>16.67ms for 60fps)
      if (totalDuration.inMicroseconds > 16670) {
        _droppedFrames++;
      }
    }
  }

  /// Track widget rebuild
  void trackRebuild(String widgetName) {
    if (!kDebugMode) return;
    
    _widgetRebuildCounts[widgetName] = (_widgetRebuildCounts[widgetName] ?? 0) + 1;
  }

  /// Get performance metrics
  Map<String, dynamic> getMetrics() {
    if (_frameDurations.isEmpty) {
      return {
        'status': 'No data collected yet',
      };
    }

    final avgFrameTime = _frameDurations
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b) / _frameDurations.length;
    
    final avgFps = 1000000 / avgFrameTime;
    final dropRate = _totalFrames > 0 ? (_droppedFrames / _totalFrames) * 100 : 0;
    
    final sessionDuration = _sessionStart != null 
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;

    return {
      'averageFPS': avgFps.toStringAsFixed(1),
      'averageFrameTime': '${(avgFrameTime / 1000).toStringAsFixed(2)}ms',
      'totalFrames': _totalFrames,
      'droppedFrames': _droppedFrames,
      'dropRate': '${dropRate.toStringAsFixed(2)}%',
      'sessionDuration': sessionDuration.toString(),
      'topRebuildWidgets': _getTopRebuildWidgets(),
    };
  }

  /// Get widgets with most rebuilds
  Map<String, int> _getTopRebuildWidgets() {
    final sorted = _widgetRebuildCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(10));
  }

  /// Print performance report
  void printReport() {
    if (!kDebugMode) return;
    
    final metrics = getMetrics();
    debugPrint('\n📊 ===== PERFORMANCE REPORT =====');
    debugPrint('Average FPS: ${metrics['averageFPS']}');
    debugPrint('Average Frame Time: ${metrics['averageFrameTime']}');
    debugPrint('Total Frames: ${metrics['totalFrames']}');
    debugPrint('Dropped Frames: ${metrics['droppedFrames']}');
    debugPrint('Drop Rate: ${metrics['dropRate']}');
    debugPrint('Session Duration: ${metrics['sessionDuration']}');
    
    if (_widgetRebuildCounts.isNotEmpty) {
      debugPrint('\nTop Rebuilding Widgets:');
      final topWidgets = metrics['topRebuildWidgets'] as Map<String, int>;
      topWidgets.forEach((widget, count) {
        debugPrint('  $widget: $count rebuilds');
      });
    }
    
    debugPrint('================================\n');
  }

  /// Reset metrics
  void reset() {
    _frameDurations.clear();
    _widgetRebuildCounts.clear();
    _totalFrames = 0;
    _droppedFrames = 0;
    _sessionStart = DateTime.now();
    debugPrint('📊 PerformanceMonitor: Metrics reset');
  }

  /// Stop monitoring
  void dispose() {
    if (kDebugMode) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
      debugPrint('📊 PerformanceMonitor: Disposed');
    }
  }
}

/// Widget Rebuild Tracker
/// Wraps a widget to track its rebuild count
class RebuildTracker extends StatelessWidget {
  final Widget child;
  final String name;

  const RebuildTracker({
    super.key,
    required this.child,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      PerformanceMonitor().trackRebuild(name);
    }
    return child;
  }
}

/// Performance Overlay Widget
/// Shows real-time performance metrics on screen
class PerformanceOverlay extends StatefulWidget {
  final Widget child;

  const PerformanceOverlay({
    super.key,
    required this.child,
  });

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_showOverlay)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMetricsText(),
                ],
              ),
            ),
          ),
        Positioned(
          top: 50,
          left: 10,
          child: FloatingActionButton.small(
            onPressed: () => setState(() => _showOverlay = !_showOverlay),
            child: Icon(_showOverlay ? Icons.close : Icons.speed),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsText() {
    final metrics = PerformanceMonitor().getMetrics();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricRow('FPS', metrics['averageFPS'] ?? 'N/A'),
        _buildMetricRow('Frame Time', metrics['averageFrameTime'] ?? 'N/A'),
        _buildMetricRow('Dropped', '${metrics['droppedFrames'] ?? 0}'),
        _buildMetricRow('Drop Rate', metrics['dropRate'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Example usage:
/// 
/// // In main.dart
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   if (kDebugMode) {
///     PerformanceMonitor().initialize();
///   }
///   
///   runApp(const MyApp());
/// }
/// 
/// // Wrap your app with performance overlay
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return PerformanceOverlay(
///       child: MaterialApp(
///         home: HomePage(),
///       ),
///     );
///   }
/// }
/// 
/// // Track widget rebuilds
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return RebuildTracker(
///       name: 'MyWidget',
///       child: Container(
///         child: Text('Hello'),
///       ),
///     );
///   }
/// }
/// 
/// // Print performance report
/// PerformanceMonitor().printReport();
