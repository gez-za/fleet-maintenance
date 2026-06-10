import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final Uint8List? imageBytes;
  final VoidCallback onPickImage;

  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.imageBytes,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (imageBytes != null) {
      imageProvider = MemoryImage(imageBytes!);
    } else if (imageFile != null) {
      imageProvider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onPickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}