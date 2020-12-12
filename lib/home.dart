import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmpam/main.dart';
import 'package:farmpam/signIn.dart';
import 'package:flutter/material.dart';
import 'assets.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cart.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection("users");

//product list for main.
List<DocumentSnapshot> items;
Stream<QuerySnapshot> product =
FirebaseFirestore.instance.collection("product").snapshots();

CollectionReference productCollection = FirebaseFirestore.instance.collection("product");

//variable for search function.
String searchKeyword;

//cartpage에 쓸 데이터.
List<dynamic> cartList = new List<dynamic>();

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  String title = 'Main page';
  var userLat;
  var userLong;
  var userAddr;
  TextEditingController _controller;
  bool isSearching = false;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get documentId => null;

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshots) {
    return ListView(
        shrinkWrap: true,
        children:
        snapshots.map((data) => buildListTile(context, data)).toList());
  }

  StreamBuilder<QuerySnapshot> search(String value) {
    print("search");
    print(value);
    return StreamBuilder<QuerySnapshot>(
      stream: productCollection
      .where('searchKeyword', arrayContains: value)
      .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        items = snapshot.data.docs;
        return _buildList(context, items);
      },
    );
  }


  StreamBuilder<QuerySnapshot> queryProducts(var minUserLat,var maxUserLat, var userAddr) {
    return StreamBuilder<QuerySnapshot>(
        stream: productCollection
            .where('farmLocationLat', isGreaterThan: minUserLat)
            .where('farmLocationLat', isLessThan: maxUserLat)
        .where('location', isEqualTo: userAddr)
        .snapshots(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) return LinearProgressIndicator();
    items = snapshot.data.docs;
    return _buildList(context, items);
    },
    );
  }


  @override
  Widget build(BuildContext context) {
    User user = _auth.currentUser;

    if (currentUser == null) {
      users.add({
        'address': "",
        'addressLat': 0,
        'addressLong': 0,
        'cart': [],
        'chatList': [],
        'favorite': [],
        'like': [],
        'isVerified': true,
        'nickName': user.displayName,
        'sellingProducts': [],
        'uid': user.uid,
        'farmDescription': '',
        'farmImage': '',
        'farmReview': [],
        'farmName': '',
        'farmLocation': '',
        'farmLocationLat': 0,
        'farmLocationLong': 0,
        'image': '',
      }).then((value) => {currentUser = value});
    }
    print("home currentuser == $currentUser");

    print(cartList);
    print(name);
    print(description);

    //cart page에 필요한 데이터.
    setState(() {
      setData();
      print("home currentuser22 == $currentUser");
    });

    return Scaffold(
      appBar: header(context, title, true),
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: IconButton(
                    icon: Icon(Icons.search), onPressed: () {
                  setState(() {
                    _controller.text == ''
                        ? isSearching = false
                    : isSearching = true;
                  });
                } ),
              ),
              SizedBox(
                  width: 250,
                  height: 40,
                  //TODO: Textbox for searching
                  child: TextField(
                    controller: _controller,
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Search",
                    ),
                    onSubmitted: (String value) async {
                      setState(() {
                        _controller.text == ''
                            ? isSearching = false
                            : isSearching = true;
                      });
                    },
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //TODO: dropdown menu for sorting
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                child: Text(
                  "Product List",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              DropdownButton(items: null, onChanged: null),
            ],
          ),
          Divider(
            thickness: 1.5,
          ),
          Container(
            child:
            isSearching? search(_controller.text)
                : queryProducts(userLat-5, userLat+5, userAddr)
          )
        ],
      ),
      bottomNavigationBar: footer(context),
    );
  }

  Future<void> setData() async {
    String userdoc =
    currentUser.toString().substring(24, currentUser.toString().length - 1);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userdoc)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      int len = documentSnapshot.data()['cart'].length;
      userLat = documentSnapshot.data()['addressLat'];
      userLong = documentSnapshot.data()['addressLong'];
      userAddr = documentSnapshot.data()['address'];
      cartList.removeRange(0, cartList.length);

      for (int i = 0; i < len; i++) {
        cartList.insert(i, documentSnapshot.data()['cart'][i]);
      }
    });

    if (cartList.length != name.length && cartList.length != 0) {
      name.removeRange(0, name.length);
      image.removeRange(0, image.length);
      location.removeRange(0, location.length);
      starRating.removeRange(0, starRating.length);
      price.removeRange(0, price.length);
      description.removeRange(0, description.length);
      for (int i = 0; i < cartList.length; i++) {
        await FirebaseFirestore.instance
            .collection("product")
            .doc(cartList[i])
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          name.add(documentSnapshot.data()['name']);
          image.add(documentSnapshot.data()['image']);
          location.add(documentSnapshot.data()['location']);
          starRating.add(documentSnapshot.data()['starRating'].toString());
          price.add(documentSnapshot.data()['price'].toString());
          String temp = documentSnapshot.data()['description'];
          if (temp.length >= 10) {
            temp = temp.substring(0, 10) + "...";
          } else {
            temp = temp + "...";
          }
          description.add(temp);
          productRef.add(documentSnapshot.reference);
        });
      }
    }
  }

  //TODO: make search function.

}
