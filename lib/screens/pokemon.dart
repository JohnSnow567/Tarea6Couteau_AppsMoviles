import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _nameController = TextEditingController(text: 'pikachu');
  Map<String, dynamic>? _pokemon;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _fetchPokemon(String name) async {
    final n = name.toLowerCase().trim();
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$n');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() {
        _pokemon = json.decode(res.body);
      });
    } else {
      setState(() {
        _pokemon = null;
      });
    }
  }

  Future<void> _playCryFromPokemon() async {
    if (_pokemon == null) return;

    final int? id = _pokemon!['id'] as int?;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID del Pokémon no disponible')));
      return;
    }

    final cryUrl = 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/$id.ogg';
    try {
      await _player.play(UrlSource(cryUrl));
      setState(() => _isPlaying = true);
      _player.onPlayerComplete.listen((event) => setState(() => _isPlaying = false));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo reproducir el sonido (no disponible o error)')));
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre del Pokémon', hintText: 'pikachu')),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton(onPressed: () => _fetchPokemon(_nameController.text), child: const Text('Buscar')),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: _pokemon == null ? null : () => _playCryFromPokemon(),
              child: Text(_isPlaying ? 'Reproduciendo...' : 'Reproducir sonido')),
        ]),
        const SizedBox(height: 12),
        Expanded(child: _pokemon == null ? const Center(child: Text('Sin datos')) : _buildPokemon()),
      ]),
    );
  }

  Widget _buildPokemon() {
    final sprite = _pokemon!['sprites']?['front_default'];
    final baseExp = _pokemon!['base_experience'];
    final abilities = (_pokemon!['abilities'] as List).map((a) => a['ability']['name']).join(', ');
    return SingleChildScrollView(
      child: Column(children: [
        if (sprite != null) Image.network(sprite, height: 300),
        const SizedBox(height: 8),
        Text('Experiencia base: $baseExp', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text('Habilidades: $abilities'),
      ]),
    );
  }
}