import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mastery Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Python', style: TextStyle(color: AppColors.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendar, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Score Card
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Overall Score', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        const Text('78%', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('Above Average ', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('🏆', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 36,
                            sections: [
                              PieChartSectionData(
                                value: 30,
                                color: AppColors.primaryBlue,
                                showTitle: false,
                                radius: 12,
                              ),
                              PieChartSectionData(
                                value: 30,
                                color: AppColors.primaryPurple,
                                showTitle: false,
                                radius: 12,
                              ),
                              PieChartSectionData(
                                value: 40,
                                color: AppColors.accentOrange,
                                showTitle: false,
                                radius: 12,
                              ),
                            ],
                          ),
                        ),
                        // Inner ring background
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: const Center(child: Icon(LucideIcons.target, color: Colors.white, size: 24)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Topic-wise Performance Chart
            const Text('Topic-wise Performance', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            GlassContainer(
              padding: const EdgeInsets.all(24),
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        backgroundColor: Colors.transparent,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const style = TextStyle(color: AppColors.textSecondary, fontSize: 10);
                                String text;
                                switch (value.toInt()) {
                                  case 0: text = 'Vars'; break;
                                  case 1: text = 'Types'; break;
                                  case 2: text = 'Loops'; break;
                                  case 3: text = 'Funcs'; break;
                                  case 4: text = 'OOP'; break;
                                  default: text = ''; break;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(text, style: style),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                if (value == 0 || value == 100) return const SizedBox.shrink();
                                return Text('${value.toInt()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10));
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withValues(alpha: 0.05),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _buildBarGroup(0, 85, 90, 70),
                          _buildBarGroup(1, 80, 75, 85),
                          _buildBarGroup(2, 90, 85, 60),
                          _buildBarGroup(3, 70, 60, 50),
                          _buildBarGroup(4, 60, 50, 42),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(AppColors.primaryBlue, 'Content'),
                      const SizedBox(width: 16),
                      _buildLegendItem(AppColors.primaryPurple, 'Assess'),
                      const SizedBox(width: 16),
                      _buildLegendItem(AppColors.accentOrange, 'Logic'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Weak Areas Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.05),
                border: const Border(left: BorderSide(color: AppColors.errorRed, width: 4)),
                borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(LucideIcons.alertCircle, color: AppColors.errorRed, size: 20),
                      SizedBox(width: 12),
                      Text('Needs Improvement', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('• OOP Logic (42%)\n• File Handling Assessment (55%)', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.5)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryPurple,
                      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('AI Recommendation', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(LucideIcons.arrowRight, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Radar Chart
            const Text('Skill Radar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            GlassContainer(
              padding: const EdgeInsets.all(24),
              height: 300,
              child: RadarChart(
                RadarChartData(
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  titlePositionPercentageOffset: 0.3,
                  tickCount: 3,
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  tickBorderData: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  gridBorderData: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                  radarShape: RadarShape.polygon,
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0: return const RadarChartTitle(text: 'Syntax', angle: 0);
                      case 1: return const RadarChartTitle(text: 'Logic', angle: 0);
                      case 2: return const RadarChartTitle(text: 'Speed', angle: 0);
                      case 3: return const RadarChartTitle(text: 'Accuracy', angle: 0);
                      case 4: return const RadarChartTitle(text: 'Consistency', angle: 0);
                      case 5: return const RadarChartTitle(text: 'Problem Solving', angle: 0);
                      default: return const RadarChartTitle(text: '');
                    }
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppColors.primaryPurple.withValues(alpha: 0.4),
                      borderColor: AppColors.primaryPurple,
                      entryRadius: 3,
                      dataEntries: const [
                        RadarEntry(value: 85),
                        RadarEntry(value: 60),
                        RadarEntry(value: 70),
                        RadarEntry(value: 90),
                        RadarEntry(value: 75),
                        RadarEntry(value: 50),
                      ],
                      borderWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double content, double assess, double logic) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: content, color: AppColors.primaryBlue, width: 6, borderRadius: BorderRadius.circular(2)),
        BarChartRodData(toY: assess, color: AppColors.primaryPurple, width: 6, borderRadius: BorderRadius.circular(2)),
        BarChartRodData(toY: logic, color: AppColors.accentOrange, width: 6, borderRadius: BorderRadius.circular(2)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
