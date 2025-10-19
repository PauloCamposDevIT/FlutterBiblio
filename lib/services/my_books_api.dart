import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/my_book_model.dart';

class BooksAPI {
  static const String _baseUrl = 'https://openlibrary.org';

  static Future<List<Livro>> pesquisarLivros(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}&limit=40'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rawBooks = (data['docs'] as List).map((item) => Livro.fromJson(item));

      // Filtro para evitar livros duplicados (mesmo título e autor)
      final Map<String, Livro> uniqueBooks = {};
      for (final livro in rawBooks) {
        final chaveUnica = '${livro.titulo.toLowerCase()}-${livro.autor?.toLowerCase() ?? "sem_autor"}';
        if (!uniqueBooks.containsKey(chaveUnica)) {
          uniqueBooks[chaveUnica] = livro;
        }
      }

      return uniqueBooks.values.toList();
    } else {
      throw Exception('Falha ao carregar livros: ${response.statusCode}');
    }
  }
}
