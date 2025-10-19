import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/my_comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ******** Comentários ********

  Future<void> adicionarComentario(Comentario comentario) async {
    await _firestore.collection('comentarios').add(comentario.toMap());
  }

  // Agora a query filtra também pelo userId, para que o utilizador veja só os seus comentários
  Stream<QuerySnapshot> obterComentarios(String livroId, String userId) {
    return _firestore
        .collection('comentarios')
        .where('livroId', isEqualTo: livroId)
        .where('userId', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots();
  }

  Future<void> atualizarComentario(String docId, String novoTexto) async {
    await _firestore.collection('comentarios').doc(docId).update({
      'texto': novoTexto,
      'data': Timestamp.now(),
    });
  }

  //apagar um comentário
  Future<void> deleteComentario(String docId) async {
    await _firestore.collection('comentarios').doc(docId).delete();
  }


  // ******** Favoritos ********

  // Adiciona um livro aos favoritos do utilizador
  Future<void> adicionarFavorito(Map<String, dynamic> favoritoData) async {
    await _firestore.collection('favoritos').add(favoritoData);
  }

  // Obtém os livros favoritos do utilizador
  Stream<QuerySnapshot> obterFavoritos(String userId) {
    return _firestore
        .collection('favoritos')
        .where('userId', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots();
  }

  // Remove um favorito (opcional, para permitir remover da lista)
  Future<void> removerFavorito(String docId) async {
    await _firestore.collection('favoritos').doc(docId).delete();
  }



  // ******** Livros Lidos ********
  Future<void> adicionarLivroLido(Map<String, dynamic> livroData) async {
    await _firestore.collection('livrosLidos').add(livroData);
  }

  Future<void> removerLivroLido(String docId) async {
    await _firestore.collection('livrosLidos').doc(docId).delete();
  }

  Stream<QuerySnapshot> obterLivrosLidos(String userId) {
    return _firestore
        .collection('livrosLidos')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }


}
