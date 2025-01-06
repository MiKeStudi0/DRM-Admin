import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ResourceManagementChart extends StatelessWidget {
  const ResourceManagementChart({super.key});

  final Color neededColor = Colors.blue; // Color representing needed resources
  final Color availableColor =
      Colors.green; // Color representing available resources
  final double width = 7;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: .8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                makeResourcesIcon(),
                const SizedBox(
                  width: 38,
                ),
                const Text(
                  'Resource Management',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: 100, // Maximum value for resources (100% of need)
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 39,
                        interval: 20, // Intervals for quantity
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: _getBarGroups(), // Bar groups represent resources
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  // Each bar group will now represent a different resource
  List<BarChartGroupData> _getBarGroups() {
    // For each resource (food, clothes, etc.), we create a bar group
    final barGroupFood =
        makeGroupData(0, 80, 50); // Food: Needed: 80, Available: 50
    final barGroupClothes =
        makeGroupData(1, 60, 40); // Clothes: Needed: 60, Available: 40
    final barGroupWater =
        makeGroupData(2, 100, 75); // Water: Needed: 100, Available: 75
    final barGroupMedicine =
        makeGroupData(3, 50, 30); // Medicine: Needed: 50, Available: 30

    return [
      barGroupFood,
      barGroupClothes,
      barGroupWater,
      barGroupMedicine,
    ];
  }

  // Creates bar group data (for one resource)
  BarChartGroupData makeGroupData(int x, double needed, double available) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: needed, // Height for "needed" resources
          color: neededColor,
          width: width,
        ),
        BarChartRodData(
          toY: available, // Height for "available" resources
          color: availableColor,
          width: width,
        ),
      ],
    );
  }

  // Left titles show the amount of resources (e.g., percentage or units)
  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text('${value.toInt()}%', style: style), // Show percentages
    );
  }

  // Bottom titles represent the resource types
  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Food', 'Clothes', 'Water', 'Medicine'];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, // Margin top
      child: text,
    );
  }

  // Resource icon in header (optional)
  Widget makeResourcesIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
