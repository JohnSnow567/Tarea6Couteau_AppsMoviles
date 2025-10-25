import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final String name = 'Jonathan Martinez';
  final String matricula = '2023-1417';
  final String email = 'jhonmartnez032@gmail.com';
  final String phone = '+1-809-837-4705';
  final String photoAsset = 'assets/me.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(radius: 120, backgroundImage: AssetImage(photoAsset)),
              SizedBox(height: 12),
              Text(
                name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text('Matrícula: $matricula'),
              SizedBox(height: 6),
              Text('Email: $email'),
              SizedBox(height: 6),
              Text('Tel: $phone'),
              SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(Icons.email),
                label: Text('Enviar correo'),
                onPressed: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: email,
                    queryParameters: {'subject': 'Interés en tu trabajo'},
                  );
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                icon: Icon(Icons.call),
                label: Text('Llamar'),
                onPressed: () async {
                  final uri = Uri(scheme: 'tel', path: phone);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
