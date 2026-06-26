class Animal {
  const Animal({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.status,
    required this.description,
    required this.dateReported,
    required this.reportedBy,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String type;
  final String location;
  final String status;
  final String description;
  final String dateReported;
  final String reportedBy;
  final String? imageUrl;

  bool get isCat => type.toLowerCase() == 'cat';
  bool get needsHelp => status.toLowerCase() != 'healthy';
}
