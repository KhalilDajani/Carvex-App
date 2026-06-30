import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../data/app_state.dart';
import '../data/car_data.dart';
import 'car_detail_screen.dart';
import 'favorites_screen.dart';
import 'compare_screen.dart';
import 'sell_car_screen.dart';
import 'financing_screen.dart';
import 'signin_screen.dart';
import 'profile_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'my_listings_screen.dart';
import 'chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    
    if (state.isLoggedIn && state.isSeller) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: CarvexAppBar(onMenu: () => _openDrawer(context)),
        floatingActionButton: const _MessagesFab(),
        body: _SellerDashboard(onAddCar: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SellCarScreen()));
        }),
      );
    }

    
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: CarvexAppBar(
        favCount: state.favorites.length,
        compareCount: state.compareList.length,
        onFavorites: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
        onCompare: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CompareScreen())),
        onMenu: () => _openDrawer(context),
      ),
      floatingActionButton: state.isLoggedIn ? const _MessagesFab() : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _HeroBanner(searchController: _searchController),
          ),
          SliverToBoxAdapter(child: _CategoryFilter()),
          
          if (!state.isSeller)
            SliverToBoxAdapter(
              child: _PriceFilterBar(
                minController: _minPriceController,
                maxController: _maxPriceController,
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Cars For Sale',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                  const Spacer(),
                  if (!state.isLoadingCars)
                    Text(
                      '${state.filteredCars.length} cars',
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                ],
              ),
            ),
          ),

          
          if (state.isLoadingCars)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )

          
          else if (state.filteredCars.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car_outlined,
                        size: 64, color: AppColors.lightGrey),
                    const SizedBox(height: 16),
                    Text(
                      state.hasPriceFilter
                          ? 'No cars found for this price'
                          : 'No cars listed yet',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.hasPriceFilter
                          ? 'Try a different price range or clear the filter.'
                          : 'Sellers will list their cars here.\nCheck back soon!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.grey),
                    ),
                    if (state.hasPriceFilter) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          context.read<AppState>().clearPriceFilter();
                          _minPriceController.clear();
                          _maxPriceController.clear();
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear Price Filter'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )

          
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final car = state.filteredCars[i];
                    return CarCard(
                      car: car,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CarDetailScreen(car: car)),
                      ),
                      onFavorite: () => state.toggleFavorite(car.id),
                      onCompare: () {
                        if (state.compareList.length >= 3 &&
                            !state.isInCompare(car.id)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Max 3 cars for comparison'),
                                backgroundColor: AppColors.primary),
                          );
                        } else {
                          if (state.isInCompare(car.id)) {
                            state.removeFromCompare(car.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${car.fullName} removed from compare')),
                            );
                          } else {
                            state.addToCompare(car);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${car.fullName} added to compare')),
                            );
                          }
                        }
                      },
                    );
                  },
                  childCount: state.filteredCars.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SellerDashboard extends StatelessWidget {
  final VoidCallback onAddCar;
  const _SellerDashboard({required this.onAddCar});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.dark, AppColors.darkNavy],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Seller Account',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome back,\n${state.userName}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to list a vehicle? Add it below\nand buyers will see it instantly.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: onAddCar,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'List Your Car',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fill in the details, upload a photo,\nand go live in minutes.',
                            style:
                                TextStyle(fontSize: 13, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.grey),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyListingsScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.directions_car_outlined,
                          color: Colors.green, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Listings',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.myListingsCount} car${state.myListingsCount == 1 ? '' : 's'} listed',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.grey),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FinancingScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calculate_outlined,
                          color: Colors.blue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Finance Calculator',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Estimate monthly payments.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.grey),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBD6FB)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your listings are visible to all buyers on Carvex as soon as you publish them.',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF3B5998), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PriceFilterBar extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;

  const _PriceFilterBar({
    required this.minController,
    required this.maxController,
  });

  void _applyFilter(BuildContext context) {
    final state = context.read<AppState>();
    final minText = minController.text.trim();
    final maxText = maxController.text.trim();
    final minPrice = minText.isEmpty ? null : double.tryParse(minText);
    final maxPrice = maxText.isEmpty ? null : double.tryParse(maxText);

    if (minText.isNotEmpty && minPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid minimum price'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    if (maxText.isNotEmpty && maxPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid maximum price'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum price cannot exceed maximum price'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    state.setPriceFilter(minPrice: minPrice, maxPrice: maxPrice);
  }

  void _clearFilter(BuildContext context) {
    context.read<AppState>().clearPriceFilter();
    minController.clear();
    maxController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.lightGrey, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.filter_list, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Filter by Price',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              if (state.hasPriceFilter)
                GestureDetector(
                  onTap: () => _clearFilter(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear, size: 12, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Min price',
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AppColors.offWhite,
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '—',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: maxController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Max price',
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AppColors.offWhite,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () => _applyFilter(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (state.hasPriceFilter) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _filterLabel(state),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
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

  String _filterLabel(AppState state) {
    final min = state.minPriceFilter;
    final max = state.maxPriceFilter;
    if (min != null && max != null) {
      return 'Showing cars: \$${_fmt(min)} – \$${_fmt(max)}';
    } else if (min != null) {
      return 'Showing cars above \$${_fmt(min)}';
    } else if (max != null) {
      return 'Showing cars below \$${_fmt(max)}';
    }
    return '';
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toStringAsFixed(0);
}

class _HeroBanner extends StatelessWidget {
  final TextEditingController searchController;

  const _HeroBanner({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.dark,
      ),
      child: Stack(
        children: [
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkNavy,
                    AppColors.dark,
                    AppColors.primary.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Your\nPerfect Car',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Browse thousands of quality vehicles from\ntrusted sellers. Your dream car is just a click away.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 12)
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: context.read<AppState>().setSearch,
                        decoration: const InputDecoration(
                          hintText: 'Search by make, model...',
                          prefixIcon:
                              Icon(Icons.search, color: AppColors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          filled: false,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text('Search'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatChip(value: '10,000+', label: 'Available Cars'),
                    _Divider(),
                    StatChip(value: '5,000+', label: 'Happy Customers'),
                    _Divider(),
                    StatChip(value: '500+', label: 'Verified Dealers'),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.white24);
  }
}

class _CategoryFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: CarData.categories.map((cat) {
            final isSelected = state.selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => state.setCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.offWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.lightGrey,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textMedium,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final mediaQuery = MediaQuery.of(context);
    // Cap the sheet at 85% of screen height so it never overflows on any device
    final maxSheetHeight = mediaQuery.size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: SafeArea(
        top: false, // top safe area is handled by useSafeArea in showModalBottomSheet
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              // Extra bottom padding for devices with home indicator
              mediaQuery.viewPadding.bottom > 0 ? 8 : 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const CarvexLogo(),
                const SizedBox(height: 20),
                const Divider(color: AppColors.lightGrey),

                // Home
                _MenuItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                    }),

                // Sell Your Car (sellers / admins only)
                if (state.canManageCars)
                  _MenuItem(
                      icon: Icons.sell_outlined,
                      label: 'Sell Your Car',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SellCarScreen()));
                      }),

                // Finance Calculator
                _MenuItem(
                    icon: Icons.calculate_outlined,
                    label: 'Finance Calculator',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FinancingScreen()));
                    }),

                // Messages (signed-in users)
                if (state.isLoggedIn)
                  _MenuItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'Messages',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatListScreen()));
                      }),

                // My Favorites & Compare Cars (buyers only)
                if (!state.isSeller) ...[
                  _MenuItem(
                      icon: Icons.favorite_border,
                      label: 'My Favorites',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FavoritesScreen()));
                      }),
                  _MenuItem(
                      icon: Icons.compare_arrows,
                      label: 'Compare Cars',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CompareScreen()));
                      }),
                ],

                // Admin Panel
                if (state.isAdmin)
                  _MenuItem(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Panel',
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminPanelScreen()),
                      );
                    },
                  ),

                // My Profile / Sign Out (or Sign In)
                if (state.isLoggedIn) ...[
                  _MenuItem(
                      icon: Icons.person_outline,
                      label: 'My Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()));
                      }),
                  _MenuItem(
                      icon: Icons.logout,
                      label: 'Sign Out',
                      color: AppColors.primary,
                      onTap: () async {
                        Navigator.pop(context);
                        await state.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        }
                      }),
                ] else
                  _MenuItem(
                      icon: Icons.login,
                      label: 'Sign In',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignInScreen()));
                      }),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textDark),
      title: Text(label,
          style: TextStyle(
              color: color ?? AppColors.textDark,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _MessagesFab extends StatelessWidget {
  const _MessagesFab();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      tooltip: 'Messages',
      shape: const CircleBorder(),
      onPressed: () {
        final state = context.read<AppState>();
        if (!state.isLoggedIn) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SignInScreen()));
          return;
        }
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ChatListScreen()));
      },
      child: const Icon(Icons.chat_bubble_rounded),
    );
  }
}
