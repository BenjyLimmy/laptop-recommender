import 'package:laptop_reco/utils.dart';

class Laptop {
  String? title;
  String? productId;
  String? averageRating;
  String? reviewCount;
  String? product_url;
  double? price;
  String? imageUrl;
  Histogram? histogram;
  String? review_summary;
  // Aspect score properties
  int? audioScore;
  int? batteryScore;
  int? buildQualityScore;
  int? designScore;
  int? displayScore;
  int? performanceScore;
  int? portabilityScore;
  int? priceScore;

  // NEW: Replace individual sentiment lists with a structured object
  ReviewSentiments? reviewSentiments;

  // Keep direct access properties for backwards compatibility
  List<String>? get pos5Aspects => reviewSentiments?.pos5Aspects;
  List<String>? get neg5Aspects => reviewSentiments?.neg5Aspects;
  List<String>? get pos4Aspects => reviewSentiments?.pos4Aspects;
  List<String>? get neg4Aspects => reviewSentiments?.neg4Aspects;
  List<String>? get pos3Aspects => reviewSentiments?.pos3Aspects;
  List<String>? get neg3Aspects => reviewSentiments?.neg3Aspects;
  List<String>? get pos2Aspects => reviewSentiments?.pos2Aspects;
  List<String>? get neg2Aspects => reviewSentiments?.neg2Aspects;
  List<String>? get pos1Aspects => reviewSentiments?.pos1Aspects;
  List<String>? get neg1Aspects => reviewSentiments?.neg1Aspects;
  List<Review>? reviews;

  Laptop(
      {this.title,
      this.productId,
      this.averageRating,
      this.reviewCount,
      this.product_url,
      this.price,
      this.imageUrl,
      this.histogram,
      this.review_summary,
      // Add aspect scores to constructor
      this.audioScore,
      this.batteryScore,
      this.buildQualityScore,
      this.designScore,
      this.displayScore,
      this.performanceScore,
      this.portabilityScore,
      this.priceScore,
      this.reviewSentiments,
      this.reviews});

  Laptop.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    title = TextSanitizer.sanitize(title);
    productId = json['product_id'];
    averageRating = json['average_rating'];
    reviewCount = json['review_count'];
    product_url = json['product_url'];
    price = json['price'] != null
        ? double.tryParse(
            json['price'].toString().replaceAll(RegExp(r'[^0-9.]'), ''))
        : null;
    imageUrl = json['image_url'];
    histogram = json['histogram'] != null
        ? new Histogram.fromJson(json['histogram'])
        : null;
    review_summary = json['review_summary'];
    // Parse aspect scores
    audioScore = json['audioScore'] as int?;
    batteryScore = json['batteryScore'] as int?;
    buildQualityScore = json['buildQualityScore'] as int?;
    designScore = json['designScore'] as int?;
    displayScore = json['displayScore'] as int?;
    performanceScore = json['performanceScore'] as int?;
    portabilityScore = json['portabilityScore'] as int?;
    priceScore = json['priceScore'] as int?;
    if (json['review_sentiments'] != null) {
      reviewSentiments = ReviewSentiments.fromJson(json['review_sentiments']);
    }

    if (json['review'] != null) {
      reviews = <Review>[];
      json['review'].forEach((v) {
        reviews!.add(new Review.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['product_id'] = this.productId;
    data['average_rating'] = this.averageRating;
    data['review_count'] = this.reviewCount;
    data['product_url'] = this.product_url;
    data['price'] = this.price;
    data['image_url'] = this.imageUrl;
    if (this.histogram != null) {
      data['histogram'] = this.histogram!.toJson();
    }
    // Serialize aspect scores
    data['audioScore'] = this.audioScore;
    data['batteryScore'] = this.batteryScore;
    data['buildQualityScore'] = this.buildQualityScore;
    data['designScore'] = this.designScore;
    data['displayScore'] = this.displayScore;
    data['performanceScore'] = this.performanceScore;
    data['portabilityScore'] = this.portabilityScore;
    data['priceScore'] = this.priceScore;

    data['review_summary'] = this.review_summary;
    if (this.reviewSentiments != null) {
      data['review_sentiments'] = this.reviewSentiments!.toJson();
    }
    if (this.reviews != null) {
      data['review'] = this.reviews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Histogram {
  String? s5Star;
  String? s4Star;
  String? s3Star;
  String? s2Star;
  String? s1Star;

  Histogram({this.s5Star, this.s4Star, this.s3Star, this.s2Star, this.s1Star});

  Histogram.fromJson(Map<String, dynamic> json) {
    s5Star = json['5_star'];
    s4Star = json['4_star'];
    s3Star = json['3_star'];
    s2Star = json['2_star'];
    s1Star = json['1_star'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['5_star'] = this.s5Star;
    data['4_star'] = this.s4Star;
    data['3_star'] = this.s3Star;
    data['2_star'] = this.s2Star;
    data['1_star'] = this.s1Star;
    return data;
  }
}

class Review {
  String? reviewerName;
  String? starRating;
  String? reviewDate;
  String? reviewText;

  Review({
    this.reviewerName,
    this.starRating,
    this.reviewDate,
    this.reviewText,
  });

  Review.fromJson(Map<String, dynamic> json) {
    reviewerName = json['reviewer_name'];
    starRating = json['star_rating'];
    reviewDate = json['review_date'];
    reviewText = TextSanitizer.sanitize(json['review_text']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reviewer_name'] = this.reviewerName;
    data['star_rating'] = this.starRating;
    data['review_date'] = this.reviewDate;
    data['review_text'] = this.reviewText;
    return data;
  }
}

class ReviewSentiments {
  List<String>? pos5Aspects;
  List<String>? neg5Aspects;
  List<String>? pos4Aspects;
  List<String>? neg4Aspects;
  List<String>? pos3Aspects;
  List<String>? neg3Aspects;
  List<String>? pos2Aspects;
  List<String>? neg2Aspects;
  List<String>? pos1Aspects;
  List<String>? neg1Aspects;

  ReviewSentiments({
    this.pos5Aspects,
    this.neg5Aspects,
    this.pos4Aspects,
    this.neg4Aspects,
    this.pos3Aspects,
    this.neg3Aspects,
    this.pos2Aspects,
    this.neg2Aspects,
    this.pos1Aspects,
    this.neg1Aspects,
  });

  ReviewSentiments.fromJson(Map<String, dynamic> json) {
    pos5Aspects = json['pos_5_aspects'] != null
        ? List<String>.from(json['pos_5_aspects'])
        : null;
    neg5Aspects = json['neg_5_aspects'] != null
        ? List<String>.from(json['neg_5_aspects'])
        : null;
    pos4Aspects = json['pos_4_aspects'] != null
        ? List<String>.from(json['pos_4_aspects'])
        : null;
    neg4Aspects = json['neg_4_aspects'] != null
        ? List<String>.from(json['neg_4_aspects'])
        : null;
    pos3Aspects = json['pos_3_aspects'] != null
        ? List<String>.from(json['pos_3_aspects'])
        : null;
    neg3Aspects = json['neg_3_aspects'] != null
        ? List<String>.from(json['neg_3_aspects'])
        : null;
    pos2Aspects = json['pos_2_aspects'] != null
        ? List<String>.from(json['pos_2_aspects'])
        : null;
    neg2Aspects = json['neg_2_aspects'] != null
        ? List<String>.from(json['neg_2_aspects'])
        : null;
    pos1Aspects = json['pos_1_aspects'] != null
        ? List<String>.from(json['pos_1_aspects'])
        : null;
    neg1Aspects = json['neg_1_aspects'] != null
        ? List<String>.from(json['neg_1_aspects'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pos_5_aspects'] = this.pos5Aspects;
    data['neg_5_aspects'] = this.neg5Aspects;
    data['pos_4_aspects'] = this.pos4Aspects;
    data['neg_4_aspects'] = this.neg4Aspects;
    data['pos_3_aspects'] = this.pos3Aspects;
    data['neg_3_aspects'] = this.neg3Aspects;
    data['pos_2_aspects'] = this.pos2Aspects;
    data['neg_2_aspects'] = this.neg2Aspects;
    data['pos_1_aspects'] = this.pos1Aspects;
    data['neg_1_aspects'] = this.neg1Aspects;
    return data;
  }
}
