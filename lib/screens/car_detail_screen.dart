import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/car_model.dart';
import '../data/app_state.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class CarDetailScreen extends StatelessWidget {
  final CarModel car;

  const CarDetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final liveCar =
        state.allCars.firstWhere((c) => c.id == car.id, orElse: () => car);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.dark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: AppColors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => state.toggleFavorite(liveCar.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.black38, shape: BoxShape.circle),
                  child: Icon(
                    liveCar.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: liveCar.isFavorite
                        ? AppColors.primary
                        : AppColors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (state.isInCompare(liveCar.id)) {
                    state.removeFromCompare(liveCar.id);
                  } else if (state.compareList.length < 3) {
                    state.addToCompare(liveCar);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.black38, shape: BoxShape.circle),
                  child: Icon(
                    Icons.compare_arrows,
                    color: state.isInCompare(liveCar.id)
                        ? AppColors.primary
                        : AppColors.white,
                  ),
                ),
              ),
              if (state.canManageCars)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Edit listing — coming soon'),
                          backgroundColor: AppColors.primary),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.black38, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.edit_outlined, color: AppColors.white),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    liveCar.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.dark),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Price / rating card ──────────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              liveCar.category,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            liveCar.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        liveCar.fullName,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${_formatPrice(liveCar.price)}',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SpecItem(
                                icon: Icons.speed,
                                label: 'Mileage',
                                value: '${liveCar.mileage} mi'),
                            _divider(),
                            _SpecItem(
                                icon: Icons.settings,
                                label: 'Transmission',
                                value: liveCar.transmission),
                            _divider(),
                            _SpecItem(
                                icon: Icons.local_gas_station,
                                label: 'Fuel',
                                value: liveCar.fuelType),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Manage listing (seller/admin only) ───────────────────
                if (state.canManageCars)
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.manage_accounts_outlined,
                            size: 18, color: AppColors.grey),
                        const SizedBox(width: 8),
                        const Text('Manage Listing',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Listing'),
                                content: const Text(
                                    'Are you sure you want to delete this listing?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await state.deleteCar(liveCar.id);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content:
                                                    Text('Listing deleted')));
                                      }
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (state.canManageCars) const SizedBox(height: 8),

                // ── Description ──────────────────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 10),
                      Text(
                        liveCar.description,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMedium,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Features ─────────────────────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Features',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: liveCar.features
                            .map((f) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.offWhite,
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: AppColors.lightGrey),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(f,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textDark)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Dealer card ───────────────────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dealer',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                liveCar.dealer.isNotEmpty
                                    ? liveCar.dealer[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(liveCar.dealer,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark)),
                              const Text('Verified Dealer',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.grey)),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(liveCar.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showContactDealer(context, state, liveCar),
                icon: const Icon(Icons.phone_outlined, size: 18),
                label: const Text('Contact Dealer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showRequestInfo(context, state, liveCar),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Request Info',
                    style: TextStyle(
                        color: AppColors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact Dealer bottom sheet ────────────────────────────────────────────
  void _showContactDealer(
      BuildContext context, AppState state, CarModel liveCar) {
    if (!state.isLoggedIn) {
      _showLoginPrompt(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContactDealerSheet(car: liveCar),
    );
  }

  // ── Request Info bottom sheet ──────────────────────────────────────────────
  void _showRequestInfo(
      BuildContext context, AppState state, CarModel liveCar) {
    if (!state.isLoggedIn) {
      _showLoginPrompt(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestInfoSheet(car: liveCar, state: state),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please log in to contact the dealer'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: AppColors.lightGrey);

  String _formatPrice(double price) {
    final s = price.toInt().toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return result.toString();
  }
}

// ── Contact Dealer Sheet ───────────────────────────────────────────────────────
class _ContactDealerSheet extends StatefulWidget {
  final CarModel car;
  const _ContactDealerSheet({required this.car});

  @override
  State<_ContactDealerSheet> createState() => _ContactDealerSheetState();
}

class _ContactDealerSheetState extends State<_ContactDealerSheet> {
  Map<String, dynamic>? _sellerData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
    if (widget.car.sellerId?.isEmpty ?? true) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.car.sellerId ?? '')
          .get();
      setState(() {
        _sellerData = doc.data();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellerName =
        _sellerData?['name'] as String? ?? widget.car.dealer;
    final sellerEmail = _sellerData?['email'] as String? ?? '';
    final sellerPhone = _sellerData?['phone'] as String? ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    sellerName.isNotEmpty
                        ? sellerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sellerName,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const Text('Verified Dealer',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: AppColors.primary),
            ))
          else ...[
            // Car being enquired about
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.car.fullName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                  ),
                  Text(
                    '\$${widget.car.price.toInt()}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Contact Options',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),

            // Message Seller — opens an in-app chat (hidden on your own listing)
            if (context.read<AppState>().currentUserId != widget.car.sellerId)
              _ContactButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Message Seller',
                subtitle: 'Chat inside Carvex',
                color: AppColors.primary,
                onTap: () async {
                  final state = context.read<AppState>();
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  // Close the bottom sheet first — otherwise a new screen or a
                  // snackbar would be hidden behind it and look like nothing
                  // happened.
                  navigator.pop();

                  if (!state.isLoggedIn) {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Sign in to message the seller')),
                    );
                    return;
                  }

                  try {
                    final chatId = await ChatService.instance.getOrCreateChat(
                      car: widget.car,
                      buyerId: state.currentUserId,
                      buyerName: state.userName,
                    );
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: chatId,
                          otherUserName: sellerName,
                        ),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Could not open chat: $e')),
                    );
                  }
                },
              ),

            if (context.read<AppState>().currentUserId != widget.car.sellerId)
              const SizedBox(height: 10),

            // Phone button
            if (sellerPhone.isNotEmpty)
              _ContactButton(
                icon: Icons.phone_rounded,
                label: 'Call Dealer',
                subtitle: sellerPhone,
                color: const Color(0xFF16A34A),
                onTap: () async {
                  final uri = Uri.parse('tel:$sellerPhone');
                  Navigator.pop(context);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),

            if (sellerPhone.isNotEmpty) const SizedBox(height: 10),

            // Email button
            if (sellerEmail.isNotEmpty)
              _ContactButton(
                icon: Icons.email_outlined,
                label: 'Email Dealer',
                subtitle: sellerEmail,
                color: AppColors.primary,
                onTap: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: sellerEmail,
                    query: 'subject=Carvex enquiry: ${widget.car.fullName}',
                  );
                  Navigator.pop(context);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),

            // Fallback if no contact info stored
            if (sellerPhone.isEmpty && sellerEmail.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.grey, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Contact details not available. Use "Request Info" to send the dealer a message.',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: color)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Request Info Sheet ─────────────────────────────────────────────────────────
class _RequestInfoSheet extends StatefulWidget {
  final CarModel car;
  final AppState state;

  const _RequestInfoSheet({required this.car, required this.state});

  @override
  State<_RequestInfoSheet> createState() => _RequestInfoSheetState();
}

class _RequestInfoSheetState extends State<_RequestInfoSheet> {
  final _messageCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  final List<String> _quickMessages = [
    'Is this car still available?',
    'Can I schedule a test drive?',
    'What is the best price you can offer?',
    'Does it come with a warranty?',
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInquiry() async {
    final message = _messageCtrl.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a message first')),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      await FirebaseFirestore.instance.collection('inquiries').add({
        'carId': widget.car.id,
        'carName': widget.car.fullName,
        'sellerId': widget.car.sellerId ?? '',
        'sellerName': widget.car.dealer,
        'buyerId': widget.state.currentUserId,
        'buyerName': widget.state.userName,
        'buyerEmail': widget.state.userEmail,
        'message': message,
        'status': 'unread',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _sending = false;
        _sent = true;
      });
    } catch (e) {
      setState(() => _sending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send. Please try again.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: _sent ? _buildSuccessState() : _buildFormState(),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: Color(0xFF16A34A), size: 36),
        ),
        const SizedBox(height: 16),
        const Text('Request Sent!',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 8),
        Text(
          'Your message has been sent to ${widget.car.dealer}. They will get back to you soon.',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 14, color: AppColors.grey, height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Done',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildFormState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Title
        const Text('Request More Info',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(
          'About ${widget.car.fullName}',
          style: const TextStyle(fontSize: 14, color: AppColors.grey),
        ),
        const SizedBox(height: 20),

        // Quick reply chips
        const Text('Quick questions',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickMessages
              .map((msg) => GestureDetector(
                    onTap: () => _messageCtrl.text = msg,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Text(msg,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textDark)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),

        // Message field
        const Text('Your message',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: _messageCtrl,
          maxLines: 4,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Write your message here…',
            hintStyle: const TextStyle(color: AppColors.grey),
            filled: true,
            fillColor: AppColors.offWhite,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Send button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _sending ? null : _sendInquiry,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(_sending ? 'Sending…' : 'Send Request',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
      ],
    );
  }
}