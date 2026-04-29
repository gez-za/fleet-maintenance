import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../constants/app_colors.dart';
import '../models/user.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;
  final File? localImage;
  final Uint8List? localBytes;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.user,
    this.radius = 40,
    this.localImage,
    this.localBytes,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? AppColors.primary.withOpacity(0.2),
                width: borderWidth,
              ),
            )
          : null,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: _getBackgroundImage(),
        child: _getFallbackChild(),
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    // 1. Local bytes (Web or recently picked)
    if (localBytes != null) {
      return MemoryImage(localBytes!);
    }

    // 2. Local File (Mobile recently picked)
    if (localImage != null && !kIsWeb) {
      return FileImage(localImage!);
    }

    // 3. Remote URL
    final photoUrl = user?.profile?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      final fullUrl = ApiConstants.getFullImageUrl(photoUrl);
      if (fullUrl != null) {
        return NetworkImage(fullUrl);
      }
    }

    return null;
  }

  Widget? _getFallbackChild() {
    if (_getBackgroundImage() != null) return null;

    String initials = '?';
    if (user?.profile != null) {
      final p = user!.profile!;
      final first = p.prenom.isNotEmpty ? p.prenom[0].toUpperCase() : '';
      final second = p.nom.isNotEmpty ? p.nom[0].toUpperCase() : '';
      initials = '$first$second'.isNotEmpty ? '$first$second' : '?';
    } else if (user != null) {
      initials = user!.displayName.isNotEmpty ? user!.displayName[0].toUpperCase() : '?';
    }

    return Text(
      initials,
      style: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: radius * 0.8,
      ),
    );
  }
}
