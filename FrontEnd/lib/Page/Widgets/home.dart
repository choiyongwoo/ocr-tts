// ignore_for_file: deprecated_member_use, non_constant_identifier_names, prefer_typing_uninitialized_variables, unused_local_variable

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dplit/GetPart/FromBackend.dart';
import 'package:dplit/GetPart/UIPart.dart';
import 'package:dplit/Tool/MyTheme.dart';
import 'package:dplit/Tool/TextSize.dart';
import 'package:dplit/Tool/WidgetStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'pdfview.dart';

final fb = Get.put(FromBackend());

home(
  context,
  maxHeight,
  maxWidth,
  scrollController,
  pdfViewerController,
  searchNode,
  isportrait,
) {
  List pageview = [
    view0(context, maxHeight, maxWidth, searchNode, pdfViewerController),
    view1(context, maxHeight, maxWidth, searchNode, pdfViewerController)
  ];
  return SizedBox(
      height: maxHeight,
      width: maxWidth,
      child: SingleChildScrollView(
          controller: scrollController, child: pageview[isportrait]));
}

// 세로 모드는 view0으로 통합
view0(
  context,
  maxHeight,
  maxWidth,
  searchNode,
  pdfViewerController,
) {
  return Column(
    children: [
      const SizedBox(
        height: 20,
      ),
      Searchview(context, maxHeight, maxWidth, searchNode, 0),
      const SizedBox(
        height: 20,
      ),
      PDFDashboard(
        context,
        maxHeight,
        maxWidth,
        searchNode,
        pdfViewerController,
        0,
      ),
      const SizedBox(
        height: 20,
      ),
      Settingview(context, maxHeight, maxWidth, searchNode, 0),
      const SizedBox(
        height: 20,
      ),
      //QAview()
    ],
  );
}

// 가로 모드는 view1로 통합
view1(context, maxHeight, maxWidth, searchNode, pdfViewerController) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        flex: 2,
        child: PDFDashboard(
          context,
          maxHeight,
          maxWidth,
          searchNode,
          pdfViewerController,
          1,
        ),
      ),
      const SizedBox(
        width: 20,
      ),
      Flexible(
          flex: 1,
          child: Container(
            constraints: BoxConstraints.expand(height: maxHeight - 50),
            child: Column(
              children: [
                Searchview(context, maxHeight, maxWidth, searchNode, 1),
                const SizedBox(
                  height: 10,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child:
                      Settingview(context, maxHeight, maxWidth, searchNode, 1),
                )
              ],
            ),
          ))

      //QAview()
    ],
  );
}

// 뷰에 포함되어야 하는 작은 뷰 :
// pdf를 불러오는 절반의 대시보드(바텀뷰로 pdf를 파일 또는 링크로 불러옴과 동시에 OCR을 진행하게 로딩뷰를 보여줌),
// TTS + QA(추후 진행이라 주석처리)를 실행하는 버튼뷰,
// TTS를 실행해주는 목소리를 선택하거나 속도 조절하는 설정칸,
// QA결과뷰
Searchview(context, maxHeight, maxWidth, searchNode, section) {
  var filesomething, filepath, filename;
  List files = [];
  return ContainerDesign(
      color: MyTheme.colorWhite,
      type: 0,
      child: SizedBox(
          height: section == 0 ? 100 : 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Divider(height: 30, thickness: 2, color: uiset.backgroundcolor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                      flex: 2,
                      child: GetBuilder<UIPart>(builder: (_) {
                        return ContainerDesign(
                          color: uiset.isstart == 0
                              ? MyTheme.colororigred
                              : MyTheme.colororigblue,
                          type: 0,
                          child: InkWell(
                              onTap: () async {
                                // 이 코드는 새로 변경된 부분으로
                                // 서버로 보내기 전 기존 로컬 파일경로를 받아옴.
                                try {
                                  if (uiset.isstart == 0) {
                                    IconSnackBar.show(
                                        context: context,
                                        snackBarType: SnackBarType.alert,
                                        label:
                                            '변환 중 상태이므로 재시도를 원하시면 우측의 x표시를 클릭해주세요!');
                                  } else if (uiset.mp3paths != '' ||
                                      uiset.filepaths != '') {
                                    IconSnackBar.show(
                                        context: context,
                                        snackBarType: SnackBarType.alert,
                                        label:
                                            '변환이 완료된 상태이므로 재시도를 원하시면 우측의 x표시를 클릭해주세요!');
                                  } else if (uiset.isstart != 99 &&
                                      uiset.mp3paths == '') {
                                    IconSnackBar.show(
                                        context: context,
                                        snackBarType: SnackBarType.fail,
                                        label:
                                            '음성변환이 중 예기치 못한 에러로 재시도를 원하시면 우측의 x표시를 클릭해주세요!');
                                  } else {
                                    uiset.setclickedpdf(false);
                                    fb.setstatus('', 'PDF');
                                    fb.setstatus('', 'MP3');
                                    //await loadfile3(context);
                                    files = await loadfile3();
                                    if (files[0] != null) {
                                      uiset.setstart(0);
                                      uiset.setpdffilename(files[0]);
                                      uiset.setpdffilepath(files[1], 0);
                                      //uiset.setprocesslist(0);
                                      await fb.tosendfile();
                                      if (uiset.filepaths == '') {
                                        IconSnackBar.show(
                                            context: context,
                                            snackBarType: SnackBarType.fail,
                                            label:
                                                'PDF변환 중 예기치 못한 에러로 인해 사용불가상태입니다! 다시 시도해주세요');
                                      } else if (uiset.mp3paths == '') {
                                        // 파일이 존재하지 않는 경우 예외 처리
                                        uiset.setmp3filepath('');
                                        fb.setstatus('Bad Request', 'MP3');
                                        IconSnackBar.show(
                                            context: context,
                                            snackBarType: SnackBarType.fail,
                                            label:
                                                '음성변환 중 예기치 못한 에러로 인해 사용불가상태입니다! 다시 시도해주세요');
                                      } else {
                                        fb.setAudio('start');
                                        fb.isplaying('stop');
                                        fb.player.stop();
                                      }
                                      uiset.setstart(1);
                                    } else {
                                      IconSnackBar.show(
                                          context: context,
                                          snackBarType: SnackBarType.fail,
                                          label: '파일변환이 완료되지 않았습니다! 다시 시도해주세요');
                                    }
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              },
                              child: SizedBox(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      uiset.isstart == 0
                                          ? MaterialIcons.do_not_disturb
                                          : AntDesign.upload,
                                      size: 25,
                                      color: MyTheme.colorWhite,
                                    ),
                                    Text(
                                      uiset.isstart == 0
                                          ? '변환중'
                                          : (uiset.isstart == 1
                                              ? '변환완료'
                                              : '변환시작'),
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        wordSpacing: 2,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.bold,
                                        fontSize: contentTextsize(),
                                        color: MyTheme.colorWhite,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )),
                        );
                      })),
                  Flexible(
                      flex: 1,
                      child: InkWell(
                          onTap: () {
                            // 변환 중인 경우를 제외하고 재시도를 가능하게 하는 로직
                            if (uiset.isstart != 0) {
                              uiset.filepaths = '';
                              uiset.filebytes = Uint8List(1);
                              fb.setstatus('', 'PDF');
                              fb.setstatus('', 'MP3');
                              uiset.setclickedpdf(false);
                              uiset.setmp3filepath('');
                              fb.isplaying('stop');
                              fb.setDuration(Duration.zero);
                              fb.setPosition(Duration.zero);
                              fb.player.stop();
                              uiset.setstart(99);
                            } else {
                              IconSnackBar.show(
                                  context: context,
                                  snackBarType: SnackBarType.alert,
                                  label: '변환 중 상태이므로 변환이 완료되면 다시 눌러주세요!');
                            }
                          },
                          child: SizedBox(
                            child: Icon(
                              MaterialIcons.clear,
                              size: iconsize(),
                              color: MyTheme.colorblack,
                            ),
                          ))),
                ],
              )
            ],
          )));
}

PDFDashboard(
  context,
  maxHeight,
  maxWidth,
  searchNode,
  pdfViewerController,
  section,
) {
  return ContainerDesign(
      color: MyTheme.colorWhite,
      type: 0,
      child: GetBuilder<UIPart>(builder: (_) {
        return SizedBox(
          height: section == 0
              ? (maxHeight * 0.4 > 500 ? maxHeight * 0.4 : 500)
              : maxHeight - 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '뷰어',
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        wordSpacing: 2,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        fontSize: contentTextsize(),
                        color: MyTheme.colorblack),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          pdfViewerController.zoomLevel -= 1;
                        },
                        child: Icon(
                          Feather.zoom_out,
                          size: iconsize(),
                          color: MyTheme.colorgrey,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          pdfViewerController.zoomLevel += 1;
                        },
                        child: Icon(
                          Feather.zoom_in,
                          size: iconsize(),
                          color: MyTheme.colorblack,
                        ),
                      )
                    ],
                  )
                ],
              ),
              // 선택한 파일이 있는 경우 PDF를 보여줍니다.
              uiset.isclikedpdf
                  ? Flexible(
                      fit: FlexFit.tight,
                      child: GetPlatform.isWeb ||
                              GetPlatform.isWindows ||
                              GetPlatform.isMacOS
                          //? uiset.filebytes != Uint8List(1)
                          ? FutureBuilder(
                              future: fb.FetchPDFPath(),
                              builder: (context, snapshot) {
                                return GetBuilder<FromBackend>(builder: (_) {
                                  if (fb.status_pdf == '') {
                                    return uiset.filepaths != ''
                                        ? SfPdfViewer.file(
                                            File(uiset.filepaths),
                                            controller: pdfViewerController,
                                            interactionMode:
                                                PdfInteractionMode.pan)
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '서버로부터 불러오는 중입니다. 잠시만 기다려주십시오.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    wordSpacing: 2,
                                                    letterSpacing: 2,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: contentTextsize(),
                                                    color:
                                                        MyTheme.colorgreyshade),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              SimpleCircularProgressBar(
                                                mergeMode: true,
                                                backColor:
                                                    MyTheme.colorgreyshade,
                                                fullProgressColor:
                                                    MyTheme.colororiggreen,
                                                animationDuration: 100,
                                              ),
                                            ],
                                          );
                                  } else if (snapshot.data == null &&
                                      uiset.filepaths == '') {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          AntDesign.frowno,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          fb.status_pdf,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              wordSpacing: 2,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.bold,
                                              fontSize: contentTextsize(),
                                              color: MyTheme.colororigred),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'x버튼을 클릭하여 재시도해주세요',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              wordSpacing: 2,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.normal,
                                              fontSize: contentsmallTextsize(),
                                              color: MyTheme.colorgreyshade),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return SizedBox(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: MyTheme.colororigblue,
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            '서버로부터 불러오는 중입니다. 잠시만 기다려주십시오.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                wordSpacing: 2,
                                                letterSpacing: 2,
                                                fontWeight: FontWeight.normal,
                                                fontSize:
                                                    contentsmallTextsize(),
                                                color: MyTheme.colorgreyshade),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                });
                              },
                            )
                          : SfPdfViewer.file(File(uiset.filepaths),
                              controller: pdfViewerController,
                              interactionMode: PdfInteractionMode.pan))
                  : Flexible(
                      fit: FlexFit.tight,
                      child: GetBuilder<UIPart>(
                        builder: (_) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                section == 0
                                    ? '상단의 업로드 버튼으로\n파일 업로드 해주세요'
                                    : '우측의 업로드 버튼으로\n파일 업로드 해주세요',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: MyTheme.colorgrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: contentTextsize()),
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          );
                        },
                      )), // 선택한 파일이 PDF가 아닌 경우 빈 컨테이너 표시
            ],
          ),
        );
      }));
}

Settingview(context, maxHeight, maxWidth, searchNode, section) {
  var txtpath;
  return ContainerDesign(
      color: MyTheme.colorWhite,
      type: 0,
      child: SizedBox(
        height: section == 0 ? 500 : maxHeight - 100 - 150,
        child: Column(
          children: [
            GetBuilder<UIPart>(builder: (_) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /*InkWell(
                    onTap: () {
                      uiset.setdrawerlist(0);
                    },
                    child: Text(
                      'To-PDF',
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          wordSpacing: 2,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          fontSize: contentTextsize(),
                          color: uiset.drawerlist[0] == true
                              ? MyTheme.colorblack
                              : MyTheme.colorgrey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),*/
                  InkWell(
                    onTap: () {
                      uiset.setdrawerlist(0);
                    },
                    child: Text(
                      'To-Voice',
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          wordSpacing: 2,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          fontSize: contentTextsize(),
                          color: uiset.drawerlist[0] == true
                              ? MyTheme.colorblack
                              : MyTheme.colorgrey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }),
            Divider(
              height: 30,
              thickness: 2,
              color: uiset.backgroundcolor,
            ),
            Flexible(
                fit: FlexFit.tight,
                child: GetBuilder<UIPart>(
                  builder: (_) {
                    return uiset.isstart != 0 && uiset.mp3paths != ''
                        ? Viewdrawerbox()
                        : NoneViewBox(context);
                  },
                ))
          ],
        ),
      ));
}

//QAview(){}
Viewdrawerbox() {
  return SizedBox(
    child: GetBuilder<FromBackend>(builder: (_) {
      return FutureBuilder(
        future: fb.Fetchvoice(),
        builder: (context, snapshot) {
          if (snapshot.hasData || fb.status_mp3 == '') {
            return SizedBox(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Slider(
                    min: 0,
                    max: fb.duration.inSeconds.toDouble(),
                    value: fb.position.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await fb.player.seek(position);
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(fb.position),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            wordSpacing: 2,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: contentTextsize(),
                            color: MyTheme.colorblack),
                      ),
                      Text(
                        formatTime(fb.duration),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            wordSpacing: 2,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: contentTextsize(),
                            color: MyTheme.colorblack),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GetBuilder<FromBackend>(builder: (_) {
                          return Row(
                            children: [
                              InkWell(
                                  onTap: () async {
                                    fb.isplaying('stop');
                                    fb.player.stop();
                                  },
                                  child: Icon(
                                    Ionicons.stop,
                                    color: MyTheme.colororigred,
                                    size: largeiconsize(),
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                  onTap: () async {
                                    if (fb.playing == 'pause') {
                                      fb.isplaying('resume');
                                      fb.player.resume();
                                    } else if (fb.playing == 'stop') {
                                      fb.isplaying('play');
                                      //fb.loadmp3File(uiset.mp3paths);
                                      fb.player.play(
                                          DeviceFileSource(uiset.mp3paths));
                                    } else {
                                      fb.isplaying('pause');
                                      fb.player.pause();
                                    }
                                  },
                                  child: Icon(
                                    fb.playing == 'pause' ||
                                            fb.playing == 'stop'
                                        ? AntDesign.play
                                        : AntDesign.pausecircle,
                                    color: MyTheme.colororigblue,
                                    size: largeiconsize(),
                                  ))
                            ],
                          );
                        })
                      ],
                    ))
              ],
            ));
          } else {
            if (fb.status_mp3 == 'Bad Request' ||
                fb.status_mp3 == 'Server Not Exists') {
              return SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      AntDesign.frowno,
                      color: Colors.red,
                      size: 30,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      fb.status_mp3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          wordSpacing: 2,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          fontSize: contentTextsize(),
                          color: MyTheme.colororigred),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'x버튼을 클릭하여 재시도해주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          wordSpacing: 2,
                          letterSpacing: 2,
                          fontWeight: FontWeight.normal,
                          fontSize: contentsmallTextsize(),
                          color: MyTheme.colorgreyshade),
                    ),
                  ],
                ),
              );
            } else {
              return SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: MyTheme.colororigblue,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      '서버로부터 불러오는 중입니다. 잠시만 기다려주십시오.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          wordSpacing: 2,
                          letterSpacing: 2,
                          fontWeight: FontWeight.normal,
                          fontSize: contentsmallTextsize(),
                          color: MyTheme.colorgreyshade),
                    ),
                  ],
                ),
              );
            }
          }
        },
      );
    }),
  );
}

NoneViewBox(context) {
  return GetBuilder<UIPart>(builder: (_) {
    return uiset.isstart == 1 && uiset.mp3paths == ''
        ? SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  AntDesign.frowno,
                  color: Colors.red,
                  size: 30,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  fb.status_mp3,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      wordSpacing: 2,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      fontSize: contentTextsize(),
                      color: MyTheme.colororigred),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'x버튼을 클릭하여 재시도해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      wordSpacing: 2,
                      letterSpacing: 2,
                      fontWeight: FontWeight.normal,
                      fontSize: contentsmallTextsize(),
                      color: MyTheme.colorgreyshade),
                ),
              ],
            ),
          )
        : SizedBox(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Slider(
                  min: 0,
                  max: 1,
                  value: fb.position.inSeconds.toDouble(),
                  onChanged: (value) async {}),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(fb.position),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          wordSpacing: 2,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          fontSize: contentTextsize(),
                          color: MyTheme.colorblack),
                    ),
                    Text(
                      formatTime(fb.duration),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          wordSpacing: 2,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          fontSize: contentTextsize(),
                          color: MyTheme.colorblack),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        IconSnackBar.show(
                            context: context,
                            snackBarType: SnackBarType.fail,
                            label: '상단의 변환과정을 먼저 수행하셔야 합니다.');
                      },
                      child: GetBuilder<FromBackend>(builder: (_) {
                        return Icon(
                          AntDesign.play,
                          color: MyTheme.colororigblue,
                          size: largeiconsize(),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ));
  });
}

formatTime(Duration durationone) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(durationone.inHours);
  final minutes = twoDigits(durationone.inMinutes.remainder(60));
  final seconds = twoDigits(durationone.inSeconds.remainder(60));

  return [
    if (durationone.inHours > 0) hours,
    minutes,
    seconds,
  ].join(' : ');
}
