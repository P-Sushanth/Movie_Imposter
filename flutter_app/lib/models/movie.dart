enum Industry {
  tollywood,
  bollywood,
  hollywood,
}

extension IndustryExtension on Industry {
  String get id {
    switch (this) {
      case Industry.tollywood:
        return 'tollywood';
      case Industry.bollywood:
        return 'bollywood';
      case Industry.hollywood:
        return 'hollywood';
    }
  }

  String get label {
    switch (this) {
      case Industry.tollywood:
        return 'Tollywood';
      case Industry.bollywood:
        return 'Bollywood';
      case Industry.hollywood:
        return 'Hollywood';
    }
  }

  static Industry fromString(String str) {
    switch (str.toLowerCase()) {
      case 'tollywood':
        return Industry.tollywood;
      case 'bollywood':
        return Industry.bollywood;
      case 'hollywood':
        return Industry.hollywood;
      default:
        throw ArgumentError('Unknown industry: $str');
    }
  }
}

class Movie {
  final String id;
  final String title;
  final Industry industry;
  final int releaseYear;
  final String decade;
  final String hero;
  final String director;
  final String genre;
  final bool isAdult;
  final bool isRemake;

  const Movie({
    required this.id,
    required this.title,
    required this.industry,
    required this.releaseYear,
    required this.decade,
    required this.hero,
    required this.director,
    required this.genre,
    required this.isAdult,
    required this.isRemake,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      industry: IndustryExtension.fromString(json['industry'] as String),
      releaseYear: json['releaseYear'] as int,
      decade: json['decade'] as String,
      hero: json['hero'] as String,
      director: json['director'] as String,
      genre: json['genre'] as String,
      isAdult: json['isAdult'] as bool,
      isRemake: json['isRemake'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'industry': industry.id,
      'releaseYear': releaseYear,
      'decade': decade,
      'hero': hero,
      'director': director,
      'genre': genre,
      'isAdult': isAdult,
      'isRemake': isRemake,
    };
  }
}

class ClueItem {
  final String key;
  final String label;
  final String value;
  final String displayText;

  const ClueItem({
    required this.key,
    required this.label,
    required this.value,
    required this.displayText,
  });
}
