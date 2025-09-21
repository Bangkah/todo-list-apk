import 'package:flutter/material.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple To-Do',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _tasks = [];
  final TextEditingController _ctrl = TextEditingController();

  void _add() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _tasks.add(_ctrl.text.trim()));
    _ctrl.clear();
  }

  void _toggle(int i) {
    setState(() => _tasks[i] = _tasks[i].startsWith('✅ ')
        ? _tasks[i].substring(2)
        : '✅ ${_tasks[i]}');
  }

  void _delete(int i) => setState(() => _tasks.removeAt(i));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple To-Do')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                          labelText: 'New task', border: OutlineInputBorder())),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _add),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(_tasks[i]),
                onTap: () => _toggle(i),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(i)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}