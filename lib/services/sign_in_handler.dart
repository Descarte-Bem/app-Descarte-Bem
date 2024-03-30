import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInHandler {
  BuildContext context;
  SignInHandler(this.context);

  final auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserCredential? userCredential;

  Future<void> signInWithGoogle() async {
    if (auth.currentUser != null) {
      try {
        await auth.signOut();
        await googleSignIn.signOut();

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        debugPrint('Deslogado');
      } catch(e) {
        debugPrint("ERRO DESLOGANDO: $e");
      }
    } else {
      try {
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        userCredential = await auth.signInWithCredential(credential);

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        debugPrint('Logado: ${userCredential!.user!.email}');
      } catch(e) {
        debugPrint("ERRO LOGANDO: $e");
      }
    }
  }

  Future<void> signInWithApple() async {
    if (Platform.isIOS) {
      String generateNonce([int length = 32]) {
        const charset =
            '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
        final random = Random.secure();
        return List.generate(length, (_) =>
        charset[random.nextInt(charset.length)]).join();
      }

      String sha256ofString(String input) {
        final bytes = utf8.encode(input);
        final digest = sha256.convert(bytes);
        return digest.toString();
      }

      try{
        final rawNonce = generateNonce();
        final nonce = sha256ofString(rawNonce);

        final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            webAuthenticationOptions: WebAuthenticationOptions(
                clientId: "br.uff.descartabemid",
                redirectUri: Uri.parse("https://descarte-b78a4.firebaseapp.com/__/auth/handler")
            ),
            nonce: nonce
        );

        // Create an `OAuthCredential` from the credential returned by Apple.
        final appleOauthProvider = OAuthProvider(
          "apple.com",
        );

        appleOauthProvider.setScopes([
          'email',
          'name',
        ]);

        final oauthCredential = appleOauthProvider.credential(
          idToken: credential.identityToken,
          rawNonce: rawNonce,
        );

        UserCredential auth = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
        if (auth.user != null) {
          if (auth.user != null) {
            if (auth.user?.email == null &&
                credential.email != null) {
              await auth.user?.updateEmail(credential.email!);
            }

            if (auth.user?.displayName == null &&
                credential.givenName != null &&
                credential.familyName != null) {
              await auth.user?.updateDisplayName(
                  '${credential.givenName} ${credential.familyName}');
            }
          }

          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
        else {
          FirebaseAuth.instance.signOut();
          print("Deslogado");
        }
      } catch (e) {
        print(e);
      }
    } else {
      try{
        final appleProvider = AppleAuthProvider();
        UserCredential auth = await FirebaseAuth.instance.signInWithProvider(appleProvider);
        if (auth.user != null) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
        else {
          FirebaseAuth.instance.signOut();
          print("Deslogado");
        }
      } catch (e) {
        print(e);
      }
    }
  }
}