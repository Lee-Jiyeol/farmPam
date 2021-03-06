import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmpam/productDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'assets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'main.dart';
import 'signIn.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class addProductPage extends StatefulWidget {
  @override
  _addProductPageState createState() => _addProductPageState();
}

class _addProductPageState extends State<addProductPage> {
  final databaseReference = FirebaseFirestore.instance;
  String title = "Add Product";
  var _image;
  var newImageUploaded = false;
  String uid_;
  String tempID = Uuid().v1();
  String _uploadedFileURL;
  final productName = TextEditingController();
  final productPrice = TextEditingController();
  final productDescription = TextEditingController();

  Future getImage() async {
    final _picker = ImagePicker();
    var imageTemp = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(imageTemp.path);
      newImageUploaded = true; // Need?
    });
  }

  Widget imageDisplay() {
    if (!newImageUploaded) {
      return Image.network(defaultURL, width: 200, height: 150);
    } else {
      return Image.file(_image, width: 200, height: 150);
    }
  }

  Future uploadFile(String productName) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('product/$tempID');
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);
    await storageUploadTask.onComplete;
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  void uploadProduct(String tempName, String price, String description) async {
    await databaseReference.collection("product").doc(tempID).set({
      'name': tempName,
      'price': int.parse(price),
      'image': "product/$tempID",
      'ID': tempID,
      'description': description,
      'lastModified': FieldValue.serverTimestamp(),
      'creatorID': user.uid,
      'favoritedPeople': [],
      'location': '',
      'review': [],
      'starRating': 0,
      'starRatingList': [],
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("current user === ${FirebaseAuth.instance.currentUser.uid}");
    return Scaffold(
      appBar: header(context, title, false),
      body: ListView(
        children: <Widget>[
          imageDisplay(),
          SizedBox(
            height: 2,
          ),
          IconButton(
            icon: Icon(
              Icons.camera_alt,
            ),
            onPressed: () {
              getImage();
            },
          ),
          TextFormField(
            controller: productName,
            validator: (value) {
              if (value.isEmpty) {
                return '';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              labelText: 'ProductName',
            ),
          ),
          SizedBox(height: 5.0),
          TextFormField(
            controller: productPrice,
            validator: (value) {
              if (value.isEmpty) {
                return '';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              labelText: 'Price',
            ),
          ),
          SizedBox(height: 5.0),
          TextFormField(
            controller: productDescription,
            validator: (value) {
              if (value.isEmpty) {
                return '';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              labelText: 'Description',
            ),
          ),
          FlatButton(
            onPressed: () {
              uploadProduct(
                  productName.text, productPrice.text, productDescription.text);
              uploadFile(productName.text);
              Navigator.of(context).pop();
            },
            child: Text(
              "Save",
            ),
          ),
        ],
      ),
      bottomNavigationBar: footer(context),
    );
  }
}
