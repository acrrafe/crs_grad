import 'dart:io';

import 'package:aad_oauth/model/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aad_oauth/aad_oauth.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final Config config = new Config(
  tenant: "YOUR_TENANT_ID",
  clientId: "YOUR_CLIENT_ID",
  scope: "openid profile offline_access",
  // redirectUri is Optional as a default is calculated based on app type/web location
  redirectUri: "your redirect url available in azure portal",
  navigatorKey: navigatorKey,
  webUseRedirect: true, // default is false - on web only, forces a redirect flow instead of popup auth
  //Optional parameter: Centered CircularProgressIndicator while rendering web page in WebView
  loader: Center(child: CircularProgressIndicator()),
  postLogoutRedirectUri: 'http://your_base_url/logout', //optional
);