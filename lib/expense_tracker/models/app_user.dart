/// Represents the active user profile and personal preferences.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String currencySymbol;
  final double monthlyBudget;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.currencySymbol = '₹',
    this.monthlyBudget = 50000.0,
  });

  /// Default profile for first-time use with Indian Rupee defaults.
  factory AppUser.defaultProfile() {
    return const AppUser(
      id: 'default_user_01',
      name: 'Alex Johnson',
      email: 'alex.johnson@example.com',
      currencySymbol: '₹',
      monthlyBudget: 50000.0,
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? currencySymbol,
    double? monthlyBudget,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currencySymbol': currencySymbol,
      'monthlyBudget': monthlyBudget,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? 'default_user_01',
      name: json['name'] as String? ?? 'Alex Johnson',
      email: json['email'] as String? ?? 'alex.johnson@example.com',
      currencySymbol: json['currencySymbol'] as String? ?? '₹',
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 50000.0,
    );
  }
}
