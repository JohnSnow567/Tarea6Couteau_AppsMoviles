// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
class WordpressNewsPage extends StatefulWidget {
  const WordpressNewsPage({super.key});

  @override
  State<WordpressNewsPage> createState() => _WordpressNewsPageState();
}

class _WordpressNewsPageState extends State<WordpressNewsPage> {
  // Sitio por defecto (puedes cambiarlo). Se usa el host para la API pública de WordPress.com
  final String _defaultSite = 'sevensisterslove.com';

  List<dynamic>? _posts;
  String? _logoUrl;
  String? _siteHost;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadForDefaultSite();
  }

  void _loadForDefaultSite() => _fetchPostsFromWpComApi(_defaultSite);

  Future<void> _fetchPostsFromWpComApi(String hostOrUrl) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _posts = null;
    });

    try {
      // Normalizar: si el usuario pasa una URL completa, extraer el host
      var host = hostOrUrl.trim();
      if (host.startsWith('http')) {
        final uri = Uri.parse(host);
        host = uri.host;
      }
      if (host.isEmpty) throw Exception('Host vacío');

      _siteHost = host;

      // Favicon vía Google (evita problemas CORS en Flutter Web)
      final googleFav = 'https://www.google.com/s2/favicons?domain=$host&sz=64';
      final proxied = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(googleFav)}';
      _logoUrl = proxied;

      // Construir endpoint público de WordPress.com
      final api = 'https://public-api.wordpress.com/wp/v2/sites/$host/posts?per_page=3';
      final res = await http.get(Uri.parse(api));
      if (res.statusCode != 200) {
        throw Exception('API devolvió ${res.statusCode}');
      }

      final data = json.decode(res.body);
      if (data == null || data is! List) {
        throw Exception('Respuesta inesperada de la API');
      }

      setState(() {
        _posts = data.cast<dynamic>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _posts = [];
        _errorMessage = 'No se pudieron cargar publicaciones: ${e.toString()}';
      });
    }
  }

  // Eliminar tags HTML de forma segura
  String _stripHtml(String? html) {
    if (html == null) return '';
    // Reemplazar tags con cadena vacía
    return html.replaceAll(RegExp(r'<[^>]*>', dotAll: true), '').trim();
  }

  // Extraer la primera imagen del contenido HTML (si existe)
  String? _extractFirstImageFromContent(dynamic post) {
    try {
      if (post is Map && post.containsKey('content') && post['content'] is Map) {
        final rendered = (post['content']['rendered'] ?? '') as String;
        if (rendered.isEmpty) return null;
      }

      // También puede venir en jetpack_featured_media_url o featured_image
      if (post is Map) {
        final jf = post['jetpack_featured_media_url'];
        if (jf != null && jf.toString().isNotEmpty) return jf.toString();
        final fi = post['featured_image'];
        if (fi != null && fi.toString().isNotEmpty) return fi.toString();
        final thumb = post['thumbnail'];
        if (thumb != null && thumb.toString().isNotEmpty) return thumb.toString();

        // jetpack-related-posts -> img.src
        if (post.containsKey('jetpack-related-posts') && post['jetpack-related-posts'] is List) { final rel = post['jetpack-related-posts'] as List;
          for (final r in rel) {
            if (r is Map && r.containsKey('img') && r['img'] is Map && r['img']['src'] != null) {
              final src = r['img']['src'];
              if (src.toString().isNotEmpty) return src.toString();
            }
          }
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  String _postTitle(dynamic post) {
    try {
      if (post is Map) {
        final t = post['title'];
        if (t is Map && t['rendered'] != null) return _stripHtml(t['rendered']);
        if (t is String) return _stripHtml(t);
      }
    } catch (e) {}
    return '';
  }

  String _postExcerpt(dynamic post) {
    try {
      if (post is Map) {
        final e = post['excerpt'];
        if (e is Map && e['rendered'] != null) return _stripHtml(e['rendered']);
        if (e is String) return _stripHtml(e);
      }
    } catch (e) {}
    return '';
  }

  String _postLink(dynamic post) {
    try {
      if (post is Map) {
        if (post['link'] != null && post['link'].toString().isNotEmpty) return post['link'];
        if (post['guid'] != null && post['guid'] is Map && post['guid']['rendered'] != null) return post['guid']['rendered'];
        if (post['url'] != null) return post['url'];
      }
    } catch (e) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Header con logo y host
          Row(
            children: [
                Image.network(
                  _logoUrl!,
                  width: 48,
                  height: 48,
                  errorBuilder: (c, e, st) => const SizedBox(width: 72, height: 72),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _siteHost ?? 'WordPress site',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () => _fetchPostsFromWpComApi(_siteHost ?? _defaultSite),
                child: const Text('Actualizar'),
              )
            ],
          ),
          const SizedBox(height: 12),

          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),

          if (!_loading && _errorMessage != null)
            Expanded(child: Center(child: Text(_errorMessage!))),

          if (!_loading && (_posts == null || _posts!.isEmpty))
            const Expanded(child: Center(child: Text('No hay publicaciones para mostrar'))),

          if (!_loading && _posts != null && _posts!.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _posts!.length,
                itemBuilder: (context, index) {
                  final p = _posts![index];
                  final title = _postTitle(p);
                  final excerpt = _postExcerpt(p);
                  final link = _postLink(p);
                  final img = _extractFirstImageFromContent(p);

                  return Card(
                    child: ListTile(
                      leading: img != null
                          ? Image.network(
                              img,
                              width: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, st) => const SizedBox(width: 72),
                            )
                          : null,
                      title: Text(title),
                      subtitle: Text(excerpt, maxLines: 3, overflow: TextOverflow.ellipsis),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final uri = Uri.parse(link);
                          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        child: const Text('Visitar'),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}