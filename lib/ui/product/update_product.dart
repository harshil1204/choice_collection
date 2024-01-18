
import 'package:choice_collection/config/config.dart';
import 'package:choice_collection/homepage.dart';
import 'package:choice_collection/resources/color.dart';
import 'package:choice_collection/ui/product/main_page.dart';
import 'package:choice_collection/widget/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class UpdateProduct extends StatefulWidget {
  dynamic snapShot;
  String id;

  UpdateProduct({Key? key,required this.snapShot,required this.id}) : super(key: key);

  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescController = TextEditingController();

  String? imageUrl;
  DateTime? picked;
  DateTime? picked1;

  String groupValue="true";

  @override
  void initState() {
    _productNameController.text=widget.snapShot['name'];
    _productDescController.text=widget.snapShot['description'];
    groupValue = widget.snapShot['inStock'];
    imageUrl=widget.snapShot['url'];
    picked =(widget.snapShot['rentDate'] == null)
        ? DateTime.now()
        : widget.snapShot['rentDate'].toDate();
    picked1 =(widget.snapShot['returnDate'] == null)
        ? DateTime.now()
        : widget.snapShot['returnDate'].toDate();
    if(groupValue == "true"){
      picked = null;
      picked1 = null;
    }
    super.initState();
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

  Future<void> selectDate(BuildContext context) async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    setState(() {

    });
    print(picked);
    // if (picked != null && picked != context.read<SelectDateProvider>().selectedDate) {
    //   context.read<SelectDateProvider>().updateSelectedDate(picked);
    // }
  }

  Future<void> selectDate1(BuildContext context) async {
    picked1 = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    setState(() {

    });
    // if (picked != null && picked != context.read<SelectDateProvider>().selectedDate) {
    //   context.read<SelectDateProvider>().updateSelectedDate(picked);
    // }
  }

  void updateProductDetails(String productName,String desc) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Products').doc(widget.id).update({
        'name': productName,
        'url': imageUrl,
        'description':desc,
        'rentDate':picked,
        'returnDate':picked1,
        'inStock':groupValue,
      });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(),),(route) => false,);
      print('Product details updated successfully');
    } catch (e) {
      print('Error updating product details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CommonText.bold("Update the product details",color: AppColor.white,size:17),
        backgroundColor: AppColor.primary,
        iconTheme: const IconThemeData(
            color: AppColor.white
        ),
      ),
      body: Stack(
        children: [
          Opacity(
              opacity: MyConfig.opacity,
              child: Image.asset(MyConfig.bg,fit: BoxFit.cover,height: double.infinity,width: double.infinity )),
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
                  const Align( alignment: Alignment.centerLeft,child: CommonText.semiBold("order Status :",size: 16,color: AppColor.black,)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColor.black,width: 1)
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CommonText.semiBold("Available : ",color: AppColor.black,size: 14,),
                            Radio(
                              value: "true",
                              groupValue: groupValue,
                              onChanged: (value) {
                                setState(() {
                                    picked = null;
                                    picked1 = null;
                                  groupValue = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CommonText.semiBold("In order : ",color: AppColor.black,size: 14,),
                            Radio(
                              value: "false",
                              groupValue: groupValue,
                              onChanged: (value) {
                                setState(() {
                                  groupValue = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12,),
                  TextField(
                    maxLines: 2,
                    controller: _productDescController,
                    decoration: const InputDecoration(
                      labelText: 'Product Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  InkWell(
                    onTap: (){
                      selectDate(context);
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.purple.withOpacity(.7),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 4,),
                      child:   Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const CommonText.bold("Select date for rent: ",size: 15),
                          (picked==null)
                              ? const Icon(Icons.date_range,size: 30,)
                              :CommonText("${picked!.day.toString()}-${picked!.month.toString()}-${picked!.year.toString()}",maxLines: 3,),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  InkWell(
                    onTap: (){
                      selectDate1(context);
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.purple.withOpacity(.7),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 4,),
                      child:   Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const CommonText.bold("Select return order date: ",size: 15),
                          (picked1==null)
                              ? const Icon(Icons.date_range,size: 30,)
                              :CommonText("${picked1!.day.toString()}-${picked1!.month.toString()}-${picked1!.year.toString()}",maxLines: 3,),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      uploadImage();
                    },
                    child: Container(
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
                      String productName = _productNameController.text.trim();

                      String productDesc = _productDescController.text.trim();
                      //uploadImage();
                      if (productName.isNotEmpty &&   imageUrl!.isNotEmpty ) {
                        updateProductDetails(productName,productDesc);
                        _productNameController.clear();
                        _productDescController.clear();
                        imageUrl="";
                      }
                    },
                    child: const Text('Update Category'),
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
