import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  final String id;
  final String title;
  final String overview;
  final String posterUrl;
  final String releaseDate;
  final String? addedBy; // admin uid (null if from API)
  final DateTime? createdAt; // null if from API

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.releaseDate,
    this.addedBy,
    this.createdAt,
  });

  // From TMDb API response
  factory MovieModel.fromApi(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterUrl: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : '',
      releaseDate: json['release_date'] ?? '',
    );
  }

  // From Firestore (admin-added movies)
  factory MovieModel.fromFirestore(Map<String, dynamic> data) {
    return MovieModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      overview: data['overview'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      releaseDate: data['releaseDate'] ?? '',
      addedBy: data['addedBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // To Firestore (when admin adds manually)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterUrl': posterUrl,
      'releaseDate': releaseDate,
      'addedBy': addedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}