import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MovieRatingBadge extends StatefulWidget {
  const MovieRatingBadge({
    super.key,
    required this.rating,
  });

  final double rating;

  @override
  State<MovieRatingBadge> createState() => _MovieRatingBadgeState();
}

class _MovieRatingBadgeState extends State<MovieRatingBadge> {
  @override
  void initState() {
    super.initState();
  }

  String convertRating(double rating) {
    rating = rating * 10;
    return rating.toStringAsFixed(0);
  }

  String getRatingColor(double rating) {
    if (rating >= 7.5) {
      return '#00FF00'; // Green
    } else if (rating >= 6.0) {
      return '#FFA500'; // Orange
    } else {
      return '#FF0000'; // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 9,
      top: 9,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Color.fromARGB(221, 8, 28, 34),
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
              BorderSide(color: Color.fromARGB(54, 255, 255, 255), width: 2)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.string(
              '''
              <svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                <circle cx="50" cy="50" r="45" stroke="${getRatingColor(widget.rating)}" stroke-width="10" fill="none" stroke-dasharray="${(widget.rating * 28.3).toStringAsFixed(1)}, 283" />
              </svg>
              ''',
              width: MediaQuery.of(context).size.width * 0.11,
              height: MediaQuery.of(context).size.width * 0.11,
            ),
            Text(
              '${convertRating(widget.rating)}%',
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}
