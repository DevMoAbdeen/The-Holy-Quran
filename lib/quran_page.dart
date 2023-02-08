import 'package:flutter/material.dart';
import 'package:holy_quran/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all_surahs_screen.dart';
import 'constants.dart';
import 'main.dart';

class QuranPage extends StatefulWidget {
  static const id = "QuranPage";

  // قيمة static عشان أصلها من واجهة الsearch ولو ضغطت على أي اية من البحث أغير قيمتها وأنتقل للصفحة اللي فيها الآية اللي ضغطت عليها
  static int pageNumber = -1;

  @override
  QuranPageState createState() => QuranPageState();
}

class QuranPageState extends State<QuranPage> {
  late final Future<SharedPreferences> pref = SharedPreferences.getInstance();

  // رقم الصفحة اللي عليها علامة
  int savePage = -1;

  late String surahName = "";
  late int juz = 1;
  List ayats = [];
  String startPage = "";

  // رقم الصفحة اللي هيكتبه المستخدم للإنتقال للصفحة
  late int writePage;

  int currentPage = QuranPage.pageNumber == -1 ? 0 : QuranPage.pageNumber;
  late PageController pageController;

  // بكتب البسملة بالبداية لو السورة ما كانت الفاتحة أو التوبة
  String basmala(String surahName) {
    return (surahName != "الفَاتِحة" && surahName != "التوبَة")
        ? "\n﻿بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\n"
        : "\n";
  }

  String showAya(Map aya) {
    // لو بداية السورة بكتب اسم السورة والبسملة
    if (aya["aya_no"] == 1) {
      // أول سطر بالصفحة لو كان بداية سورة جديدة بطبع سطر فاضي, هاد الشرط عشان أمنع السطر الفاضي
      if (startPage == "") {
        return "${"\n سُورَةُ " + aya["sura_name_ar"]}" +
            basmala(aya["sura_name_ar"]) +
            aya["aya_text"].substring(0, aya["aya_text"].length - 3);
      } else {
        startPage = "";
        return aya["aya_text"].substring(0, aya["aya_text"].length - 3);
      }
    } else {
      // لو مش بداية السورة بس برجع الآية وبقص آخرها عشان مطبعش رقم الآية
      return aya["aya_text"].substring(0, aya["aya_text"].length - 3);
    }
  }

  void getPageData(Map aya) {
    surahName = aya["sura_name_ar"];
    juz = aya["jozz"];
    // بكتب اسم السورة والبسملة لو كانت أول اية بالصفحة هي اول اية بالسورة
    startPage = aya["aya_no"] == 1
        ? "سُورَةُ ${aya["sura_name_ar"]}${basmala(aya["sura_name_ar"])}"
        : "";
  }

  @override
  void initState() {
    pageController = PageController(initialPage: currentPage, viewportFraction: 1.0);

    // برجع رقم الصفحة اللي عليها علامة عشان أغير لون الcontainer للأحمر
    pref.then((pref) {
      setState(() {
        // داخل setState عشان أول ما يفتح التطبيق لو كانت أول صفحة هي اللي عليها علامة مش هيتغير لونها
        // لانو لما يجيب قيمتها بتكون الواجهة مبنية
        savePage = pref.getInt("currentPage") ?? -1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // برجع قيمتها ل1- عشان لما أرجع للصفحة الرئيسية يعرض الثلاث نقط اللي فيهم menuItems
          QuranPage.pageNumber = -1;
          return true;
        },
        child: Scaffold(
          appBar: QuranPage.pageNumber != -1
              ? AppBar(title: const Text("Holy Quran"))
              : AppBar(
                  title: const Text("Holy Quran"),
                  actions: [
                    PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        _createPopupMenuItem(1, "البحث عن آية", Icons.search),
                        _createPopupMenuItem(2, "الفهرس", Icons.list),
                        _createPopupMenuItem(3, "تحديد صفحة", Icons.numbers),
                        _createPopupMenuItem(4, "حفظ علامة", Icons.bookmark_add),
                        _createPopupMenuItem(5, "الإنتقال إلى العلامة", Icons.bookmark),
                        _createPopupMenuItem(6, "حذف العلامة", Icons.bookmark_remove),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 1:{
                              Navigator.pushNamed(context, SearchScreen.id);
                            }
                            break;

                          case 2:{
                              Navigator.pushNamed(context, AllSurahsPage.id);
                            }
                            break;

                          case 3:{
                              _settingBottom();
                            }
                            break;

                          case 4:{
                              pref.then((pref) {
                                pref.setInt("currentPage", currentPage);
                                savePage = currentPage;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.blueAccent,
                                  content: Text(
                                    '$currentPage تم حفظ العلامة على صفحة ',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                              setState(() {});
                            }
                            break;

                          case 5:{
                              pref.then((pref) {
                                int page = pref.getInt("currentPage") ?? -1;
                                print("page = $page");
                                if (page != -1) {
                                  setState(() {
                                    pageController.jumpToPage(page - 1);
                                  });
                                } else {
                                  // لو القيمة رجعت -1 يعني المستخددم محفظش أي صفحة
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        '!! لم تحفظ أي علامة بعد',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              });
                            }
                            break;

                          case 6:{
                              if (savePage != -1) {
                                pref.then((pref) {
                                  pref.remove("currentPage");
                                  savePage = -1;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'تم حذف العلامة',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      '!! لم تحفظ أي علامة بعد',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                            }
                            break;
                        }
                      },
                    ),
                  ],
                ),
          body: PageView.builder(
            itemCount: 604,
            controller: pageController,
            itemBuilder: (BuildContext context, int index) {
              ayats = MyApp.allQuranAyats.where((aya) => aya["page"] == index + 1).toList();
              if (ayats.isNotEmpty) {
                getPageData(ayats[0]);
              }
              currentPage = index + 1;
              return ayats.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: RichText(
                              textDirection: TextDirection.rtl,
                              overflow: TextOverflow.visible,
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                text: startPage,
                                style: const TextStyle(
                                  fontFamily: 'HafsSmart',
                                  color: Colors.black,
                                  fontSize: 24,
                                  height: 2,
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                                children: [
                                  for (int i = 0; i < ayats.length; i++) ...{
                                    TextSpan(
                                      text: showAya(ayats[i]),
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
                                        child: Text('${ayats[i]['aya_no']}'),
                                      ),
                                    ),
                                  }
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 4),
                            // الصفحة اللي عليها علامة بلون أحمر والباقي أزرق
                            color: (savePage == currentPage) ? Colors.red : Colors.blue,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$juz الجُزْءُ ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${currentPage} صفحة ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "سُورَةُ $surahName",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "HafsSmart",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
            },
          ),
        ));
  }

  PopupMenuEntry<int> _createPopupMenuItem(
      int value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.black),
        ],
      ),
    );
  }

  void _settingBottom() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                margin: EdgeInsets.all(8),
                child: TextField(
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  onChanged: (value) {
                    try {
                      writePage = int.parse(value.toString().trim());
                    } catch (ex) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('!! أكتب رقم صحيح')),
                      );
                    }
                  },
                  decoration: kTextFieldDecoration.copyWith(hintText: "أكتب رقم الصفحة..."),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  elevation: 5.0,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30.0),
                  child: MaterialButton(
                    onPressed: () {
                      if (writePage >= 1 && writePage <= 604) {
                        setState(() {
                          pageController.jumpToPage(writePage - 1);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('!! أكتب رقم بين 1 و604')),
                        );
                      }
                      Navigator.pop(context);
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: const Text(
                      "الذهاب للصفحة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
