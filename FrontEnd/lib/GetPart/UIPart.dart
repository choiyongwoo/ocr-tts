// ignore_for_file: camel_case_types, non_constant_identifier_names, file_names, avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../Tool/MyTheme.dart';

class UIPart extends GetxController {
  final box = GetStorage();
  int isstart = 99;
  bool isspeechtoggle = true;
  double maxWidth = 0.0;
  double maxHeight = 0.0;
  int pagenumber = 0;
  Uint8List filebytes = Uint8List(1);
  String filename = '';
  String postfilepaths = '';
  String filepaths = '';
  String txtpaths = '';
  String mp3paths = '';
  String txtcontents = '';
  int filelen = 0;
  bool isclikedpdf = false;
  bool loading = false;
  bool sheetloading = false;
  int statusbarcolor = 0;
  Color backgroundcolor = MyTheme.colorgreyshade;
  Color color_textstatus = MyTheme.colorWhite;
  Color color_text = MyTheme.colorblack;
  /*List<bool> processlist = [
    true,
    false,
    false,
  ];*/
  List<bool> drawerlist = [
    true,
  ];
  int activeindex = 0;
  int imgindex = 0;
  Locale? locale;
  int selecttxtscaler = 2;
  String lastword = '';

  ///loadLocale
  ///
  ///사용자의 기기 내 locale 정보를 얻는 데에 사용된다.
  void loadLocale() {
    locale = (box.read('locale') == null
        ? Get.deviceLocale
        : Locale('${box.read('locale')}', ''))!;
    if (locale!.languageCode == 'en') {
      locale = const Locale('en', '');
    } else if (locale!.languageCode == 'ko') {
      locale = const Locale('ko', '');
    } else {
      locale = const Locale('en', '');
    }

    update();
    notifyChildrens();
  }

  ///changeLocale
  ///
  ///사용자의 기기 내 locale 정보를 변경하는 데에 사용된다.
  void changeLocale(context) {
    /*if (newlocale.languageCode == 'en') {
      locale = const Locale('en', '');
    } else if (newlocale.languageCode == 'ko') {
      locale = const Locale('ko', '');
    }*/
    if (locale!.languageCode == 'en') {
      locale = const Locale('ko', '');
    } else if (locale!.languageCode == 'ko') {
      locale = const Locale('en', '');
    }
    box.write('locale', locale!.languageCode.toString());
    locale = Locale('${box.read('locale')}', '');

    loadLocale();
    Get.updateLocale(locale!);

    update();
    notifyChildrens();
  }

  ///settingdestroy
  ///
  ///모든 UI를 최초의 상태로 되돌리는 데에 사용된다.
  void settingdestroy() {
    update();
    notifyChildrens();
  }

  ///setloading
  ///
  ///모든 UI상에서 로딩중인지를 판단하는 데에 사용된다.
  void setloading(bool what, int i) {
    if (i == 0) {
      loading = what;
    } else {
      sheetloading = what;
    }

    update();
    notifyChildrens();
  }

  ///settextscale
  ///
  ///모든 UI상에서 텍스트 사이즈를 업데이트하는 데에 사용된다.
  void settextscale(int i) {
    selecttxtscaler = i;

    update();
    notifyChildrens();
  }

  void setappbox() async {
    loading = true;
    box.write('backgroundcolor', MyTheme.colorgreyshade.value);
    box.write('textcolor', MyTheme.colorWhite.value);
    box.write('statusbarcolor', 0);

    backgroundcolor = Color(box.read('backgroundcolor'));
    color_textstatus = Color(box.read('textcolor'));
    statusbarcolor = box.read('statusbarcolor') ?? 0;
    selecttxtscaler = 2;

    loading = false;

    update();
    notifyChildrens();
  }

  void changeappbox() {
    if (box.read('backgroundcolor') == MyTheme.colorWhite.value) {
      box.write('backgroundcolor', MyTheme.colorgreyshade.value);
      box.write('textcolor', MyTheme.colorWhite.value);
      box.write('statusbarcolor', 1);
    } else {
      box.write('backgroundcolor', MyTheme.colorWhite.value);
      box.write('textcolor', MyTheme.colorgreyshade.value);
      box.write('statusbarcolor', 0);
    }

    backgroundcolor = Color(box.read('backgroundcolor'));
    color_textstatus = Color(box.read('textcolor'));
    statusbarcolor = box.read('statusbarcolor') ?? 0;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: backgroundcolor,
        statusBarBrightness:
            statusbarcolor == 0 ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            statusbarcolor == 0 ? Brightness.dark : Brightness.light));

    update();
    notifyChildrens();
  }

  void setoffset(double what1, double what2) {
    maxWidth = what1;
    maxHeight = what2;
    update();
    notifyChildrens();
  }

  void setpageindex(int what) {
    pagenumber = what;

    update();
    notifyChildrens();
  }

  /*void setprocesslist(int what) {
    if (processlist[what] == true) {
    } else {
      for (int i = 0; i < processlist.length; i++) {
        if (processlist[i] == true) {
          processlist[i] = false;
        }
      }
      processlist[what] = !processlist[what];
    }

    update();
    notifyChildrens();
  }*/

  void setdrawerlist(int what) {
    if (drawerlist[what] == true) {
    } else {
      for (int i = 0; i < drawerlist.length; i++) {
        if (drawerlist[i] == true) {
          drawerlist[i] = false;
        }
      }
      drawerlist[what] = !drawerlist[what];
    }

    update();
    notifyChildrens();
  }

  void setclickedpdf(bool what) {
    isclikedpdf = what;

    update();
    notifyChildrens();
  }

  void setstart(int what) {
    isstart = what;

    update();
    notifyChildrens();
  }

  void setspeechtoggle(bool what) {
    isspeechtoggle = what;

    update();
    notifyChildrens();
  }

  void setlastword(String what) {
    lastword = what;

    update();
    notifyChildrens();
  }

  /// Each

  void setpdffilebytes(Uint8List what) {
    filebytes = what;
    setclickedpdf(true);
    update();
    notifyChildrens();
  }

  void setpdffilename(String what) {
    filename = what;
    setclickedpdf(true);
    update();
    notifyChildrens();
  }

  void setpdffilepath(String what, int where) {
    if (where == 0) {
      postfilepaths = what;
    } else {
      filepaths = what;
    }

    setclickedpdf(true);
    update();
    notifyChildrens();
  }

  void setmp3filepath(String what) {
    mp3paths = what;
    update();
    notifyChildrens();
  }

  void setfilelen(int what) {
    filelen = what;
    update();
    notifyChildrens();
  }
}
