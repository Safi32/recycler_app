class WasteCategory {
  final String name;
  final String description;
  final double reward;
  final double penalty;
  final bool isActive;

  WasteCategory({
    required this.name,
    required this.description,
    required this.reward,
    required this.penalty,
    this.isActive = true,
  });
}
