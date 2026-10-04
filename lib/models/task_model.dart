class TaskModel {
  final int? id;
  final String title;
  final String description;
  final int assignedToId;
  final String dueDate;
  final String priority;
  final String status;
  final String? notes;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.assignedToId,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.notes,
  });

  // SLA Calculation Rule based on assignment requirements
  String get slaStatus {
    if (status == 'Completed') return 'Completed';
    
    DateTime due = DateTime.tryParse(dueDate) ?? DateTime.now();
    DateTime now = DateTime.now();
    
    // An incomplete task whose deadline has passed should be identified as "Overdue"
    if (now.isAfter(due) && status != 'Completed') {
      return 'Overdue';
    }
    
    // Rule for determining when a task becomes "At Risk" (e.g., due within 2 days)
    if (due.difference(now).inDays <= 2 && status != 'Completed') {
      return 'At Risk';
    }
    
    return 'On Track';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedToId': assignedToId,
      'dueDate': dueDate,
      'priority': priority,
      'status': status,
      'notes': notes,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      assignedToId: map['assignedToId'],
      dueDate: map['dueDate'],
      priority: map['priority'],
      status: map['status'],
      notes: map['notes'],
    );
  }
}
