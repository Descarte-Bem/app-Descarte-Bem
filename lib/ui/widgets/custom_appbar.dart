import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'circular_avatar_button.dart';

class CustomAppBar extends AppBar{
  final bool? autoLeading;
  final Widget? customLeading;
  final BuildContext context;

  CustomAppBar({super.key, this.customLeading, this.autoLeading, required this.context});

  @override
  Widget? get leading => autoLeading == true ?
      IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey.shade700,),
        onPressed: () {
          Navigator.pop(context);
        },
        ) :
      customLeading;
  @override
  bool get automaticallyImplyLeading => false;
  @override
  Color? get backgroundColor => const Color(0xFFFFFFFF);
  @override
  double? get elevation => 0;
  @override
  double? get toolbarHeight => MediaQuery.of(context).size.height/10;
  @override
  Widget? get title => const Text("Descarta Bem");
  @override
  TextStyle? get titleTextStyle => const TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w400,
      fontSize: 22
  );
  @override
  bool? get centerTitle => true;
  @override
  List<Widget>? get actions => [
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        debugPrint("CRIANDO...");
        DocumentReference docRef = await FirebaseFirestore.instance.collection('farmacias').add({
          "nome": "Droga Raia",
          "cep": "24220021",
          "numero": "56",
          "localizacao": const GeoPoint(-22.903624,-43.1164579)
        });
        debugPrint("Doc criado: ${docRef.id}");
      },
    ),
    const CircularAvatarButton()
  ];


}