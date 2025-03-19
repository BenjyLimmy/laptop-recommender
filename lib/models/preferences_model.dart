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

  Map<String, String> aspectToLabelMap = {
    'DISPLAY': 'Display',
    'BATTERY': 'Battery',
    'PERFORMANCE': 'Performance',
    'DESIGN': 'Design',
    'AUDIO': 'Audio',
    'BUILD_QUALITY': 'Build Quality',
    'PRICE': 'Price',
    'PORTABILITY': 'Portability',
  };

  // Get the top [count] laptops based on current preferences
  Future<List<Laptop>> getRecommendedLaptops(int count) async {
    // Define possible API endpoints
    final apiHosts = [
      'localhost:8081', // Local development
      '10.0.2.2:8081', // Android emulator to host
      'host.docker.internal:8081', // Docker container to host
      'api:8081', // Docker container to container (if using docker-compose)
    ];

    try {
      setLoading('Finding the perfect laptops based on your preferences...');

      // Extract selected aspects
      List<String> selectedAspects = [];
      aspectSelected.forEach((aspect, isSelected) {
        if (isSelected) {
          selectedAspects.add(aspect.toUpperCase().replaceAll(' ', '_'));
        }
      });
      // Build query parameters
      Map<String, String> queryParams = {};
      if (selectedAspects.isNotEmpty) {
        queryParams['aspects'] = (selectedAspects
              ..sort((a, b) => (aspectWeights[aspectToLabelMap[b]] ?? 0)
                  .compareTo(aspectWeights[aspectToLabelMap[a]] ?? 0)))
            .join(',');
      } else {
        queryParams['aspects'] = '';
      }

      // Try each possible host until one works
      Exception? lastException;
      for (String host in apiHosts) {
        try {
          final uri = Uri.http(host, '/laptops', queryParams);
          print('Attempting to connect to: $uri');

          final response = await http.get(uri).timeout(Duration(seconds: 5));

          if (response.statusCode == 200) {
            print('Successfully connected to $host');
            List<dynamic> jsonResponse = json.decode(response.body);
            List<Laptop> laptops =
                jsonResponse.map((json) => Laptop.fromJson(json)).toList();
            // print(jsonResponse);
            // await Future.delayed(Duration(seconds: 2));
            setLoading(
                'Almost ready with your personalized recommendations...');
            setIdle();
            _allLaptops = laptops;
            return laptops;
          }
        } catch (e) {
          print('Failed to connect to $host: $e');
          lastException = e as Exception;
          continue; // Try the next host
        }
      }

      // If we get here, all connection attempts failed
      throw lastException ?? Exception('Could not connect to any API endpoint');
    } catch (e) {
      print('Error: ${e.toString()}');
      setError('Failed to load laptops: ${e.toString()}');
      return [];
    }
  }
}
