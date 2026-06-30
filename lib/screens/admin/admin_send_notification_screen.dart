import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class _C {
  static const bg           = Color(0xFF0F1117);
  static const surface      = Color(0xFF1A1D27);
  static const card         = Color(0xFF20232F);
  static const border       = Color(0xFF2C2F3E);
  static const accent       = Color(0xFFD32F2F);
  static const accentSoft   = Color(0x22D32F2F);
  static const textPrimary  = Color(0xFFF1F5F9);
  static const textSecondary= Color(0xFF94A3B8);
  static const textMuted    = Color(0xFF64748B);
}

class AdminSendNotificationScreen extends StatefulWidget {
  const AdminSendNotificationScreen({super.key});

  @override
  State<AdminSendNotificationScreen> createState() =>
      _AdminSendNotificationScreenState();
}

class _AdminSendNotificationScreenState
    extends State<AdminSendNotificationScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetRole = 'all'; 
  bool _isSending = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both title and message.');
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await NotificationService.instance.sendNotification(
        title: title,
        message: message,
        targetRole: _targetRole,
        type: 'admin_broadcast',
      );

      setState(() {
        _isSending = false;
        _successMessage = 'Notification sent successfully!';
        _titleController.clear();
        _messageController.clear();
      });
    } catch (e) {
      setState(() {
        _isSending = false;
        _errorMessage = 'Failed to send notification. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _C.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Send Notification',
          style: TextStyle(
              color: _C.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _C.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.campaign_rounded,
                        color: _C.accent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Broadcast Message',
                            style: TextStyle(
                                color: _C.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        SizedBox(height: 4),
                        Text(
                            'Send a notification to Buyers, Sellers, or all users.',
                            style: TextStyle(
                                color: _C.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            
            const Text('Audience',
                style: TextStyle(
                    color: _C.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                _AudienceChip(
                  label: 'All Users',
                  icon: Icons.groups_rounded,
                  isSelected: _targetRole == 'all',
                  onTap: () => setState(() => _targetRole = 'all'),
                ),
                const SizedBox(width: 8),
                _AudienceChip(
                  label: 'Buyers',
                  icon: Icons.shopping_bag_outlined,
                  isSelected: _targetRole == 'buyer',
                  onTap: () => setState(() => _targetRole = 'buyer'),
                ),
                const SizedBox(width: 8),
                _AudienceChip(
                  label: 'Sellers',
                  icon: Icons.storefront_outlined,
                  isSelected: _targetRole == 'seller',
                  onTap: () => setState(() => _targetRole = 'seller'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            
            const Text('Notification Title',
                style: TextStyle(
                    color: _C.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            _DarkTextField(
              controller: _titleController,
              hintText: 'e.g. New feature available!',
              maxLines: 1,
            ),
            const SizedBox(height: 20),

            
            const Text('Message',
                style: TextStyle(
                    color: _C.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            _DarkTextField(
              controller: _messageController,
              hintText: 'Write your message here...',
              maxLines: 5,
            ),
            const SizedBox(height: 28),

            
            if (_errorMessage != null)
              _FeedbackBanner(
                  message: _errorMessage!, isError: true),
            if (_successMessage != null)
              _FeedbackBanner(
                  message: _successMessage!, isError: false),
            if (_errorMessage != null || _successMessage != null)
              const SizedBox(height: 16),

            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isSending ? null : _send,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isSending ? 'Sending...' : 'Send Notification',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AudienceChip({
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _C.accentSoft : _C.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _C.accent : _C.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? _C.accent : _C.textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    color: isSelected ? _C.accent : _C.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _DarkTextField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _C.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _C.textMuted),
        filled: true,
        fillColor: _C.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _FeedbackBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.primary : const Color(0xFF0D9488);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: color,
              size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
