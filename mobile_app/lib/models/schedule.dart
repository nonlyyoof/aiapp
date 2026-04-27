class ScheduleItem {
  final int id;
  final String subject;
  final String room;
  final String teacher;
  final DateTime startTime;
  final DateTime endTime;
  final String dayOfWeek;

  ScheduleItem({
    required this.id,
    required this.subject,
    required this.room,
    required this.teacher,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
  });
}