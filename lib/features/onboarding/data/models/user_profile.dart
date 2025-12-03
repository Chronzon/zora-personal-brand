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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'] ?? '',
      whatILove: json['what_i_love'] ?? '',
      whatImGoodAt: json['what_im_good_at'] ?? '',
      whatTheWorldNeeds: json['what_the_world_needs'] ?? '',
      whatICanBePaidFor: json['what_i_can_be_paid_for'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'what_i_love': whatILove,
      'what_im_good_at': whatImGoodAt,
      'what_the_world_needs': whatTheWorldNeeds,
      'what_i_can_be_paid_for': whatICanBePaidFor,
    };
  }
}
