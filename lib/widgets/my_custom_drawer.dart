import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<Map<String, String>> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/quotes/random'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'content': data['quote'],
          'author': data['author'],
        };
      } else {
        throw Exception('Erro ao obter citação');
      }
    } catch (e) {
      return {
        'content': 'A leitura é para a mente o que o exercício é para o corpo.',
        'author': 'Joseph Addison',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFAFCE1),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // Cabeçalho com citação da API
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: FutureBuilder<Map<String, String>>(
                  future: fetchQuote(),
                  builder: (context, snapshot) {
                    String quoteContent;
                    String quoteAuthor;
                    if (snapshot.hasData && snapshot.data != null) {
                      quoteContent = snapshot.data!['content'] ?? '';
                      quoteAuthor = snapshot.data!['author'] ?? '';
                    } else {
                      quoteContent = 'A leitura é para a mente o que o exercício é para o corpo.';
                      quoteAuthor = 'Joseph Addison';
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          '"$quoteContent"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.brown,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '- $quoteAuthor',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                           // color: Colors.black54,
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(
                indent: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              // opções a selecionar do menu
              ListTile(
                leading: const Icon(Icons.star, color: Color(0xFF9D6550),),
                title: const Text(
                  'F A V O R I T O S',
                  style: TextStyle(letterSpacing: 2, color: Color(0xFF9D6550),),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/favoritos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.checklist, color: Color(0xFF9D6550),),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'L I V R O S',
                      style: TextStyle(letterSpacing: 2, color: Color(0xFF9D6550),),
                    ),
                    Text(
                      'L I D O S',
                      style: TextStyle(letterSpacing: 2, color: Color(0xFF9D6550),),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/livros-lidos');
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'L O G O U T',
                  style: TextStyle(letterSpacing: 2, color: Color(0xFF9D6550),),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
