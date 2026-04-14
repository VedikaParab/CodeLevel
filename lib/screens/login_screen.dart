import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'language_selection_screen.dart';
import '../services/cognito_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  bool _obscurePassword = true;

  final TextEditingController _usernameController =
  TextEditingController();
  final TextEditingController _emailController =
  TextEditingController();
  final TextEditingController _passwordController =
  TextEditingController();

  final CognitoService _cognitoService = CognitoService();

  String _activeTab = 'Login';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _activeTab =
        _tabController.index == 0 ? 'Login' : 'Register';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LanguageSelectionScreen(),
      ),
    );
  }

  // ===============================
  // 🔐 AUTH HANDLER
  // ===============================
  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email and Password cannot be empty"),
        ),
      );
      return;
    }

    if (_activeTab == 'Register') {

      final result =
      await _cognitoService.signUp(email, password);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));

      if (result.startsWith("Sign up successful")) {
        _showOtpDialog(email);
      }

    } else {

      final result =
      await _cognitoService.signIn(email, password);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));

      if (result == "Login successful") {
        _navigateToNext();
      }
    }
  }

  // ===============================
  // 🔑 OTP DIALOG
  // ===============================
  void _showOtpDialog(String email) {
    final TextEditingController otpController =
    TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Verification Code"),
          content: TextField(
            controller: otpController,
            decoration: const InputDecoration(
              hintText: "Enter OTP from email",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final code = otpController.text.trim();

                final result =
                await _cognitoService.confirmSignUp(
                    email, code);

                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(content: Text(result)),
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 40),

              const Center(
                child: Icon(
                  LucideIcons.bot,
                  size: 64,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'CodeLevel',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Container(
                height: 50,
                decoration: BoxDecoration(
                  color:
                  Colors.white.withOpacity(0.05),
                  borderRadius:
                  BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(25),
                    gradient:
                    AppColors.primaryGradient,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor:
                  AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Register'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildForm(),

              const SizedBox(height: 32),

              GradientButton(
                text: _activeTab == 'Login'
                    ? 'Login'
                    : 'Create Account',
                onPressed: _handleAuth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [

        if (_activeTab == 'Register') ...[
          _buildTextField(
            label: 'Username',
            icon: LucideIcons.user,
            controller: _usernameController,
          ),
          const SizedBox(height: 16),
        ],

        _buildTextField(
          label: 'Email',
          icon: LucideIcons.mail,
          controller: _emailController,
        ),

        const SizedBox(height: 16),

        _buildTextField(
          label: 'Password',
          icon: LucideIcons.lock,
          controller: _passwordController,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 4),
      hasGlow: false,
      child: TextField(
        controller: controller,
        obscureText:
        isPassword && _obscurePassword,
        style:
        const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon,
              color: AppColors.textSecondary,
              size: 20),
          hintText: label,
          hintStyle:
          const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _obscurePassword
                  ? LucideIcons.eye
                  : LucideIcons.eyeOff,
              color:
              AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword =
                !_obscurePassword;
              });
            },
          )
              : null,
        ),
      ),
    );
  }
}