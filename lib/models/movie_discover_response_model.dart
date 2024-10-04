import 'package:tmdb_api_project/models/movie_model.dart';

class MovieDiscoverResponse{
  final int page;
  final List<Movie> results;
  final int totalPages;
  final int totalResults;

  const MovieDiscoverResponse({
  required this.page,
  required this.results,
  required this.totalPages,
  required this.totalResults,
});

  factory MovieDiscoverResponse.fromJson(Map<String, dynamic> json){
    return MovieDiscoverResponse(
      page: json['page'] as int,
      results: (json['results'] as List).map((e) => Movie.fromJson(e)).toList(),
      totalPages: json['total_pages'] as int,
      totalResults: json['total_results'] as int,
    );
  }

  //   @override
  // String toString() {
  //   return 'MovieDiscoverResponse(page: $page, totalPages: $totalPages, totalResults: $totalResults, results: $results)';
  // }
}

