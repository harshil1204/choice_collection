
import 'package:cached_network_image/cached_network_image.dart';
import 'package:choice_collection/config/config.dart';
import 'package:choice_collection/resources/color.dart';
import 'package:choice_collection/ui/product/update_product.dart';
import 'package:choice_collection/widget/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'add_product.dart';


class ProductList extends StatefulWidget {
  String cat_id;
  ProductList({Key? key,required this.cat_id}) : super(key: key);

  @override
  State<ProductList> createState() => _ProductListState();
}



class _ProductListState extends State<ProductList> {

  void deleteProduct(String productId,String url) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('Products').doc(productId).delete();
      await FirebaseStorage.instance.refFromURL(url).delete().then((value) => print("delete"));
      print('Product deleted successfully');
      Navigator.pop(context); // Close the dialog after deletion
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CommonText.bold("Product List",color: AppColor.white,size: 18,),
        backgroundColor: AppColor.primary,
        iconTheme: IconThemeData(
            color: AppColor.white
        ),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct(catId: widget.cat_id)));
          }, icon: Icon(Icons.add)
          )
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('Products').where('id', isEqualTo: widget.cat_id).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print(snapshot.data!.docs);
              return Stack(
                children: [
                  Opacity(
                      opacity: MyConfig.opacity,
                      child: Image.asset(MyConfig.bg,fit: BoxFit.fill,height: double.infinity )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 9,
                        ),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 0.8,crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 14),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data!.docs[index];
                              return Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  UpdateProduct(snapShot: snapshot.data!.docs[index],id: snapshot.data!.docs[index].id),));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(/*border: Border.all(width: 1, color: Colors.black), */borderRadius: BorderRadius.circular(9)),
                                      child: Column(
                                        children: [
                                          Container(
                                              height: 170,
                                              width: double.infinity,
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20)
                                              ),
                                              child:CachedNetworkImage(imageUrl: data['url'],
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) => Image.asset("assets/images/loading.png",width: double.infinity,
                                                  fit: BoxFit.fill,),
                                              )),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                //color: Colors.grey,
                                                  borderRadius: BorderRadius.circular(9)
                                              ),
                                              width: double.infinity,
                                              child: Center(
                                                child: Text(
                                                  data['name'].toString() ?? '',
                                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(onPressed: (){
                                      deleteProduct(snapshot.data!.docs[index].id,snapshot.data!.docs[index]['url']);
                                    }, icon: const Icon(Icons.delete)),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(child: CircularProgressIndicator(color: Colors.grey,));
            }
          }),
    );
  }
}
