import 'package:tmdb_api_project/Misc/movie_rating_badge.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_api_project/Misc/background.dart';
import 'package:tmdb_api_project/models/cast_model.dart';
import 'package:tmdb_api_project/models/genre_model.dart';
import 'package:tmdb_api_project/models/movie_model.dart';
import 'package:tmdb_api_project/services/genre_list_service.dart';
import 'package:tmdb_api_project/services/discover_movie_service.dart';
import 'package:url_launcher/url_launcher.dart';

// https://stackoverflow.com/questions/57977167/device-country-in-flutter

class MoviePage extends StatefulWidget {
  final Future<String> genreId;

  const MoviePage(this.genreId, {super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

String baseImgUrl = 'https://image.tmdb.org/t/p/original';

class _MoviePageState extends State<MoviePage> {
  late Future<List<Genre>> genres;
  late Future<Movie?> _randomMovie;
  late Future<List<Cast>> _credits;
  late Future<List<String>> director;
  late Future<String> trailer;

  @override
  void initState() {
    super.initState();
    genres = fetchGenres();
    _randomMovie = widget.genreId.then((genreId) => discoverMovies(genreId));
    _credits = _randomMovie.then((movie) => getMovieCredits(movie!.id));
    director = _credits.then((credits) {
      List<String> directorNames = [];
      for (var credit in credits) {
        if (credit.job == 'Director') {
          directorNames.add(credit.name);
        }
      }
      if (directorNames.isEmpty) {
        directorNames.add('Director not found');
      }
      return directorNames;
    });

    trailer = _randomMovie.then((movie) => getMovieTrailer(movie!.id));
  }

  //to get genre names
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

  //to format date
  String dateFormater(String date) {
    if (date == '') {
      return 'Date not found';
    }
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    List<String> dateList = date.split('-');

    int monthIndex = int.parse(dateList[1]) - 1;

    if (monthIndex < 0 || monthIndex >= months.length) {
      print('Month index error, check 2');
    }

    return '${dateList[2]} ${months[monthIndex]} ${dateList[0]}';
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
            padding: const EdgeInsets.all(25),
            shape: const CircleBorder(),
          ),
          onPressed: () {
            setState(() {
              _randomMovie =
                  widget.genreId.then((genreId) => discoverMovies(genreId));
              _credits =
                  _randomMovie.then((movie) => getMovieCredits(movie!.id));
              director = _credits.then((credits) {
                List<String> directorNames = [];
                for (var credit in credits) {
                  if (credit.job == 'Director') {
                    directorNames.add(credit.name);
                  }
                }
                if (directorNames.isEmpty) {
                  directorNames.add('Director not found');
                }
                return directorNames;
              });
              trailer =
                  _randomMovie.then((movie) => getMovieTrailer(movie!.id));
            });
          },
          child: const Icon(Icons.refresh, size: 40),
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
                    future: Future.wait([_randomMovie, director, trailer]),
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
                                    '$baseImgUrl${(snapshot.data![0] as Movie).posterPath}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 550,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey,
                                        width: double.infinity,
                                        height: 550,
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white,
                                            size: 50),
                                      );
                                    },
                                  ),
                                ),
                                MovieRatingBadge(
                                    rating: (snapshot.data![0] as Movie)
                                        .voteAverage),
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
                                      text: (snapshot.data![0] as Movie).title,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  FutureBuilder<List<String>>(
                                      future: getGenreNames(
                                          (snapshot.data![0] as Movie)
                                              .genreIds),
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
                                          return Wrap(
                                            children: [
                                              for (var genre in snapshot.data!)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 213, 209, 219),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 5,
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                      right: 5, top: 5),
                                                  child: Text(
                                                    genre,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }
                                      }),
                                  const SizedBox(height: 10),
                                  if ((snapshot.data![0] as Movie).overview !=
                                      "")
                                    Text(
                                      (snapshot.data![0] as Movie).overview,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w100,
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  RichText(
                                      text: TextSpan(
                                    text: 'Director: ',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            (snapshot.data![1] as List<String>)
                                                .join(', '),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w100,
                                        ),
                                      ),
                                    ],
                                  )),
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
                                          text: dateFormater(
                                              (snapshot.data![0] as Movie)
                                                  .releaseDate),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w100,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (snapshot.data![2] != '')
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                const Color.fromARGB(
                                                    255, 46, 46, 46),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 213, 209, 219),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                          ),
                                          onPressed: () {
                                            launchUrl(Uri.parse(
                                                snapshot.data![2] as String));
                                          },
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.play_arrow),
                                              Text('Watch Trailer'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
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
