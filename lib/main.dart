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

class IsarExample extends StatefulWidget {
  const IsarExample({super.key});

  @override
  State<IsarExample> createState() => _IsarExampleState();
}

class _IsarExampleState extends State<IsarExample> {
  final TextEditingController controller = TextEditingController();
  final dao = UserDao();
  List<User> users = [];
  @override
  void initState() {
    super.initState();
    dao.getAll().then((value) => setState(() => users = value));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Isar example'),
        ),
        body: SingleChildScrollView(
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
                          final id = await dao.upsert(user);
                          user.id = id;
                          controller.clear();

                          setState(() {
                            users.add(user);
                          });
                        },
                        child: const Text('Create user'))
                  ],
                ),
              ),
              ListView.builder(
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
                          dao.deleteOne(user);
                          setState(() {
                            users.removeWhere(
                                (element) => user.id == element.id);
                          });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  })
            ],
          ),
        ));
  }
}
