class Todo {
  String title;
  bool isCompleted;
  String id;

  Todo({
    required this.title,
    required this.id,
    this.isCompleted = false,
  });
  void toggleCompleted() {
    isCompleted = !isCompleted;
  }
}
