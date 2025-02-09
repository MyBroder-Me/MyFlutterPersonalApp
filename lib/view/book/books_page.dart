import 'package:flutter/material.dart';
import 'package:myapp/view/book/books_dialogs.dart';
import 'package:provider/provider.dart';

import '../../controller/book_service.dart';
import '../../model/book.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
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
                          onPressed: () async {
                            await editBook(context, book);
                            setState(() {
                              booksFuture = Provider.of<BookService>(context,
                                      listen: false)
                                  .fetchBooks();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await removeBook(context, book.id!);
                            setState(() {
                              booksFuture = Provider.of<BookService>(context,
                                      listen: false)
                                  .fetchBooks();
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await addBook(context);
            setState(() {
              booksFuture =
                  Provider.of<BookService>(context, listen: false).fetchBooks();
            });
          },
          label: Text("Add Book"),
          icon: const Icon(Icons.add),
        ));
  }
}
