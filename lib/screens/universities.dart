import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UniversitiesPage extends StatefulWidget {
  const UniversitiesPage({super.key});

  @override
  State<UniversitiesPage> createState() => _UniversitiesPageState();
}

class _UniversitiesPageState extends State<UniversitiesPage> {
  final TextEditingController _countryController = TextEditingController(text: 'Dominican Republic');
  List<dynamic>? _unis;

  Future<void> _searchUnis(String country) async {
    final q = country.replaceAll(' ', '+');
    final url = Uri.parse('http://universities.hipolabs.com/search?country=$q');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() {
        _unis = json.decode(res.body);
      });
    } else {
      setState(() {
        _unis = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        TextField(controller: _countryController, decoration: const InputDecoration(labelText: 'Country (in English)', hintText: 'e.g. Dominican Republic')),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () => _searchUnis(_countryController.text.trim()), child: const Text('Buscar universidades')),
        const SizedBox(height: 12),
        Expanded(child: _unis == null ? const Text('No results yet') : _buildList()),
      ]),
    );
  }

  Widget _buildList() {
    if (_unis == null || _unis!.isEmpty) return const Text('Sin universidades encontradas');
    return ListView.builder(
      itemCount: _unis!.length,
      itemBuilder: (context, index) {
        final u = _unis![index];
        final name = u['name'] ?? '';
        final domain = (u['domains'] != null && u['domains'].isNotEmpty) ? u['domains'][0] : '';
        final web = (u['web_pages'] != null && u['web_pages'].isNotEmpty) ? u['web_pages'][0] : '';
        return Card(
          child: ListTile(
            title: Text(name),
            subtitle: Text(domain),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () async {
                final uri = Uri.parse(web);
                if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
          ),
        );
      },
    );
  }
}
