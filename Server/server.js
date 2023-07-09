const express = require('express');
const { graphqlHTTP } = require("express-graphql");
const { GraphQLSchema, GraphQLObjectType, GraphQLString, GraphQLList, GraphQLNonNull, GraphQLInt,GraphQLBoolean } = require('graphql');
const mysql = require('mysql');


// Create an instance of the Express application
const app = express();

// create a pool to send request to the db
const pool = mysql.createPool({
  host: 'localhost',
  user: 'ismail',
  password: '123',
  database: 'TODODATABASE'
});



const TODOType = new GraphQLObjectType({
  name: 'Todo',
  description: 'This is a todo item',
  fields: () => ({
    id: { type: new GraphQLNonNull(GraphQLInt) },
    title: { type: new GraphQLNonNull(GraphQLString) },
    description: { type: new GraphQLNonNull(GraphQLString) },
    isDone: { type: new GraphQLNonNull(GraphQLBoolean) },
  })
})


// Define your GraphQL schema
const RootQueryType = new GraphQLObjectType({
  name: 'Query',
  description: 'Root Query',
  fields: () => ({
    getOneTodo: {
      type: TODOType,
      description: 'get single todo',
      args: {
        id: { type: GraphQLInt },
      },
      resolve: (parent, args) => {
        return new Promise((resolve, reject) => {
          const query = 'SELECT * FROM Todos WHERE id = ?';
          pool.query(query, [args.id], (error, results) => {
            if (error) {
              reject(error);
            } else {
              resolve(results[0]);
            }
          });
        });
      }
    },

    getMultipleTodos: {
      type: new GraphQLList(TODOType),
      description: 'List of All todos',
      resolve: () => {
        return new Promise((resolve, reject) => {
          const query = 'SELECT * FROM todos';
          pool.query(query, (error, results) => {
            if (error) {
              reject(error);
            } else {
              resolve(results);
            }
          });
        });
      }
    },
  })
})

const RootMutaionType = new GraphQLObjectType({
  name: 'Mutation',
  description: 'Root Mutation',
  fields: () => ({
    addTodo: {
      type: TODOType,
      description: 'Add a todo',
      args: {
        title: { type: new GraphQLNonNull(GraphQLString) },
        description: { type: new GraphQLNonNull(GraphQLString) },
        isDone: { type: new GraphQLNonNull(GraphQLBoolean) },
      },
      resolve: (parent, args) => {
        return new Promise((resolve, reject) => {
          const query = 'INSERT INTO todos (title, description,isDone) VALUES (?, ?,?)';
          const values = [args.title, args.description,args.isDone];

          pool.query(query, values, (error, result) => {
            if (error) {
              reject(error);
            } else {
              const insertedtodo = {
                id: result.insertId,
                title: args.title,
                description: args.description,
                isDone: args.isDone
              };
              resolve(insertedtodo);
            }
          });
        });
      }
    },
    deletetodo: {
      type: GraphQLBoolean,
      description: 'Delete a line from a table',
      args: {
        tableName: { type: new GraphQLNonNull(GraphQLString) },
        id: { type: new GraphQLNonNull(GraphQLInt) },
      },
      resolve: (parent, args) => {
        return new Promise((resolve, reject) => {
          const query = 'DELETE FROM ' + args.tableName + ' WHERE id = ?';
          const values = [args.id];
    
          pool.query(query, values, (error, result) => {
            if (error) {
              reject(error);
              return false;
            } else 
            {resolve(result.affectedRows > 0);
            return true;}
          });
        });
      }
    },
    toggleIsDone: {
      type: GraphQLBoolean,
      description: 'Toggle the isDone status of a todo',
      args: {
        tableName: { type: new GraphQLNonNull(GraphQLString) },
        id: { type: new GraphQLNonNull(GraphQLInt) },
      },
      resolve: (parent, args) => {
        return new Promise((resolve, reject) => {
          const query = 'UPDATE ' + args.tableName + ' SET isDone = NOT isDone WHERE id = ?';
          const values = [args.id];
      
          pool.query(query, values, (error, result) => {
            if (error) {
              reject(error);
              return false;
            } else {
              resolve(result.affectedRows > 0);
              return true;
            }
          });
        });
      },
    },
    
    
  })
})

const schema = new GraphQLSchema({
  query: RootQueryType,
  mutation: RootMutaionType
})


// Set up the '/graphql' endpoint with the GraphQL middleware
app.use('/graphql', graphqlHTTP({
  schema: schema, // Pass your GraphQL schema
  graphiql: true // Enable GraphiQL for interactive exploration
}));

// Start the server
app.listen(5001, () => console.log('Server Running'));