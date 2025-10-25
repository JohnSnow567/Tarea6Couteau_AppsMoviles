import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Caja de herramientas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: Image.asset('assets/toolbox.jpg', fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            const Text('Esta aplicación sirve para varias utilidades: predecir género, edad, buscar universidades, ver el clima, consultar Pokémon y leer noticias WordPress.'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}