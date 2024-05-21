import 'package:blog_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onClick;
  const AuthButton({
    super.key,
    required this.buttonText,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPalette.gradient2, AppPalette.gradient3],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.transparentColor,
          shadowColor: AppPalette.transparentColor,
          fixedSize: const Size(395, 50),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
