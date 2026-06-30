import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/app_state.dart';
import '../models/car_model.dart';
import 'sell_car_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final listings = state.myListings;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          'My Listings (${listings.length})',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add listing',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellCarScreen()),
            ),
          ),
        ],
      ),
      body: listings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined,
                      size: 64, color: AppColors.lightGrey),
                  const SizedBox(height: 16),
                  const Text(
                    'No listings yet',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the + button above to add your first car.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              itemBuilder: (context, i) => _ListingCard(
                car: listings[i],
                onDelete: () => _confirmDelete(context, state, listings[i]),
              ),
            ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, CarModel car) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Remove "${car.fullName}" from Carvex?\nThis cannot be undone.',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await state.deleteCar(car.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${car.fullName} deleted'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onDelete;

  const _ListingCard({required this.car, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: car.imageUrl.isNotEmpty
                ? Image.network(
                    car.imageUrl,
                    width: 110,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),

          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.fullName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${car.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.mileage} km  •  ${car.transmission}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),

          
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.primary, size: 22),
            tooltip: 'Delete listing',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 110,
      height: 90,
      color: AppColors.offWhite,
      child: const Icon(Icons.directions_car,
          color: AppColors.lightGrey, size: 36),
    );
  }
}
