import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Pro',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class Task {
  String id;
  String title;
  bool done;
  Task({required this.id, required this.title, this.done = false});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
  factory Task.fromJson(Map<String, dynamic> j) =>
      Task(id: j['id'], title: j['title'], done: j['done']);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ctrl = TextEditingController();
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString('tasks');
    if (data != null) {
      setState(() {
        _tasks.addAll((jsonDecode(data) as List).map((e) => Task.fromJson(e)));
      });
    }
  }

  Future<void> _saveTasks() async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('tasks', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  void _addTask() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _tasks.add(Task(id: DateTime.now().toString(), title: text)));
    _ctrl.clear();
    _saveTasks();
  }

  void _toggleTask(Task task) {
    setState(() => task.done = !task.done);
    _saveTasks();
  }

  void _deleteTask(int index) {
    final removed = _tasks[index];
    setState(() => _tasks.removeAt(index));
    _saveTasks();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.title} dihapus'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() {
            _tasks.insert(index, removed);
            _saveTasks();
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _tasks.where((t) => !t.done).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Pro'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('$active tugas aktif',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (_) => _bottomInput(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _tasks.length,
              itemBuilder: (_, i) {
                final t = _tasks[i];
                return Dismissible(
                  key: Key(t.id),
                  background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.delete, color: Colors.white)),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteTask(i),
                  child: CheckboxListTile(
                    value: t.done,
                    onChanged: (_) => _toggleTask(t),
                    title: Text(t.title,
                        style: TextStyle(
                            decoration:
                                t.done ? TextDecoration.lineThrough : null)),
                  ),
                );
              },
            ),
    );
  }

  Widget _bottomInput() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(labelText: 'Tugas baru'),
                autofocus: true,
                onSubmitted: (_) {
                  _addTask();
                  Navigator.pop(context);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _addTask();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}