class WasteCategory {
  final String id;
  final String name;
  final String description;
  final double reward;
  final double penalty;
  final bool isActive;

  WasteCategory({
    this.id = '',
    required this.name,
    required this.description,
    required this.reward,
    required this.penalty,
    this.isActive = true,
  });

  factory WasteCategory.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return WasteCategory(
      id: id,
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      reward: (map['rewardRatePerKg'] ?? map['reward'] ?? 0).toDouble(),
      penalty: (map['penaltyRatePerKg'] ?? map['penalty'] ?? 0).toDouble(),
      isActive: (map['active'] ?? true) as bool,
    );
  }
}
