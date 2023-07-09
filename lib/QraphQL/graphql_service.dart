import 'package:flutter_todo/QraphQL/Graphql_config.dart';
import 'package:flutter_todo/models/todo_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphqlService {
  GraphQLClient client = GraphqlConfig().clientToQuery();

  Future<List<Todo>> getTodos() async {
    try {
      QueryResult result = await client.query(
        QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
          query {
            getMultipleTodos{id,title,description,isDone}
            }
          """)),
      );
      if (result.hasException) throw Exception(result.hasException);

      List<Todo> todoList = (result.data?['getMultipleTodos'] as List?)
              ?.map((todoData) => Todo(
                    id: todoData['id'],
                    title: todoData['title'],
                    description: todoData['description'],
                    isDone: todoData['isDone'],
                  ))
              .toList() ??
          [];

      return todoList;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> addTodo(
      {required String title, required String description}) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(fetchPolicy: FetchPolicy.noCache, document: gql("""
         mutation {
        addTodo(title:"${title}",description:"${description}",isDone:false){id}
        }
          """)),
      );
      if (result.hasException) {
        return false;
      } else if (result.data != null && result.data!['data'] != []) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> deleteTodo({required int id}) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
                mutation {
            deletetodo(id:$id
            ,tableName:"todos")
          }
          """),
        ),
      );
      if (result.hasException) {
        return false;
      } else if (result.data != null) {
        return result.data!["deletetodo"] as bool;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> toggleIsDone({required int id}) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
          mutation {
  toggleIsDone(id:$id
  ,tableName:"todos")
}
        """),
          variables: {
            'id': id,
          },
        ),
      );
      if (result.hasException) {
        return false;
      } else if (result.data != null) {
        return result.data!["toggleIsDone"] as bool;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
