class Video{
  final String id;
  final String key;
  final String type;

  Video({
    required this.id,
    required this.key,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json){
    return Video(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}
