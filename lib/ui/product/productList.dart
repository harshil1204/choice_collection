
import 'package:cached_network_image/cached_network_image.dart';
import 'package:choice_collection/config/config.dart';
import 'package:choice_collection/resources/color.dart';
import 'package:choice_collection/ui/product/update_product.dart';
import 'package:choice_collection/widget/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../order/add_order.dart';
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
      //Navigator.pop(context); // Close the dialog after deletion
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting product: $e');
      }
    }
  }
  
  DateTime? picked;
  DateTime? startOfDay;
  DateTime? endOfDay;
  final TextEditingController _tab1=TextEditingController();
  final TextEditingController _tab2=TextEditingController();

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
     if (kDebugMode) {
       print(picked.toString());
     }
  }

  String name="";
  List search=[];
  List filterDate=[];

  @override
  Widget build(BuildContext context) {
    print(widget.cat_id);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title:  CommonText.bold("Product List (${picked?.day ?? ""}-${picked?.month ?? ""})",color: AppColor.white,size: 15,),
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
          }, icon: const Icon(Icons.date_range)),
          InkWell(
              onTap: (){
                picked=null;
                setState(() {
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 3.0),
                child: Icon(Icons.refresh),
              ))
          ],
          bottom:  TabBar(
              onTap: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppColor.white,
              labelStyle: const TextStyle(
                  fontSize: 15,color: AppColor.white,
                  fontWeight: FontWeight.bold
              ),
              tabs:const [
                Tab(text: "All Stock",),
                Tab(text: "In order",),
              ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream:FirebaseFirestore.instance.collection('Products')
                    .where('id', isEqualTo: widget.cat_id)
                    // .where('inStock',isEqualTo: "true")
                    .orderBy("time",descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
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
                                child: Row(
                                  children: [
                                    const Icon(Icons.search,color: AppColor.primary),
                                    const Gap(7),
                                    Expanded(
                                      child: TextField(
                                        controller: _tab1,
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
                                            search=snapshot.data!.docs.where((element) =>
                                              element['name'].toString().toLowerCase().contains(name.toLowerCase())).toList();
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
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 0.85,crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 12),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var data = snapshot.data!.docs[index];
                                    return Stack(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                AddOrder(pid: data.id.toString(),name: data['name'].toString(),)));                                          },
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
                                                // Expanded(
                                                //     child: (rod==null)?const CommonText(""):CommonText.semiBold("returnDate: ${rod.day}-${rod.month}-${rod.year}" ?? "",color: AppColor.black,size: 11,))
                                              ],
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(onPressed: (){
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const CommonText.semiBold("Are you sure to delete ? ",color:AppColor.primary,size:20),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        },child: const CommonText.bold("Cancel",color:AppColor.primary,size:16)
                                                    ),ElevatedButton(
                                                        onPressed: (){
                                                          deleteProduct(snapshot.data!.docs[index].id,snapshot.data!.docs[index]['url']);
                                                          Navigator.pop(context);
                                                        }
                                                        , child: const CommonText.bold("Delete",color:AppColor.primary,size:16)
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          }, icon: const Icon(Icons.delete,color: AppColor.primary,)),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: IconButton(onPressed: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                UpdateProduct(snapShot: snapshot.data!.docs[index],id: snapshot.data!.docs[index].id),));
                                          }, icon: const Icon(Icons.edit,color: AppColor.primary,)),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              if(search.isNotEmpty && name.isNotEmpty)
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 0.85,crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 14),
                                  itemCount:search.length,
                                  itemBuilder: (context, index) {
                                    var data = search[index];
                                    return Stack(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                AddOrder(pid: data.id.toString(),name: data['name'].toString(),)));                                          },
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
                                                // Expanded(
                                                //     child: (rod==null)?const CommonText(""):CommonText.semiBold("${rod.day}-${rod.month}-${rod.year}" ?? "",color: AppColor.black,size: 11,))
                                              ],
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(onPressed: (){
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const CommonText.semiBold("Are you sure to delete ? ",color:AppColor.primary,size:20),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        },child: const CommonText.bold("Cancel",color:AppColor.primary,size:16)
                                                    ),ElevatedButton(
                                                        onPressed: (){
                                                          deleteProduct(snapshot.data!.docs[index].id,snapshot.data!.docs[index]['url']);
                                                          Navigator.pop(context);
                                                        }
                                                        , child: const CommonText.bold("Delete",color:AppColor.primary,size:16)
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          }, icon: const Icon(Icons.delete,color: AppColor.primary,)),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: IconButton(onPressed: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                UpdateProduct(snapShot: snapshot.data!.docs[index],id: snapshot.data!.docs[index].id),));
                                          }, icon: const Icon(Icons.edit,color: AppColor.primary,)),
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
                stream: FirebaseFirestore.instance.collection('Products')
                    .where('id', isEqualTo: widget.cat_id)
                    .where('inStock',isEqualTo: "false")
                    .orderBy("time",descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.hasData) {
                    if (kDebugMode) {
                      print(snapshot.data!.docs);
                    }
                    if(picked == null){
                      filterDate= snapshot.data!.docs;
                    }
                    else{
                      filterDate = snapshot.data!.docs
                          .where((element) =>
                          (element['order'] as List<dynamic>)
                              .any((element1) => element1['rDate'].toDate() == picked!))
                          .toList();
                    }
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
                                        controller: _tab2,
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
                                            search=snapshot.data!.docs.where((element) =>
                                                element['name'].toString().toLowerCase().contains(name.toLowerCase())).toList();
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
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 0.85,crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 14),
                                  itemCount: picked==null ? snapshot.data!.docs.length : filterDate.length,
                                  itemBuilder: (context, index) {
                                    var data = filterDate[index];
                                    // var data = snapshot.data!.docs[index];
                                    // DateTime? rod= (data['returnDate'] == null)?null:data['returnDate'].toDate();
                                    return Stack(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                AddOrder(pid: data.id.toString(),name: data['name'].toString(),)));
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
                                                // Expanded(
                                                //     child: (rod==null)?const CommonText(""):CommonText.semiBold("returnDate: ${rod.day}-${rod.month}-${rod.year}" ?? "",color: AppColor.black,size: 11,))
                                              ],
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(onPressed: (){
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const CommonText.semiBold("Are you sure to delete ? ",color:AppColor.primary,size:20),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        },child: const CommonText.bold("Cancel",color:AppColor.primary,size:16)
                                                    ),ElevatedButton(
                                                        onPressed: (){
                                                          deleteProduct(snapshot.data!.docs[index].id,snapshot.data!.docs[index]['url']);
                                                          Navigator.pop(context);
                                                        }
                                                        , child: const CommonText.bold("Delete",color:AppColor.primary,size:16)
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          }, icon: const Icon(Icons.delete,color: AppColor.primary)),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: IconButton(onPressed: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                UpdateProduct(snapShot: snapshot.data!.docs[index],id: snapshot.data!.docs[index].id),));
                                          }, icon: const Icon(Icons.edit,color: AppColor.primary,)),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              if(search.isNotEmpty && name.isNotEmpty)
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 0.85,crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 14),
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
                                                  // Expanded(
                                                  //     child: (rod==null)?const CommonText(""):CommonText.semiBold("returnDate: ${rod.day}-${rod.month}-${rod.year}" ?? "",color: AppColor.black,size: 11,))
                                                ],
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(onPressed: (){
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const CommonText.semiBold("Are you sure to delete ? ",color:AppColor.primary,size:20),
                                                      actions: [
                                                        ElevatedButton(
                                                            onPressed: (){
                                                              Navigator.pop(context);
                                                            },child: const CommonText.bold("Cancel",color:AppColor.primary,size:16)
                                                        ),ElevatedButton(
                                                            onPressed: (){
                                                              deleteProduct(snapshot.data!.docs[index].id,snapshot.data!.docs[index]['url']);
                                                              Navigator.pop(context);
                                                            }
                                                            , child: const CommonText.bold("Delete",color:AppColor.primary,size:16)
                                                        )
                                                      ],
                                                    );
                                                  },
                                              );
                                            }, icon: const Icon(Icons.delete,color: AppColor.primary)),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: IconButton(onPressed: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                  UpdateProduct(snapShot: snapshot.data!.docs[index],id: snapshot.data!.docs[index].id),));
                                            }, icon: const Icon(Icons.edit,color: AppColor.primary)),
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
