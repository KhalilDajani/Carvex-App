import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class FinancingScreen extends StatefulWidget {
  const FinancingScreen({super.key});

  @override
  State<FinancingScreen> createState() => _FinancingScreenState();
}

class _FinancingScreenState extends State<FinancingScreen> {
  double _vehiclePrice = 50000;
  double _downPayment = 10000;
  double _interestRate = 5.5;
  double _loanTermMonths = 60;

  double get _loanAmount => _vehiclePrice - _downPayment;

  double get _monthlyPayment {
    if (_loanAmount <= 0) return 0;
    final monthlyRate = _interestRate / 100 / 12;
    if (monthlyRate == 0) return _loanAmount / _loanTermMonths;
    return _loanAmount * monthlyRate * pow(1 + monthlyRate, _loanTermMonths) /
        (pow(1 + monthlyRate, _loanTermMonths) - 1);
  }

  double get _totalPayment => _monthlyPayment * _loanTermMonths;
  double get _totalInterest => _totalPayment - _loanAmount;
  double get _totalCost => _vehiclePrice + _totalInterest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.dark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: AppColors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.dark),
                  ),
                  Container(color: Colors.black54),
                  const Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Text('Financing\nMade Simple', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.white)),
                        SizedBox(height: 6),
                        Text('Get competitive rates and\nflexible terms tailored to your needs.', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Calculate Your Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 20),
                      
                      const Text('Vehicle Price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: _vehiclePrice.toInt().toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(() => _vehiclePrice = double.tryParse(v) ?? _vehiclePrice),
                        decoration: const InputDecoration(prefixText: '\$ ', hintText: '50000'),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Monthly Payment', style: TextStyle(fontSize: 13, color: AppColors.textMedium)),
                                Text(
                                  '\$${_monthlyPayment.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total Interest', style: TextStyle(fontSize: 13, color: AppColors.textMedium)),
                                Text('\$${_totalInterest.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                const SizedBox(height: 8),
                                const Text('Total Cost', style: TextStyle(fontSize: 13, color: AppColors.textMedium)),
                                Text('\$${_totalCost.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _SliderField(
                        label: 'Down Payment',
                        value: _downPayment,
                        min: 0,
                        max: _vehiclePrice * 0.9,
                        displayPrefix: '\$',
                        onChanged: (v) => setState(() => _downPayment = v),
                        minLabel: '\$0',
                        maxLabel: '\$${(_vehiclePrice * 0.9).toInt()}',
                      ),
                      const SizedBox(height: 14),
                      
                      _SliderField(
                        label: 'Interest Rate (APR)',
                        value: _interestRate,
                        min: 0,
                        max: 15,
                        displaySuffix: '%',
                        displayDecimals: 1,
                        onChanged: (v) => setState(() => _interestRate = v),
                        minLabel: '0%',
                        maxLabel: '15%',
                      ),
                      const SizedBox(height: 14),
                      
                      _SliderField(
                        label: 'Loan Term',
                        value: _loanTermMonths,
                        min: 12,
                        max: 84,
                        displaySuffix: ' months',
                        displayDecimals: 0,
                        onChanged: (v) => setState(() => _loanTermMonths = v),
                        minLabel: '1 year',
                        maxLabel: '7 years',
                        divisions: 6,
                      ),
                      const SizedBox(height: 20),
                      
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Payment Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                            const SizedBox(height: 10),
                            _BreakdownRow(label: 'Loan Amount:', value: '\$${_loanAmount.toStringAsFixed(0)}'),
                            _BreakdownRow(label: 'Down Payment:', value: '\$${_downPayment.toStringAsFixed(0)}'),
                            _BreakdownRow(label: 'Est. Monthly Payment:', value: '\$${_monthlyPayment.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '* This is an estimate. Actual rates may vary based on credit score and lender.',
                        style: TextStyle(fontSize: 11, color: AppColors.grey, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 20),
                      RedButton(label: 'Apply for Financing', onPressed: () {}),
                    ],
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Why Finance With Us?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 16),
                      _WhyItem(
                        icon: Icons.percent,
                        title: 'Competitive Rates',
                        subtitle: 'Rates starting as low as 2.99% APR for qualified buyers.',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _WhyItem(
                        icon: Icons.timer_outlined,
                        title: 'Fast Approval',
                        subtitle: 'Get pre-approved in minutes with our secure online application.',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _WhyItem(
                        icon: Icons.shield_outlined,
                        title: 'Secure Process',
                        subtitle: 'Your data is protected with bank-level encryption.',
                        color: Colors.green,
                      ),
                    ],
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

class _SliderField extends StatelessWidget {
  final String label;
  final double value, min, max;
  final String? displayPrefix, displaySuffix, minLabel, maxLabel;
  final int displayDecimals;
  final Function(double) onChanged;
  final int? divisions;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.displayPrefix,
    this.displaySuffix,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
    this.displayDecimals = 0,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            Text(
              '${displayPrefix ?? ''}${value.toStringAsFixed(displayDecimals)}${displaySuffix ?? ''}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.lightGrey,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        if (minLabel != null && maxLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(minLabel!, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                Text(maxLabel!, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
              ],
            ),
          ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label, value;
  const _BreakdownRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}

class _WhyItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;

  const _WhyItem({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
