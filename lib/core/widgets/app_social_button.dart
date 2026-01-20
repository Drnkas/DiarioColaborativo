import 'package:flutter/material.dart';

class AppSocialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;

  const AppSocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 1,
          shadowColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppGoogleButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppSocialButton(
      label: 'Continuar com Google',
      onPressed: onPressed,
      isLoading: isLoading,
      icon: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class AppAppleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppAppleButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppSocialButton(
      label: 'Continuar com Apple',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      icon: const Icon(
        Icons.apple,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
