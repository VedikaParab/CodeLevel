import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class CognitoService {
  static String? _cachedSignedInEmail;

  // 🔹 Replace with your real values
  final CognitoUserPool userPool = CognitoUserPool(
    'ap-south-1_LeEpQ69io', // example: eu-north-1_xxxxx
    '5mnikk9krtloa7pb70d9f0utr6', // example: 4abcd123xyz
  );

  // ===============================
  // 🔹 SIGN UP
  // ===============================
  Future<String> signUp(String email, String password) async {
    try {
      await userPool.signUp(email, password);
      return "Sign up successful. Check your email.";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ===============================
  // 🔹 CONFIRM SIGN UP (OTP)
  // ===============================
  Future<String> confirmSignUp(String email, String code) async {
    try {
      final cognitoUser = CognitoUser(email, userPool);

      await cognitoUser.confirmRegistration(code);

      return "Account confirmed successfully";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ===============================
  // 🔹 RESEND OTP (Optional)
  // ===============================
  Future<String> resendConfirmationCode(String email) async {
    try {
      final cognitoUser = CognitoUser(email, userPool);

      await cognitoUser.resendConfirmationCode();

      return "Verification code resent. Check your email.";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ===============================
  // 🔹 SIGN IN
  // ===============================
  Future<String> signIn(String email, String password) async {
    try {
      final cognitoUser = CognitoUser(email, userPool);

      final authDetails = AuthenticationDetails(
        username: email,
        password: password,
      );

      await cognitoUser.authenticateUser(authDetails);
      _cachedSignedInEmail = email;

      return "Login successful";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Future<String?> getSignedInEmail() async {
    if (_cachedSignedInEmail != null && _cachedSignedInEmail!.isNotEmpty) {
      return _cachedSignedInEmail;
    }

    try {
      final CognitoUser? currentUser = await userPool.getCurrentUser();
      if (currentUser == null) {
        return null;
      }

      final session = await currentUser.getSession();
      if (!(session?.isValid() ?? false)) {
        return null;
      }

      _cachedSignedInEmail = currentUser.username;
      return _cachedSignedInEmail;
    } catch (_) {
      return _cachedSignedInEmail;
    }
  }
}
