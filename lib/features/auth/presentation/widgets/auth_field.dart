import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isObscure;
  const AuthField({
    super.key,
    required this.labelText,
    required this.controller,
    this.isObscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: (value) {
        if (value!.isEmpty) {
          return "$labelText is required";
        }
        return null;
      },
      decoration: InputDecoration(
        label: Text(
          labelText,
        ),
      ),
    );
  }
}
