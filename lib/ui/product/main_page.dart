
import 'package:cached_network_image/cached_network_image.dart';
import 'package:choice_collection/config/config.dart';
import 'package:choice_collection/resources/color.dart';
import 'package:choice_collection/ui/product/productList.dart';
import 'package:choice_collection/widget/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainPageProduct extends StatefulWidget {
  const MainPageProduct({Key? key}) : super(key: key);

  @override
  State<MainPageProduct> createState() => _MainPageProductState();
}

class _MainPageProductState extends State<MainPageProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
        color: AppColor.white
        ),
        title: const CommonText.bold("Category List",color: AppColor.white,size: 18,),
        backgroundColor: AppColor.primary,
      ),
      body:  FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('Categories').get(),
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
                              return InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductList(cat_id: snapshot.data!.docs[index].id.toString()),));
                                },
                                child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
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
