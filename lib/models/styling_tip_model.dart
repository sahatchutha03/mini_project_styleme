class StylingTip {
  final int id;
  final String bodyShape; // e.g. Pear, Hourglass, Apple, Rectangle, Inverted Triangle
  final String tipTitle;
  final String tipContent;
  final String highlightFeature; // e.g. "พรางสะโพก", "เน้นเอวคอด", "เปิดช่วงไหล่"
  final String luckyColorSynergy; // คำแนะนำการประยุกต์สีมงคล

  StylingTip({
    required this.id,
    required this.bodyShape,
    required this.tipTitle,
    required this.tipContent,
    required this.highlightFeature,
    this.luckyColorSynergy = '',
  });

  factory StylingTip.fromJson(Map<String, dynamic> json) {
    return StylingTip(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      bodyShape: json['bodyShape'] ?? json['body_shape'] ?? '',
      tipTitle: json['tipTitle'] ?? json['tip_title'] ?? '',
      tipContent: json['tipContent'] ?? json['tip_content'] ?? '',
      highlightFeature: json['highlightFeature'] ?? json['highlight_feature'] ?? '',
      luckyColorSynergy: json['luckyColorSynergy'] ?? json['lucky_color_synergy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bodyShape': bodyShape,
      'tipTitle': tipTitle,
      'tipContent': tipContent,
      'highlightFeature': highlightFeature,
      'luckyColorSynergy': luckyColorSynergy,
    };
  }
}
