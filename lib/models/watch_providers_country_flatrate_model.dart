class WatchProviders{
  final String logoPath;
  final int providerId;
  final String providerName;

  WatchProviders({
    required this.logoPath,
    required this.providerId,
    required this.providerName,
  });

  factory WatchProviders.fromJson(Map<String, dynamic> json){
    return WatchProviders(
      logoPath: json['logo_path'] as String? ?? '',
      providerId: json['provider_id'] as int? ?? 0,
      providerName: json['provider_name'] as String? ?? '',
    );
  }
}