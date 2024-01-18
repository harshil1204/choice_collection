import 'dart:io';
import 'package:choice_collection/config/config.dart';
import 'package:choice_collection/homepage.dart';
import 'package:choice_collection/resources/color.dart';
import 'package:choice_collection/widget/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'categoryList.dart';

class UpdateCat extends StatefulWidget {
  String id;
  String name;
  String url;
  UpdateCat({Key? key,required this.id,required this.name,required this.url}) : super(key: key);

  @override
  State<UpdateCat> createState() => _UpdateCatState();
}

class _UpdateCatState extends State<UpdateCat> {

  String? imageUrl;
  void updateCatDetails(String catName) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Categories').doc(widget.id).update({
        'name': catName,
        'url':imageUrl,
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => CategoryList(),),(route) => false,);
      print('CAtegory details updated successfully');
    } catch (e) {
      print('Error updating product details: $e');
    }
  }
  uploadImage() async {
    final firebaseStorage = FirebaseStorage.instance;
    final imagePicker = ImagePicker();
    DateTime now =  DateTime.now();
    // var datestamp = DateFormat("yyyyMMdd'T'HHmmss");
    // String currentdate = datestamp.format(now);

    //Select Image
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null){
      //Upload to Firebase
      var snapshot = await firebaseStorage.ref()
          .child('images/$now.jpg')
          .putFile(File(image.path));
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
    } else {
      if (kDebugMode) {
        print('No Image Path Received');
      }
    }
  }

  final TextEditingController _categoryController = TextEditingController();
  void deleteCat(String catId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentReference categoryRef = FirebaseFirestore.instance.collection('Categories').doc(catId);

      WriteBatch batch = FirebaseFirestore.instance.batch();
      QuerySnapshot productQuerySnapshot = await FirebaseFirestore.instance.collection('Products').where('id', isEqualTo: catId).get();
      // await firestore.collection('Categories').doc(catId).delete();
      // Delete each product in the batch
      productQuerySnapshot.docs.forEach((productDoc) {
        batch.delete(FirebaseFirestore.instance.collection('Products').doc(productDoc.id));
      });

      // Delete the category document
      batch.delete(categoryRef);

      // Commit the batch
      await batch.commit();

      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false); // Close the dialog after deletion
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  @override
  void initState() {
    _categoryController.text=widget.name;
    imageUrl=widget.url;
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CommonText.bold("Update Category",color: AppColor.white,size:17),
        backgroundColor: AppColor.primary,
        iconTheme: const IconThemeData(
            color: AppColor.white
        ),
        actions: [
          IconButton(onPressed:(){
            deleteCat(widget.id);
          } ,icon: const Icon(Icons.delete))
        ],
      ),
      body: Stack(
        children: [
          Opacity(
              opacity: MyConfig.opacity,
              child: Image.asset(MyConfig.bg,fit: BoxFit.fill,height: double.infinity ,width: double.infinity)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TextField(
                //   controller: _categoryIdController,
                //   decoration: const InputDecoration(
                //     labelText: 'Category id',
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                InkWell(
                  onTap: (){
                    uploadImage();
                  },
                  child: Container(
                    // height: 130,
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(40),
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
                    String categoryName = _categoryController.text.trim();
                    if (categoryName.isNotEmpty) {
                      updateCatDetails(categoryName);
                      _categoryController.clear();
                    }
                  },
                  child: const Text('Update Category'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
