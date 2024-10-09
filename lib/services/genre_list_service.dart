import 'dart:convert';


import 'package:tmdb_api_project/models/genre_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String token = dotenv.env['TOKEN'] ?? 'default_api_key';
//fetches the list of genres from the api, returns a list of genre objects
Future<List<Genre>> fetchGenres() async {

  final url = Uri.parse(
     'https://api.themoviedb.org/3/genre/movie/list'
  );
  final headers = {
    'accept': 'application/json',
    'Authorization' : 'Bearer $token',
  };
  
  try{
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      //mapping the json response to a list of genre objects
      final List<Genre> genres = [];
      for (var genre in json['genres']) {
        genres.add(Genre.fromJson(genre));
      }
      return genres;
    } else {
      throw Exception('Failed to load genres, look in service: ${response.statusCode}');
    }
  }
  catch (e) {
    print('Failed to load genres, look in service: $e');
    return [];
  }
}
 
  