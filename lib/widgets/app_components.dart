import 'package:flutter/material.dart';
import '../theme/app_design_system.dart';

/// Componenti UI riutilizzabili per mantenere coerenza nell'app
class AppComponents {
  
  // ========== BUTTONS ==========
  
  /// Bottone primario standard
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: AppDesignSystem.primaryButtonStyle,
        icon: isLoading 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : (icon != null ? Icon(icon, size: 18) : const SizedBox.shrink()),
        label: Text(
          text,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  /// Bottone secondario
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: AppDesignSystem.secondaryButtonStyle,
        icon: isLoading 
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2, 
                color: AppDesignSystem.primary,
              ),
            )
          : (icon != null ? Icon(icon, size: 18) : const SizedBox.shrink()),
        label: Text(
          text,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  /// Bottone di successo
  static Widget successButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: AppDesignSystem.successButtonStyle,
        icon: isLoading 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : (icon != null ? Icon(icon, size: 18) : const SizedBox.shrink()),
        label: Text(
          text,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  /// Bottone icona circolare
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
    double size = 40,
    String? tooltip,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppDesignSystem.primary.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: (backgroundColor ?? AppDesignSystem.primary).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? AppDesignSystem.primary,
          size: size * 0.5,
        ),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }
  
  // ========== CARDS ==========
  
  /// Card standard con opzioni di personalizzazione
  static Widget standardCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool hasPrimaryAccent = false,
    VoidCallback? onTap,
  }) {
    Widget cardContent = AppDesignSystem.standardCard(
      padding: padding,
      margin: margin,
      hasPrimaryAccent: hasPrimaryAccent,
      child: child,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
        child: cardContent,
      );
    }
    
    return cardContent;
  }
  
  /// Card per statistiche con icona
  static Widget statsCard({
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return standardCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDesignSystem.paddingS),
            decoration: BoxDecoration(
              color: (iconColor ?? AppDesignSystem.primary).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppDesignSystem.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDesignSystem.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppDesignSystem.bodyMedium),
                Text(
                  value,
                  style: AppDesignSystem.headingSmall.copyWith(
                    color: iconColor ?? AppDesignSystem.primary,
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle, style: AppDesignSystem.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Card per missioni
  static Widget missionCard({
    required String title,
    required String description,
    required double progress,
    required Color statusColor,
    required IconData statusIcon,
    String? reward,
    VoidCallback? onTap,
    Widget? actionButton,
  }) {
    return standardCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.paddingXS),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Icon(statusIcon, color: statusColor, size: 16),
              ),
              const SizedBox(width: AppDesignSystem.paddingS),
              Expanded(
                child: Text(title, style: AppDesignSystem.headingSmall),
              ),
              if (reward != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.paddingS,
                    vertical: AppDesignSystem.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
                  ),
                  child: Text(
                    reward,
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.paddingS),
          Text(description, style: AppDesignSystem.bodyMedium),
          const SizedBox(height: AppDesignSystem.paddingM),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso',
                    style: AppDesignSystem.bodySmall,
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDesignSystem.paddingXS),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ],
          ),
          
          if (actionButton != null) ...[
            const SizedBox(height: AppDesignSystem.paddingM),
            actionButton,
          ],
        ],
      ),
    );
  }
  
  // ========== INPUT FIELDS ==========
  
  /// Campo di input standard
  static Widget textField({
    required TextEditingController controller,
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Widget? suffixWidget,
    bool obscureText = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(labelText, style: AppDesignSystem.bodyMedium),
          const SizedBox(height: AppDesignSystem.paddingXS),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
          decoration: AppDesignSystem.inputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            suffixWidget: suffixWidget,
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
  
  // ========== HEADERS E SEZIONI ==========
  
  /// Header standard per pagine
  static Widget pageHeader({
    required String title,
    String? subtitle,
    List<Widget>? actions,
    IconData? icon,
  }) {
    return AppDesignSystem.standardHeader(
      title: title,
      subtitle: subtitle,
      actions: actions,
      icon: icon,
    );
  }
  
  /// Header per sezioni
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    int? count,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignSystem.paddingM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppDesignSystem.headingSmall),
                    if (count != null) ...[
                      const SizedBox(width: AppDesignSystem.paddingS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDesignSystem.paddingS,
                          vertical: AppDesignSystem.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppDesignSystem.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
                        ),
                        child: Text(
                          '$count',
                          style: AppDesignSystem.bodySmall.copyWith(
                            color: AppDesignSystem.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDesignSystem.paddingXS),
                  Text(subtitle, style: AppDesignSystem.bodySmall),
                ],
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
  
  // ========== STATI EMPTY ==========
  
  /// Widget per stato vuoto con icona e messaggio
  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
    Color? iconColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDesignSystem.paddingL),
            decoration: BoxDecoration(
              color: (iconColor ?? AppDesignSystem.textTertiary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: iconColor ?? AppDesignSystem.textTertiary,
            ),
          ),
          const SizedBox(height: AppDesignSystem.paddingL),
          Text(
            title,
            style: AppDesignSystem.headingMedium,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppDesignSystem.paddingS),
            Text(
              subtitle,
              style: AppDesignSystem.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppDesignSystem.paddingL),
            action,
          ],
        ],
      ),
    );
  }
  
  // ========== LOADING STATES ==========
  
  /// Indicatore di caricamento standard
  static Widget loadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppDesignSystem.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: AppDesignSystem.paddingM),
            Text(message, style: AppDesignSystem.bodyMedium),
          ],
        ],
      ),
    );
  }
  
  // ========== AVATAR E PROFILI ==========
  
  /// Avatar circolare con iniziali o immagine
  static Widget avatar({
    String? imageUrl,
    String? username,
    double size = 40,
    bool isOnline = false,
  }) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppDesignSystem.primary,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: imageUrl != null
            ? ClipOval(
                child: Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildInitialAvatar(username, size),
                ),
              )
            : _buildInitialAvatar(username, size),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: AppDesignSystem.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppDesignSystem.darkPrimary,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  static Widget _buildInitialAvatar(String? username, double size) {
    return Center(
      child: Text(
        username?.isNotEmpty == true 
          ? username!.substring(0, 1).toUpperCase()
          : '?',
        style: AppDesignSystem.headingSmall.copyWith(
          fontSize: size * 0.4,
          color: AppDesignSystem.textPrimary,
        ),
      ),
    );
  }
}
