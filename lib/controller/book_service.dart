// lib/controller/book_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/book.dart';

class BookService {
  final SupabaseClient client;

  BookService(this.client);

  Future<List<Book>> fetchBooks() async {
    final response = await client.from('books').select().count();
    final data = response.data as List<dynamic>;
    return data.map((json) => Book.fromJson(json)).toList();
  }

  Future<void> addBook(Book book) async {
    await client.from('books').insert(book.toJson());
  }

  Future<void> removeBook(String id) async {
    await client.from('books').delete().eq('id', id);
  }

  Future<void> editBook(Book book) async {
    await client.from('books').update(book.toJson()).eq('id', book.id!);
  }

  Future<void> addBookWithCurrentUser(Book book) async {
    final userId = client.auth.currentUser?.id;
    if (userId != null) {
      final bookWithUserId = book.copyWith(usersId: userId);
      await addBook(bookWithUserId);
    } else {
      throw Exception('User not authenticated');
    }
  }
}
