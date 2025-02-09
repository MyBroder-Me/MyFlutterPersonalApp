import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/book_service.dart';
import '../model/book.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late Future<List<Book>> booksFuture;

  @override
  void initState() {
    super.initState();
    booksFuture = Provider.of<BookService>(context, listen: false).fetchBooks();
  }

  void _addBook() async {
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

    if (result != null && mounted) {
      try {
        await Provider.of<BookService>(context, listen: false)
            .addBookWithCurrentUser(result);
        if (mounted) {
          setState(() {
            booksFuture =
                Provider.of<BookService>(context, listen: false).fetchBooks();
          });
        }
      } catch (e) {
        // Handle error (e.g., show a message to the user)
        print('Error adding book: $e');
      }
    }
  }

  void _removeBook(String id) async {
    await Provider.of<BookService>(context, listen: false).removeBook(id);
    if (mounted) {
      setState(() {
        booksFuture =
            Provider.of<BookService>(context, listen: false).fetchBooks();
      });
    }
  }

  void _editBook(Book book) async {
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

    if (result != null && mounted) {
      await Provider.of<BookService>(context, listen: false).editBook(result);
      if (mounted) {
        setState(() {
          booksFuture =
              Provider.of<BookService>(context, listen: false).fetchBooks();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<Book>>(
          future: booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final books = snapshot.data!;
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text(book.author ?? 'Unknown'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editBook(book),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeBook(book.id!),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: _addBook,
        ));
  }
}

/*
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addBook,
          ),
        ],
      ),
 */
