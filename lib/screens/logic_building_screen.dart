import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';

class LogicBuildingScreen extends StatefulWidget {
  const LogicBuildingScreen({super.key});

  @override
  State<LogicBuildingScreen> createState() => _LogicBuildingScreenState();
}

class _LogicBuildingScreenState extends State<LogicBuildingScreen> {
  final List<String> _tabs = ['Puzzle', 'Pattern', 'Output', 'Flowchart', 'Algorithm'];
  String _activeTab = 'Pattern';
  bool _isRun = false;
  bool _isSuccessOverlayVisible = false;

  void _runCode() {
    setState(() {
      _isRun = true;
    });
  }

  void _submitSolution() {
    setState(() {
      _isSuccessOverlayVisible = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSuccessOverlayVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Logic Challenge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Medium 🔥', style: TextStyle(color: AppColors.accentOrange, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '240 pts',
                style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab Strip
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final tab = _tabs[index];
                    final isActive = tab == _activeTab;
                    return GestureDetector(
                      onTap: () => setState(() => _activeTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isActive ? AppColors.accentOrange : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Challenge Card
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        hasGlow: true,
                        glowColor: AppColors.accentOrange,
                        borderColor: AppColors.accentOrange,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Print this pattern:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '1\n12\n123\n1234',
                                style: TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 16, letterSpacing: 2),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Write your solution below', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Code Editor Area
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Line Numbers
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                              ),
                              child: Column(
                                children: List.generate(6, (i) => Text('${i + 1}', style: TextStyle(color: Colors.grey[600], fontFamily: 'monospace', fontSize: 14, height: 1.5))),
                              ),
                            ),
                            // Code Area
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  maxLines: 6,
                                  style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 14, height: 1.5),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  controller: TextEditingController(text: 'for i in range(1, 5):\n    for j in range(1, i + 1):\n        print(j, end="")\n    print()'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Text('💡'),
                            label: const Text('Hint', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.yellow),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _runCode,
                                icon: const Icon(LucideIcons.play, size: 16),
                                label: const Text('Run'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _submitSolution,
                                icon: const Icon(LucideIcons.check, size: 16),
                                label: const Text('Submit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Output Panel
                      if (_isRun)
                        GlassContainer(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                color: Colors.black.withValues(alpha: 0.5),
                                child: Text('Output:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: const Text(
                                  '1\n12\n123\n1234',
                                  style: TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 16, letterSpacing: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Success Overlay
          if (_isSuccessOverlayVisible)
            Positioned.fill(
              child: Container(
                color: AppColors.background.withValues(alpha: 0.8),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: AppColors.accentOrange.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 5)],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.medal, color: Colors.white, size: 48),
                          SizedBox(height: 16),
                          Text('+80 XP', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          Text('Logic Mastered!', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
