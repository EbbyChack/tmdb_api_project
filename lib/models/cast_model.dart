class Cast {
  
  final int id;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final String job;
  final String department;

  Cast({
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.job,
    required this.department,
    
   
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      
      id: json['id'] as int? ?? 0,
      knownForDepartment: json['known_for_department'] as String? ?? '',
      name: json['name'] as String? ?? '',
      originalName: json['original_name'] as String? ?? '',
      job: json['job'] as String? ?? '',
      department: json['department'] as String? ?? '',
    );
  }
}
