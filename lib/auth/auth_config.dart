import 'dart:io';

import 'package:aad_oauth/model/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aad_oauth/aad_oauth.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

   final Config config = Config(
      tenant: "c83f55a7-7fe8-4934-b759-09926430aef0",
      clientId: "d225b77a-b742-4407-9daf-4bb94aebb1ad",
      scope: "openid profile offline_access",
      redirectUri: kIsWeb
          ? ""
          : Platform.isIOS
          ? "msauth.com.example.plmCrsGrad://auth"
          : "msauth://com.example.plm_crs_grad/CZGP42p0PsfXg%2FeNVlQ9LmedzdA%3D",
      navigatorKey: navigatorKey,
      loader: SizedBox()
    // webUseRedirect: true, // default is false - on web only, forces a redirect flow instead of popup auth
    // //Optional parameter: Centered CircularProgressIndicator while rendering web page in WebView
    // loader: const Center(child: CircularProgressIndicator()),
  );
