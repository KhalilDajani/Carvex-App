import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/car_model.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  List<CarModel> _allCars = [];
  List<CarModel> _favorites = [];
  List<CarModel> _compareList = [];
  final Set<String> _favoriteIds = {};
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoadingCars = true;
  StreamSubscription<QuerySnapshot>? _carsSubscription;

  double? _minPriceFilter;
  double? _maxPriceFilter;

  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userRole = '';
  bool _isLoadingRole = false;

  AppState() {
    _listenToCars();
  }

  List<CarModel> get allCars => _allCars;
  List<CarModel> get favorites => _favorites;
  List<CarModel> get compareList => _compareList;
  String get selectedCategory => _selectedCategory;
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userRole => _userRole;
  bool get isLoadingRole => _isLoadingRole;
  bool get isLoadingCars => _isLoadingCars;
  double? get minPriceFilter => _minPriceFilter;
  double? get maxPriceFilter => _maxPriceFilter;
  bool get hasPriceFilter => _minPriceFilter != null || _maxPriceFilter != null;

  bool get isBuyer => _userRole == 'buyer';
  bool get isSeller => _userRole == 'seller';
  bool get isAdmin => _userRole == 'admin';
  bool get canManageCars => isSeller || isAdmin;
  String get currentUserId => _auth.currentUser?.uid ?? '';

  List<CarModel> get myListings => _allCars
      .where((c) => c.sellerId == _auth.currentUser?.uid)
      .toList();

  int get myListingsCount => myListings.length;

  List<CarModel> get filteredCars {
    return _allCars.where((car) {
      final matchesCategory =
          _selectedCategory == 'All' || car.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          car.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          car.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMinPrice =
          _minPriceFilter == null || car.price >= _minPriceFilter!;
      final matchesMaxPrice =
          _maxPriceFilter == null || car.price <= _maxPriceFilter!;
      return matchesCategory && matchesSearch && matchesMinPrice && matchesMaxPrice;
    }).toList();
  }

  void _listenToCars() {
    // Stream only approved listings. No orderBy on the filtered query —
    // we sort in Dart to avoid needing a composite Firestore index.
    _carsSubscription = _db
        .collection('cars')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen(
      (snapshot) {
        List<CarModel> approvedCars = snapshot.docs.map((doc) {
          final car = CarModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          return car.copyWith(isFavorite: _favoriteIds.contains(car.id));
        }).toList();
        // Sort newest-first in Dart (avoids composite index requirement)
        approvedCars.sort((a, b) => b.id.compareTo(a.id));

        final uid = _auth.currentUser?.uid;
        if (uid != null && (isSeller || isAdmin)) {
          _db
              .collection('cars')
              .where('sellerId', isEqualTo: uid)
              .where('status', whereIn: ['pending', 'rejected'])
              .get()
              .then((ownSnap) {
            final ownCars = ownSnap.docs.map((doc) {
              final car = CarModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              return car.copyWith(isFavorite: _favoriteIds.contains(car.id));
            }).toList();
            final ownIds = ownCars.map((c) => c.id).toSet();
            _allCars = [
              ...approvedCars.where((c) => !ownIds.contains(c.id)),
              ...ownCars,
            ];
            _favorites = _allCars.where((c) => c.isFavorite).toList();
            _isLoadingCars = false;
            notifyListeners();
          }).catchError((e) {
            debugPrint('[AppState] own-cars fetch error: $e');
            _allCars = approvedCars;
            _favorites = _allCars.where((c) => c.isFavorite).toList();
            _isLoadingCars = false;
            notifyListeners();
          });
        } else {
          _allCars = approvedCars;
          _favorites = _allCars.where((c) => c.isFavorite).toList();
          _isLoadingCars = false;
          notifyListeners();
        }
      },
      onError: (e) {
        debugPrint('[AppState] _listenToCars error: $e');
        _isLoadingCars = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _carsSubscription?.cancel();
    super.dispose();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPriceFilter({double? minPrice, double? maxPrice}) {
    _minPriceFilter = minPrice;
    _maxPriceFilter = maxPrice;
    notifyListeners();
  }

  void clearPriceFilter() {
    _minPriceFilter = null;
    _maxPriceFilter = null;
    notifyListeners();
  }

  void toggleFavorite(String carId) {
    if (_favoriteIds.contains(carId)) {
      _favoriteIds.remove(carId);
    } else {
      _favoriteIds.add(carId);
    }
    final idx = _allCars.indexWhere((c) => c.id == carId);
    if (idx != -1) {
      _allCars[idx] = _allCars[idx].copyWith(
        isFavorite: _favoriteIds.contains(carId),
      );
      _favorites = _allCars.where((c) => c.isFavorite).toList();
      notifyListeners();
    }
  }

  void addToCompare(CarModel car) {
    if (_compareList.length < 3 && !_compareList.any((c) => c.id == car.id)) {
      _compareList.add(car);
      notifyListeners();
    }
  }

  void removeFromCompare(String carId) {
    _compareList.removeWhere((c) => c.id == carId);
    notifyListeners();
  }

  bool isInCompare(String carId) => _compareList.any((c) => c.id == carId);

  Future<void> deleteCar(String carId) async {
    await _db.collection('cars').doc(carId).delete();
  }

  Future<void> updateProfile({required String name}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _auth.currentUser!.updateDisplayName(name);
    await _db.collection('users').doc(uid).update({'name': name});
    _userName = name;
    notifyListeners();
  }

  // Adds a car as "pending". NO notification is sent here anymore —
  // the "new car" notification now fires in approveCar(), once an admin
  // approves the listing. The seller's phone is denormalised onto the
  // car doc so the "Contact Dealer" UI always has a number to show.
  Future<void> addCar({
    required String make,
    required String model,
    required int year,
    required double price,
    required int mileage,
    required String transmission,
    required String fuelType,
    required String category,
    required String description,
    required List<String> features,
    required String imageUrl,
  }) async {
    final carName = '$year $make $model';
    debugPrint('[AppState] addCar: saving "$carName" (pending) to Firestore...');

    final docRef = await _db.collection('cars').add({
      'make': make,
      'model': model,
      'year': year,
      'price': price,
      'mileage': mileage,
      'transmission': transmission,
      'fuelType': fuelType,
      'category': category,
      'description': description,
      'features': features,
      'imageUrl': imageUrl,
      'sellerId': _auth.currentUser?.uid ?? '',
      'sellerName': _userName,
      'sellerPhone': _userPhone,
      'rating': 0.0,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('[AppState] addCar: car saved with docId=${docRef.id} (awaiting approval)');
  }

  // Called by the admin (admin_cars_screen) to approve a pending listing.
  // Flips status -> approved and fires the notifications.
  Future<void> approveCar(CarModel car) async {
    debugPrint('[AppState] approveCar: ${car.id}');
    await _db.collection('cars').doc(car.id).update({'status': 'approved'});
    await NotificationService.instance.sendCarApprovedNotifications(
      carName: car.fullName,
      carId: car.id,
      sellerId: car.sellerId ?? '',
    );
  }

  // Called by the admin to reject a pending listing.
  Future<void> rejectCar(CarModel car) async {
    debugPrint('[AppState] rejectCar: ${car.id}');
    await _db.collection('cars').doc(car.id).update({'status': 'rejected'});
    await NotificationService.instance.sendNotification(
      title: 'Listing Update',
      message: '"${car.fullName}" was not approved.',
      targetRole: '',
      targetUserId: car.sellerId ?? '',
      type: 'listing_rejected',
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await credential.user!.updateDisplayName(name);

    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _userRole = role;
    notifyListeners();

    await NotificationService.instance.onUserLogin();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoadingRole = true;
    notifyListeners();

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();

    String name = email.split('@')[0];
    String role = 'buyer';
    String phone = '';

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      name = data['name'] ?? name;
      role = data['role'] ?? role;
      phone = data['phone'] ?? '';
    }

    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _userRole = role;
    _isLoadingRole = false;
    notifyListeners();

    await NotificationService.instance.onUserLogin();
  }

  Future<void> signInWithGoogle() async {
    _isLoadingRole = true;
    notifyListeners();

    try {
      late final UserCredential userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          _isLoadingRole = false;
          notifyListeners();
          throw Exception('Google sign-in was cancelled.');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final User firebaseUser = userCredential.user!;
      final String uid = firebaseUser.uid;
      final String email = firebaseUser.email ?? '';
      final String displayName =
          firebaseUser.displayName ?? email.split('@')[0];

      final DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      String role = 'buyer';
      String phone = '';

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        role = data['role'] ?? 'buyer';
        phone = data['phone'] as String? ?? '';

        await _db.collection('users').doc(uid).update({
          'name': displayName,
          'email': email,
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // New Google users have no phone yet — prompt them to add one
        // from the profile screen (see note in the README).
        await _db.collection('users').doc(uid).set({
          'name': displayName,
          'email': email,
          'role': 'buyer',
          'phone': '',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        role = 'buyer';
        phone = '';
      }

      _isLoggedIn = true;
      _userName = displayName;
      _userEmail = email;
      _userPhone = phone;
      _userRole = role;
      _isLoadingRole = false;
      notifyListeners();

      await NotificationService.instance.onUserLogin();
    } catch (e) {
      _isLoadingRole = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await NotificationService.instance.onUserLogout();
    } catch (_) {}
    try {
      if (!kIsWeb && await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    _userRole = '';
    notifyListeners();
  }

  // Optional: let a Google/legacy user add a phone after the fact.
  Future<void> updatePhone(String phone) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'phone': phone});
    _userPhone = phone;
    notifyListeners();
  }

  void login(String name, String email) {
    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
    _userPhone = '';
    _userRole = 'buyer';
    notifyListeners();
  }

  void logout() {
    signOut();
  }
}