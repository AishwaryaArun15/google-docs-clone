import 'dart:convert';
import 'package:docs_clone/constants/constant.dart';
import 'package:docs_clone/models/document_model.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final documentRepositoryProvider =
    Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;

  DocumentRepository({
    required Client client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    var errModel = ErrorModel(data: [], error: '');
    try {
      var response = await _client.post(
          Uri.parse(pathHost + pathCreateDocument),
          body:
              jsonEncode({'createdAt': DateTime.now().millisecondsSinceEpoch}),
          headers: {
            'Content-type': 'application/json; charset=utf-8',
            'x-auth-token': token,
          });

      if (response.statusCode == 200) {
        errModel.data = DocumentModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 500) {
        errModel.error = 'Server Side Error';
      }
    } catch (e) {
      errModel.error = e.toString();
      print(e);
    }
    return errModel;
  }

  void updateDocumentTitle(
      {required String token,
      required String id,
      required String title}) async {
    try {
      var response = await _client.post(
          Uri.parse(pathHost + pathUpdateDocumentTitle),
          body: jsonEncode({'id': id, 'title': title}),
          headers: {
            'Content-type': 'application/json; charset=utf-8',
            'x-auth-token': token,
          });

      if (response.statusCode == 200) {
      } else if (response.statusCode == 500) {
        print('Server Error');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<ErrorModel> getMyDocuments(String token) async {
    var errModel = ErrorModel(data: [], error: '');
    try {
      var response =
          await _client.get(Uri.parse(pathHost + pathGetMyDocument), headers: {
        'Content-type': 'application/json; charset=utf-8',
        'x-auth-token': token,
      });

      if (response.statusCode == 200) {
        List<DocumentModel> documents = [];
        for (int i = 0; i < jsonDecode(response.body).length; i++) {
          documents.add(DocumentModel.fromJson(jsonDecode(response.body)[i]));
        }
        errModel.data = documents;
      } else if (response.statusCode == 500) {
        errModel.error = 'Server Side Error';
      }
    } catch (e) {
      errModel.error = e.toString();
      print(e);
    }
    return errModel;
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    var errModel = ErrorModel(data: [], error: '');
    try {
      var response = await _client
          .get(Uri.parse(pathHost + pathDocumentById(id)), headers: {
        'Content-type': 'application/json; charset=utf-8',
        'x-auth-token': token,
      });

      if (response.statusCode == 200) {
        var document = (DocumentModel.fromJson(jsonDecode(response.body)));
        errModel.data = document;
      } else if (response.statusCode == 500) {
        errModel.error = 'Document Not Found';
      }
    } catch (e) {
      errModel.error = e.toString();
      print(e);
    }
    return errModel;
  }
}
