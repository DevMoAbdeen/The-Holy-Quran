import 'package:flutter/material.dart';
import 'package:holy_quran/quran_page.dart';

import 'main.dart';

class AllSurahsPage extends StatefulWidget {
  static const id = "AllSurahsPage";

  const AllSurahsPage({Key? key}) : super(key: key);

  @override
  State<AllSurahsPage> createState() => _AllSurahsPageState();
}

class _AllSurahsPageState extends State<AllSurahsPage> {
  List allSurahs = [];
  String printInText = "";

  void allQuranSurahs() {
    // قيمهم 1 مش 0 عشان اول رقم بالloop 1 مش 0
    int ayatNumber = 1;
    int pageNumber = 1;
      for (int i = 1; i < MyApp.allQuranAyats.length - 1; i++) {
        ayatNumber++;
        var previousAya = MyApp.allQuranAyats[i - 1];
        var currentAya = MyApp.allQuranAyats[i];
        var nextAya = MyApp.allQuranAyats[i + 1];
        if(previousAya["sura_name_ar"].toString() != currentAya["sura_name_ar"].toString()) {
          pageNumber = currentAya["page"];
        }
        if (currentAya["sura_name_ar"].toString() != nextAya["sura_name_ar"].toString()) {
          allSurahs.add({
            "sura_name_ar": currentAya["sura_name_ar"],
            "page": pageNumber,
            "ayatNumber": ayatNumber,
          });
          ayatNumber = 0;
        }
      }
      // ضفت سورة الناس يدويا لانو الشرط بفحص الآية مع اللي بعدها وبضيف الآية الحالية, فمش هيضيف آخر سورة لانو مش هيتحقق شرطها
    allSurahs.add({
      "sura_name_ar": MyApp.allQuranAyats[MyApp.allQuranAyats.length - 1]["sura_name_ar"],
      "page": MyApp.allQuranAyats[MyApp.allQuranAyats.length - 1]["page"],
      "ayatNumber": 6,
    });
    setState(() {});
  }

  @override
  void initState() {
    allQuranSurahs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Surahs"),
      ),
      body: ListView.builder(
          itemCount: allSurahs.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // بنقص واحد لانو الpageView يبدأ من صفر والصفحات ترتيبها عادي من 1
                QuranPage.pageNumber = allSurahs[index]["page"] - 1;
                Navigator.pushNamed(context, QuranPage.id);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                color: Colors.black12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${allSurahs[index]["page"]} صفحة ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${allSurahs[index]["ayatNumber"]} :آياتها ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      " سُورَةُ ${allSurahs[index]["sura_name_ar"]}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${index + 1}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
