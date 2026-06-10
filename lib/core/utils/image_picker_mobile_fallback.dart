import 'package:image_picker/image_picker.dart';

class ImagePickerWebFallback {
  static Future<XFile?> pickImage() async {
    // Sur mobile, cette méthode ne devrait pas être appelée 
    // car on utilise l'ImagePicker standard.
    return null;
  }
}
