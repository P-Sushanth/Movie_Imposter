class PlayerGroup {
  final String id;
  final String name;
  final List<String> players;
  final int createdAt;

  const PlayerGroup({
    required this.id,
    required this.name,
    required this.players,
    required this.createdAt,
  });

  PlayerGroup copyWith({
    String? id,
    String? name,
    List<String>? players,
    int? createdAt,
  }) {
    return PlayerGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players,
      'createdAt': createdAt,
    };
  }

  factory PlayerGroup.fromJson(Map<String, dynamic> json) {
    return PlayerGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerGroup &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
