class ContentPlanItem {
  String id;
  DateTime date;
  String pillar;
  String topic;
  String caption;
  String visualInfo; // Info untuk visual, bisa berupa deskripsi atau link
  String status;

  ContentPlanItem({
    required this.id,
    required this.date,
    required this.pillar,
    required this.topic,
    this.caption = '',
    this.visualInfo = '',
    this.status = 'To Do', // Default status
  });
}