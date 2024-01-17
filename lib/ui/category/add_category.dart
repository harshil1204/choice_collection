
import 'package:choice_collection/config/config.dart';
import 'package:choice_collection/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
class AddCat extends StatefulWidget {
  const AddCat({Key? key}) : super(key: key);
  @override
  State<AddCat> createState() => _AddCatState();
}

class _AddCatState extends State<AddCat> {
  final TextEditingController _categoryIdController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String? imageUrl;

  void addCategoryToFirestore(String categoryName) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Categories').add({
        'name': categoryName,
        'url':imageUrl,
        'time': DateTime.now(),
        // Add more fields related to the category if needed
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
      const SnackBar(content: Text("Category added successfully"),);
      print('Category added successfully');
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
        title: const Text("Add Category"),
      ),
      body: Stack(
        children: [
          Opacity(
              opacity: MyConfig.opacity,
              child: Image.asset(MyConfig.bg,fit: BoxFit.fill,height: double.infinity ,width: double.infinity )),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      addCategoryToFirestore(categoryName);
                      _categoryController.clear();
                    }
                  },
                  child: const Text('Add Category'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
