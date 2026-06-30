import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/notification_service.dart';

class _AC {
  static const bg            = Color(0xFF0F1117);
  static const surface       = Color(0xFF1A1D27);
  static const card          = Color(0xFF20232F);
  static const border        = Color(0xFF2C2F3E);
  static const accent        = Color(0xFFD32F2F);
  static const accentSoft    = Color(0x22D32F2F);
  static const teal          = Color(0xFF0D9488);
  static const tealSoft      = Color(0x220D9488);
  static const amber         = Color(0xFFD97706);
  static const amberSoft     = Color(0x22D97706);
  static const green         = Color(0xFF16A34A);
  static const greenSoft     = Color(0x2216A34A);
  static const textPrimary   = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted     = Color(0xFF64748B);
}

const _kStatuses = ['pending', 'approved', 'rejected'];

_StatusStyle _statusStyle(String s) {
  switch (s) {
    case 'approved':
      return const _StatusStyle(_AC.green,  _AC.greenSoft,  Icons.check_circle_rounded);
    case 'rejected':
      return const _StatusStyle(_AC.accent, _AC.accentSoft, Icons.cancel_rounded);
    default:
      return const _StatusStyle(_AC.amber,  _AC.amberSoft,  Icons.schedule_rounded);
  }
}

class _StatusStyle {
  final Color color, soft;
  final IconData icon;
  const _StatusStyle(this.color, this.soft, this.icon);
}

class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});
  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AC.bg,
      appBar: AppBar(
        backgroundColor: _AC.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _AC.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manage Cars',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _AC.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _AC.border),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _CarsLoadingState();
          }
          if (snapshot.hasError) {
            return _ErrorState(message: 'Could not load cars.\n${snapshot.error}');
          }
          return _buildBody(snapshot.data?.docs ?? []);
        },
      ),
    );
  }

  Widget _buildBody(List<QueryDocumentSnapshot> allDocs) {
    if (allDocs.isEmpty) {
      return const _EmptyState(
        icon: Icons.directions_car_outlined,
        title: 'No listings yet',
        subtitle: 'Car listings will appear here once sellers add them.',
      );
    }

    final filtered = _filter == 'all'
        ? allDocs
        : allDocs.where((d) {
            final s = ((d.data() as Map)['status'] as String? ?? 'pending').toLowerCase();
            return s == _filter;
          }).toList();

    int pending = 0, approved = 0, rejected = 0;
    for (final d in allDocs) {
      final s = ((d.data() as Map)['status'] as String? ?? 'pending').toLowerCase();
      if (s == 'pending') pending++;
      if (s == 'approved') approved++;
      if (s == 'rejected') rejected++;
    }

    return Column(
      children: [
        _FilterBar(
          current: _filter,
          onChanged: (v) => setState(() => _filter = v),
          total: allDocs.length,
          counts: {'pending': pending, 'approved': approved, 'rejected': rejected},
        ),
        _SummaryBar(count: filtered.length, label: 'listing${filtered.length == 1 ? '' : 's'}'),
        Expanded(
          child: filtered.isEmpty
              ? const _EmptyState(
                  icon: Icons.filter_list_off_rounded,
                  title: 'No results',
                  subtitle: 'No listings match the selected filter.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return _CarAdminCard(docId: doc.id, data: data);
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  final int total;
  final Map<String, int> counts;

  const _FilterBar({
    required this.current,
    required this.onChanged,
    required this.total,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('all',      'All',      total,                  _AC.textSecondary),
      ('pending',  'Pending',  counts['pending']  ?? 0, _AC.amber),
      ('approved', 'Approved', counts['approved'] ?? 0, _AC.green),
      ('rejected', 'Rejected', counts['rejected'] ?? 0, _AC.accent),
    ];

    return Container(
      color: _AC.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: tabs.map((t) {
          final key      = t.$1;
          final label    = t.$2;
          final count    = t.$3;
          final color    = t.$4;
          final isActive = current == key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? color.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? color.withOpacity(0.4) : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    Text('$count',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isActive ? color : _AC.textMuted,
                        )),
                    Text(label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isActive ? color : _AC.textMuted,
                          letterSpacing: 0.3,
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CarAdminCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _CarAdminCard({required this.docId, required this.data});

  String _getDisplayName() {
    final name  = (data['name']  as String? ?? '').trim();
    final make  = (data['make']  as String? ?? '').trim();
    final model = (data['model'] as String? ?? '').trim();
    if (name.isNotEmpty)  return name;
    final combined = '$make $model'.trim();
    if (combined.isNotEmpty) return combined;
    return 'Unknown Car';
  }

  Future<void> _changeStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(docId)
          .update({'status': newStatus});

      // Fire notifications based on the new status.
      final year  = data['year'];
      final make  = (data['make'] as String? ?? '').trim();
      final model = (data['model'] as String? ?? '').trim();
      final carName = (make.isNotEmpty && model.isNotEmpty)
          ? '$year $make $model'
          : _getDisplayName();
      final sellerId = data['sellerId'] as String? ?? '';

      if (newStatus == 'approved') {
        await NotificationService.instance.sendCarApprovedNotifications(
          carName: carName,
          carId: docId,
          sellerId: sellerId,
        );
      } else if (newStatus == 'rejected') {
        await NotificationService.instance.sendNotification(
          title: 'Listing Update',
          message: '"$carName" was not approved.',
          targetRole: '',
          targetUserId: sellerId,
          type: 'listing_rejected',
        );
      }

      if (context.mounted) {
        _showSnack(context, 'Status set to "$newStatus"', _statusStyle(newStatus).color);
      }
    } catch (_) {
      if (context.mounted) _showSnack(context, 'Failed to update status', _AC.accent);
    }
  }

  Future<void> _deleteCar(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _AC.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(color: _AC.accentSoft, shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever_rounded, color: _AC.accent, size: 26),
              ),
              const SizedBox(height: 16),
              const Text('Delete Listing',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _AC.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'This listing will be permanently removed.\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _AC.textMuted),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _AC.textSecondary,
                        side: const BorderSide(color: _AC.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AC.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size.zero,
                        elevation: 0,
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('cars').doc(docId).delete();
      if (context.mounted) _showSnack(context, 'Listing deleted', Colors.black87);
    } catch (_) {
      if (context.mounted) _showSnack(context, 'Failed to delete listing', _AC.accent);
    }
  }

  Future<void> _editCar(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => _AdminEditCarDialog(docId: docId, data: data),
    );
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _getDisplayName();
    final price       = data['price'];
    final year        = data['year'];
    final imageUrl    = data['imageUrl'] as String? ?? '';
    final sellerId    = data['sellerId'] as String? ?? '–';
    final sellerName  = data['sellerName'] as String? ?? '';
    final status      = (data['status'] as String? ?? 'pending').toLowerCase();
    final ss          = _statusStyle(status);

    return Container(
      decoration: BoxDecoration(
        color: _AC.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AC.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 110, height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _ImgPlaceholder(),
                      )
                    : const _ImgPlaceholder(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: _AC.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      if (year != null) _InfoChip(Icons.calendar_today_rounded, '$year'),
                      if (price != null) _InfoChip(Icons.attach_money_rounded, '\$${price.toString()}'),
                      const SizedBox(height: 4),
                      _InfoChip(
                        Icons.person_outline_rounded,
                        sellerName.isNotEmpty
                            ? sellerName
                            : (sellerId.length > 10 ? '${sellerId.substring(0, 10)}…' : sellerId),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ss.soft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ss.color.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ss.icon, color: ss.color, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: ss.color),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(height: 1, color: _AC.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text('Status',
                    style: TextStyle(fontSize: 11, color: _AC.textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Theme(
                  data: ThemeData.dark().copyWith(canvasColor: const Color(0xFF2C2F3E)),
                  child: DropdownButton<String>(
                    value: _kStatuses.contains(status) ? status : 'pending',
                    isDense: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.expand_more_rounded, color: _AC.textMuted, size: 16),
                    style: const TextStyle(fontSize: 12, color: _AC.textPrimary, fontWeight: FontWeight.w600),
                    items: _kStatuses.map((s) {
                      final st = _statusStyle(s);
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s[0].toUpperCase() + s.substring(1),
                            style: TextStyle(color: st.color, fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null && val != status) _changeStatus(context, val);
                    },
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _editCar(context),
                  icon: const Icon(Icons.edit_rounded, size: 15, color: _AC.teal),
                  label: const Text('Edit',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _AC.teal)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: _AC.tealSoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteCar(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 15, color: _AC.accent),
                  label: const Text('Delete',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _AC.accent)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: _AC.accentSoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminEditCarDialog extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _AdminEditCarDialog({required this.docId, required this.data});

  @override
  State<_AdminEditCarDialog> createState() => _AdminEditCarDialogState();
}

class _AdminEditCarDialogState extends State<_AdminEditCarDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _mileageCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _sellerNameCtrl;

  String _transmission = 'Automatic';
  String _fuelType     = 'Gasoline';
  String _category     = 'Sedan';

  static const _transmissions = ['Automatic', 'Manual', 'CVT', 'Semi-Automatic'];
  static const _fuelTypes     = ['Gasoline', 'Diesel', 'Electric', 'Hybrid', 'Plug-in Hybrid'];
  static const _categories    = ['Sedan', 'SUV', 'Truck', 'Coupe', 'Convertible', 'Van', 'Wagon', 'Hatchback', 'Sports'];

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _makeCtrl       = TextEditingController(text: d['make']        as String? ?? '');
    _modelCtrl      = TextEditingController(text: d['model']       as String? ?? '');
    _yearCtrl       = TextEditingController(text: (d['year']    ?? '').toString());
    _priceCtrl      = TextEditingController(text: (d['price']   ?? '').toString());
    _mileageCtrl    = TextEditingController(text: (d['mileage'] ?? '').toString());
    _descCtrl       = TextEditingController(text: d['description']  as String? ?? '');
    _imageUrlCtrl   = TextEditingController(text: d['imageUrl']     as String? ?? '');
    _sellerNameCtrl = TextEditingController(text: d['sellerName']   as String? ?? '');

    final t = d['transmission'] as String? ?? 'Automatic';
    _transmission = _transmissions.contains(t) ? t : 'Automatic';

    final f = d['fuelType'] as String? ?? 'Gasoline';
    _fuelType = _fuelTypes.contains(f) ? f : 'Gasoline';

    final c = d['category'] as String? ?? 'Sedan';
    _category = _categories.contains(c) ? c : 'Sedan';
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _priceCtrl.dispose();
    _mileageCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    _sellerNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    try {
      final make  = _makeCtrl.text.trim();
      final model = _modelCtrl.text.trim();
      final updates = <String, dynamic>{
        'make':         make,
        'model':        model,
        'name':         '$make $model'.trim(),
        'year':         int.tryParse(_yearCtrl.text.trim())    ?? 0,
        'price':        double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
        'mileage':      int.tryParse(_mileageCtrl.text.trim()) ?? 0,
        'transmission': _transmission,
        'fuelType':     _fuelType,
        'category':     _category,
        'description':  _descCtrl.text.trim(),
        'imageUrl':     _imageUrlCtrl.text.trim(),
        'sellerName':   _sellerNameCtrl.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.docId)
          .update(updates);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Car updated successfully'),
          backgroundColor: _AC.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: _AC.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _AC.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              decoration: const BoxDecoration(
                color: _AC.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(bottom: BorderSide(color: _AC.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _AC.tealSoft, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.edit_rounded, color: _AC.teal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Car Listing',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _AC.textPrimary)),
                        Text('Admin access — all fields editable',
                            style: TextStyle(fontSize: 11, color: _AC.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: _AC.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      _buildImagePreview(),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(child: _field('Make', _makeCtrl, 'e.g. Toyota', Icons.directions_car_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Model', _modelCtrl, 'e.g. Camry', Icons.commit_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(child: _field('Year', _yearCtrl, 'e.g. 2022', Icons.calendar_today_rounded,
                              keyboard: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                final n = int.tryParse(v.trim());
                                if (n == null) return 'Invalid';
                                return null;
                              })),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Price (\$)', _priceCtrl, 'e.g. 25000', Icons.attach_money_rounded,
                              keyboard: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (double.tryParse(v.trim()) == null) return 'Invalid';
                                return null;
                              })),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _field('Mileage (km)', _mileageCtrl, 'e.g. 45000', Icons.speed_rounded,
                          keyboard: TextInputType.number),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(child: _dropdown('Transmission', _transmission, _transmissions,
                              Icons.settings_rounded, (v) => setState(() => _transmission = v!))),
                          const SizedBox(width: 12),
                          Expanded(child: _dropdown('Fuel Type', _fuelType, _fuelTypes,
                              Icons.local_gas_station_rounded, (v) => setState(() => _fuelType = v!))),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _dropdown('Category', _category, _categories,
                          Icons.category_rounded, (v) => setState(() => _category = v!)),
                      const SizedBox(height: 14),

                      _field('Seller Name', _sellerNameCtrl, 'Seller display name', Icons.storefront_rounded),
                      const SizedBox(height: 14),

                      _field('Image URL', _imageUrlCtrl, 'https://...', Icons.image_rounded,
                          keyboard: TextInputType.url,
                          onChanged: (_) => setState(() {})),
                      const SizedBox(height: 14),

                      _field('Description', _descCtrl, 'Car description...', Icons.description_rounded,
                          maxLines: 3),
                    ],
                  ),
                ),
              ),
            ),

            
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: _AC.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: _AC.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _AC.textSecondary,
                        side: const BorderSide(color: _AC.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_rounded, size: 16),
                      label: Text(_saving ? 'Saving…' : 'Save Changes',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AC.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final url = _imageUrlCtrl.text.trim();
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _AC.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AC.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _ImgPreviewPlaceholder())
          : const _ImgPreviewPlaceholder(),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: _AC.textSecondary, letterSpacing: 0.3)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(color: _AC.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _AC.textMuted, fontSize: 13),
            prefixIcon: Icon(icon, color: _AC.textMuted, size: 16),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            filled: true,
            fillColor: _AC.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border:            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _AC.border)),
            enabledBorder:     OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _AC.border)),
            focusedBorder:     OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _AC.teal, width: 1.5)),
            errorBorder:       OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _AC.accent)),
            focusedErrorBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _AC.accent, width: 1.5)),
            errorStyle: const TextStyle(color: _AC.accent, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(String label, String value, List<String> items, IconData icon, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: _AC.textSecondary, letterSpacing: 0.3)),
        const SizedBox(height: 6),
        Theme(
          data: ThemeData.dark().copyWith(canvasColor: _AC.border),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            icon: const Icon(Icons.expand_more_rounded, color: _AC.textMuted, size: 18),
            style: const TextStyle(color: _AC.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _AC.textMuted, size: 16),
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              filled: true,
              fillColor: _AC.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _AC.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _AC.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _AC.teal, width: 1.5)),
            ),
            items: items
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _AC.textPrimary, fontSize: 13),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ImgPreviewPlaceholder extends StatelessWidget {
  const _ImgPreviewPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image_rounded, color: _AC.textMuted, size: 36),
        SizedBox(height: 8),
        Text('Image preview', style: TextStyle(fontSize: 12, color: _AC.textMuted)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _AC.textMuted),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: _AC.textMuted)),
        ],
      ),
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  const _ImgPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, height: 110,
      color: const Color(0xFF2C2F3E),
      child: const Icon(Icons.directions_car_outlined, color: _AC.textMuted, size: 28),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final int count;
  final String label;
  const _SummaryBar({required this.count, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: _AC.surface,
        border: Border(bottom: BorderSide(color: _AC.border)),
      ),
      child: Text('$count $label',
          style: const TextStyle(fontSize: 12, color: _AC.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
    );
  }
}

class _CarsLoadingState extends StatelessWidget {
  const _CarsLoadingState();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 110,
        decoration: BoxDecoration(
          color: _AC.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AC.border),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _AC.card, shape: BoxShape.circle,
                border: Border.all(color: _AC.border),
              ),
              child: Icon(icon, color: _AC.textMuted, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _AC.textSecondary)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _AC.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: _AC.accentSoft, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: _AC.accent, size: 28),
            ),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _AC.textMuted)),
          ],
        ),
      ),
    );
  }
}