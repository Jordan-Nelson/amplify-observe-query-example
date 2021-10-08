import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_datastore/amplify_datastore.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
    AmplifyDataStore datastorePlugin =
        AmplifyDataStore(modelProvider: ModelProvider.instance);
    await Amplify.addPlugin(datastorePlugin);

    try {
      await Amplify.configure(amplifyconfig);
      setState(() {
        _isAmplifyConfigured = true;
      });
    } on AmplifyAlreadyConfiguredException {
      print(
          "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAmplifyConfigured) {
      return const Center(child: CircularProgressIndicator());
    }
    return const MaterialApp(home: TodoList());
  }
}

class TodoList extends StatelessWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Observe Query example'),
      ),
      body: StreamBuilder(
        stream: Amplify.DataStore.observeQuery(
          Todo.classType,
          throttleOptions: const ObserveQueryThrottleOptions.none(),
        ),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot<Todo>> snapshot,
        ) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          QuerySnapshot<Todo> querySnapshot = snapshot.data!;
          if (querySnapshot.items.isEmpty) {
            return const Center(child: Text('There are no items in the list'));
          }
          return ListView.builder(
            itemCount: querySnapshot.items.length,
            itemBuilder: (context, index) {
              Todo todo = querySnapshot.items[index];
              return ListTile(
                title: Text(todo.name),
                subtitle: Text(todo.description ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await Amplify.DataStore.delete(todo);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Amplify.DataStore.save(
            Todo(name: 'New todo', description: 'Description for new todo'),
          );
        },
        label: const Text('Add Todo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
