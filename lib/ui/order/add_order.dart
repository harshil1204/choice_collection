import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../resources/color.dart';
import '../../widget/text.dart';

class AddOrder extends StatefulWidget {
  String pid;
  String name;
  AddOrder({super.key,required this.pid,required this.name});

  @override
  State<AddOrder> createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  final TextEditingController _productDescController = TextEditingController();

  DateTime? picked;
  DateTime? picked1;

  String groupValue= "true";

  void addOrderToFirestore(String desc,BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    //Timestamp timestamp = Timestamp.fromDate(picked!);
    List<Map<String, dynamic>> b=[{
      'description':desc,
      'rDate':picked,
      'returnDate':picked1,
      'time': DateTime.now(),
    }];

    try {
      await firestore.collection('Products').doc(widget.pid).update({
        // 'id':widget.catId,
        'order': FieldValue.arrayUnion(b),
        // 'description':desc,
        // 'rentDate':picked,
        // 'returnDate':picked1,
        // 'time': DateTime.now(),
      });
      Navigator.pop(context);
      print('Order added successfully');
    } catch (e) {
      print('Error adding Order: $e');
    }
  }

  void deleteOrder(b) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> newList = [
      b
    ];
    print(b);
    try {
      await firestore.collection('Products').doc(widget.pid).update({
        'order': FieldValue.arrayRemove(newList),
      });
      // Navigator.pop(context);
      print('Order added successfully');
    } catch (e) {
      print('Error adding Order: $e');
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
    print(picked1);

  }

  String convertDate(var time){
    return "${time.day}-${time.month}-${time.year}";
  }

  final FocusNode _focusNode = FocusNode();
 @override
  void dispose() {
   _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print(widget.pid);
    return Scaffold(
      appBar: AppBar(
        title: CommonText.bold(widget.name.toString(),color: AppColor.white,size: 18,),
        backgroundColor: AppColor.primary,
        iconTheme: const IconThemeData(
            color: AppColor.white
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: (){
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return Builder(
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 6,
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 40,),
                                    const CommonText.semiBold("Order Details : ",color: AppColor.primary,size: 18,),
                                    const SizedBox(height: 20,),
                                    TextField(
                                      focusNode: _focusNode,
                                      maxLines: 3,
                                      controller: _productDescController,
                                      decoration: const InputDecoration(
                                        labelText: 'Product Description',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    InkWell(
                                      onTap: ()async{
                                        _focusNode.unfocus();
                                        await selectDate(context);
                                        setState(() {
                                        });                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: AppColor.purple.withOpacity(.7),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const CommonText.bold("Select date for rent: ",size: 15),
                                            (picked==null)
                                                ?const Icon(Icons.date_range,size: 30,)
                                                :CommonText("${picked!.day.toString()}-${picked!.month.toString()}-${picked!.year.toString()}",maxLines: 3,),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    InkWell(
                                      onTap: ()async{
                                        _focusNode.unfocus();
                                       await selectDate1(context);
                                        setState(() {
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: AppColor.purple.withOpacity(.7),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child:  Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const CommonText.bold("Select return order date: ",size: 15),
                                            (picked1==null)
                                                ?const Icon(Icons.date_range,size: 30,)
                                                :CommonText("${picked1!.day.toString()}-${picked1!.month.toString()}-${picked1!.year.toString()}",maxLines: 3,),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        String productDesc = _productDescController.text.trim();
                                        if (productDesc.isNotEmpty && picked != null && picked1 != null) {
                                          addOrderToFirestore(productDesc,context);
                                          picked=null;
                                          picked1=null;
                                          setState(() {

                                          });
                                          _productDescController.clear();
                                        }
                                        else{
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: CommonText.semiBold("please add description and date"))
                                          );
                                        }
                                      },
                                      child: const Text('Add Order'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    );
                  },);
                },
              );
            },
            icon: const Icon(Icons.add,color: AppColor.primary,),
            label:const CommonText.semiBold("Add Order",color: AppColor.primary),
          ),
        ],
      ),
      body: Stack(
        children: [
          Opacity(
              opacity: MyConfig.opacity,
              child: Image.asset(MyConfig.bg,fit: BoxFit.fill,height: double.infinity,width: double.infinity )),
          StreamBuilder(
              stream:FirebaseFirestore.instance.collection('Products').doc(widget.pid).snapshots(),
             builder: (context, snapshot) {
                if (snapshot.hasData){
                  return ListView.builder(
                    itemCount: snapshot.data!['order'].length,
                      itemBuilder: (context, index) {
                        var data=snapshot.data!['order'][index];
                        return Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(8),
                              border:Border.all(width: 1,color: AppColor.primary)
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              InkWell(
                                  onTap: () async{
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
                                                  deleteOrder(data);
                                                  Navigator.pop(context);
                                                }
                                                , child: const CommonText.bold("Delete",color:AppColor.primary,size:16)
                                            )
                                          ],
                                        );
                                      },
                                    );

                                  },
                                  child: const Icon(Icons.delete,color: AppColor.primary,)),
                              Row(
                                children: [
                                  const SizedBox(width: 120,child: CommonText.semiBold("description : ",color: AppColor.primary,size: 15,)),
                                  Expanded(child: CommonText.semiBold(data!['description'].toString(),color: AppColor.primary,size: 15,maxLines: 3,)),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 120,child: CommonText.semiBold("Rent date : ",color: AppColor.primary,size: 15,)),
                                  CommonText.semiBold(convertDate(data!['rDate'].toDate()),color: AppColor.primary,size: 15,),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 120,child: CommonText.semiBold("Return date : ",color: AppColor.primary,size: 15,)),
                                  CommonText.semiBold(convertDate(data!['returnDate'].toDate()),color: AppColor.primary,size: 15,),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                  );
                }
                else {
                  return const Center(child: CircularProgressIndicator(color: Colors.grey,));
                }
             },
          ),


        ],
      ),
    );
  }
}
