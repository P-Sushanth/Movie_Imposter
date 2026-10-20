enum Industry {
  tollywood,
  bollywood,
  hollywood,
  shows,
  kdrama,
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
      case Industry.shows:
        return 'shows';
      case Industry.kdrama:
        return 'kdrama';
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
      case Industry.shows:
        return 'Shows';
      case Industry.kdrama:
        return 'K-Drama';
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
      case 'shows':
        return Industry.shows;
      case 'kdrama':
        return Industry.kdrama;
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
  final String? hint;

  // Show-specific fields (optional for movies, populated for shows):
  final String? productionHouse;
  final int? seasonsCount;
  final int? startYear;
  final String? endYear;
  final String? adaptationOrOriginal;
  final String? releaseMedium;

  const Movie({
    required this.id,
    required this.title,
    required this.industry,
    required this.releaseYear,
    required this.decade,
    this.hero = '',
    this.director = '',
    this.genre = '',
    this.hint,
    this.productionHouse,
    this.seasonsCount,
    this.startYear,
    this.endYear,
    this.adaptationOrOriginal,
    this.releaseMedium,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      industry: IndustryExtension.fromString(json['industry'] as String),
      releaseYear: json['releaseYear'] as int,
      decade: json['decade'] as String,
      hero: (json['hero'] as String?) ?? '',
      director: (json['director'] as String?) ?? '',
      genre: (json['genre'] as String?) ?? '',
      hint: json['hint'] as String?,
      productionHouse: json['productionHouse'] as String?,
      seasonsCount: json['seasonsCount'] as int?,
      startYear: json['startYear'] as int?,
      endYear: json['endYear'] as String?,
      adaptationOrOriginal: json['adaptationOrOriginal'] as String?,
      releaseMedium: json['releaseMedium'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'industry': industry.id,
      'releaseYear': releaseYear,
      'decade': decade,
      if (hero.isNotEmpty) 'hero': hero,
      if (director.isNotEmpty) 'director': director,
      if (genre.isNotEmpty) 'genre': genre,
      if (hint != null && hint!.isNotEmpty) 'hint': hint,
      if (productionHouse != null) 'productionHouse': productionHouse,
      if (seasonsCount != null) 'seasonsCount': seasonsCount,
      if (startYear != null) 'startYear': startYear,
      if (endYear != null) 'endYear': endYear,
      if (adaptationOrOriginal != null) 'adaptationOrOriginal': adaptationOrOriginal,
      if (releaseMedium != null) 'releaseMedium': releaseMedium,
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
