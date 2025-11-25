class UserProfile {
  final String fullName;
  final String whatILove;
  final String whatImGoodAt;
  final String whatTheWorldNeeds;
  final String whatICanBePaidFor;

  UserProfile({
    this.fullName = '',
    this.whatILove = '',
    this.whatImGoodAt = '',
    this.whatTheWorldNeeds = '',
    this.whatICanBePaidFor = '',
  });

  UserProfile copyWith({
    String? fullName,
    String? whatILove,
    String? whatImGoodAt,
    String? whatTheWorldNeeds,
    String? whatICanBePaidFor,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      whatILove: whatILove ?? this.whatILove,
      whatImGoodAt: whatImGoodAt ?? this.whatImGoodAt,
      whatTheWorldNeeds: whatTheWorldNeeds ?? this.whatTheWorldNeeds,
      whatICanBePaidFor: whatICanBePaidFor ?? this.whatICanBePaidFor,
    );
  }
}
