import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holy_quran/all_surahs_screen.dart';
import 'package:holy_quran/quran_page.dart';
import 'package:holy_quran/search_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  String temp = await rootBundle.loadString('assets/hafs_smart_v8.json');
  MyApp.allQuranAyats = jsonDecode(temp) as List;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // عرفت الarray هنا أعطيتها البيانات داخل الmain عشان قبل ما يفتح التطبيق تكون البيانات موجودة, وخليتها static عشان أصلها من أي مكان عشان مرجعش الjson الا مرة واحدة
  static List<dynamic> allQuranAyats = [];

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: QuranPage.id,
      routes: {
        QuranPage.id: (context) => QuranPage(),
        SearchScreen.id: (context) => SearchScreen(),
        AllSurahsPage.id: (context) => AllSurahsPage(),
      },
    );
  }
}
