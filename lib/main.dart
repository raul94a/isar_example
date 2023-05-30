import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar_example/database/isar_helper.dart';
import 'package:isar_example/database/user_dao.dart';
import 'package:isar_example/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarHelper.instance.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: IsarExample());
  }
}

class IsarExample extends StatelessWidget {
  const IsarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = UserDao();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Isar example'),
          bottom: const TabBar(tabs: [
            Tab(
              text: 'Users',
            ),
            Tab(
              text: 'Filter',
            )
          ]),
        ),
        body: TabBarView(
          children: [
            //CRUD tab
            _CreateUserTab(
              dao: dao,
            ),
            //Filter by name tab
            _FilterUsersTab(
              dao: dao,
            )
          ],
        ),
      ),
    );
  }
}

class _FilterUsersTab extends StatefulWidget {
  const _FilterUsersTab({
    super.key,
    required this.dao,
  });

  final UserDao dao;

  @override
  State<_FilterUsersTab> createState() => _FilterUsersTabState();
}

class _FilterUsersTabState extends State<_FilterUsersTab> {
  StreamSubscription<List<User>>? subscription;
  final streamController = StreamController<List<User>>.broadcast();

  @override
  void dispose() {
    subscription?.cancel();
    streamController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: TextField(
                onChanged: (value) async {
                  if (value.isEmpty) {
                    streamController.sink.add([]);
                    return;
                  }
                  subscription = widget.dao
                      .watchUsersByName(value)
                      .listen(streamController.sink.add);
                  // dao
                  //     .watchUsersByName(value)
                  //     .listen(searchStreamController.add);
                },
                decoration:
                    const InputDecoration(hintText: 'Type the user name'),
              )),
            ],
          ),
        ),
        StreamBuilder<List<User>>(
            stream: streamController.stream,
            builder: (context, snapshot) {
              final users = snapshot.data ?? [];
              return Expanded(
                child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (ctx, index) {
                      final user = users[index];
                      return ListTile(
                        leading: Text('${user.id}'),
                        title: Text(user.name),
                        trailing: IconButton(
                          onPressed: () {
                            widget.dao.deleteOne(user);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      );
                    }),
              );
            })
      ],
    );
  }
}

class _CreateUserTab extends StatefulWidget {
  const _CreateUserTab({
    super.key,
    required this.dao,
  });

  final UserDao dao;

  @override
  State<_CreateUserTab> createState() => _CreateUserTabState();
}

class _CreateUserTabState extends State<_CreateUserTab> {
  final TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building');
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: 'Type the user name'),
                )),
                ElevatedButton(
                    onPressed: () async {
                      User user = User()..name = controller.text;
                      final id = await widget.dao.upsert(user);
                      user.id = id;
                      controller.clear();

                      // setState(() {
                      //   users.add(user);
                      // });
                    },
                    child: const Text('Create user'))
              ],
            ),
          ),
          StreamBuilder<List<User>>(
          
              stream: widget.dao.watchUsers(),
              builder: (context, snapshot) {
                
                final users = snapshot.data ?? [];
                return ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (ctx, index) {
                      final user = users[index];
                      return ListTile(
                        leading: Text('${user.id}'),
                        title: Text(user.name),
                        trailing: IconButton(
                          onPressed: () {
                            widget.dao.deleteOne(user);
                            // setState(() {
                            //   users.removeWhere((element) => user.id == element.id);
                            // });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      );
                    });
              })
        ],
      ),
    );
  }
}
