class TaskCreate {
  final int projectId;
  final int developerId;
  final String title;
  final String description;
  final double hourlyRate;

  TaskCreate({
    required this.projectId,
    required this.developerId,
    required this.title,
    required this.description,
    required this.hourlyRate,
  });

  Map<String, dynamic> toJson() => {
    'project_id': projectId,
    'developer_id': developerId,
    'title': title,
    'description': description,
    'hourly_rate': hourlyRate,
  };
}