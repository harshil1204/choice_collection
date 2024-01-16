
import 'package:choice_collection/config/config.dart';
import 'package:choice_collection/resources/color.dart';
import 'package:choice_collection/widget/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'main_page.dart';


class AddProduct extends StatefulWidget {
  String catId;
  AddProduct({Key? key,required this.catId}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescController = TextEditingController();
  final TextEditingController _productExtraController = TextEditingController();
  final TextEditingController _productStatusController = TextEditingController();

  String? imageUrl;

  void addProductToFirestore(String productName,String productPrice,String desc,String extra,String status) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Products').add({
        'id':widget.catId,
        'name': productName,
        'price':productPrice,
        'url':imageUrl,
        'extra':extra,
        'description':desc,
        'inStock':status,
        'time ': DateTime.now(),
        // Add more fields related to the category if needed
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPageProduct(),));
      print('Product added successfully');
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    DateTime now =  DateTime.now();
    // var datestamp = DateFormat("yyyyMMdd'T'HHmmss");
    // String currentdate = datestamp.format(now);

    //Select Image
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null){
      //Upload to Firebase
      var snapshot = await _firebaseStorage.ref()
          .child('images/$now.jpg')
          .putFile(File(image.path));
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
    } else {
      print('No Image Path Received');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CommonText.bold("Add Product",color: AppColor.white,size: 18,),
        backgroundColor: AppColor.primary,
        iconTheme: IconThemeData(
            color: AppColor.white
        ),
      ),
      body: Stack(
        children: [
          Opacity(
              opacity: MyConfig.opacity,
              child: Image.asset(MyConfig.bg,fit: BoxFit.fill,height: double.infinity,width: double.infinity )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30,),
                  TextField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: _productStatusController,
                    decoration: const InputDecoration(
                      labelText: 'Product Status',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    maxLines: 6,
                    controller: _productDescController,
                    decoration: const InputDecoration(
                      labelText: 'Product Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  // Text("Select image.."),
                  InkWell(
                    onTap: (){
                      uploadImage();
                    },
                    child: Container(
                      // height: 130,
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                          border: Border.all(color: Colors.white),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(2, 2),
                              spreadRadius: 2,
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: (imageUrl == null)
                            ? const Icon(Icons.photo)
                            : Image.network(imageUrl.toString(),height: 50,fit: BoxFit.fill,)
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      String productName = _productNameController.text.trim();
                      String productPrice = _productPriceController.text.trim();
                      String productDesc = _productDescController.text.trim();
                      String productExtra = _productExtraController.text.trim();
                      String productStatus = _productStatusController.text.trim();
                      //uploadImage();
                      if (productName.isNotEmpty && productPrice.isNotEmpty && imageUrl!.isNotEmpty && productDesc.isNotEmpty && productExtra.isNotEmpty) {
                        addProductToFirestore(productName,productPrice,productDesc,productExtra,productStatus);
                        _productNameController.clear();
                        _productPriceController.clear();
                        _productDescController.clear();
                        _productExtraController.clear();
                        _productStatusController.clear();
                        imageUrl="";
                      }
                    },
                    child: const Text('Add Product'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
