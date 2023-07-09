import 'package:flutter/material.dart';
import 'package:flutter_todo/ShowListPage.dart';
import 'package:flutter_todo/addTodoPage.dart';
import 'package:flutter_todo/models/todo_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TO do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'todo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> todoList = [
    Todo(id: 1, title: "title", description: "description", isDone: false)
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WebSocketChannel channel =
        WebSocketChannel.connect(Uri.parse('ws://localhost:5001/graphql?'));

    channel.stream.listen((message) {
      print("message:" + message.toString());
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddTodoPage when the plus button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTodoPage(),
                ),
              ).then((newTodo) {
                if (newTodo != null) {
                  // Add the newTodo to the list if it's not null
                  setState(() {
                    todoList.add(newTodo);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: ShowListPage(),
    );
  }
}
