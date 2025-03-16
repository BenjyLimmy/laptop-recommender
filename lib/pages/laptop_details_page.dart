import 'package:flutter/material.dart';
import 'package:laptop_reco/entities/laptop.dart';
import 'package:laptop_reco/widgets/laptop_card.dart';

class LaptopDetailsPage extends StatelessWidget {
  final Laptop laptop;
  final List<Map<String, dynamic>> reviews;

  const LaptopDetailsPage({
    Key? key,
    required this.laptop,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(laptop.title ?? ''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: laptop.title ?? '',
                child: Image.network(
                  laptop.imageUrl ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Text(
                laptop.review_summary ?? '',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text('Detailed Ratings:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              // StarRating(title: 'Display', rating: laptop.display ?? 5),
              // StarRating(title: 'Battery', rating: laptop.battery ?? 5),
              // StarRating(title: 'Performance', rating: laptop.performance ?? 5),
              // StarRating(title: 'Design', rating: laptop.design ?? 5),
              SizedBox(height: 24),
              Text('Reviews',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 12),
              ...reviews.map((review) {
                return Card(
                  color: Colors.grey[850],
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(
                      review['reviewer']! as String,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      review['comment']! as String,
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: StarRating(
                      title: '',
                      rating: review['rating'] as double,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
