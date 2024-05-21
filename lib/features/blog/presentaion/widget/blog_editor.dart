import 'package:flutter/material.dart';

class BlogEditor extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  const BlogEditor({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: Text(labelText),
      ),
      maxLines: null,
      validator: (value) {
        if (value!.isEmpty) {
          return "$labelText is empty";
        }
        return null;
      },
    );
  }
}
