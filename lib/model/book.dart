class Book {
  final DateTime? createdAt;
  final String title;
  String? author;
  bool? isFinished;
  String? id;
  String? imageUrl;
  String? ebookUrl;
  List<String>? tag;
  String? epub;
  final String usersId;

  Book({
    this.createdAt,
    required this.title,
    this.author,
    this.isFinished,
    this.id,
    this.imageUrl,
    this.ebookUrl,
    this.tag,
    this.epub,
    required this.usersId,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      title: json['title'],
      author: json['author'] as String?,
      isFinished: json['is_finished'] as bool?,
      id: json['id'] as String?,
      imageUrl: json['image_url'] as String?,
      ebookUrl: json['ebook_url'] as String?,
      tag: (json['tag'] as List<dynamic>?)?.map((e) => e as String).toList(),
      epub: json['epub'] as String?,
      usersId: json['users_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'title': title,
      'author': author,
      'is_finished': isFinished,
      'image_url': imageUrl,
      'ebook_url': ebookUrl,
      'tag': tag,
      'epub': epub,
      'users_id': usersId,
    };
    if (createdAt != null) {
      data['created_at'] = createdAt!.toIso8601String();
    }
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  Book copyWith({
    DateTime? createdAt,
    String? title,
    String? author,
    bool? isFinished,
    String? id,
    String? imageUrl,
    String? ebookUrl,
    List<String>? tag,
    String? epub,
    String? usersId,
  }) {
    return Book(
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      author: author ?? this.author,
      isFinished: isFinished ?? this.isFinished,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      ebookUrl: ebookUrl ?? this.ebookUrl,
      tag: tag ?? this.tag,
      epub: epub ?? this.epub,
      usersId: usersId ?? this.usersId,
    );
  }
}
