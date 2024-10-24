import 'package:docs_clone/common/colors.dart';
import 'package:docs_clone/common/loader.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackBar = ScaffoldMessenger.of(context);

    final errModel =
        await ref.read(documentRepositoryProvider).createDocument(token);
    if (errModel.data != null) {
      navigator.push('/document/${errModel.data.id}');
    } else {
      snackBar.showSnackBar(SnackBar(
        content: Text(errModel.error),
      ));
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    Routemaster.of(context).push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tBlueColor,
        elevation: 0,
        actions: [
          IconButton(
              tooltip: 'Create Document',
              onPressed: () => createDocument(context, ref),
              icon: const Icon(
                Icons.add,
                color: tWhiteColor,
              )),
          IconButton(
              tooltip: 'Sign Out',
              onPressed: () => signOut(ref),
              icon: const Icon(
                Icons.logout,
                color: tWhiteColor,
              )),
        ],
        title: const Text(
          'Google Docs Clone',
          style: TextStyle(color: tWhiteColor, fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder(
          future: ref
              .watch(documentRepositoryProvider)
              .getMyDocuments(ref.watch(userProvider)!.token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            return Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Created By Me',
                      style: TextStyle(fontSize: 16, color: tBlackColor),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data!.data.length,
                          itemBuilder: (context, index) {
                            DocumentModel document = snapshot.data!.data[index];
                            return SizedBox(
                              height: 100,
                              width: 60,
                              child: Card(
                                elevation: 0,
                                child: InkWell(
                                  onTap: () =>
                                      navigateToDocument(context, document.id),
                                  child: Center(
                                    child: Text(
                                      document.title,
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
