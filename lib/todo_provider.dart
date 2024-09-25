import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app1/components/colors.dart';

import 'models/data.dart';

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  TodoProvider() {
    fetchTodos();
  }

  void fetchTodos() {
    FirebaseFirestore.instance
        .collection('todos')
        .snapshots()
        .listen((snapshot) {
      _todos.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data();
        _todos.add(Todo(
          title: data['title'],
          isCompleted: data['isCompleted'] ?? false,
          id: doc.id,
        ));
      }
      notifyListeners();
    });
  }

  Future<void> addTodo(BuildContext context, String title) async {
    title = title.trim();

    if (title.isEmpty) {
      showSnackBar(context, 'Cannot add an empty task');
      return;
    }

    bool isDuplicate =
        _todos.any((todo) => todo.title.toLowerCase() == title.toLowerCase());
    if (isDuplicate) {
      showSnackBar(context, 'Cannot add duplicate task');
      return;
    }

    await FirebaseFirestore.instance.collection('todos').add({
      'title': title,
      'isCompleted': false, // New todos are incomplete by default
    });
  }

  // Show a SnackBar
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.alertColor,
        duration: const Duration(seconds: 1),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  Future<void> updateTodo(String id, String title, bool isCompleted) async {
    if (title.trim().isEmpty) {
      debugPrint('Cannot update a todo with an empty title');
      return;
    }

    await FirebaseFirestore.instance.collection('todos').doc(id).update({
      'title': title.trim(),
      'isCompleted': isCompleted,
    });
  }

  Future<void> removeTodo(String id) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).delete();
  }

  Future<void> toggleTodoStatus(int index) async {
    final todo = _todos[index];
    todo.toggleCompleted();

    await FirebaseFirestore.instance.collection('todos').doc(todo.id).update({
      'isCompleted': todo.isCompleted,
    });
  }
}
