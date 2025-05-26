import 'package:flutter/material.dart';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

class StatistichePage extends StatelessWidget {
  const StatistichePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          AppComponents.pageHeader(
            title: '📊 STATISTICHE',
            subtitle: 'Traccia i tuoi progressi',
            icon: Icons.analytics,
          ),
          Expanded(
            child: AppComponents.emptyState(
              icon: Icons.construction,
              title: 'In Costruzione',
              subtitle: 'La pagina delle statistiche sarà presto disponibile',
              iconColor: AppDesignSystem.warning,
            ),
          ),
        ],
      ),
    );
  }
}
