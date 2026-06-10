class AppValidators {
  AppValidators._();

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire.';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est obligatoire.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Adresse email invalide.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire.';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un chiffre.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe.';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }
}