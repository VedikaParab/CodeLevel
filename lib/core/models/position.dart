class Position {
  int x;
  int y;

  Position(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '($x, $y)';

  Position copyWith({int? x, int? y}) {
    return Position(x ?? this.x, y ?? this.y);
  }
}
