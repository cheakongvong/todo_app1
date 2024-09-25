import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/colors.dart';
import '../models/data.dart';
import '../todo_provider.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isEditing = false;
  int? editingIndex;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    // Listen to Firestore collection 'todos' and keep the UI updated in real-time
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('todos').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Build todo list from Firestore data
        final todos = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Todo(
            title: data['title'],
            isCompleted: data['isCompleted'] ?? false,
            id: doc.id, // Store Firestore document ID
          );
        }).toList();

        // Filter todos based on the search query
        final filteredTodos = todoProvider.todos
            .where((todo) =>
                todo.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            title: const Text('ToDo List'),
            backgroundColor: AppColors.primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                Expanded(
                  child: filteredTodos.isEmpty
                      ? const Center(
                          child: Text(
                            'No result. Create a new one instead',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredTodos.length,
                          itemBuilder: (context, index) {
                            final todo = filteredTodos[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  border:
                                      Border.all(color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                          todo.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            decoration: todo.isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        leading: Checkbox(
                                          value: todo.isCompleted,
                                          onChanged: (value) {
                                            todoProvider
                                                .toggleTodoStatus(index);
                                          },
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // Remove task
                                        FirebaseFirestore.instance
                                            .collection('todos')
                                            .doc(todo.id)
                                            .delete();
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _controller.text = todo.title;
                                          isEditing = true;
                                          editingIndex = index;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: 10,
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Search or enter new task',
                              labelText:
                                  isEditing ? 'Edit task' : 'Search/Add task',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.textColor,
                                fontSize: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            onSubmitted: (value) async {
                              if (isEditing && editingIndex != null) {
                                // If editing, update the existing todo
                                final todoId =
                                    todoProvider.todos[editingIndex!].id;
                                todoProvider.updateTodo(
                                  todoId,
                                  value.trim(),
                                  todoProvider.todos[editingIndex!].isCompleted,
                                );
                                setState(() {
                                  isEditing = false;
                                  editingIndex = null;
                                });
                              } else {
                                // Add new todo with context for SnackBar
                                await todoProvider.addTodo(
                                    context, value.trim());

                                // Clear search query after adding a new task
                                setState(() {
                                  searchQuery = '';
                                });
                              }

                              _controller.clear();
                            }),
                      ),
                      const SizedBox(width: 10),
                      if (isEditing)
                        ElevatedButton(
                          onPressed: () {
                            final inputText = _controller.text.trim();
                            if (inputText.isEmpty) return;

                            final todoId = todoProvider.todos[editingIndex!].id;
                            FirebaseFirestore.instance
                                .collection('todos')
                                .doc(todoId)
                                .update({
                              'title': inputText,
                            }).then((_) {
                              setState(() {
                                isEditing = false;
                                editingIndex = null;
                                searchQuery = '';
                              });
                              _controller.clear();
                            }).catchError((error) {
                              debugPrint('Failed to update todo: $error');
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(70, 50),
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: const Text('Update'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
