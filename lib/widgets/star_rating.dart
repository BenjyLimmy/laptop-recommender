import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final String? title;
  final double rating;
  final double size;

  StarRating({
    this.title,
    required this.rating,
    this.size = 23,
  });

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

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
          Icon(Icons.star, color: Colors.amber, size: size),
        // Half star (at most one)
        if (hasHalfStar) Icon(Icons.star_half, color: Colors.amber, size: size),
        // Empty stars for the remainder
        for (int i = 0; i < emptyStars; i++)
          Icon(Icons.star_outline, color: Colors.amber, size: size),
      ],
    );
  }
}
