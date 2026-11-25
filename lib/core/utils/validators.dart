class Validators {
  const Validators._();

  static String? email(String? value, {required String message}) {
    if (value == null || value.trim().isEmpty) return message;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return message;
    return null;
  }

  static String? password(String? value, {required String message, int minLength = 6}) {
    if (value == null || value.trim().length < minLength) return message;
    return null;
  }

  static String? required(String? value, {required String message}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? phone(String? value, {required String message}) {
    if (value == null || value.trim().length < 8) return message;
    return null;
  }
}
