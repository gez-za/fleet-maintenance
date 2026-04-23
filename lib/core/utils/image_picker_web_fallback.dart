import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Un service de secours pour le Web qui utilise directement l'API HTML
/// pour éviter l'erreur MissingPluginException.
class ImagePickerWebFallback {
  static Future<XFile?> pickImage() async {
    final completer = Completer<XFile?>();
    
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false;
      
    input.onChange.listen((event) {
      if (input.files == null || input.files!.isEmpty) {
        completer.complete(null);
        return;
      }
      
      final file = input.files![0];
      final reader = html.FileReader();
      
      reader.onLoadEnd.listen((e) {
        final bytes = reader.result as Uint8List;
        completer.complete(XFile(
          html.Url.createObjectUrlFromBlob(file),
          bytes: bytes,
          name: file.name,
          length: bytes.length,
        ));
      });
      
      reader.onError.listen((e) {
        completer.completeError("Erreur lors de la lecture du fichier");
      });
      
      reader.readAsArrayBuffer(file);
    });
    
    // Note: onCancel n'est pas supporté par tous les navigateurs sur FileUploadInputElement
    // On se base sur onChange. Si l'utilisateur annule, le completer ne finira pas
    // mais cela ne bloque pas l'application.
    
    input.click();
    
    return completer.future;
  }
}
