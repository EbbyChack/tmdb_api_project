
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:tmdb_api_project/Misc/token.dart';

import 'package:tmdb_api_project/models/movie_discover_response_model.dart';
import 'package:tmdb_api_project/models/movie_model.dart';

Future<Movie?> discoverMovies(genreId) async {

  //code for fetching random page number
  String  getRandomPageNumber () {
    var random = Random();
    int min = 1;
    int max = 500;
    return (min + random.nextInt(max - min)).toString();
  }
  
  String randomPageNumber = getRandomPageNumber();

  
  final url = Uri.parse(
     'https://api.themoviedb.org/3/discover/movie?'
  );
  final headers = {
    'accept': 'application/json',
    'Authorization' : 'Bearer $token',
  };
  final pageUrl = url.replace(queryParameters: {
    'page': randomPageNumber,
    'with_genres': '$genreId',
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
      throw Exception('Failed to load movies, look in service: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load movies, look in service: $e');
    return null; //
  }
}