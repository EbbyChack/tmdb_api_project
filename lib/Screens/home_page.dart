import 'package:flutter/material.dart';
import 'package:tmdb_api_project/Misc/background.dart';
import 'package:tmdb_api_project/Screens/movie_page.dart';
import 'package:tmdb_api_project/models/genre_model.dart';
import 'package:tmdb_api_project/services/genre_list_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Genre>> genres;
  String? _selectedGenre;
  final String allGenres = '';

  @override
  void initState() {
    super.initState();
    genres = fetchGenres();
  }

  Future<String> getGenreId(String? genreName) async {
    String genreId = '';
    List<Genre> genreList = await genres;
    for (var genre in genreList) {
      if (genre.name == genreName) {
        genreId = genre.id.toString();
        break;
      }
    }
    return genreId;
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(203, 255, 255, 255),
              ),
              child: FutureBuilder<List<Genre>>(
                future: fetchGenres(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No genres available');
                  } else {
                    return DropdownButton<String>(
                      value: _selectedGenre,
                      enableFeedback: true,
                      borderRadius: BorderRadius.circular(10),
                      isExpanded: true,
                      elevation: 20,
                      underline: Container(
                        height: 0,
                      ),
                      iconEnabledColor: Colors.black,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                      dropdownColor: const Color.fromARGB(255, 234, 234, 234),
                      hint: const Text('Select a genre'),
                      items: [
                        DropdownMenuItem(
                          value: allGenres,
                          child: Text('All'),
                        ),
                        ...snapshot.data!.map((Genre genre) {
                          return DropdownMenuItem<String>(
                            value: genre.name,
                            child: Text(genre.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGenre = newValue;
                        });
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Hero(
              tag: 'pick',
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MoviePage(getGenreId(_selectedGenre))),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF372554),
                  elevation: 30,
                  shadowColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Pick a Movie'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
