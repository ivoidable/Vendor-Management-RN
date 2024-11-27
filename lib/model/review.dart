class Review {
  String id;
  String reviewerId;
  String organizerId;
  String eventId;
  String review;
  int rating;
  List<String> imagesUrls;

  Review({
    required this.id,
    required this.reviewerId,
    required this.organizerId,
    required this.eventId,
    required this.review,
    required this.rating,
    required this.imagesUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewer_id': reviewerId,
      'organizer_id': organizerId,
      'event_id': eventId,
      'review': review,
      'rating': rating,
      'images_urls': imagesUrls,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      reviewerId: map['reviewer_id'],
      organizerId: map['organizer_id'],
      eventId: map['event_id'],
      review: map['review'],
      rating: map['rating'],
      imagesUrls: List<String>.from(map['images_urls']),
    );
  }
}
