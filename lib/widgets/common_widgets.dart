import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/car_model.dart';
import 'notification_bell.dart';

class CarvexLogo extends StatelessWidget {
  final bool light;
  const CarvexLogo({super.key, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: AppColors.dark,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/carvex_logo.png'),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CARVEX',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2,
                color: light ? AppColors.white : AppColors.dark,
              ),
            ),
            Text(
              'كـارفـكس',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 9,
                letterSpacing: 1,
                color: light ? AppColors.white.withValues(alpha: 0.7) : AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CarvexAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int favCount;
  final int compareCount;
  final VoidCallback? onFavorites;
  final VoidCallback? onCompare;
  final VoidCallback? onMenu;

  const CarvexAppBar({
    super.key,
    this.favCount = 0,
    this.compareCount = 0,
    this.onFavorites,
    this.onCompare,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      titleSpacing: 16,
      title: const CarvexLogo(),
      actions: [
        const NotificationBell(),
        _IconBadge(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          count: favCount,
          isActive: favCount > 0,
          activeColor: AppColors.primary,
          onTap: onFavorites,
        ),
        _IconBadge(
          icon: Icons.compare_arrows,
          count: compareCount,
          isActive: compareCount > 0,
          activeColor: AppColors.primary,
          onTap: onCompare,
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenu,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  const _IconBadge({
    required this.icon,
    this.activeIcon,
    this.count = 0,
    this.isActive = false,
    required this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            isActive && activeIcon != null ? activeIcon! : icon,
            color: isActive ? activeColor : AppColors.darkGrey,
          ),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.onFavorite,
    this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    car.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: AppColors.lightGrey,
                      child: const Icon(Icons.directions_car, size: 60, color: AppColors.grey),
                    ),
                  ),
                ),
                
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dark.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      car.category,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: Icons.compare_arrows,
                        onTap: onCompare,
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: car.isFavorite ? Icons.favorite : Icons.favorite_border,
                        iconColor: car.isFavorite ? AppColors.primary : AppColors.darkGrey,
                        onTap: onFavorite,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.fullName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_formatPrice(car.price)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Spec(icon: Icons.speed, label: '${_formatMileage(car.mileage)} mi'),
                      const SizedBox(width: 20),
                      _Spec(icon: Icons.settings, label: car.transmission),
                      const SizedBox(width: 20),
                      _Spec(icon: Icons.local_gas_station, label: car.fuelType),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.lightGrey),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            car.dealer[0],
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        car.dealer,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        car.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final parts = price.toInt().toString().split('');
      final result = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i > 0 && (parts.length - i) % 3 == 0) result.write(',');
        result.write(parts[i]);
      }
      return result.toString();
    }
    return price.toInt().toString();
  }

  String _formatMileage(int mileage) {
    if (mileage >= 1000) {
      return '${(mileage / 1000).toStringAsFixed(1)}K';
    }
    return mileage.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor ?? AppColors.darkGrey),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Spec({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
      ],
    );
  }
}

class RedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const RedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class CarvexTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CarvexTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.grey)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class StatChip extends StatelessWidget {
  final String value;
  final String label;

  const StatChip({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
