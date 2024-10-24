import 'dart:async';
import 'package:docs_clone/common/colors.dart';
import 'package:docs_clone/common/loader.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/repository/document_repository.dart';
import 'package:docs_clone/repository/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart' as delta;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _quillController;
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();

  void updateDocumentTitle(WidgetRef ref, String title) async {
    ref.read(documentRepositoryProvider).updateDocumentTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  Future<void> fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);
    if (errorModel != null && errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _quillController = quill.QuillController(
          document: errorModel!.data.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(
                  delta.Delta.fromJson(errorModel!.data.content)),
          selection: const TextSelection.collapsed(offset: 0));
      setState(() {});
    }
    _quillController!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {
          'delta': event.change,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });

    socketRepository.changeListener((data) {
      _quillController!.compose(
        delta.Delta.fromJson(data['delta']),
        _quillController?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.remote,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _quillController!.document.toDelta(),
        'room': widget.id
      });
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: tBlueColor),
              onPressed: () {
                Clipboard.setData(ClipboardData(
                        text: 'http://localhost:3000/#/document/${widget.id}'))
                    .then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link Copied!')));
                });
              },
              icon: const Icon(
                Icons.lock,
                size: 16,
                color: tWhiteColor,
              ),
              label: const Text(
                'Share',
                style: TextStyle(color: tWhiteColor),
              ),
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace('/');
                },
                child: Image.asset(
                  'assets/images/docs-logo.png',
                  height: 40,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  onSubmitted: (value) => updateDocumentTitle(ref, value),
                  controller: titleController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: tBlueColor)),
                      contentPadding: EdgeInsets.only(left: 10)),
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: tGreyColor, width: 0.1)),
            )),
      ),
      body: _quillController == null
          ? const Loader()
          : Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  quill.QuillSimpleToolbar(
                    controller: _quillController,
                    configurations:
                        const quill.QuillSimpleToolbarConfigurations(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 750,
                      child: Card(
                        color: tWhiteColor,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: quill.QuillEditor.basic(
                            controller: _quillController,
                            configurations:
                                const quill.QuillEditorConfigurations(),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
