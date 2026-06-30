import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../data/app_state.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        
        await context.read<AppState>().signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        }
      } catch (e) {
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_friendlyError(e.toString())),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  
  void _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      await context.read<AppState>().signInWithGoogle();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('cancelled')
            ? 'Google sign-in was cancelled.'
            : 'Google sign-in failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  
  String _friendlyError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email.';
    if (error.contains('wrong-password')) return 'Incorrect password. Please try again.';
    if (error.contains('invalid-email')) return 'Please enter a valid email address.';
    if (error.contains('too-many-requests')) return 'Too many attempts. Please wait a moment.';
    return 'Sign in failed. Please check your credentials.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (_) => false,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, color: AppColors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Back to Home',
                            style: TextStyle(color: AppColors.white, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_outline,
                                size: 36, color: AppColors.grey),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sign in to continue to Carvex',
                            style: TextStyle(fontSize: 14, color: AppColors.grey),
                          ),
                          const SizedBox(height: 28),
                          CarvexTextField(
                            label: 'Email Address',
                            hint: 'you@example.com',
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v!.isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 16),
                          CarvexTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppColors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Enter your password' : null,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v!),
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Remember me',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMedium)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          RedButton(
                              label: 'Sign In',
                              onPressed: _signIn,
                              isLoading: _isLoading),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textMedium)),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SignUpScreen())),
                                child: const Text(' Sign up',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: AppColors.lightGrey)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('Or continue with',
                                    style: TextStyle(
                                        fontSize: 12, color: AppColors.grey)),
                              ),
                              Expanded(child: Divider(color: AppColors.lightGrey)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  label: 'Google',
                                  icon: Icons.g_mobiledata,
                                  isLoading: _isGoogleLoading,
                                  onPressed: _signInWithGoogle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SocialButton(
                                  label: 'Facebook',
                                  icon: Icons.facebook,
                                  isLoading: false,
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDark,
        side: const BorderSide(color: AppColors.lightGrey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
