import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:rehabilitacion_app/models/therapy.dart';

class TherapyFirebaseService extends ChangeNotifier {
  final String _baseUrl = 'rehabilitacion-fisica-default-rtdb.firebaseio.com';
  // final String _baseUrl = 'firestore.googleapis.com/v1/projects/rehabilitacion-fisica/databases/(default)/documents/users';
  // final String _firebaseToken = 'AIzaSyCJKd2wJVyXZrSMvdS91nNZtlKUVI5DZVI';

  final List<Therapy> therapies = [];
  late Therapy? selectedTherapy;

  final storage = new FlutterSecureStorage();

  File? newPictureFile;

  bool isLoading = true;
  bool isSaving = false;

  TherapyFirebaseService() {
    this.loadTherapies();
    // this.getTherapies();
  }

  Future loadTherapies() async {
    this.isLoading = true;
    notifyListeners();

    CollectionReference collectionTherapy =
        FirebaseFirestore.instance.collection('therapies');

    collectionTherapy.get().then((QuerySnapshot querySnapshot) {
      print(querySnapshot.metadata);
      querySnapshot.docs.forEach((doc) {
        // print('Doc: $doc');
        // print('Doc Name: ${doc['name']}');
        // print('Doc Image: ${doc['image']}');
        final Therapy tmp = Therapy(
          imagen: doc['image'],
          nombre: doc['name'],
        );
        this.therapies.add(tmp);
        final datos = jsonEncode(doc.data());
        // Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // String resp = data.toString();
        // final _dat = jsonDecode(resp);
        // doc.data() as Map<String, dynamic>;
        // Map<String, dynamic> data = jsonDecode(doc);
        // http.Response dat = jsonEncode(data);

        // String jsonDataResp = dat.body.toString();
        // final _data = jsonDecode(jsonDataResp);
        final qwerty = jsonDecode(datos);

        // qwerty.forEach((key, value) {
        //   print('Index: $index');
        //   print('Nombre: ${qwerty['name']}');
        //   print(qwerty['image']);
        //   // final temp = Therapy.fromJson(value);
        //   // final Therapy tmp = Therapy(nombre: '');
        //   final Therapy tmp = Therapy(
        //     id: key,
        //     imagen: qwerty['image'],
        //     nombre: qwerty['name'],
        //   );
        //   // tmp.id = key;
        //   // tmp.nombre = qwerty['nombre'];
        //   // tmp.imagen = qwerty['image'];
        //   // temp.id = key;
        //   // temp.nombre = data['name'];
        //   // temp.imagen = data['image'];
        //   index++;
        //   // this.therapies.add(tmp);
        // });

        // print(data);

        // querySnapshot.docs.map((DocumentSnapshot document) {
        //   Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        //   // final temp = Therapy.fromMap(data as Map<String, dynamic>);
        //   // temp.nombre = data['name'];
        //   // temp.imagen = data['image'];
        //   print(data['name']);
        //   print(data['image']);
        //   // this.therapies.add(temp);
        // });

        // final temp = Therapy.fromMap(doc as Map<String, dynamic>);
        // temp.id = '123456';
        // temp.nombre = doc['name'];
        // temp.imagen = doc['image'];
        // temp.nombre = doc['name'];
        // print('Doc: ');
        // print(doc['name']);
        // print(doc['image']);
        // print('Data: ');
        // print(data['name']);
        // print(data['image']);
        // temp.id = data['id'];
        // temp.imagen = data['image'];
        // temp.nombre = data['name'];
        // this.therapies.add(temp);
      });
    });
    // }).catchError((error) => print(error));

    // final DocumentSnapshot snapshot = collectionTherapy as DocumentSnapshot;
    // Map<String, dynamic> mapTherapy = snapshot.data() as Map<String, dynamic>;

    // final Map<String, dynamic> map = collectionTherapy as Map<String, dynamic>;

    // map.forEach((key, value) {
    //   final tempTherapy = Therapy.fromMap(value);
    //   tempTherapy.id = key;
    // });

    // print('Carga de terapias: ${mapTherapy['name']}');

    this.isLoading = false;
    notifyListeners();
  }

  Future saveOrCreateTherapy(Therapy therapy) async {
    isSaving = true;
    notifyListeners();

    if (therapy.id == null) {
      // Crear
      // await this.createTherapy(therapy);
      await this.addTherapy(therapy);
    } else {
      // Actualizar
      await this.updateTherap(therapy);
      // await this.updateTherapy(therapy);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> createTherapy(Therapy therapy) async {
    final url = Uri.https(_baseUrl, 'terapias.json');
    final resp = await http.post(url, body: therapy.toJson());
    final decodedData = json.decode(resp.body);

    // print(decodedData); en este print se observa 'name' como el id de firebase
    therapy.id = decodedData['name'];
    this.therapies.add(therapy);

    // addTherapy(therapy.nombre, therapy.imagen);
    // print(decodedData);
    // print(therapy.id);
    // print(therapy.nombre);
    // print(therapy.imagen);

    return '';
  }

  Future<void> addTherapy(Therapy therapy) async {
    CollectionReference collectionTherapy =
        FirebaseFirestore.instance.collection('therapies');

    return collectionTherapy
        .add({
          'name': therapy.nombre,
          'image': therapy.imagen,
        })
        .then((value) => print('Terapia registrada'))
        .catchError((error) => print('Error $error'));
  }

  void updateSelectedTherapyImage(String path) {
    this.selectedTherapy!.imagen = path;
    this.newPictureFile = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String> updateTherapy(Therapy therapy) async {
    final url = Uri.https(_baseUrl, 'terapias/${therapy.id}.json');
    final resp = await http.put(url, body: therapy.toJson());
    final decodedData = json.decode(resp.body);

    final index =
        this.therapies.indexWhere((element) => element.id == therapy.id);

    this.therapies[index] = therapy;
    // updateTherap(therapy.id!, therapy.nombre, therapy.imagen);

    return therapy.id!;
  }

  Future<void> updateTherap(Therapy therapy) async {
    CollectionReference collectionTherapy =
        FirebaseFirestore.instance.collection('therapies');

    // final index =
    //     this.therapies.indexWhere((element) => element.id == therapy.id);

    return collectionTherapy
        .doc(therapy.id)
        .set({
          'name': therapy.nombre,
          'image': therapy.imagen,
        })
        .then((value) => print('Terapia actualizada'))
        .catchError((error) => print('Error $error'));
  }

  Future<String?> uploadImage() async {
    if (this.newPictureFile == null) return null;

    isSaving = true;
    notifyListeners();

    // https://api.cloudinary.com/v1_1/<cloud name>/<resource_type>/upload
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dlbgjolbl/image/upload?upload_preset=exhitflm');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salió mal');
      print(resp.body);
      return null;
    }

    // Indicando que se subió la imagen, limpiando esa propiedad
    this.newPictureFile = null;

    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }
}
