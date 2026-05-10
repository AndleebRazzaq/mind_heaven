import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cbt_intervention.dart';
import '../models/journal_entry.dart';
import 'emergency_resources_screen.dart';

class ReframeOutputScreen extends StatefulWidget {
  final CBTIntervention intervention;
  final JournalEntry entry;

  const ReframeOutputScreen({
    super.key,
    required this.intervention,
    required this.entry,
  });

  @override
  State<ReframeOutputScreen> createState() => _ReframeOutputScreenState();
}

class _ReframeOutputScreenState extends State<ReframeOutputScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    if (widget.intervention.showBreathing) {
      _breathingController.repeat();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d - h:mm a');
    final hasBreathing = widget.intervention.showBreathing;

    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFB4C6FC), size: 24),
            const SizedBox(width: 10),
            const Text(
              'AI Journal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp
              Text(
                dateFormat.format(widget.entry.dateTime),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // 🧠 1. EMOTIONAL STATE (Primary)
              _buildEmotionalStateSection(),
              const SizedBox(height: 32),

              // 🧩 2. PATTERN SECTION
              _buildPatternSection(),
              const SizedBox(height: 32),

              // 🌿 3. REFRAME (More CBT-aligned)
              _buildReframeSection(),
              const SizedBox(height: 32),

              // 🫁 4. BREATHING CARD (Conditional)
              if (hasBreathing) ...[
                _buildBreathingCard(),
                const SizedBox(height: 32),
              ],

              // 🚨 5. EMERGENCY CARD (Conditional)
              if (widget.intervention.showEmergency) ...[
                _buildEmergencyCard(),
                const SizedBox(height: 32),
              ],

              // 🌱 5. PLANT SUGGESTION (Shorter + Softer)
              _buildPlantSection(),
              const SizedBox(height: 32),

              // 📊 6. INTENSITY INDICATOR (Subtle)
              _buildIntensityIndicator(),
              const SizedBox(height: 40),

              // CTA BUTTON
              _buildCtaButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 🧠 EMOTIONAL STATE SECTION
  // ============================================================================
  Widget _buildEmotionalStateSection() {
    final emotionalState = widget.intervention.emotionalState ?? 'Neutral';
    final subtitle =
        widget.intervention.emotionalStateSubtitle ?? 'You seem grounded.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMOTIONAL STATE',
          style: TextStyle(
            color: const Color(0xFFB4C6FC).withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          emotionalState,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 🧩 PATTERN SECTION
  // ============================================================================
  Widget _buildPatternSection() {
    final pattern =
        widget.intervention.detectedDistortionLabel ?? 'No pattern detected';
    final explanation = widget.intervention.pattern ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PATTERN',
          style: TextStyle(
            color: const Color(0xFFB4C6FC).withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          pattern,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (explanation.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            explanation,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================================
  // 🌿 REFRAME SECTION (More CBT-aligned)
  // ============================================================================
  Widget _buildReframeSection() {
    final reframe =
        widget.intervention.reframe ??
        widget.intervention.balancedReframeSuggestion ??
        'Consider one alternative perspective that might be more balanced.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REFRAME',
          style: TextStyle(
            color: const Color(0xFFB4C6FC).withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB4C6FC).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Text(
            reframe,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 🫁 BREATHING CARD (Dynamic, conditional)
  // ============================================================================
  Widget _buildBreathingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D5A8C).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF64B5F6).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.air, color: Color(0xFF64B5F6), size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pause & Reset',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your stress level seems elevated right now. Try one slow breathing cycle before continuing.',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Animated breathing orb
          _buildBreathingOrb(),
          const SizedBox(height: 12),
          Text(
            '4-4-6 Breathing: Inhale 4s • Hold 4s • Exhale 6s',
            style: TextStyle(
              color: const Color(0xFF64B5F6).withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Animated breathing orb
  Widget _buildBreathingOrb() {
    return Center(
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          final scale =
              0.8 +
              (0.2 * _breathingController.value.abs() * 2).clamp(0.0, 1.0);
          final opacity =
              0.4 +
              (0.6 *
                  (1 - (_breathingController.value - 0.5).abs() * 2).clamp(
                    0.0,
                    1.0,
                  ));

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB((opacity * 255).toInt(), 100, 181, 246),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================================
  // 🚨 EMERGENCY CARD (Dynamic, conditional)
  // ============================================================================
  Widget _buildEmergencyCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEF5350).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF5350).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmergencyResourcesScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Color(0xFFEF5350), size: 24),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Emergency Resources',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFEF5350), size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your intensity level is very high right now. If you are feeling overwhelmed or having harmful thoughts, please reach out. Help is available.',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 🌱 PLANT SUGGESTION (Shorter + Softer)
  // ============================================================================
  Widget _buildPlantSection() {
    final plant = widget.intervention.plantSuggestion;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4ADE80).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: Color(0xFF4ADE80), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plant.isNotEmpty
                  ? plant
                  : '🌱 A plant can help you feel more grounded.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 📊 INTENSITY INDICATOR (Subtle)
  // ============================================================================
  Widget _buildIntensityIndicator() {
    final intensityLabel = widget.intervention.intensityLabel ?? 'Moderate';
    final intensity = widget.intervention.emotionIntensity ?? 50.0;

    return Row(
      children: [
        Text(
          'Emotional Intensity •',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          intensityLabel,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: intensity / 100,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getIntensityColor(intensity),
              ),
              minHeight: 3,
            ),
          ),
        ),
      ],
    );
  }

  Color _getIntensityColor(double intensity) {
    if (intensity < 30) return const Color(0xFF4ADE80); // Green - Low
    if (intensity < 60) return const Color(0xFFFFB74D); // Orange - Moderate
    if (intensity < 85) return const Color(0xFFFF7043); // Orange-Red - High
    return const Color(0xFFEF5350); // Red - Very High
  }

  // ============================================================================
  // CTA BUTTON
  // ============================================================================
  Widget _buildCtaButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF8A6BFF), Color(0xFFE4A4C1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              'I feel more grounded',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101216),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
