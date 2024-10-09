import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:tmdb_api_project/models/cast_model.dart';

import 'package:tmdb_api_project/models/movie_discover_response_model.dart';
import 'package:tmdb_api_project/models/movie_model.dart';
import 'package:tmdb_api_project/models/videos_model.dart';
import 'package:tmdb_api_project/models/watch_providers_country_flatrate_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String token = dotenv.env['TOKEN'] ?? 'default_api_key';
//to get a random movie, it returns a movie object
Future<Movie?> discoverMovies(genreId) async {
  //array of sort options to choose from randomly
  List<String> sortByOptions = [
    'popularity.desc',
    'revenue.desc',
    'vote_average.desc',
    'vote_count.desc'
  ];

  //code for getting a random page number
  String getRandomPageNumber() {
    var random = Random();
    int min = 1;
    int max = 500;
    return (min + random.nextInt(max - min)).toString();
  }

  //asigning random page number to a variable
  String randomPageNumber = getRandomPageNumber();

  //executing the api call
  final url = Uri.parse('https://api.themoviedb.org/3/discover/movie?');
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  //adding query parameters to the url with a random page number, genre id passed in as an argument and a random sort option
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

//to get credits for a movie by passing in a movie id, it returns a list of cast objects
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
      //accessing the crew array in the json response and mapping it to a list of cast objects
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

//to get trailer for a movie by passing in a movie id, it returns a string of the youtube url
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
      //accessing the results array in the json response and mapping it to a list of video objects
      final videos =
          (json['results'] as List).map((e) => Video.fromJson(e)).toList();
      //finding the first video object with the type 'Trailer' 
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

//to get watch providers for a movie by passing in a movie id and a country code, it returns a list of watch providers objects
Future<List<WatchProviders>> getWatchProviders(
    int movieId, String country) async {
  final url =
      Uri.parse('https://api.themoviedb.org/3/movie/$movieId/watch/providers');

  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      //accessing the flatrate array inside the country code in results and mapping it to a list of watch providers objects 
      final watchProviders = (json['results'][country]["flatrate"] as List)
          .map((e) => WatchProviders.fromJson(e))
          .toList();

      return watchProviders;
    } else {
      throw Exception(
          'Failed to load watch providers, look in service: ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load watch providers, look in service: $e');
    return [];
  }
}
