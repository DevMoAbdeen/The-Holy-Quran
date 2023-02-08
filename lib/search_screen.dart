import 'package:flutter/material.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/quran_page.dart';
import 'constants.dart';

class SearchScreen extends StatefulWidget {
  static const id = "SearchScreen";

  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List resultSearch = [];
  String printInText = "";

  void result(String search) {
    resultSearch.clear();
    if (search.length > 1) {
      for (int i = 0; i < MyApp.allQuranAyats.length; i++) {
        var aya = MyApp.allQuranAyats[i];
        if (aya["aya_text_emlaey"].toString().contains(search)) {
          resultSearch.add({
            "sura_name_ar": aya["sura_name_ar"],
            "page": aya["page"],
            "aya_no": aya["aya_no"],
            "aya_text": aya["aya_text"],
          });
        }
      }
      if (resultSearch.isEmpty) {
        printInText = "!! لا يوجد نتائج للبحث, تأكد أنك كتبت الآية بشكل صحيح";
      } else {
        printInText = "تم العثور على ${resultSearch.length} نتيجة ";
      }
    } else if (search.length == 1) {
      printInText = "!! أكتب أكثر من حرف للبحث";
    } else {
      printInText = "";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search"),),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(8),
            child: TextField(
              textDirection: TextDirection.rtl,
              onChanged: (value) {
                print("${value}");
                result(value);
              },
              decoration: kTextFieldDecoration.copyWith(hintText: "بحث ..."),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$printInText",
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: resultSearch.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      // بنقص واحد لانو الpageView يبدأ من صفر والصفحات ترتيبها عادي من 1
                      QuranPage.pageNumber = resultSearch[index]["page"] - 1;
                      Navigator.pushNamed(context, QuranPage.id);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.black12,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${resultSearch[index]["page"]} صفحة ",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "سُورَةُ ${resultSearch[index]["sura_name_ar"]}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "HafsSmart",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          RichText(
                            textDirection: TextDirection.rtl,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'HafsSmart',
                                color: Colors.black,
                                fontSize: 24,
                                height: 2,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                              children: [
                                TextSpan(
                                  text: resultSearch[index]["aya_text"].substring(0, resultSearch[index]["aya_text"].length - 3),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: "HafsSmart",
                                  ),
                                ),
                                WidgetSpan(
                                  baseline: TextBaseline.alphabetic,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        opacity: 0.5,
                                        image: AssetImage('images/end.png'),
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${resultSearch[index]['aya_no']}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                // Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
