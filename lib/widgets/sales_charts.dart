import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:panaderia_liz/config/constants.dart';
import 'package:panaderia_liz/models/index.dart';
import 'package:panaderia_liz/utils/formatters.dart';

class SalesCharts extends StatelessWidget {
  final List<Sale> sales;

  const SalesCharts({
    Key? key,
    required this.sales,
  }) : super(key: key);

  Map<String, double> _calculateSalesByPaymentMethod() {
    final methods = <String, double>{
      'Efectivo': 0.0,
      'Tarjeta': 0.0,
      'QR': 0.0,
    };

    for (final sale in sales) {
      final method = _getPaymentMethodName(sale.paymentMethod);
      methods[method] = (methods[method] ?? 0.0) + sale.total;
    }

    return methods;
  }

  Map<String, double> _calculateDailySales() {
    final dailyData = <String, double>{};

    for (final sale in sales) {
      final dateKey = Formatters.date(sale.createdAt);
      dailyData[dateKey] = (dailyData[dateKey] ?? 0.0) + sale.total;
    }

    // Ordenar y tomar últimos 7 días
    final sorted = dailyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sorted.length > 7) {
      return Map.fromEntries(sorted.skip(sorted.length - 7));
    }
    return dailyData;
  }

  String _getPaymentMethodName(String code) {
    const methods = {
      'cash': 'Efectivo',
      'card': 'Tarjeta',
      'qr': 'QR',
    };
    return methods[code] ?? 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar gráficos'),
      );
    }

    final paymentMethods = _calculateSalesByPaymentMethod();
    final dailySales = _calculateDailySales();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pie Chart - Ventas por Método de Pago
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ventas por Método de Pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: paymentMethods.values.every((v) => v == 0)
                        ? const Center(
                            child: Text('Sin datos disponibles'),
                          )
                        : PieChart(
                            PieChartData(
                              sections: _buildPieSections(paymentMethods),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  _buildLegend(paymentMethods),
                ],
              ),
            ),
          ),

          // Bar Chart - Ventas por Día
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ventas Últimos 7 Días',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: dailySales.isEmpty
                        ? const Center(
                            child: Text('Sin datos disponibles'),
                          )
                        : BarChart(
                            _buildBarChartData(dailySales),
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

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> paymentMethods,
  ) {
    final total = paymentMethods.values.fold<double>(0, (a, b) => a + b);
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
    ];

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    paymentMethods.forEach((method, amount) {
      if (amount > 0) {
        final percentage = (amount / total) * 100;
        sections.add(
          PieChartSectionData(
            value: amount,
            color: colors[colorIndex % colors.length],
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
        colorIndex++;
      }
    });

    return sections;
  }

  Widget _buildLegend(Map<String, double> paymentMethods) {
    final colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange];
    final total = paymentMethods.values.fold<double>(0, (a, b) => a + b);

    int colorIndex = 0;
    return Column(
      children: [
        ...paymentMethods.entries.map((entry) {
          if (entry.value == 0) return const SizedBox.shrink();

          final color = colors[colorIndex % colors.length];
          final percentage = (entry.value / total) * 100;
          colorIndex++;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.key),
                ),
                Text(
                  '${Formatters.currency(entry.value)} (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  BarChartData _buildBarChartData(Map<String, double> dailySales) {
    final maxValue = dailySales.values.isEmpty
        ? 10.0
        : dailySales.values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue * 1.3; // 30% padding above tallest bar

    final barGroups = <BarChartGroupData>[];
    int x = 0;

    dailySales.forEach((date, amount) {
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: AppConstants.primaryColor,
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: Colors.grey.withOpacity(0.1),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      x++;
    });

    final dates = dailySales.keys.toList();

    return BarChartData(
      barGroups: barGroups,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY > 0 ? maxY / 4 : 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          tooltipMargin: 4,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${Formatters.currency(rod.toY)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < dates.length) {
                // Show day/month from the date string
                final parts = dates[index].split('/');
                final label = parts.length >= 2
                    ? '${parts[0]}/${parts[1]}'
                    : dates[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxY > 0 ? maxY / 4 : 1,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const Text('');
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '\$${value.toStringAsFixed(value < 10 ? 1 : 0)}',
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    );
  }
}
