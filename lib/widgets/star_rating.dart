import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final String? title;
  final double rating;
  final double size;
  final Color starColor;

  StarRating({
    this.title,
    required this.rating,
    this.size = 23,
    this.starColor = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    double remainder = rating - fullStars;
    int emptyStars = 5 - fullStars - (remainder > 0 ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            '$title:',
            style: TextStyle(fontSize: size),
          ),
          SizedBox(width: 4),
        ],
        // Full stars
        for (int i = 0; i < fullStars; i++)
          Icon(Icons.star, color: starColor, size: size),

        // Partial star with decimal precision
        if (remainder > 0)
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Empty star as background
                Icon(Icons.star_outline, color: starColor, size: size),

                // Clipped filled star to show partial fill
                ClipRect(
                  clipper: _StarClipper(width: remainder),
                  child: Icon(Icons.star, color: starColor, size: size),
                ),
              ],
            ),
          ),

        // Empty stars for the remainder
        for (int i = 0; i < emptyStars; i++)
          Icon(Icons.star_outline, color: starColor, size: size),
      ],
    );
  }
}

// Custom clipper to show partial stars based on decimal value
class _StarClipper extends CustomClipper<Rect> {
  final double width;

  _StarClipper({required this.width});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * width, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) => width != oldClipper.width;
}
