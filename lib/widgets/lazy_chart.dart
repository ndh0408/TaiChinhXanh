import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';
import '../theme.dart';

typedef ChartBuilder<T> = Widget Function(BuildContext context, T data);

class LazyChart<T> extends StatefulWidget {
  final ChartType chartType;
  final Future<T> Function() dataLoader;
  final ChartBuilder<T> chartBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? title;
  final double? height;
  final EdgeInsets? padding;
  final bool autoLoad;
  final Duration? cacheDuration;

  const LazyChart({
    Key? key,
    required this.chartType,
    required this.dataLoader,
    required this.chartBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.title,
    this.height,
    this.padding,
    this.autoLoad = true,
    this.cacheDuration,
  }) : super(key: key);

  @override
  State<LazyChart<T>> createState() => _LazyChartState<T>();
}

class _LazyChartState<T> extends State<LazyChart<T>> {
  bool _hasBeenVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDataIfNeeded();
      });
    }
  }

  void _loadDataIfNeeded() {
    final chartProvider = context.read<ChartProvider>();

    // Check if data is already cached and valid
    if (chartProvider.isLoaded(widget.chartType)) {
      return;
    }

    // Load data
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final chartProvider = context.read<ChartProvider>();
      await chartProvider.loadChartData<T>(
        widget.chartType,
        widget.dataLoader,
        cacheDuration: widget.cacheDuration,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Widget _buildLoadingWidget() {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    return Container(
      height: widget.height ?? 200,
      padding: widget.padding ?? EdgeInsets.all(AppTheme.spacing4),
      decoration: AppTheme.whiteCardDecoration,
      child: Column(
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.spacing4),
          ],
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  Text(
                    'Đang tải dữ liệu...',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textMuted,
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

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      height: widget.height ?? 200,
      padding: widget.padding ?? EdgeInsets.all(AppTheme.spacing4),
      decoration: AppTheme.whiteCardDecoration,
      child: Column(
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: AppTheme.headlineMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.spacing4),
          ],
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.errorColor,
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  Text(
                    'Lỗi tải dữ liệu',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: AppTheme.spacing3),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing2,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (context, chartProvider, child) {
        // Check loading state
        if (chartProvider.isLoading(widget.chartType)) {
          return _buildLoadingWidget();
        }

        // Check error state
        if (_errorMessage != null) {
          return _buildErrorWidget();
        }

        // Get cached data
        final data = chartProvider.getCachedData(widget.chartType) as T?;

        if (data == null) {
          // Data not loaded yet - trigger loading for lazy charts
          if (!widget.autoLoad) {
            return InkWell(
              onTap: _loadData,
              child: Container(
                height: widget.height ?? 200,
                padding: widget.padding ?? EdgeInsets.all(AppTheme.spacing4),
                decoration: AppTheme.whiteCardDecoration,
                child: Column(
                  children: [
                    if (widget.title != null) ...[
                      Text(
                        widget.title!,
                        style: AppTheme.headlineMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                    ],
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 48,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(height: AppTheme.spacing3),
                            Text(
                              'Nhấn để tải biểu đồ',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing2),
                            Text(
                              'Tiết kiệm băng thông và cải thiện hiệu suất',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textMuted,
                              ),
                              textAlign: TextAlign.center,
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

          // Auto-load but not started yet
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadDataIfNeeded();
          });
          return _buildLoadingWidget();
        }

        // Render chart with data
        return widget.chartBuilder(context, data);
      },
    );
  }
}

// Specialized widgets for different chart types
class LazyLineChart extends StatelessWidget {
  final String title;
  final Future<Map<DateTime, double>> Function() dataLoader;
  final Widget Function(BuildContext, Map<DateTime, double>) chartBuilder;
  final double? height;

  const LazyLineChart({
    Key? key,
    required this.title,
    required this.dataLoader,
    required this.chartBuilder,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LazyChart<Map<DateTime, double>>(
      chartType: ChartType.incomeLineChart,
      dataLoader: dataLoader,
      chartBuilder: chartBuilder,
      title: title,
      height: height,
      cacheDuration: const Duration(minutes: 10),
    );
  }
}

class LazyPieChart extends StatelessWidget {
  final String title;
  final Future<Map<String, double>> Function() dataLoader;
  final Widget Function(BuildContext, Map<String, double>) chartBuilder;
  final double? height;

  const LazyPieChart({
    Key? key,
    required this.title,
    required this.dataLoader,
    required this.chartBuilder,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LazyChart<Map<String, double>>(
      chartType: ChartType.expensePieChart,
      dataLoader: dataLoader,
      chartBuilder: chartBuilder,
      title: title,
      height: height,
      cacheDuration: const Duration(minutes: 5),
    );
  }
}

class LazyBarChart extends StatelessWidget {
  final String title;
  final Future<List<Map<String, dynamic>>> Function() dataLoader;
  final Widget Function(BuildContext, List<Map<String, dynamic>>) chartBuilder;
  final double? height;

  const LazyBarChart({
    Key? key,
    required this.title,
    required this.dataLoader,
    required this.chartBuilder,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LazyChart<List<Map<String, dynamic>>>(
      chartType: ChartType.monthlyComparison,
      dataLoader: dataLoader,
      chartBuilder: chartBuilder,
      title: title,
      height: height,
      cacheDuration: const Duration(minutes: 15),
    );
  }
}

// Performance monitoring widget
class ChartPerformanceInfo extends StatelessWidget {
  const ChartPerformanceInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (context, chartProvider, child) {
        final metrics = chartProvider.getPerformanceMetrics();

        return Container(
          padding: EdgeInsets.all(AppTheme.spacing3),
          margin: EdgeInsets.all(AppTheme.spacing2),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chart Performance',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: AppTheme.spacing2),
              Text(
                'Cached: ${metrics['totalCachedCharts']}',
                style: AppTheme.bodySmall,
              ),
              Text(
                'Avg Load: ${metrics['averageLoadTime'].inMilliseconds}ms',
                style: AppTheme.bodySmall,
              ),
              Text(
                'Cache Hit: ${(metrics['cacheHitRate'] * 100).toStringAsFixed(1)}%',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}


