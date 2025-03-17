import 'dart:math';

import 'package:flutter/material.dart';
import 'package:laptop_reco/entities/laptop.dart';
import 'package:intl/intl.dart';
import 'package:laptop_reco/utils.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this dependency for currency formatting

class LaptopCard extends StatefulWidget {
  final Laptop laptop;
  LaptopCard({required this.laptop});

  @override
  _LaptopCardState createState() => _LaptopCardState();
}

class _LaptopCardState extends State<LaptopCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'RM ');
    final rating = _extractRating(widget.laptop.averageRating ?? '0');

    double width = MediaQuery.of(context).size.width;
    bool showReviewInMain = width >= 1200;
    final reviews = [
      {
        'reviewer': 'Alice',
        'rating': 4.5,
        'comment': 'Great laptop, excellent display and battery!'
      },
      {
        'reviewer': 'Bob',
        'rating': 3.5,
        'comment': 'Good performance but design could improve.'
      },
      {
        'reviewer': 'Charlie',
        'rating': 5.0,
        'comment': 'Absolutely love it, exceeded my expectations!'
      },
    ];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: _isHovering
            ? (Matrix4.identity()
              ..scale(1.005)
              ..translate(0.0, -2.0, 0.0))
            : Matrix4.identity(),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _buildDetailDialog(context, reviews),
            );
          },
          child: Card(
            elevation: _isHovering ? 8 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image with gradient overlay and price tag
                  Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Image
                      Hero(
                        tag: widget.laptop.title ?? '',
                        child: SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: Image.network(
                            widget.laptop.imageUrl ??
                                'https://via.placeholder.com/300x200?text=No+Image',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(Icons.laptop,
                                    size: 80, color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay

                      // Price tag
                      if (widget.laptop.price != null)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.laptop.price != null
                                  ? currencyFormat
                                      .format(widget.laptop.price! * 4.44)
                                  : '-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Content padding
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          getFirstPart(widget.laptop.title ?? '-'),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        // Rating row
                        Row(
                          children: [
                            StarRating(rating: rating),
                            const SizedBox(width: 8),
                            Text(
                              widget.laptop.reviewCount ?? '0 reviews',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Quick specs - extract from summary
                        if (widget.laptop.review_summary != null &&
                            showReviewInMain) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.laptop.review_summary!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Aspect highlights - showing top positive aspects as chips
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _getTopAspects(widget.laptop)
                              .take(3)
                              .map((aspect) {
                            return Chip(
                              label: Text(
                                _formatAspect(aspect),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: const Color.fromARGB(
                                        255, 116, 202, 241)),
                              ),
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.symmetric(horizontal: 8),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: _getAspectColor(aspect),
                                  width: 1,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  // Action button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Optional: Add comparison checkbox or other actions here
                        TextButton.icon(
                          icon: const Icon(Icons.info_outline),
                          label: const Text('View Details'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  _buildDetailDialog(context, reviews),
                            );
                          },
                        ),
                        // if (_isHovering)
                        //   AnimatedOpacity(
                        //     opacity: _isHovering ? 1.0 : 0.0,
                        //     duration: Duration(milliseconds: 200),
                        //     child: IconButton(
                        //       icon: Icon(Icons.favorite_border),
                        //       onPressed: () {
                        //         // Add to favorites functionality
                        //         ScaffoldMessenger.of(context).showSnackBar(
                        //           SnackBar(
                        //             content: Text('Added to favorites'),
                        //             duration: Duration(seconds: 1),
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailDialog(
      BuildContext context, List<Map<String, dynamic>> reviews) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                leading: const Icon(Icons.laptop, color: Colors.white),
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: widget.laptop.title ?? '',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.laptop.imageUrl ?? '',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.laptop,
                                  size: 80, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        // Add a gradient overlay to ensure the close button is visible
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: null, // No title in the app bar
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ];
          },
          body: Padding(
            padding: const EdgeInsets.all(16).copyWith(left: 24, right: 24),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and external link
                    Wrap(
                      children: [
                        Text(
                          getFirstPart(widget.laptop.title ?? ''),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        if (widget.laptop.product_url != null &&
                            widget.laptop.product_url != "///")
                          IconButton(
                            icon: const Icon(Icons.open_in_new,
                                color: Colors.blue),
                            tooltip: 'Visit product website',
                            onPressed: () async {
                              final url =
                                  widget.laptop.product_url!.startsWith('http')
                                      ? widget.laptop.product_url
                                      : 'https://${widget.laptop.product_url}';
                              // You'll need to add the url_launcher package
                              launchUrl(Uri.parse(url!));
                              // For now, show a snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Would open: $url')),
                              );
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price section
                    if (widget.laptop.price != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              '${(widget.laptop.price != null) ? NumberFormat.currency(symbol: 'RM ').format(widget.laptop.price! * 4.44) : 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Histogram section
                    if (widget.laptop.histogram != null) ...[
                      const Text(
                        'Overall Ratings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child:
                            _buildHistogram(context, widget.laptop.histogram!),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Summary
                    if (widget.laptop.review_summary != null) ...[
                      const Text(
                        'Summary',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          widget.laptop.review_summary!,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Text(
                      'Aspect Ratings',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    _buildRatingDetails(),
                    const SizedBox(height: 16),

                    const Text(
                      'Reviews',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    if (widget.laptop.reviews != null &&
                        widget.laptop.reviews!.isNotEmpty)
                      ...widget.laptop.reviews!.map((review) {
                        return Card(
                          color: const Color.fromARGB(255, 10, 4, 36),
                          margin: EdgeInsets.only(bottom: 8, right: 16),
                          child: ListTile(
                            title: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: _getRandomAvatarColor(
                                        review.reviewerName ?? ''),
                                    child: Text(
                                      review.reviewerName?[0] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Alternative: use an anonymous icon instead of initials
                                    // child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    review.reviewerName ?? 'Anonymous User',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(left: 44.0, bottom: 4),
                              child: Text(review.reviewText ?? ''),
                            ),
                            trailing: review.starRating != null
                                ? StarRating(
                                    rating: double.parse(
                                      review.starRating!.split(' ')[0],
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this new method to build histogram visualization
  Widget _buildHistogram(BuildContext context, Histogram histogram) {
    // Function to extract percentage value from string like "70%"
    int _extractPercentage(String? percentStr) {
      if (percentStr == null) return 0;
      final regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(percentStr);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
      return 0;
    }

    final ratings = [
      {
        'label': '5 \u2605',
        'percent': _extractPercentage(histogram.s5Star),
        'color': Colors.green
      },
      {
        'label': '4 \u2605',
        'percent': _extractPercentage(histogram.s4Star),
        'color': Colors.lightGreen
      },
      {
        'label': '3 \u2605',
        'percent': _extractPercentage(histogram.s3Star),
        'color': Colors.amber
      },
      {
        'label': '2 \u2605',
        'percent': _extractPercentage(histogram.s2Star),
        'color': Colors.orange
      },
      {
        'label': '1 \u2605',
        'percent': _extractPercentage(histogram.s1Star),
        'color': Colors.red
      },
    ];

    return Container(
      height: 180,
      child: Column(
        children: ratings.map((rating) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    rating['label'] as String,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (rating['percent'] as int) / 100,
                        child: Container(
                          height: 18,
                          decoration: BoxDecoration(
                            color: rating['color'] as Color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${rating['percent']}%',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingDetails() {
    // Extract ratings for each aspect from the laptop data
    return Column(
      children: [
        _buildAspectRating('Display', _getAspectRating('DISPLAY')),
        SizedBox(height: 4),
        _buildAspectRating('Battery', _getAspectRating('BATTERY')),
        SizedBox(height: 4),
        _buildAspectRating('Performance', _getAspectRating('PERFORMANCE')),
        SizedBox(height: 4),
        _buildAspectRating('Design', _getAspectRating('DESIGN')),
        SizedBox(height: 4),
        _buildAspectRating('Audio', _getAspectRating('AUDIO')),
      ],
    );
  }

  Widget _buildAspectRating(String title, double rating) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(title),
        ),
        Expanded(
          flex: 3,
          child: StarRating(rating: rating),
        ),
      ],
    );
  }

  // Helper method to extract rating from string like "4.5 out of 5 stars"
  double _extractRating(String ratingStr) {
    try {
      final regex = RegExp(r'(\d+(\.\d+)?)');
      final match = regex.firstMatch(ratingStr);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
    } catch (e) {
      print('Error parsing rating: $e');
    }
    return 0.0;
  }

  // Get top aspects to display as chips
  List<String> _getTopAspects(Laptop laptop) {
    List<String> aspects = [];
    if (laptop.pos5Aspects != null) aspects.addAll(laptop.pos5Aspects!);
    if (aspects.length < 3 && laptop.pos4Aspects != null)
      aspects.addAll(laptop.pos4Aspects!);
    return aspects;
  }

  // Format aspect name for display
  String _formatAspect(String aspect) {
    return aspect
        .split('_')
        .map((word) => word.length > 0
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  // Determine aspect color based on its name
  Color _getAspectColor(String aspect) {
    switch (aspect.toUpperCase()) {
      case 'PERFORMANCE':
        return Colors.blue[100]!;
      case 'DISPLAY':
        return Colors.purple[100]!;
      case 'BATTERY':
        return Colors.green[100]!;
      case 'DESIGN':
        return Colors.orange[100]!;
      case 'AUDIO':
        return Colors.red[100]!;
      case 'BUILD_QUALITY':
        return Colors.teal[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  // Get rating for a specific aspect
  double _getAspectRating(String aspect) {
    // These are placeholder calculations. In a real app, you'd need to extract this data
    // from your API or process the aspect lists more thoroughly.
    aspect = aspect.toUpperCase();
    final laptop = widget.laptop;

    if (laptop.pos5Aspects != null && laptop.pos5Aspects!.contains(aspect))
      return 5.0;
    if (laptop.pos4Aspects != null && laptop.pos4Aspects!.contains(aspect))
      return 4.0;
    if (laptop.pos3Aspects != null && laptop.pos3Aspects!.contains(aspect))
      return 3.0;
    if (laptop.pos2Aspects != null && laptop.pos2Aspects!.contains(aspect))
      return 2.0;
    if (laptop.pos1Aspects != null && laptop.pos1Aspects!.contains(aspect))
      return 1.0;

    // Negative aspects would subtract from a base score
    return 3.0; // Default neutral rating
  }
}

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

Color _getRandomAvatarColor(String name) {
  // Use the name to generate a consistent color
  final colors = [
    Colors.blue[700]!,
    Colors.purple[600]!,
    Colors.green[700]!,
    Colors.orange[700]!,
    Colors.red[700]!,
    Colors.teal[700]!,
    Colors.pink[600]!,
    Colors.indigo[600]!,
  ];

  // Use the name to pick a consistent color from the list
  int hashCode = name.hashCode.abs();
  return colors[hashCode % colors.length];
}
