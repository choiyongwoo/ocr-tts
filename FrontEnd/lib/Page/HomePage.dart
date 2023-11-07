// ignore_for_file: prefer_typing_uninitialized_variables, unused_local_variable, non_constant_identifier_names, camel_case_types, file_names

import 'dart:async';

import 'package:dplit/GetPart/FromBackend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../GetPart/UIPart.dart';
import '../Tool/WidgetStyle.dart';
import '../initScreen.dart';
import 'Insideview/homeview.dart';
import 'Widgets/appbarview.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final searchNode = FocusNode();
  late ScrollController scrollController;
  late TextEditingController textcontroller;
  final uiset = Get.put(UIPart());
  final fb = Get.put(FromBackend());
  bool speechEnabled = false;
  var threshold = 100;
  var difference = 0;
  late PdfViewerController pdfViewerController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    textcontroller = TextEditingController();
    pdfViewerController = PdfViewerController();
    fb.setAudio('reset');

    fb.player.onDurationChanged.listen((newDuration) {
      fb.setDuration(newDuration);
    });
    fb.player.onPositionChanged.listen((newPosition) async {
      if (fb.playing != 'stop' || fb.playing != 'pause') {
        fb.setPosition(newPosition);
      }
      difference = fb.duration.inMilliseconds - fb.position.inMilliseconds;
      fb.setdifference(difference);
      if (fb.differ <= threshold) {
        print('==========STOP==========');
        fb.isplaying('stop');
        fb.setPosition(Duration.zero);
        //fb.player.stop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    textcontroller.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: OrientationBuilder(
      builder: (context, orientation) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: uiset.backgroundcolor,
            statusBarBrightness:
                uiset.statusbarcolor == 0 ? Brightness.dark : Brightness.light,
            statusBarIconBrightness: uiset.statusbarcolor == 0
                ? Brightness.dark
                : Brightness.light));
        return FutureBuilder(
          future: initScreen(),
          builder: (context, snapshot) {
            return Scaffold(
                backgroundColor: uiset.backgroundcolor,
                body: GetBuilder<UIPart>(builder: (_) => MainBody()));
          },
        );
      },
    ));
  }

  Widget MainBody() {
    return OrientationBuilder(builder: ((context, orientation) {
      return GetBuilder<UIPart>(
          builder: (_) => GestureDetector(
                onTap: () {
                  searchNode.unfocus();
                },
                child: SizedBox(
                  height: Get.height <= 300 ? 250 : Get.height,
                  width: Get.width,
                  child: GetBuilder<UIPart>(
                    builder: (_) {
                      return Container(
                          color: uiset.backgroundcolor,
                          child: Column(
                            children: [
                              AppBarCustom(
                                  title: 'V Ridge',
                                  node: searchNode,
                                  textcon: textcontroller),
                              Flexible(
                                fit: FlexFit.tight,
                                child: SizedBox(
                                  width: Get.width > 1000
                                      ? Get.width - 120
                                      : Get.width,
                                  child: ScrollConfiguration(
                                      behavior: NoBehavior(),
                                      child: LayoutBuilder(
                                        builder: ((context, constraint) {
                                          return Column(
                                            children: [
                                              responsivewidget(
                                                PageMove(
                                                    constraint.maxHeight,
                                                    constraint.maxWidth,
                                                    orientation,
                                                    searchNode),
                                                Get.width,
                                              ),
                                            ],
                                          );
                                        }),
                                      )),
                                ),
                              ),
                            ],
                          ));
                    },
                  ),
                ),
              ));
    }));
  }

  PageMove(maxHeight, maxWidth, orientation, searchNode) {
    List page = [
      UI_home(context, maxWidth, maxHeight, orientation, scrollController,
          searchNode, pdfViewerController),
    ];
    return page[uiset.pagenumber];
  }
}
