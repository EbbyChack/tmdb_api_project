import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:tmdb_api_project/Misc/token.dart';
import 'package:tmdb_api_project/models/cast_model.dart';

import 'package:tmdb_api_project/models/movie_discover_response_model.dart';
import 'package:tmdb_api_project/models/movie_model.dart';
import 'package:tmdb_api_project/models/videos_model.dart';

Future<Movie?> discoverMovies(genreId) async {
  List<String> sortByOptions = [
    'popularity.desc',
    'revenue.desc',
    'vote_average.desc',
    'vote_count.desc'
  ];

  //code for fetching random page number
  String getRandomPageNumber() {
    var random = Random();
    int min = 1;
    int max = 500;
    return (min + random.nextInt(max - min)).toString();
  }

  //asigning random page number to a variable
  String randomPageNumber = getRandomPageNumber();

  final url = Uri.parse('https://api.themoviedb.org/3/discover/movie?');
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final pageUrl = url.replace(queryParameters: {
    'page': randomPageNumber,
    'with_genres': '$genreId',
    'sort_by': sortByOptions[Random().nextInt(sortByOptions.length)],
  });

  try {
    final response = await http.get(pageUrl, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final randomPage = MovieDiscoverResponse.fromJson(json);
      final randomMovieNumber = Random().nextInt(randomPage.results.length);
      final randomMovie = randomPage.results[randomMovieNumber];

      return randomMovie;
    } else {
      throw Exception(
          'Failed to load movies, look in service: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load movies, look in service: $e');
    return null; //
  }
}

//to get credits for a movie
Future<List<Cast>> getMovieCredits(int movieId) async {
  final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/credits?');
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final credits =
          (json['crew'] as List).map((e) => Cast.fromJson(e)).toList();
      return credits;
    } else {
      throw Exception(
          'Failed to load credits, look in service: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load credits, look in service: $e');
    return [];
  }
}

//to get trailer
Future<String> getMovieTrailer(int movieId) async {
  final url = Uri.parse('https://api.themoviedb.org/3/movie/$movieId/videos?');
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final videos =
          (json['results'] as List).map((e) => Video.fromJson(e)).toList();
      final trailer = videos.firstWhere((element) => element.type == 'Trailer');
      const youtubeUrl = 'https://www.youtube.com/watch?v=';
      return youtubeUrl + trailer.key;
    } else {
      throw Exception(
          'Failed to load trailer, look in service: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load trailer, look in service: $e');
    return '';
  }
}
