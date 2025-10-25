import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GenderPage extends StatefulWidget {
  const GenderPage({super.key});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _gender;
  double? _probability;

  Future<void> _predictGender(String name) async {
    final url = Uri.parse('https://api.genderize.io/?name=${Uri.encodeComponent(name)}');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final jsonResp = json.decode(res.body);
      setState(() {
        _gender = jsonResp['gender'];
        _probability = (jsonResp['probability'] is num) ? (jsonResp['probability'] as num).toDouble() : null;
      });
    } else {
      setState(() {
        _gender = null;
        _probability = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej: Irma'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _predictGender(_nameController.text.trim()),
            child: const Text('Predecir género'),
          ),
          const SizedBox(height: 20),
          if (_gender != null)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: _gender == 'male' ? Colors.blue[100] : Colors.pink[100],
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(_gender == 'male' ? Icons.male : Icons.female, size: 72),
                    const SizedBox(height: 12),
                    Text('Género: ${_gender!}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    if (_probability != null) Text('Probabilidad: ${(_probability! * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}