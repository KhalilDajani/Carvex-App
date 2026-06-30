import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../data/car_data.dart';
import '../data/app_state.dart';
import 'signin_screen.dart';

class SellCarScreen extends StatefulWidget {
  const SellCarScreen({super.key});

  @override
  State<SellCarScreen> createState() => _SellCarScreenState();
}

class _SellCarScreenState extends State<SellCarScreen> {
  int _currentStep = 0;
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  
  String _selectedMake = 'Select Make';
  String _selectedYear = 'Select Year';
  String _selectedTransmission = 'Select Transmission';
  String _selectedFuelType = 'Select Fuel Type';
  String _selectedCategory = 'Select Category';
  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();
  final _vinController = TextEditingController();

  
  final _priceController = TextEditingController();
  String _selectedCondition = 'Select Condition';
  final _descController = TextEditingController();
  final _carseerController = TextEditingController();
  final _autoscoreController = TextEditingController();
  final Set<String> _selectedFeatures = {};

  final List<String> _featureOptions = [
    'Navigation', 'Leather Seats', 'Sunroof', 'Bluetooth',
    'Backup Camera', 'Heated Seats', 'AWD', 'Adaptive Cruise',
  ];

  
  final _imageUrlController = TextEditingController();
  final _step3Key = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _modelController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _carseerController.dispose();
    _autoscoreController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_step3Key.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    try {
      final state = context.read<AppState>();

      await state.addCar(
        make: _selectedMake,
        model: _modelController.text.trim(),
        year: int.parse(_selectedYear),
        price: double.parse(_priceController.text.trim()),
        mileage: int.tryParse(_mileageController.text.trim()) ?? 0,
        transmission: _selectedTransmission,
        fuelType: _selectedFuelType,
        category: _selectedCategory,
        description: _descController.text.trim(),
        features: _selectedFeatures.toList(),
        imageUrl: _imageUrlController.text.trim(),
      );

      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit listing: $e'),
          backgroundColor: AppColors.primary,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 8),
            Icon(Icons.check_circle, color: AppColors.primary, size: 60),
            SizedBox(height: 16),
            Text(
              'Listing Published!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            SizedBox(height: 8),
            Text(
              'Your car is now live and visible to all buyers on Carvex.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text(
              'Done',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && _step1Key.currentState!.validate()) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1 && _step2Key.currentState!.validate()) {
      setState(() => _currentStep = 2);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (!state.isLoggedIn) {
      return _AccessDenied(
        message: 'Please sign in to list your car.',
        buttonLabel: 'Sign In',
        onButtonTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        ),
      );
    }
    if (!state.canManageCars) {
      return _AccessDenied(
        message:
            'Your account is set up for buying.\n\nOnly Sellers and Admins can list cars.',
        buttonLabel: 'Go Back',
        onButtonTap: () => Navigator.pop(context),
      );
    }

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
                decoration: const BoxDecoration(
                    color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: AppColors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=800&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.dark),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.black54],
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Text(
                          'Sell Your Car',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Get the best price for your vehicle.\nList it on Carvex today.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
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
                _StepIndicator(currentStep: _currentStep),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentStep == 0
                      ? _Step1(
                          key: const ValueKey('step1'),
                          formKey: _step1Key,
                          selectedMake: _selectedMake,
                          selectedYear: _selectedYear,
                          selectedTransmission: _selectedTransmission,
                          selectedFuelType: _selectedFuelType,
                          selectedCategory: _selectedCategory,
                          modelController: _modelController,
                          mileageController: _mileageController,
                          vinController: _vinController,
                          onMakeChanged: (v) =>
                              setState(() => _selectedMake = v),
                          onYearChanged: (v) =>
                              setState(() => _selectedYear = v),
                          onTransmissionChanged: (v) =>
                              setState(() => _selectedTransmission = v),
                          onFuelTypeChanged: (v) =>
                              setState(() => _selectedFuelType = v),
                          onCategoryChanged: (v) =>
                              setState(() => _selectedCategory = v),
                          onNext: _nextStep,
                        )
                      : _currentStep == 1
                          ? _Step2(
                              key: const ValueKey('step2'),
                              formKey: _step2Key,
                              priceController: _priceController,
                              descController: _descController,
                              carseerController: _carseerController,
                              autoscoreController: _autoscoreController,
                              selectedCondition: _selectedCondition,
                              selectedFeatures: _selectedFeatures,
                              featureOptions: _featureOptions,
                              onConditionChanged: (v) =>
                                  setState(() => _selectedCondition = v),
                              onFeatureToggled: (f) => setState(() {
                                if (_selectedFeatures.contains(f)) {
                                  _selectedFeatures.remove(f);
                                } else {
                                  _selectedFeatures.add(f);
                                }
                              }),
                              onBack: _prevStep,
                              onNext: _nextStep,
                            )
                          : _Step3(
                              key: const ValueKey('step3'),
                              formKey: _step3Key,
                              imageUrlController: _imageUrlController,
                              isSubmitting: _isSubmitting,
                              onBack: _prevStep,
                              onSubmit: _submit,
                            ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onButtonTap;

  const _AccessDenied({
    required this.message,
    required this.buttonLabel,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sell Your Car',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: AppColors.lightGrey, shape: BoxShape.circle),
                child:
                    const Icon(Icons.lock_outline, size: 40, color: AppColors.grey),
              ),
              const SizedBox(height: 20),
              const Text('Access Restricted',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.grey),
              ),
              const SizedBox(height: 24),
              RedButton(label: buttonLabel, onPressed: onButtonTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Vehicle Details', 'Condition & Price', 'Photos'];
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Expanded(
                  child: Container(
                    height: 2,
                    color: i ~/ 2 < currentStep
                        ? AppColors.primary
                        : AppColors.lightGrey,
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              final isDone = stepIdx < currentStep;
              final isActive = stepIdx == currentStep;
              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isActive
                      ? AppColors.primary
                      : AppColors.lightGrey,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: AppColors.white)
                      : Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive ? AppColors.white : AppColors.grey,
                          ),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps
                .map((s) => Text(
                      s,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: steps.indexOf(s) <= currentStep
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String selectedMake, selectedYear, selectedTransmission,
      selectedFuelType, selectedCategory;
  final TextEditingController modelController, mileageController, vinController;
  final Function(String) onMakeChanged, onYearChanged, onTransmissionChanged,
      onFuelTypeChanged, onCategoryChanged;
  final VoidCallback onNext;

  const _Step1({
    super.key,
    required this.formKey,
    required this.selectedMake,
    required this.selectedYear,
    required this.selectedTransmission,
    required this.selectedFuelType,
    required this.selectedCategory,
    required this.modelController,
    required this.mileageController,
    required this.vinController,
    required this.onMakeChanged,
    required this.onYearChanged,
    required this.onTransmissionChanged,
    required this.onFuelTypeChanged,
    required this.onCategoryChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehicle Details',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const Text("Tell us about your car's basic information.",
                style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 20),
            _DropdownField(
              label: 'Make',
              value: selectedMake,
              items: CarData.makes,
              onChanged: onMakeChanged,
              validator: (v) => v == 'Select Make' ? 'Select a make' : null,
            ),
            const SizedBox(height: 14),
            CarvexTextField(
              label: 'Model',
              hint: 'e.g. M3, C63, 911',
              controller: modelController,
              validator: (v) => v!.isEmpty ? 'Enter model' : null,
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Year',
              value: selectedYear,
              items: CarData.years,
              onChanged: onYearChanged,
              validator: (v) => v == 'Select Year' ? 'Select a year' : null,
            ),
            const SizedBox(height: 14),
            CarvexTextField(
              label: 'Mileage (km)',
              hint: '0',
              prefixIcon: Icons.speed,
              controller: mileageController,
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Enter mileage' : null,
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Transmission',
              value: selectedTransmission,
              items: CarData.transmissions,
              onChanged: onTransmissionChanged,
              validator: (v) =>
                  v == 'Select Transmission' ? 'Select transmission' : null,
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Fuel Type',
              value: selectedFuelType,
              items: CarData.fuelTypes,
              onChanged: onFuelTypeChanged,
              validator: (v) =>
                  v == 'Select Fuel Type' ? 'Select fuel type' : null,
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Category',
              value: selectedCategory,
              items: CarData.listingCategories,
              onChanged: onCategoryChanged,
              validator: (v) =>
                  v == 'Select Category' ? 'Select category' : null,
            ),
            const SizedBox(height: 14),
            CarvexTextField(
              label: 'VIN (Optional)',
              hint: 'Vehicle Identification Number',
              controller: vinController,
            ),
            const SizedBox(height: 24),
            RedButton(label: 'Next Step', onPressed: onNext),
          ],
        ),
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController priceController, descController,
      carseerController, autoscoreController;
  final String selectedCondition;
  final Set<String> selectedFeatures;
  final List<String> featureOptions;
  final Function(String) onConditionChanged;
  final Function(String) onFeatureToggled;
  final VoidCallback onBack, onNext;

  const _Step2({
    super.key,
    required this.formKey,
    required this.priceController,
    required this.descController,
    required this.carseerController,
    required this.autoscoreController,
    required this.selectedCondition,
    required this.selectedFeatures,
    required this.featureOptions,
    required this.onConditionChanged,
    required this.onFeatureToggled,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Condition & Price',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const Text('Describe the condition and set your price.',
                style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 20),
            const Text('Asking Price',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Enter asking price' : null,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Condition',
              value: selectedCondition,
              items: CarData.conditions,
              onChanged: onConditionChanged,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBD6FB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.open_in_new, size: 16, color: Color(0xFF1565C0)),
                      SizedBox(width: 6),
                      Text('Vehicle Inspection Report',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Add your CarSeer or AutoScore Inspection report link to increase buyer confidence.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF3B5998)),
                  ),
                  const SizedBox(height: 12),
                  const Text('CarSeer Report URL (Optional)',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: carseerController,
                    decoration: const InputDecoration(
                      hintText: 'https://carseer.com/report/...',
                      prefixIcon: Icon(Icons.link, size: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('AutoScore Report URL (Optional)',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: autoscoreController,
                    decoration: const InputDecoration(
                      hintText: 'https://autoscore.com/inspec...',
                      prefixIcon: Icon(Icons.link, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CarvexTextField(
              label: 'Description',
              hint: 'Tell buyers what makes your car special...',
              controller: descController,
              validator: (v) => v!.isEmpty ? 'Enter a description' : null,
            ),
            const SizedBox(height: 14),
            const Text('Features',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: featureOptions.map((f) {
                final selected = selectedFeatures.contains(f);
                return GestureDetector(
                  onTap: () => onFeatureToggled(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.offWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.lightGrey),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? AppColors.primary : AppColors.textMedium,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.lightGrey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Next Step',
                        style: TextStyle(
                            color: AppColors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Step3 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController imageUrlController;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const _Step3({
    super.key,
    required this.formKey,
    required this.imageUrlController,
    required this.isSubmitting,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<_Step3> createState() => _Step3State();
}

class _Step3State extends State<_Step3> {
  String _previewUrl = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Car Photo',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const Text('Paste a link to your car photo.',
                style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 20),

            
            TextFormField(
              controller: widget.imageUrlController,
              onChanged: (v) => setState(() => _previewUrl = v.trim()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter an image URL' : null,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://example.com/car.jpg',
                prefixIcon: Icon(Icons.link, size: 20),
              ),
            ),

            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How to get an image link:',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  SizedBox(height: 4),
                  Text(
                    '1. Upload your photo to imgur.com (free)\n'
                    '2. Right-click the image → Copy image address\n'
                    '3. Paste the link above',
                    style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.6),
                  ),
                ],
              ),
            ),

            
            if (_previewUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Preview',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _previewUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: const Center(
                      child: Text('Could not load image — check the URL',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.grey)),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.isSubmitting ? null : widget.onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.lightGrey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isSubmitting ? null : widget.onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: widget.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Publish Listing',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String) onChanged;
  final String? Function(String?)? validator;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          validator: validator,
          items: items
              .map((i) => DropdownMenuItem(
                  value: i, child: Text(i, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (v) => onChanged(v!),
          decoration: InputDecoration(
            suffixIcon:
                const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.lightGrey)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.lightGrey)),
          ),
          icon: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
