class CarData {
  static List<String> categories = [
    'All', 'Sports', 'Sedan', 'SUV', 'Luxury', 'Electric'
  ];

  
  static List<String> listingCategories = [
    'Select Category', 'Sports', 'Sedan', 'SUV', 'Luxury', 'Electric'
  ];

  static List<String> makes = [
    'Select Make', 'Porsche', 'Tesla', 'Mercedes-Benz', 'BMW', 'Audi',
    'Ferrari', 'Lamborghini', 'Range Rover', 'Toyota', 'Honda', 'Ford',
    'Chevrolet', 'Nissan', 'Hyundai', 'Kia', 'Lexus', 'Infiniti', 'Cadillac',
    'Jaguar', 'Bentley', 'Rolls-Royce', 'Maserati', 'Aston Martin', 'McLaren',
  ];

  static List<String> years = List.generate(15, (i) => (2024 - i).toString())
    ..insert(0, 'Select Year');

  static List<String> transmissions = [
    'Select Transmission', 'Automatic', 'Manual', 'CVT', 'DCT'
  ];

  static List<String> fuelTypes = [
    'Select Fuel Type', 'Gasoline', 'Diesel', 'Electric', 'Hybrid', 'Plug-in Hybrid'
  ];

  static List<String> conditions = [
    'Select Condition', 'Excellent', 'Very Good', 'Good', 'Fair'
  ];
}
