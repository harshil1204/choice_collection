
import 'package:cached_network_image/cached_network_image.dart';
import 'package:choice_collection/config/config.dart';
import 'package:choice_collection/provider/dateprovider.dart';
import 'package:choice_collection/resources/color.dart';
import 'package:choice_collection/ui/product/update_product.dart';
import 'package:choice_collection/widget/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

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
      if (kDebugMode) {
        print('Product deleted successfully');
      }
      Navigator.pop(context); // Close the dialog after deletion
    } catch (e) {
      print('Error deleting product: $e');
    }
  }
  
  DateTime? picked;
  DateTime? startOfDay;
  DateTime? endOfDay;

  Future<void> _selectDate(BuildContext context) async {
    picked = await showDatePicker(
      context: context,
      initialDate:(picked==null)?DateTime.now(): picked as DateTime,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
     // startOfDay = DateTime(picked!.year, picked!.month, picked!.day);
     // endOfDay = startOfDay!.add(const Duration(days: 1));
        setState(() {

        });


     print(picked);
    // if (picked != null && picked != context.read<SelectDateProvider>().selectedDate) {
    //   context.read<SelectDateProvider>().updateSelectedDate(picked!);
    // }
  }

  String name="";
  List search=[];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title:  CommonText.bold("Product List   (${picked?.day ?? ""} -${picked?.month ?? ""})",color: AppColor.white,size: 16,),
          backgroundColor: AppColor.primary,
          iconTheme: const IconThemeData(
              color: AppColor.white
          ),
          actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct(catId: widget.cat_id)));
            }, icon: const Icon(Icons.add)
            ),
          IconButton(onPressed: (){
            _selectDate(context);
          }, icon: const Icon(Icons.date_range))
          ],
          bottom: const TabBar(
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppColor.white,
              labelStyle: TextStyle(
                  fontSize: 15,color: AppColor.white,
                  fontWeight: FontWeight.bold
              ),
              tabs:[
                Tab(text: "In Stock",),
                Tab(text: "Out Stock",),
              ]
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream:(picked!=null)
                    ?FirebaseFirestore.instance.collection('Products')
                    .where('id', isEqualTo: widget.cat_id)
                    .where('inStock',isEqualTo: "true")
                    .where('rentDate', isEqualTo: picked)
                    //.where('rentDate', isLessThan: endOfDay)
                    .orderBy("time",descending: true)
                    .snapshots()
                    : FirebaseFirestore.instance.collection('Products')
                    .where('id', isEqualTo: widget.cat_id)
                    .where('inStock',isEqualTo: "true")
                    .orderBy("time",descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data!.docs);
                    return Stack(
                      children: [
                        Opacity(
                            opacity: MyConfig.opacity,
                            child: Image.asset(MyConfig.bg,fit: BoxFit.fill,height: double.infinity,width: double.infinity, )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Gap( 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 3),
                                decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColor.grey,
                                        blurRadius: 0.5,
                                      )
                                    ]
                                ),
                                child:  Row(
                                  children: [
                                    const Icon(Icons.search,color: AppColor.primary),
                                    const Gap(7),
                                    Expanded(
                                      child: TextField(
                                        cursorHeight: 25,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Search"
                                        ),
                                        onChanged: (value) {
                                          if(value.isEmpty){
                                            FocusScope.of(context).unfocus();
                                          }
                                          setState(() {
                                            name=value;
                                            search=snapshot.data!.docs.where((element) => element['name'].toString().toLowerCase().startsWith(name.toLowerCase())).toList();
                                            print("heloooo ::::${search.toString()}");
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              if(search.isEmpty && name.isEmpty || name == "")
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
                              ),
                              if(search.isNotEmpty && name.isNotEmpty)
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 0.8,crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 14),
                                  itemCount:search.length,
                                  itemBuilder: (context, index) {
                                    var data = search[index];
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
                  }
                  else {
                    return const Center(child: CircularProgressIndicator(color: Colors.grey,));
                  }
                }),
            StreamBuilder<QuerySnapshot>(
                stream:(picked!=null)
                    ?FirebaseFirestore.instance.collection('Products')
                    .where('id', isEqualTo: widget.cat_id)
                    .where('inStock',isEqualTo: "false")
                    .where('rentDate', isEqualTo: picked)
                //.where('rentDate', isLessThan: endOfDay)
                    .orderBy("time",descending: true)
                    .snapshots()
                    : FirebaseFirestore.instance.collection('Products')
                    .where('id', isEqualTo: widget.cat_id)
                    .where('inStock',isEqualTo: "false")
                    .orderBy("time",descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data!.docs);
                    return Stack(
                      children: [
                        Opacity(
                            opacity: MyConfig.opacity,
                            child: Image.asset(MyConfig.bg,fit: BoxFit.fill,height: double.infinity, width: double.infinity,)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Gap( 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 3),
                                decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColor.grey,
                                        blurRadius: 0.5,
                                      )
                                    ]
                                ),
                                child:  Row(
                                  children: [
                                    const Icon(Icons.search,color: AppColor.primary),
                                    const Gap(7),
                                    Expanded(
                                      child: TextField(
                                        cursorHeight: 25,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Search"
                                        ),
                                        onChanged: (value) {
                                          if(value.isEmpty){
                                            FocusScope.of(context).unfocus();
                                          }
                                          setState(() {
                                            name=value;
                                            search=snapshot.data!.docs.where((element) => element['name'].toString().toLowerCase().startsWith(name.toLowerCase())).toList();
                                            print("heloooo ::::${search.toString()}");
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              if(search.isEmpty && name.isEmpty || name == "")
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
                              ),
                              if(search.isNotEmpty && name.isNotEmpty)
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 0.8,crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 14),
                                    itemCount: search.length,
                                    itemBuilder: (context, index) {
                                      var data = search[index];
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
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  else {
                    return const Center(child: CircularProgressIndicator(color: Colors.grey,));
                  }
                }),
          ],
        ),
      ),
    );
  }
}
