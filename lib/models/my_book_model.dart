class Livro {
  final String id;
  final String titulo;
  final String? autor;
  final String? urlImagem;

  Livro({
    required this.id,
    required this.titulo,
    this.autor,
    this.urlImagem,
  });

  /// da build um objeto Livro a partir dos dados da Open Library.
  factory Livro.fromJson(Map<String, dynamic> json) {
    // atribui o id
    String id = json['key'] ?? '';

    // da build ao URL da imagem
    String? urlImagem;
    if (json.containsKey('cover_i')) {
      urlImagem = 'https://covers.openlibrary.org/b/id/${json['cover_i']}-M.jpg';
    }



    return Livro(
      id: id,
      titulo: json['title'] ?? 'Título desconhecido',
      autor: (json['author_name'] as List?)?.join(', ') ?? 'Autor desconhecido',
      urlImagem: urlImagem,
    );
  }
}
