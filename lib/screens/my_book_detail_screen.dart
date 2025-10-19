import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_book_model.dart';
import '../models/my_comment_model.dart';
import '../services/firestore_service.dart';
import '../widgets/my_comment_widget.dart';
import '../widgets/my_custom_appbar.dart';
import 'package:biblioteca1/main.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> with RouteAware {
  bool _isFavorito = false;
  bool _isLido = false;
  String? _favoritoDocId;
  String? _livroLidoDocId;

  @override
  void initState() {
    super.initState();
    // verificar os favoritos e os livros lidos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarFavorito();
      _verificarSeEstaNaListaLidos();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    //  atualiza os estados
    _verificarFavorito();
    _verificarSeEstaNaListaLidos();
  }

  @override
  Widget build(BuildContext context) {
    // objeto Livro mas como argumento
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Livro) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Erro'),
        body: const Center(child: Text('Livro não encontrado.')),
      );
    }
    final Livro livro = args;
    final currentUser = Provider.of<User?>(context)!;
    final FirestoreService firestore = FirestoreService();

    return Scaffold(
      backgroundColor: Color(0xFFf8fade),
      appBar: CustomAppBar(
        title: livro.titulo,
        actions: [
          // Botão para adicionar aos favoritos com estados
          IconButton(
            icon: Icon(
              _isFavorito ? Icons.star : Icons.star_border,
              color: _isFavorito ? Colors.yellow : Colors.white,
            ),
            onPressed: () => _alternarFavorito(livro, currentUser.uid),
          ),
          // Menu de hamburguer para marcar/desmarcar como lido
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_read') {
                _alternarListaLidos(livro, currentUser.uid);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_read',
                child: Row(
                  children: [
                    Icon(
                      _isLido ? Icons.check_circle : Icons.check_circle_outline,
                        color: Colors.brown,
                    ),
                    const SizedBox(width: 8),
                    Text(_isLido ? 'Remover de Lidos' : 'Marcar como Lido',
                      style: TextStyle(color: Colors.brown
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Dados do livro feteched à api
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (livro.urlImagem != null)
                  Image.network(livro.urlImagem!),
                const SizedBox(height: 10),
                Text('Autor: ${livro.autor ?? "Desconhecido"}'),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const Divider(color: Color(0xFF9D6550)),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Comentários:', style: TextStyle(fontSize: 18)),
          ),
          // Lista de comentários do user atual
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.obterComentarios(livro.id, currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Ainda não há comentários.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final comentario = Comentario(
                      id: doc.id,
                      livroId: doc['livroId'],
                      userId: doc['userId'],
                      texto: doc['texto'],
                      data: (doc['data'] as Timestamp).toDate(),
                    );
                    return CommentWidget(
                      comentario: comentario,
                      onEdit: () => _mostrarDialogoEditar(
                        context,
                        doc.id,
                        doc['texto'],
                      ),
                      onDelete: () => _deletarComentario(context, doc.id),
                    );
                  },
                );
              },
            ),
          ),
          // form para adicionar comentarios
          _FormularioComentario(livroId: livro.id),
        ],
      ),
    );
  }

  // mostra diálogo para/sobre(?) editar comentário
  void _mostrarDialogoEditar(BuildContext context, String docId, String textoAtual) {
    TextEditingController controller = TextEditingController(text: textoAtual);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFF8FADE),
        title: const Text(
          'Editar Comentário',
          style: TextStyle(color: Colors.brown),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.brown),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.brown),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.brown),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirestoreService().atualizarComentario(docId, controller.text);
              Navigator.pop(context);
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }


  // Método para apagar um comentário
  void _deletarComentario(BuildContext context, String docId) async {
    await FirestoreService().deleteComentario(docId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentário apagado.')),
    );
  }

  // Verifica se o livro já está nos favoritos/atualiza o estado
  void _verificarFavorito() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Livro) return;
    final Livro livro = args;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final favoritosRef = FirebaseFirestore.instance.collection('favoritos');
    final query = await favoritosRef
        .where('userId', isEqualTo: currentUser.uid)
        .where('livroId', isEqualTo: livro.id)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        _isFavorito = true;
        _favoritoDocId = query.docs.first.id;
      });
    } else {
      setState(() {
        _isFavorito = false;
        _favoritoDocId = null;
      });
    }
  }

  // Verifica se o livro está na lista de livros já lidos
  void _verificarSeEstaNaListaLidos() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Livro) return;
    final Livro livro = args;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final livrosLidosRef = FirebaseFirestore.instance.collection('livrosLidos');
    final query = await livrosLidosRef
        .where('userId', isEqualTo: currentUser.uid)
        .where('livroId', isEqualTo: livro.id)
        .limit(1)
        .get();

    setState(() {
      _isLido = query.docs.isNotEmpty;
      _livroLidoDocId = query.docs.isNotEmpty ? query.docs.first.id : null;
    });
  }

  // Alterna o estado de favorito: adiciona se não estiver, remove se já estiver.
  void _alternarFavorito(Livro livro, String userId) async {
    final favoritosRef = FirebaseFirestore.instance.collection('favoritos');

    if (_isFavorito && _favoritoDocId != null) {
      await favoritosRef.doc(_favoritoDocId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro removido dos favoritos.')),
      );
      setState(() {
        _isFavorito = false;
        _favoritoDocId = null;
      });
    } else {
      final query = await favoritosRef
          .where('userId', isEqualTo: userId)
          .where('livroId', isEqualTo: livro.id)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        final novoFavorito = await favoritosRef.add({
          'userId': userId,
          'livroId': livro.id,
          'titulo': livro.titulo,
          'autor': livro.autor,
          'urlImagem': livro.urlImagem,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livro adicionado aos favoritos!')),
        );
        setState(() {
          _isFavorito = true;
          _favoritoDocId = novoFavorito.id;
        });
      } else {
        setState(() {
          _isFavorito = true;
          _favoritoDocId = query.docs.first.id;
        });
      }
    }
  }

  // Alterna o estado da lista de livros lidos '''''''''''
  void _alternarListaLidos(Livro livro, String userId) async {
    final livrosLidosRef = FirebaseFirestore.instance.collection('livrosLidos');

    if (_isLido && _livroLidoDocId != null) {
      await livrosLidosRef.doc(_livroLidoDocId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro removido da lista de lidos.')),
      );
      setState(() {
        _isLido = false;
        _livroLidoDocId = null;
      });
    } else {
      final query = await livrosLidosRef
          .where('userId', isEqualTo: userId)
          .where('livroId', isEqualTo: livro.id)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        final novoLivroLido = await livrosLidosRef.add({
          'userId': userId,
          'livroId': livro.id,
          'titulo': livro.titulo,
          'autor': livro.autor,
          'urlImagem': livro.urlImagem,
          'data': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livro marcado como lido!',
            style: TextStyle(color: Colors.brown
              ),
            )
          ),
        );
        setState(() {
          _isLido = true;
          _livroLidoDocId = novoLivroLido.id;
        });
      } else {
        setState(() {
          _isLido = true;
          _livroLidoDocId = query.docs.first.id;
        });
      }
    }
  }
}

// adicionar novos comentários
class _FormularioComentario extends StatelessWidget {
  final String livroId;
  final TextEditingController _controller = TextEditingController();

  _FormularioComentario({required this.livroId});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context)!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Escreve um comentário...',
                labelStyle: TextStyle(color: Colors.blueGrey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF9D6550)),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.brown),
            onPressed: () async {
              final texto = _controller.text.trim();
              if (texto.isEmpty) return;
              final comentario = Comentario(
                id: '',
                livroId: livroId,
                userId: currentUser.uid,
                texto: texto,
                data: DateTime.now(),
              );
              await FirestoreService().adicionarComentario(comentario);
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }
}
