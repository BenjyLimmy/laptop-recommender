import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laptop_reco/entities/laptop.dart';
import 'package:http/http.dart' as http;

enum LoadingState {
  idle,
  loading,
  error,
}

class PreferencesModel extends ChangeNotifier {
  // Loading state management
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;
  String _loadingMessage = 'Loading...';

  // Getters for state
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  String get loadingMessage => _loadingMessage;
  List<Laptop> get allLaptops => _allLaptops;

  // Helper methods to check state
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get isIdle => _loadingState == LoadingState.idle;
  bool get isError => _loadingState == LoadingState.error;

  // Define the aspect names
  static final List<String> aspects = [
    'Display',
    'Battery',
    'Performance',
    'Design',
    'Audio',
    'Build Quality',
    'Price',
    'Portability'
  ];

  static final String jsonString = """
[
  {
    "title": "HP Pavilion 15 Laptop",
    "product_id": "B0123ABCDE",
    "average_rating": "4.5 out of 5 stars",
    "review_count": "580 global ratings",
    "link": "https://www.amazon.com/HP-Pavilion-Touchscreen-Anti-Glare-Processor/dp/B0C4G4L53W",
    "price": 550,
    "image_url": "https://m.media-amazon.com/images/I/71nh46fzDYL._AC_UY218_.jpg",
    "histogram": {
      "5_star": "70%",
      "4_star": "20%",
      "3_star": "6%",
      "2_star": "2%",
      "1_star": "2%"
    },
    "summary": "A powerful laptop with excellent performance and a sleek design. It boasts a vibrant display and robust build quality. The battery life is also commendable for extended use.",
    "pos_5_aspects": ["PERFORMANCE", "DISPLAY", "DESIGN", "BUILD_QUALITY", "BATTERY"],
    "neg_5_aspects": [],
    "pos_4_aspects": ["AUDIO"],
    "neg_4_aspects": ["PRICE"],
    "pos_3_aspects": [],
    "neg_3_aspects": ["PORTABILITY"],
    "pos_2_aspects": [],
    "neg_2_aspects": [],
    "pos_1_aspects": [],
    "neg_1_aspects": []
  },
  {
    "title": "Lenovo IdeaPad Slim 3",
    "product_id": "B0456FGHIJ",
    "average_rating": "3.8 out of 5 stars",
    "review_count": "320 global ratings",
    "link": "https://www.amazon.com/HP-Pavilion-Touchscreen-Anti-Glare-Processor/dp/B0C4G4L53W",
    "price": 320,
    "image_url": "https://m.media-amazon.com/images/I/71nh46fzDYL._AC_UY218_.jpg",
    "histogram": {
      "5_star": "55%",
      "4_star": "15%",
      "3_star": "15%",
      "2_star": "8%",
      "1_star": "7%"
    },
    "summary": "A budget-friendly laptop designed for everyday tasks. Its portability and long battery life make it ideal for on-the-go use. However, the performance might be limited for demanding applications.",
    "pos_5_aspects": ["PRICE", "PORTABILITY", "BATTERY"],
    "neg_5_aspects": [],
    "pos_4_aspects": ["DISPLAY"],
    "neg_4_aspects": ["PERFORMANCE"],
    "pos_3_aspects": ["BUILD_QUALITY"],
    "neg_3_aspects": ["AUDIO"],
    "pos_2_aspects": [],
    "neg_2_aspects": ["DESIGN"],
    "pos_1_aspects": [],
    "neg_1_aspects": []
  },
  {
    "title": "Acer Aspire 5",
    "product_id": "B0789KLMNO",
    "average_rating": "4.0 out of 5 stars",
    "review_count": "410 global ratings",
    "link": "https://www.amazon.com/HP-Pavilion-Touchscreen-Anti-Glare-Processor/dp/B0C4G4L53W",
    "price": 450,
    "image_url": "https://m.media-amazon.com/images/I/71nh46fzDYL._AC_UY218_.jpg",
    "histogram": {
      "5_star": "60%",
      "4_star": "20%",
      "3_star": "10%",
      "2_star": "5%",
      "1_star": "5%"
    },
    "summary": "A versatile laptop offering a good balance of performance and features. It delivers a decent display and reliable battery life. While its portability is average, it serves well for various tasks.",
    "pos_5_aspects": ["PERFORMANCE", "DISPLAY"],
    "neg_5_aspects": [],
    "pos_4_aspects": ["BATTERY", "BUILD_QUALITY"],
    "neg_4_aspects": ["PORTABILITY"],
    "pos_3_aspects": ["DESIGN"],
    "neg_3_aspects": ["AUDIO"],
    "pos_2_aspects": [],
    "neg_2_aspects": ["PRICE"],
    "pos_1_aspects": [],
    "neg_1_aspects": []
  },
    {
    "title": "ASUS VivoBook 14",
    "product_id": "B0ABCDEFGH",
    "average_rating": "4.3 out of 5 stars",
    "review_count": "380 global ratings",
    "link": "https://www.amazon.com/HP-Pavilion-Touchscreen-Anti-Glare-Processor/dp/B0C4G4L53W",
    "price": 400,
    "image_url": "https://m.media-amazon.com/images/I/71nh46fzDYL._AC_UY218_.jpg",
    "histogram": {
      "5_star": "68%",
      "4_star": "18%",
      "3_star": "8%",
      "2_star": "3%",
      "1_star": "3%"
    },
    "summary": "A compact and efficient laptop designed for everyday use. Its portability and long battery life are key highlights. The display is clear and vibrant, making it suitable for various tasks.",
    "pos_5_aspects": ["PORTABILITY", "DISPLAY", "BATTERY"],
    "neg_5_aspects": [],
    "pos_4_aspects": ["PERFORMANCE", "DESIGN"],
    "neg_4_aspects": ["AUDIO"],
    "pos_3_aspects": ["BUILD_QUALITY"],
    "neg_3_aspects": ["PRICE"],
    "pos_2_aspects": [],
    "neg_2_aspects": [],
    "pos_1_aspects": [],
    "neg_1_aspects": []
  }
]
""";

  // Dummy list of laptops (static data for recommendations)
  List<Laptop> _allLaptops = [];

  // User-selected aspects and their weights
  Map<String, bool> aspectSelected = {};
  Map<String, double> aspectWeights = {};

  PreferencesModel() {
    // Initialize all aspects as selected with a medium importance (5 out of 10)
    for (var aspect in aspects) {
      aspectSelected[aspect] = false;
      aspectWeights[aspect] = 5.0;
    }
  }

  void setAspectSelected(String aspect, bool isSelected) {
    aspectSelected[aspect] = isSelected;
    notifyListeners(); // Notify UI of changes
  }

  void setLoading([String? message]) {
    _loadingState = LoadingState.loading;
    if (message != null) {
      _loadingMessage = message;
    } else {
      _loadingMessage = 'Loading...';
    }
    notifyListeners();
  }

  // Set idle state
  void setIdle() {
    _loadingState = LoadingState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // Set error state
  void setError(String message) {
    _loadingState = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void setAspectWeight(String aspect, double weight) {
    aspectWeights[aspect] = weight;
    notifyListeners(); // Notify UI of changes
  }

  Future<String> _loadJsonFromAsset() async {
    return await rootBundle.loadString('lib/sample_data.json');
  }

  // Get the top [count] laptops based on current preferences
  Future<List<Laptop>> getRecommendedLaptops(int count) async {
    // Sort all laptops by weighted score (highest first)
    //   List<Laptop> sorted = List.from(_allLaptops);
    //   sorted.sort((a, b) => b
    //       .totalScore(aspectSelected, aspectWeights)
    //       .compareTo(a.totalScore(aspectSelected, aspectWeights)));
    //   // Take the top N laptops
    //   return sorted.take(count).toList();
    // }

    try {
      // Set loading state with a custom message
      setLoading('Finding the perfect laptops based on your preferences...');

      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        // List<dynamic> jsonResponse = json.decode(response.body);
        // List<Laptop> laptops =
        //     jsonResponse.map((json) => Laptop.fromJson(json)).toList();

        // First loading phase
        // await Future.delayed(Duration(seconds: 2));

        // Update loading message to show progress
        setLoading('Analyzing laptop features and your preferences...');
        // await Future.delayed(Duration(seconds: 2));

        // Final loading message
        setLoading('Almost ready with your personalized recommendations...');
        // await Future.delayed(Duration(seconds: 1));
        // Parse the static JSON data
        final jsonString = await _loadJsonFromAsset();
        List<dynamic> jsonResponse = json.decode(jsonString);
        List<Laptop> laptops =
            jsonResponse.map((json) => Laptop.fromJson(json)).toList();

        // Set state back to idle
        setIdle();
        _allLaptops = laptops;
        return laptops;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load laptops');
      }
    } catch (e) {
      // Set error state
      setError('Failed to load laptops: ${e.toString()}');
      return [];
    }
  }
}
