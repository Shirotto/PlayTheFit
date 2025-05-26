import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_design_system.dart';

/// Componente per background uniforme dell'app con effetto stellare
class AppBackground extends StatefulWidget {
  final Widget child;
  final bool showStars;
  final List<Color>? customGradient;
  
  const AppBackground({
    super.key,
    required this.child,
    this.showStars = true,
    this.customGradient,
  });

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.customGradient ?? AppDesignSystem.primaryGradient,
        ),
      ),
      child: Stack(
        children: [
          // Sfondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.customGradient ?? AppDesignSystem.primaryGradient,
              ),
            ),
          ),

          // Animazione stelle (opzionale)
          if (widget.showStars)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarfieldPainter(
                    animation: _animationController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),

          // Contenuto principale
          widget.child,
        ],
      ),
    );
  }
}

/// Painter unificato per le stelle di sfondo
class StarfieldPainter extends CustomPainter {
  final double animation;

  StarfieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final random = math.Random(42); // Seed fisso per consistenza

    // Genera stelle con diversi colori e dimensioni
    for (int i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Dimensione variabile delle stelle
      final starSize = 0.5 + random.nextDouble() * 2.5;
      
      // Effetto twinkle sincronizzato con l'animazione
      final twinkleSpeed = 0.5 + random.nextDouble() * 1.5;
      final twinkle = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(
        animation * 2 * math.pi * twinkleSpeed + i
      ));

      // Colori delle stelle basati su design system
      Color starColor;
      final colorSeed = i % 20;
      
      if (colorSeed < 8) {
        // Stelle principali bianche
        starColor = Colors.white.withOpacity(0.4 * twinkle);
      } else if (colorSeed < 12) {
        // Stelle blu (primarie)
        starColor = AppDesignSystem.primary.withOpacity(0.3 * twinkle);
      } else if (colorSeed < 15) {
        // Stelle ambra
        starColor = AppDesignSystem.warning.withOpacity(0.4 * twinkle);
      } else if (colorSeed < 17) {
        // Stelle viola
        starColor = AppDesignSystem.secondary.withOpacity(0.3 * twinkle);
      } else {
        // Stelle cyan
        starColor = AppDesignSystem.accent.withOpacity(0.3 * twinkle);
      }

      // Disegna la stella base
      canvas.drawCircle(Offset(x, y), starSize, paint..color = starColor);

      // Aggiunge bagliore per alcune stelle
      if (colorSeed < 15) {
        canvas.drawCircle(
          Offset(x, y),
          starSize * 2.5,
          paint..color = starColor.withOpacity(0.1 * twinkle),
        );
      }

      // Stelle più luminose con effetto croce
      if (colorSeed < 5 && twinkle > 0.8) {
        final crossSize = starSize * 3;
        
        // Linea orizzontale
        canvas.drawLine(
          Offset(x - crossSize, y),
          Offset(x + crossSize, y),
          paint
            ..color = starColor.withOpacity(0.2)
            ..strokeWidth = 0.5,
        );
        
        // Linea verticale
        canvas.drawLine(
          Offset(x, y - crossSize),
          Offset(x, y + crossSize),
          paint
            ..color = starColor.withOpacity(0.2)
            ..strokeWidth = 0.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

/// Layout base per le pagine dell'app con background e SafeArea
class AppPageLayout extends StatelessWidget {
  final Widget child;
  final bool showStars;
  final List<Color>? customGradient;
  final EdgeInsets? padding;
  
  const AppPageLayout({
    super.key,
    required this.child,
    this.showStars = true,
    this.customGradient,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        showStars: showStars,
        customGradient: customGradient,
        child: SafeArea(
          child: Container(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Wrapper per Scaffold con design system unificato
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showStars;
  final List<Color>? customGradient;
  final EdgeInsets? padding;
  
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showStars = true,
    this.customGradient,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: AppBackground(
        showStars: showStars,
        customGradient: customGradient,
        child: Container(
          padding: padding,
          child: body,
        ),
      ),
    );
  }
}

/// AppBar personalizzata con design system
class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const AppBarCustom({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppDesignSystem.headingMedium.copyWith(
          color: foregroundColor ?? AppDesignSystem.textPrimary,
        ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor ?? AppDesignSystem.textPrimary,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Bottom Navigation Bar personalizzata
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesignSystem.darkSecondary.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDesignSystem.radiusL),
          topRight: Radius.circular(AppDesignSystem.radiusL),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: AppDesignSystem.shadowL,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDesignSystem.radiusL),
          topRight: Radius.circular(AppDesignSystem.radiusL),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppDesignSystem.primary,
          unselectedItemColor: AppDesignSystem.textTertiary,
          selectedLabelStyle: AppDesignSystem.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppDesignSystem.bodySmall,
          elevation: 0,
        ),
      ),
    );
  }
}
