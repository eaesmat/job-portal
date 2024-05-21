import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  try {
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.camera, // Enable camera option
      preferredCameraDevice: CameraDevice.rear, // Set preferred camera device
    );

    if (xFile == null) {
      // If camera option is not chosen, fallback to gallery
      final galleryXFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, // Enable gallery option
      );
      
      return galleryXFile != null ? File(galleryXFile.path) : null;
    }

    return File(xFile.path);
  } catch (e) {
    return null;
  }
}
