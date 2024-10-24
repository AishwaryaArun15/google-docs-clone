import 'dart:convert';
import 'package:docs_clone/constants/constant.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/models/user_model.dart';
import 'package:docs_clone/repository/localstorage_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localstorageRepository: LocalstorageRepository()));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalstorageRepository _localstorageRepository;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required LocalstorageRepository localstorageRepository})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localstorageRepository = localstorageRepository;

  Future<ErrorModel> signInWithGoogle() async {
    var errModel = ErrorModel(data: [], error: '');
    try {
      final userAccount = await _googleSignIn.signIn();
      if (userAccount != null) {
        final user = UserModel(
            email: userAccount.email,
            name: userAccount.displayName ?? 'Unknown User',
            profilePicture: userAccount.photoUrl ?? '',
            token: '',
            uid: '');

        var response = await _client.post(Uri.parse(pathHost + pathAuthSignup),
            body: jsonEncode(user),
            headers: {'Content-type': 'application/json; charset=utf-8'});

        if (response.statusCode == 200) {
          final newUser = user.copyWith(
            uid: jsonDecode(response.body)['user']['_id'],
            token: jsonDecode(response.body)['token'],
          );
          errModel.data = newUser;
          _localstorageRepository.setToken(newUser.token);
        } else if (response.statusCode == 500) {
          errModel.error = 'Server Side Error';
        }
      }
    } catch (e) {
      errModel.error = e.toString();
      if (kDebugMode) {
        print(e);
      }
    }
    return errModel;
  }

  Future<ErrorModel> getUserData() async {
    var errModel = ErrorModel(data: [], error: '');
    try {
      String? token = await _localstorageRepository.getToken();
      if (token != null) {
        var response = await _client.get(Uri.parse(pathHost), headers: {
          'Content-type': 'application/json; charset=utf-8',
          'x-auth-token': token,
        });

        if (response.statusCode == 200) {
          final newUser = UserModel.fromJson(jsonDecode(response.body)['user'])
              .copyWith(token: token);
          errModel.data = newUser;
          _localstorageRepository.setToken(newUser.token);
        } else if (response.statusCode == 500) {
          errModel.error = 'Server Side Error';
        }
      }
    } catch (e) {
      errModel.error = e.toString();
      print(e);
    }
    return errModel;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localstorageRepository.setToken('');
    return;
  }
}
