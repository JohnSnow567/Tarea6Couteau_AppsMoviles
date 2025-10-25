import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AgePage extends StatefulWidget {
  const AgePage({super.key});

  @override
  State<AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  final TextEditingController _nameController = TextEditingController();
  int? _age;
  String? _category;

  Future<void> _predictAge(String name) async {
    final url = Uri.parse('https://api.agify.io/?name=${Uri.encodeComponent(name)}');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final j = json.decode(res.body);
      setState(() {
        _age = j['age'];
        if (_age == null) {
          _category = null;
        } else if (_age! < 30) {
          _category = 'Joven';
        } else if (_age! < 60) {
          _category = 'Adulto';
        } else {
          _category = 'Anciano';
        }
      });
    } else {
      setState(() {
        _age = null;
        _category = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej: Meelad')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => _predictAge(_nameController.text.trim()), child: const Text('Determinar edad')),
        const SizedBox(height: 20),
        if (_age != null)
          Expanded(
            child: Column(
              children: [
                Text('Edad estimada: $_age', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Categoría: $_category', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Expanded(child: _categoryImage()),
              ],
            ),
          ),
      ]),
    );
  }

  Widget _categoryImage() {
    final asset = _category == 'Joven'
        ? 'assets/young.jpg'
        : _category == 'Adulto'
            ? 'assets/adult.jpg'
            : 'assets/old.jpg';
    return Image.asset(asset, fit: BoxFit.contain);
  }
}
