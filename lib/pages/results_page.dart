import 'package:flutter/material.dart';
import 'package:laptop_reco/widgets/laptop_card.dart';
import 'package:laptop_reco/widgets/loading_animation.dart';
import 'package:laptop_reco/models/preferences_model.dart';
import 'package:laptop_reco/entities/laptop.dart';
import 'package:provider/provider.dart';

class ResultsPage extends StatefulWidget {
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late Future<List<Laptop>> _laptopsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState
    final prefs = Provider.of<PreferencesModel>(context, listen: false);
    _laptopsFuture = prefs.getRecommendedLaptops(5);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesModel>(context);

    // Determine grid columns based on screen width (responsive layout)
    double width = MediaQuery.of(context).size.width;
    int columns;
    if (width >= 1200) {
      columns = 2;
    } else {
      columns = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Top Recommendations'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Builder(
          builder: (context) {
            // Check the loading state
            if (prefs.isLoading) {
              // Show loading indicator with custom message
              return LoadingAnimation(message: prefs.loadingMessage);
            } else if (prefs.isError) {
              // Show error message
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 16),
                    Text('Error: ${prefs.errorMessage ?? "Unknown error"}',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _laptopsFuture = prefs.getRecommendedLaptops(5);
                        });
                      },
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              // Show results from the future
              return FutureBuilder<List<Laptop>>(
                future: _laptopsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 60),
                          SizedBox(height: 16),
                          Text('Error: ${snapshot.error}',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Empty state
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.laptop_outlined,
                              color: Colors.grey, size: 80),
                          SizedBox(height: 16),
                          Text('No matching laptops found',
                              style: Theme.of(context).textTheme.titleLarge),
                          SizedBox(height: 8),
                          Text('Try adjusting your preferences',
                              style: Theme.of(context).textTheme.bodyMedium),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Back to Preferences'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Show grid view with laptop cards
                    return GridView.count(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2, // width/height ratio for cards
                      children: snapshot.data!
                          .map((laptop) => LaptopCard(laptop: laptop))
                          .toList(),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
