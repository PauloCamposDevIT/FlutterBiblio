import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_book_model.dart';
import '../services/my_books_api.dart';
import '../widgets/my_book_card.dart';
import '../widgets/my_custom_appbar.dart';
import '../widgets/my_custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Livro> _livros = [];

  // pesquisa e atualiza a lista de livros
  void _pesquisarLivros() async {
    final livros = await BooksAPI.pesquisarLivros(_searchController.text);
    setState(() {
      _livros = livros;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFCE1),
      appBar: const CustomAppBar(title: 'B I B L I O T E C A'),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // text field para a pesquisa
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'P E S Q U I S A',
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _pesquisarLivros,
                    ),
                  ),
                  onSubmitted: (_) => _pesquisarLivros(),
                ),
              ),
              // Lista de livros ou mensagem de "Nenhum resultado encontrado"
              Expanded(
                child: _livros.isEmpty
                    ? const Center(child: Text("Nenhum resultado encontrado."))
                    : ListView.builder(
                  itemCount: _livros.length,
                  itemBuilder: (context, index) {
                    return BookCard(livro: _livros[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
