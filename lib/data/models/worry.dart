enum WorryIntensity {
  pluto,    // 1단계 - 명왕성
  mercury,  // 2단계 - 수성
  mars,     // 3단계 - 화성
  venus,    // 4단계 - 금성
  earth,    // 5단계 - 지구
  neptune,  // 6단계 - 해왕성
  uranus,   // 7단계 - 천왕성
  saturn,   // 8단계 - 토성
  jupiter,  // 9단계 - 목성
  sun,      // 10단계 - 태양
}

extension WorryIntensityX on WorryIntensity {
  int get level => index + 1;

  String get planetName {
    switch (this) {
      case WorryIntensity.pluto:   return '명왕성';
      case WorryIntensity.mercury: return '수성';
      case WorryIntensity.mars:    return '화성';
      case WorryIntensity.venus:   return '금성';
      case WorryIntensity.earth:   return '지구';
      case WorryIntensity.neptune: return '해왕성';
      case WorryIntensity.uranus:  return '천왕성';
      case WorryIntensity.saturn:  return '토성';
      case WorryIntensity.jupiter: return '목성';
      case WorryIntensity.sun:     return '태양';
    }
  }

  String get label {
    switch (this) {
      case WorryIntensity.pluto:   return '거의 신경 안 쓰여요';
      case WorryIntensity.mercury: return '살짝 신경 쓰여요';
      case WorryIntensity.mars:    return '조금 마음에 걸려요';
      case WorryIntensity.venus:   return '은근히 무거워요';
      case WorryIntensity.earth:   return '제법 무겁게 느껴져요';
      case WorryIntensity.neptune: return '꽤 신경 쓰여요';
      case WorryIntensity.uranus:  return '많이 무거워요';
      case WorryIntensity.saturn:  return '상당히 크게 느껴져요';
      case WorryIntensity.jupiter: return '정말 크게 느껴져요';
      case WorryIntensity.sun:     return '가장 무겁고 큰 걱정이에요';
    }
  }

  String get shortLabel => '$level단계 $planetName';

  String get emoji {
    switch (this) {
      case WorryIntensity.pluto:   return '🪨';
      case WorryIntensity.mercury: return '🌑';
      case WorryIntensity.mars:    return '🔴';
      case WorryIntensity.venus:   return '🌕';
      case WorryIntensity.earth:   return '🌍';
      case WorryIntensity.neptune: return '🔵';
      case WorryIntensity.uranus:  return '💎';
      case WorryIntensity.saturn:  return '🪐';
      case WorryIntensity.jupiter: return '🟠';
      case WorryIntensity.sun:     return '☀️';
    }
  }

  double get planetSize {
    switch (this) {
      case WorryIntensity.pluto:   return 28;
      case WorryIntensity.mercury: return 34;
      case WorryIntensity.mars:    return 40;
      case WorryIntensity.venus:   return 46;
      case WorryIntensity.earth:   return 52;
      case WorryIntensity.neptune: return 58;
      case WorryIntensity.uranus:  return 64;
      case WorryIntensity.saturn:  return 70;
      case WorryIntensity.jupiter: return 80;
      case WorryIntensity.sun:     return 90;
    }
  }
}

enum WorryStatus {
  active,
  reviewable,
  resolved,
}

enum ReviewAnswer {
  resolved,      // 예 - 해결됨
  notResolved,   // 아니요 - 해결 안 됨
}

extension ReviewAnswerX on ReviewAnswer {
  String get label {
    switch (this) {
      case ReviewAnswer.resolved:    return '해결됨';
      case ReviewAnswer.notResolved: return '미해결';
    }
  }

  String get emoji {
    switch (this) {
      case ReviewAnswer.resolved:    return '✨';
      case ReviewAnswer.notResolved: return '😔';
    }
  }

  bool get isResolved => this == ReviewAnswer.resolved;
}

class Worry {
  final String id;
  final String content;
  final WorryIntensity intensity;
  final DateTime reviewAt;
  final DateTime createdAt;
  WorryStatus status;
  ReviewAnswer? reviewAnswer;
  String? reviewNote;
  DateTime? reviewedAt;

  Worry({
    required this.id,
    required this.content,
    required this.intensity,
    required this.reviewAt,
    required this.createdAt,
    this.status = WorryStatus.active,
    this.reviewAnswer,
    this.reviewNote,
    this.reviewedAt,
  });

  void updateStatus() {
    if (status == WorryStatus.active && DateTime.now().isAfter(reviewAt)) {
      status = WorryStatus.reviewable;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'intensity': intensity.index,
      'reviewAt': reviewAt.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status.index,
      'reviewAnswer': reviewAnswer?.index,
      'reviewNote': reviewNote,
      'reviewedAt': reviewedAt?.millisecondsSinceEpoch,
    };
  }

  factory Worry.fromMap(Map<dynamic, dynamic> map) {
    final rawIntensity = map['intensity'] as int;
    final intensityIndex =
        rawIntensity.clamp(0, WorryIntensity.values.length - 1);

    final w = Worry(
      id: map['id'] as String,
      content: map['content'] as String,
      intensity: WorryIntensity.values[intensityIndex],
      reviewAt: DateTime.fromMillisecondsSinceEpoch(map['reviewAt'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      status: WorryStatus.values[map['status'] as int],
      reviewAnswer: map['reviewAnswer'] != null
          ? ReviewAnswer.values[
              (map['reviewAnswer'] as int).clamp(0, ReviewAnswer.values.length - 1)]
          : null,
      reviewNote: map['reviewNote'] as String?,
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reviewedAt'] as int)
          : null,
    );
    return w;
  }

  Worry copyWith({
    WorryStatus? status,
    ReviewAnswer? reviewAnswer,
    String? reviewNote,
    DateTime? reviewedAt,
  }) {
    return Worry(
      id: id,
      content: content,
      intensity: intensity,
      reviewAt: reviewAt,
      createdAt: createdAt,
      status: status ?? this.status,
      reviewAnswer: reviewAnswer ?? this.reviewAnswer,
      reviewNote: reviewNote ?? this.reviewNote,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
