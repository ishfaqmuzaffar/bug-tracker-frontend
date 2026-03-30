import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'admin@test.com');
  final _passwordController = TextEditingController(text: '123456');
  final _authService = AuthService();

  bool _loading = false;
  bool _statsLoading = true;
  String? _error;

  late final AnimationController _animationController;

  LoginDashboardStats _stats = const LoginDashboardStats(
    totalIssues: 0,
    pendingIssues: 0,
    fixedIssues: 0,
    criticalIssues: 0,
    highPriorityIssues: 0,
    inProgressIssues: 0,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _statsLoading = true;
    });

    try {
      final data = await _authService.getLoginStats();

      _stats = LoginDashboardStats(
        totalIssues: _toInt(data['totalIssues']),
        pendingIssues: _toInt(data['pendingIssues']),
        fixedIssues: _toInt(data['fixedIssues']),
        criticalIssues: _toInt(data['criticalIssues']),
        highPriorityIssues: _toInt(data['highPriorityIssues']),
        inProgressIssues: _toInt(data['inProgressIssues']),
      );

      _animationController.forward(from: 0);
    } catch (_) {
      _stats = const LoginDashboardStats(
        totalIssues: 0,
        pendingIssues: 0,
        fixedIssues: 0,
        criticalIssues: 0,
        highPriorityIssues: 0,
        inProgressIssues: 0,
      );
    } finally {
      if (mounted) {
        setState(() {
          _statsLoading = false;
        });
      }
    }
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      widget.onLoginSuccess();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 980;

    return Scaffold(
      body: Row(
        children: [
          if (!isCompact)
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E3A8A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.bug_report_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'JKCIP & HADP\nTrack bugs.\nShip faster.',
                          style: TextStyle(
                            fontSize: 42,
                            height: 1.08,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(
                          width: 560,
                          child: Text(
                            'Live engineering health at a glance. Monitor pending, fixed, and priority issues before signing in.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Expanded(
                          child: _statsLoading
                              ? const _LeftPanelLoading()
                              : FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.easeOut,
                                  ),
                                  child: _LiveStatsPanel(
                                    stats: _stats,
                                    animation: _animationController,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 5,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to continue to your bug tracking dashboard.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            prefixIcon: Icons.mail_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            obscureText: true,
                            prefixIcon: Icons.lock_outline_rounded,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.danger.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          AppButton(
                            text: 'Sign In',
                            onPressed: _login,
                            loading: _loading,
                            icon: Icons.login_rounded,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Demo credentials currently filled in for quick access.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
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

class _LiveStatsPanel extends StatelessWidget {
  final LoginDashboardStats stats;
  final Animation<double> animation;

  const _LiveStatsPanel({
    required this.stats,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedStats = stats.safe;
    final fixedRatio = resolvedStats.fixedRatio;
    final pendingRatio = resolvedStats.pendingRatio;
    final criticalRatio = resolvedStats.criticalRatio;
    final highPriorityRatio = resolvedStats.highPriorityRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isShort = constraints.maxHeight < 560;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Issues',
                    value: resolvedStats.totalIssues.toString(),
                    icon: Icons.confirmation_number_rounded,
                    accent: const Color(0xFF60A5FA),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    label: 'Pending',
                    value: resolvedStats.pendingIssues.toString(),
                    icon: Icons.pending_actions_rounded,
                    accent: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    label: 'Fixed',
                    value: resolvedStats.fixedIssues.toString(),
                    icon: Icons.task_alt_rounded,
                    accent: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 11,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Issue Distribution',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Current system load split across resolved, pending and critical items.',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Center(
                            child: AnimatedBuilder(
                              animation: animation,
                              builder: (context, _) {
                                return DonutIssueChart(
                                  size: isShort ? 180 : 220,
                                  fixedRatio: fixedRatio * animation.value,
                                  pendingRatio: pendingRatio * animation.value,
                                  criticalRatio: criticalRatio * animation.value,
                                  centerTop: resolvedStats.totalIssues.toString(),
                                  centerBottom: 'Live Issues',
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 14,
                            runSpacing: 12,
                            children: const [
                              _LegendItem(
                                color: Color(0xFF22C55E),
                                label: 'Fixed',
                              ),
                              _LegendItem(
                                color: Color(0xFFF59E0B),
                                label: 'Pending',
                              ),
                              _LegendItem(
                                color: Color(0xFFEF4444),
                                label: 'Critical',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 12,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live Overview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Quick operational indicators from your issue tracker.',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          AnimatedBuilder(
                            animation: animation,
                            builder: (context, _) {
                              return Column(
                                children: [
                                  _ProgressMetric(
                                    label: 'Issues Fixed',
                                    valueText:
                                        '${resolvedStats.fixedIssues}/${resolvedStats.totalIssues}',
                                    progress: fixedRatio * animation.value,
                                    color: const Color(0xFF22C55E),
                                  ),
                                  const SizedBox(height: 18),
                                  _ProgressMetric(
                                    label: 'Issues Pending',
                                    valueText:
                                        '${resolvedStats.pendingIssues}/${resolvedStats.totalIssues}',
                                    progress: pendingRatio * animation.value,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(height: 18),
                                  _ProgressMetric(
                                    label: 'Critical Issues',
                                    valueText:
                                        '${resolvedStats.criticalIssues}/${resolvedStats.totalIssues}',
                                    progress: criticalRatio * animation.value,
                                    color: const Color(0xFFEF4444),
                                  ),
                                  const SizedBox(height: 18),
                                  _ProgressMetric(
                                    label: 'High Priority',
                                    valueText:
                                        '${resolvedStats.highPriorityIssues}/${resolvedStats.totalIssues}',
                                    progress:
                                        highPriorityRatio * animation.value,
                                    color: const Color(0xFF8B5CF6),
                                  ),
                                ],
                              );
                            },
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniInfoCard(
                                  label: 'In Progress',
                                  value: resolvedStats.inProgressIssues.toString(),
                                  color: const Color(0xFF38BDF8),
                                  icon: Icons.autorenew_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MiniInfoCard(
                                  label: 'Critical',
                                  value: resolvedStats.criticalIssues.toString(),
                                  color: const Color(0xFFEF4444),
                                  icon: Icons.warning_amber_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniInfoCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  final String label;
  final String valueText;
  final double progress;
  final Color color;

  const _ProgressMetric({
    required this.label,
    required this.valueText,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              valueText,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 10,
            color: Colors.white.withValues(alpha: 0.10),
            child: FractionallySizedBox(
              widthFactor: safeProgress,
              alignment: Alignment.centerLeft,
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DonutIssueChart extends StatelessWidget {
  final double size;
  final double fixedRatio;
  final double pendingRatio;
  final double criticalRatio;
  final String centerTop;
  final String centerBottom;

  const DonutIssueChart({
    super.key,
    required this.size,
    required this.fixedRatio,
    required this.pendingRatio,
    required this.criticalRatio,
    required this.centerTop,
    required this.centerBottom,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              fixedRatio: fixedRatio,
              pendingRatio: pendingRatio,
              criticalRatio: criticalRatio,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerTop,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                centerBottom,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double fixedRatio;
  final double pendingRatio;
  final double criticalRatio;

  _DonutPainter({
    required this.fixedRatio,
    required this.pendingRatio,
    required this.criticalRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width * 0.12;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width / 2) - strokeWidth;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, backgroundPaint);

    final Paint fixedPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint pendingPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint criticalPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const double gap = 0.08;
    double startAngle = -math.pi / 2;

    final double fixedSweep =
        math.max(0.0, (math.pi * 2 * fixedRatio) - gap).toDouble();
    final double pendingSweep =
        math.max(0.0, (math.pi * 2 * pendingRatio) - gap).toDouble();
    final double criticalSweep =
        math.max(0.0, (math.pi * 2 * criticalRatio) - gap).toDouble();

    if (fixedSweep > 0) {
      canvas.drawArc(rect, startAngle, fixedSweep, false, fixedPaint);
    }
    startAngle += (math.pi * 2 * fixedRatio);

    if (pendingSweep > 0) {
      canvas.drawArc(rect, startAngle, pendingSweep, false, pendingPaint);
    }
    startAngle += (math.pi * 2 * pendingRatio);

    if (criticalSweep > 0) {
      canvas.drawArc(rect, startAngle, criticalSweep, false, criticalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.fixedRatio != fixedRatio ||
        oldDelegate.pendingRatio != pendingRatio ||
        oldDelegate.criticalRatio != criticalRatio;
  }
}

class _LeftPanelLoading extends StatelessWidget {
  const _LeftPanelLoading();

  @override
  Widget build(BuildContext context) {
    Widget block({
      required double height,
      double width = double.infinity,
      BorderRadius? radius,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: radius ?? BorderRadius.circular(18),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: block(height: 86)),
            const SizedBox(width: 14),
            Expanded(child: block(height: 86)),
            const SizedBox(width: 14),
            Expanded(child: block(height: 86)),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(child: block(height: double.infinity)),
              const SizedBox(width: 16),
              Expanded(child: block(height: double.infinity)),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginDashboardStats {
  final int totalIssues;
  final int pendingIssues;
  final int fixedIssues;
  final int criticalIssues;
  final int highPriorityIssues;
  final int inProgressIssues;

  const LoginDashboardStats({
    required this.totalIssues,
    required this.pendingIssues,
    required this.fixedIssues,
    required this.criticalIssues,
    required this.highPriorityIssues,
    required this.inProgressIssues,
  });

  LoginDashboardStats get safe {
    final safeTotal = totalIssues <= 0 ? 1 : totalIssues;
    return LoginDashboardStats(
      totalIssues: safeTotal,
      pendingIssues: pendingIssues.clamp(0, safeTotal),
      fixedIssues: fixedIssues.clamp(0, safeTotal),
      criticalIssues: criticalIssues.clamp(0, safeTotal),
      highPriorityIssues: highPriorityIssues.clamp(0, safeTotal),
      inProgressIssues: inProgressIssues.clamp(0, safeTotal),
    );
  }

  double get fixedRatio => fixedIssues / totalIssues;
  double get pendingRatio => pendingIssues / totalIssues;
  double get criticalRatio => criticalIssues / totalIssues;
  double get highPriorityRatio => highPriorityIssues / totalIssues;
}