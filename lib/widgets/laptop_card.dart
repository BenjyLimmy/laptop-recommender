import 'package:flutter/material.dart';
import 'package:laptop_reco/entities/laptop.dart';
import 'package:intl/intl.dart';
import 'package:laptop_reco/utils.dart';
import 'package:laptop_reco/widgets/star_rating.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this dependency for currency formatting

class LaptopCard extends StatefulWidget {
  final Laptop laptop;
  LaptopCard({required this.laptop});

  @override
  _LaptopCardState createState() => _LaptopCardState();
}

class _LaptopCardState extends State<LaptopCard> {
  bool _isHovering = false;

  void showLaptopPopup() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _buildDetailDialog(context);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.05);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'RM ');
    final rating = _extractRating(widget.laptop.averageRating ?? '0');

    double width = MediaQuery.of(context).size.width;
    bool showReviewInMain = width >= 1200;

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
          onTap: showLaptopPopup,
          child: Card(
            elevation: _isHovering ? 8 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
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
                            const SizedBox(height: 15),
                            Text(
                              widget.laptop.review_summary!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
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
                                labelPadding:
                                    EdgeInsets.symmetric(horizontal: 8),
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
                          TextButton.icon(
                            icon: const Icon(Icons.info_outline),
                            label: const Text('View Details'),
                            onPressed: showLaptopPopup,
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
      ),
    );
  }

  Widget _buildDetailDialog(BuildContext context) {
    return AnimatedBuilder(
      animation: ModalRoute.of(context)!.animation!,
      builder: (context, child) {
        return Transform.scale(
          scale: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOutQuint,
          ).value,
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      leading: const Icon(Icons.laptop, color: Colors.white),
                      expandedHeight: 300.0,
                      floating: false,
                      pinned: true,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
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
                  padding:
                      const EdgeInsets.all(16).copyWith(left: 24, right: 24),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
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
                                    final url = widget.laptop.product_url!
                                            .startsWith('http')
                                        ? widget.laptop.product_url
                                        : 'https://${widget.laptop.product_url}';
                                    // You'll need to add the url_launcher package
                                    launchUrl(Uri.parse(url!));
                                    // For now, show a snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Would open: $url')),
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
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.attach_money,
                                      color: Colors.white),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildHistogram(
                                  context, widget.laptop.histogram!),
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          _buildRatingDetails(),
                          const SizedBox(height: 16),

                          const Text(
                            'Reviews',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              _getRandomAvatarColor(
                                                  review.reviewerName ?? ''),
                                          child: review.reviewerName != null
                                              ? Text(
                                                  review.reviewerName?[0] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                          // Alternative: use an anonymous icon instead of initials
                                          // child: Icon(Icons.person, color: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          review.reviewerName ??
                                              'Anonymous User',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 44.0, bottom: 4),
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
          ),
        );
      },
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
        _buildAspectRating('Design', _getAspectRating('PRICE')),
        SizedBox(height: 4),
        _buildAspectRating('Audio', _getAspectRating('AUDIO')),
        SizedBox(height: 4),
        _buildAspectRating('Build Quality', _getAspectRating('BUILD_QUALITY')),
        SizedBox(height: 4),
        _buildAspectRating('Portability', _getAspectRating('PORTABILITY')),
        SizedBox(height: 4),
        _buildAspectRating('Price', _getAspectRating('DESIGN')),
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
    // Create a map of aspect name to score
    Map<String, int?> aspectScores = {
      'AUDIO': laptop.audioScore,
      'BATTERY': laptop.batteryScore,
      'BUILD_QUALITY': laptop.buildQualityScore,
      'DESIGN': laptop.designScore,
      'DISPLAY': laptop.displayScore,
      'PERFORMANCE': laptop.performanceScore,
      'PORTABILITY': laptop.portabilityScore,
      'PRICE': laptop.priceScore,
    };

    // Filter out null scores and sort by score value (highest first)
    List<MapEntry<String, int?>> sortedAspects = aspectScores.entries
        .where((entry) => entry.value != null)
        .toList()
      ..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));

    // Return top 3 aspects (or fewer if there aren't 3)
    return sortedAspects.take(3).map((entry) => entry.key).toList();
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
    aspect = aspect.toUpperCase();
    final laptop = widget.laptop;

    // Get raw score for this aspect
    int? score;
    switch (aspect) {
      case 'AUDIO':
        score = laptop.audioScore;
        break;
      case 'BATTERY':
        score = laptop.batteryScore;
        break;
      case 'BUILD_QUALITY':
        score = laptop.buildQualityScore;
        break;
      case 'DESIGN':
        score = laptop.designScore;
        break;
      case 'DISPLAY':
        score = laptop.displayScore;
        break;
      case 'PERFORMANCE':
        score = laptop.performanceScore;
        break;
      case 'PORTABILITY':
        score = laptop.portabilityScore;
        break;
      case 'PRICE':
        score = laptop.priceScore;
        break;
    }

    // If no score available, return a neutral rating
    if (score == null) return 3.0;

    // Constants for normalization
    const int minPossibleScore = -10; // What you consider "terrible"
    const int maxPossibleScore = 25; // What you consider "excellent"
    const double minStars = 1.0; // Minimum star rating (not 0)
    const double maxStars = 5.0; // Maximum star rating

    // Normalize to 1-5 star range with clamping
    double normalizedScore = minStars +
        (score - minPossibleScore) *
            (maxStars - minStars) /
            (maxPossibleScore - minPossibleScore);

    // Clamp between 1 and 5 stars
    return normalizedScore.clamp(minStars, maxStars);
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
