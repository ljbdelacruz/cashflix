import 'dart:convert';
import 'dart:io';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
// import 'package:foody_ui/typdef/mytypedef.dart';
// import 'package:http/http.dart' as http;
// import 'package:traveller/config/constants.config.dart';
// import 'package:traveller/model/userinfo.model.dart';
// import 'package:traveller/services/firebase.service.dart';
// import 'package:traveller/services/firebaseauth.service.dart';

class FacebookService {
  static FacebookService instance = FacebookService();
  final facebookLogin = FacebookLogin();
  FacebookUserInfo facebookData;

  getFacebookUserInfo(
      FacebookLoginResult result, String token, GetUserModelInfo scall) {
    final token = result.accessToken.token;
    http
        .get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=' +
                token)
        .then((resp) {
      final json = jsonDecode(resp.body);
      var data = FacebookUserInfo.json(json);
      data.accessToken = token;
      FacebookService.instance.facebookData = data;
      MyFirebaseAuthService.instance.facebookLogin(token);
      FirebaseService.instance.pushUserDataFacebookLogin(data);
      Constants.instance.platformSignIn = PlatformSignin.facebook;
      FirebaseService.instance.fetchUserInfo(data.id, (model) {
        Constants.instance.userInfo = model;
        scall(model);
      });
      // scall(data);
    });
  }

  fbLoginInit(NormalCallback cancel, GetStringData error,
      GetUserModelInfo scall) async {
    final result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        getFacebookUserInfo(result, result.accessToken.token, scall);
        break;
      case FacebookLoginStatus.cancelledByUser:
        cancel();
        break;
      case FacebookLoginStatus.error:
        error(result.errorMessage);
        break;
    }
  }

  downloadProfileImage(String id, String mainImage) async {
    if (mainImage.length <= 0) {
      FirebaseService.instance.updateProfileImage(
          id, "http://graph.facebook.com/" + id + "/picture?type=normal");
    }
  }
}

class FacebookUserInfo {
  String email = "sample";
  String firstName = "sample";
  String lastName = "sample";
  String name = "sample";
  String id = "sample";
  String accessToken;

  FacebookUserInfo();
  FacebookUserInfo.json(dynamic data) {
    this.email = data["email"].toString();
    this.firstName = data["first_name"].toString();
    this.lastName = data["last_name"].toString();
    this.name = data["name"].toString();
    this.id = data["id"].toString();
  }
}
