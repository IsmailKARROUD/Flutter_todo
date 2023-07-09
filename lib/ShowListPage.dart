import 'package:flutter/material.dart';
import 'package:flutter_todo/models/todo_model.dart';
import 'package:flutter_todo/QraphQL/graphql_service.dart';

class ShowListPage extends StatefulWidget {
  ShowListPage();

  @override
  _ShowListPageState createState() => _ShowListPageState();
}

class _ShowListPageState extends State<ShowListPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: GraphqlService().getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != []) {
            final List<Todo> todoList = snapshot.data! as List<Todo>;
            return ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                Todo todo = todoList[index];
                return Card(
                  shadowColor: Colors.black,
                  color: Colors.white,
                  child: ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.description),
                      leading: Checkbox(
                        value: todo.isDone,
                        onChanged: (_) async {
                          await GraphqlService()
                              .toggleIsDone(id: todo.id)
                              .then((value) {
                            setState(() {});
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _showDeleteDialog(todo);
                        },
                      )),
                );
              },
            );
          } else {
            return const Center(
              child: Text("no todo yet"),
            );
          }
        });
  }

  void _showDeleteDialog(Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Todo'),
          content: const Text('Are you sure you want to delete this todo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await GraphqlService().deleteTodo(id: todo.id).then((value) {
                  setState(() {});
                  Navigator.of(context).pop();
                });
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
