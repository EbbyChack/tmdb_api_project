import 'package:tmdb_api_project/Misc/movie_rating_badge.dart';

import 'package:flutter/material.dart';
import 'package:tmdb_api_project/Misc/background.dart';
import 'package:tmdb_api_project/models/genre_model.dart';
import 'package:tmdb_api_project/models/movie_model.dart';
import 'package:tmdb_api_project/services/genre_list_service.dart';
import 'package:tmdb_api_project/services/discover_movie_service.dart';

class MoviePage extends StatefulWidget {
  final Future<String> genreId;

  const MoviePage( this.genreId, {super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

String baseImgUrl = 'https://image.tmdb.org/t/p/w500';

class _MoviePageState extends State<MoviePage> {
  late Future<List<Genre>> genres;
  late Future<Movie?> _randomMovie;

  

  @override
  void initState() {
    super.initState();
    genres = fetchGenres();
  _randomMovie = widget.genreId.then((genreId) => discoverMovies(genreId));
    
   
  }

  Future<List<String>> getGenreNames(List<int> genreIds) async {
    List<Genre> genreList = await genres;
    List<String> genreNames = [];

    for (int id in genreIds) {
      for (Genre genre in genreList) {
        if (genre.id == id) {
          genreNames.add(genre.name);
          break;
        }
      }
    }
    return genreNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Hero(
        tag: 'pick',
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF372554),
            elevation: 30,
            shadowColor: Colors.black,
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
          ),
          onPressed: () {
            setState(() {
              _randomMovie = widget.genreId.then((genreId) => discoverMovies(genreId));
            });
          },
          child: const Icon(Icons.refresh),
        ),
      ),
      body: Background(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: FutureBuilder(
                    future: _randomMovie,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(136, 255, 255, 255),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 130,
                              height: 130,
                              child: CircularProgressIndicator(
                                strokeWidth: 10.0,
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                    child: Image.network(
                                    '$baseImgUrl${snapshot.data!.posterPath}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 550,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                      color: Colors.grey,
                                      width: double.infinity,
                                      height: 550,
                                      child: const Icon(Icons.image_not_supported,
                                        color: Colors.white, size: 50),
                                      );
                                    },
                                    ),
                                ),
                                MovieRatingBadge(
                                    rating: snapshot.data!.voteAverage),
                              ],
                            ),
                            Container(
                              constraints: const BoxConstraints(
                                minHeight: 300,
                                minWidth: double.infinity,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(215, 255, 255, 255),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: snapshot.data!.title,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if(snapshot.data?.overview != "")
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Description: ',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    snapshot.data!.overview,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Release Date: ',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: snapshot.data!.releaseDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w100,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  FutureBuilder<List<String>>(
                                      future: getGenreNames(
                                          snapshot.data!.genreIds),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData) {
                                          return const Text('No data');
                                        } else {
                                          return RichText(
                                            text: TextSpan(
                                              text: 'Genres: ',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      snapshot.data!.join(', '),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w100,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Text('No data');
                      }
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
