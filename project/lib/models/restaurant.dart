class Restaurant{
  final int? id;
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final String category;
  final double latitude;
  final double longitude;
  final String description;
  final int deliveryTime;
  Restaurant({
    this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.deliveryTime,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.rating
  });
  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'name':name,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'deliveryTime': deliveryTime,
    };
  }
  factory Restaurant.fromMap(Map<String,dynamic>map){
    return Restaurant(
      id:map['id'],
      name: map['name'],
      address: map['address'],
      imageUrl: map['imageUrl'],
      rating: map['rating'],
      category: map['category'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      description: map['description'],
      deliveryTime: map['deliveryTime'],
    );
  }

}