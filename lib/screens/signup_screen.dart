import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../data/app_state.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  
  
  
  String _selectedRole = 'buyer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please agree to the Terms of Service'),
            backgroundColor: AppColors.primary),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        
        await context.read<AppState>().signUp(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
              phone: _phoneController.text.trim(),
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

  String _friendlyError(String error) {
    if (error.contains('email-already-in-use'))
      return 'An account already exists with this email.';
    if (error.contains('invalid-email')) return 'Please enter a valid email.';
    if (error.contains('weak-password'))
      return 'Password is too weak. Use at least 8 characters.';
    return 'Sign up failed. Please try again.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (_) => false,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back,
                            color: AppColors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Back to Home',
                            style: TextStyle(
                                color: AppColors.white, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: AppColors.lightGrey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_outline,
                              size: 36, color: AppColors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign up to get started with Carvex',
                          style:
                              TextStyle(fontSize: 14, color: AppColors.grey),
                        ),
                        const SizedBox(height: 24),
                        CarvexTextField(
                          label: 'Full Name',
                          hint: 'John Doe',
                          prefixIcon: Icons.person_outline,
                          controller: _nameController,
                          validator: (v) =>
                              v!.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 14),
                        CarvexTextField(
                          label: 'Email Address',
                          hint: 'you@example.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v!.isEmpty ? 'Enter your email' : null,
                        ),
                        const SizedBox(height: 14),
                        CarvexTextField(
                          label: 'Phone Number',
                          hint: '+962 7X XXX XXXX',
                          prefixIcon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your phone number';
                            }
                            final digits =
                                v.replaceAll(RegExp(r'[^0-9]'), '');
                            if (digits.length < 7) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        CarvexTextField(
                          label: 'Password',
                          hint: 'Create a password',
                          prefixIcon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppColors.grey),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return 'Enter a password';
                            if (v.length < 8) {
                              return 'Must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 4, left: 2),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Must be at least 8 characters',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.grey)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        CarvexTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          prefixIcon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppColors.grey),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) {
                            if (v != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'I want to',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _RoleOption(
                              label: 'Buy a Car',
                              icon: Icons.directions_car_outlined,
                              isSelected: _selectedRole == 'buyer',
                              onTap: () =>
                                  setState(() => _selectedRole = 'buyer'),
                            ),
                            const SizedBox(width: 12),
                            _RoleOption(
                              label: 'Sell a Car',
                              icon: Icons.sell_outlined,
                              isSelected: _selectedRole == 'seller',
                              onTap: () =>
                                  setState(() => _selectedRole = 'seller'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _agreeToTerms,
                                onChanged: (v) =>
                                    setState(() => _agreeToTerms = v!),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMedium),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500)),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        RedButton(
                            label: 'Create Account',
                            onPressed: _signUp,
                            isLoading: _isLoading),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMedium)),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignInScreen())),
                              child: const Text(' Sign in',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Expanded(
                                child: Divider(color: AppColors.lightGrey)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Or sign up with',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.grey)),
                            ),
                            Expanded(
                                child: Divider(color: AppColors.lightGrey)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                                icon: _isGoogleLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : const Icon(Icons.g_mobiledata, size: 20),
                                label: const Text('Google'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textDark,
                                  side: const BorderSide(
                                      color: AppColors.lightGrey),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.facebook, size: 20),
                                label: const Text('Facebook'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textDark,
                                  side: const BorderSide(
                                      color: AppColors.lightGrey),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.offWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
