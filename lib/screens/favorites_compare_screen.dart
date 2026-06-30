import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/app_state.dart';
import '../widgets/common_widgets.dart';
import 'car_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const CarvexLogo(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Icon(
            state.favorites.isNotEmpty ? Icons.favorite : Icons.favorite_border,
            color: state.favorites.isNotEmpty ? AppColors.primary : AppColors.grey,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: state.favorites.isNotEmpty ? AppColors.primary : AppColors.grey,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  'My Favorites',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              state.favorites.isEmpty
                  ? "You haven't saved any favorites yet"
                  : '${state.favorites.length} car${state.favorites.length > 1 ? 's' : ''} saved',
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ),
          Expanded(
            child: state.favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(40),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.favorite_border, size: 60, color: AppColors.lightGrey),
                              SizedBox(height: 16),
                              Text('No favorites yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                              SizedBox(height: 8),
                              Text(
                                'Start adding cars to your favorites to see them here',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.favorites.length,
                    itemBuilder: (context, i) {
                      final car = state.favorites[i];
                      return CarCard(
                        car: car,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailScreen(car: car))),
                        onFavorite: () => state.toggleFavorite(car.id),
                        onCompare: () => state.addToCompare(car),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const CarvexLogo(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Icon(
            Icons.compare_arrows,
            color: state.compareList.isNotEmpty ? AppColors.primary : AppColors.grey,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.compare_arrows, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Compare Cars',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              state.compareList.isEmpty
                  ? 'Add cars to compare their features'
                  : '${state.compareList.length} of 3 cars selected',
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ),
          Expanded(
            child: state.compareList.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.compare_arrows, size: 60, color: AppColors.lightGrey),
                          SizedBox(height: 16),
                          Text('No cars to compare', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          SizedBox(height: 8),
                          Text(
                            'Add up to 3 cars to compare their features side by side',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        
                        Row(
                          children: [
                            const SizedBox(width: 90),
                            ...state.compareList.map((car) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            car.imageUrl,
                                            height: 90,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(height: 90, color: AppColors.lightGrey),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => state.removeFromCompare(car.id),
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                              child: const Icon(Icons.close, size: 14, color: AppColors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      car.fullName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _CompareRow(label: 'Price', values: state.compareList.map((c) => '\$${_fmt(c.price)}').toList(), highlight: true),
                              _CompareRow(label: 'Year', values: state.compareList.map((c) => c.year.toString()).toList()),
                              _CompareRow(label: 'Mileage', values: state.compareList.map((c) => '${c.mileage} mi').toList(), highlight: true),
                              _CompareRow(label: 'Transmission', values: state.compareList.map((c) => c.transmission).toList()),
                              _CompareRow(label: 'Fuel', values: state.compareList.map((c) => c.fuelType).toList(), highlight: true),
                              _CompareRow(label: 'Category', values: state.compareList.map((c) => c.category).toList()),
                              _CompareRow(label: 'Rating', values: state.compareList.map((c) => '⭐ ${c.rating}').toList(), highlight: true, isLast: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _fmt(double price) {
    final s = price.toInt().toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write(',');
      result.write(s[i]);
    }
    return result.toString();
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final List<String> values;
  final bool highlight;
  final bool isLast;

  const _CompareRow({required this.label, required this.values, this.highlight = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlight ? AppColors.offWhite : AppColors.white,
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(12)) : null,
        border: !isLast ? const Border(bottom: BorderSide(color: AppColors.lightGrey, width: 0.5)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
            ),
          ),
          ...values.map((v) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                v,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
            ),
          )),
          
          ...List.generate(3 - values.length, (_) => const Expanded(child: SizedBox())),
        ],
      ),
    );
  }
}
