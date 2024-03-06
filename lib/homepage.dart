import 'package:choice_collection/resources/color.dart';
import 'package:choice_collection/ui/category/categoryList.dart';
import 'package:choice_collection/ui/drawer/drawer.dart';
import 'package:choice_collection/ui/product/main_page.dart';
import 'package:choice_collection/widget/text.dart';
import 'package:flutter/material.dart';

import 'config/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Container(
        //     clipBehavior: Clip.hardEdge,
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(30)
        //     ),
        //     child: Image.asset("assets/images/logo.png"),
        //   ),
        // ),
        iconTheme: const IconThemeData(color:AppColor.white ),
        title: const CommonText.bold("Choice Wedding Collection",size: 17),
        backgroundColor: AppColor.primary,
      ),
      drawer: const CustomDrawer(),
      body:  Stack(
        children: [
          Opacity(
              opacity: MyConfig.opacity,
              child: Image.asset(MyConfig.bg,fit: BoxFit.fill,height: double.infinity )),
          Center(
            child: Padding(
              padding:  const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryList(),));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                      decoration: BoxDecoration(
                          color:AppColor.grey,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Center(child:  Text("Add Category",
                        style: TextStyle(fontSize: 17,color: Colors.white),
                      )),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MainPageProduct(),));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                      decoration: BoxDecoration(
                          color: AppColor.grey,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Center(child:  Text("Add Product",
                        style: TextStyle(fontSize: 17,color: Colors.white),
                      )),
                    ),
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
