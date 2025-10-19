import 'package:flutter/material.dart';
import '../models/my_book_model.dart';

class BookCard extends StatelessWidget {
  final Livro livro;

  const BookCard({super.key, required this.livro});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEBD0BD),
      child: ListTile(
        leading: livro.urlImagem != null
            ? Image.network(livro.urlImagem!, width: 50)
            : const Icon(Icons.book),
        title: Text(livro.titulo,
            style: const TextStyle(color: Color(0xFF9D6550)),
        ),
        subtitle: Text(
          livro.autor ?? '',
          style: const TextStyle(color: Colors.blueGrey),
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => Navigator.pushNamed(
            context,
            '/detalhes',
            arguments: livro
        ),
      ),
    );
  }
}
