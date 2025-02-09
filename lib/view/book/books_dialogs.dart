import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/book_service.dart';
import '../../model/book.dart';

Future<void> addBook(BuildContext context) async {
  final titleController = TextEditingController();
  final authorController = TextEditingController();

  final result = await showDialog<Book>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              final book = Book(
                title: titleController.text,
                author: authorController.text,
                usersId: '', // Placeholder, will be set in the service
              );
              Navigator.of(context).pop(book);
            },
          ),
        ],
      );
    },
  );

  if (result != null && context.mounted) {
    try {
      await Provider.of<BookService>(context, listen: false)
          .addBookWithCurrentUser(result);
      if (context.mounted) {
        // Refresh the book list
        Provider.of<BookService>(context, listen: false).fetchBooks();
        // Update the state to refresh the list
        (context as Element).markNeedsBuild();
      }
    } catch (e) {
      // Handle error (e.g., show a message to the user)
      print('Error adding book: $e');
    }
  }
}

Future<void> removeBook(BuildContext context, String id) async {
  await Provider.of<BookService>(context, listen: false).removeBook(id);
}

Future<void> editBook(BuildContext context, Book book) async {
  final titleController = TextEditingController(text: book.title);
  final authorController = TextEditingController(text: book.author);

  final result = await showDialog<Book>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              final updatedBook = Book(
                createdAt: book.createdAt,
                title: titleController.text,
                author: authorController.text,
                id: book.id,
                usersId: book.usersId,
              );
              Navigator.of(context).pop(updatedBook);
            },
          ),
        ],
      );
    },
  );

  if (result != null && context.mounted) {
    await Provider.of<BookService>(context, listen: false).editBook(result);
  }
}
