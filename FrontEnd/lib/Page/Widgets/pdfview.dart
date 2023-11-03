// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../GetPart/UIPart.dart';

loadfile1() async {
  final uiset = Get.put(UIPart());
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'xls', 'xlsx', 'ppt', 'pptx', 'doc', 'docx'],
  );

  if (result != null) {
    uiset.setfilelen(result.files.length);
    if (uiset.filelen > 1) {
      return null;
    } else {
      return result.files.first.path!;
    }
  } else {
    return null;
  }
}

loadfile2() async {
  final uiset = Get.put(UIPart());
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'xls', 'xlsx', 'ppt', 'pptx', 'doc', 'docx'],
  );

  if (result != null) {
    uiset.setfilelen(result.files.length);
    if (uiset.filelen > 1) {
      return null;
    } else {
      Uint8List fileBytes = result.files.first.bytes!;
      return fileBytes;
    }
  } else {
    return null;
  }
}

/*loadfile3() async {
  final uiset = Get.put(UIPart());
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'xls', 'xlsx', 'ppt', 'pptx', 'doc', 'docx'],
  );

  if (result != null) {
    uiset.setfilelen(result.files.length);
    if (uiset.filelen > 1) {
      return [null, null];
    } else {
      return [result.files.first.name.split('.')[0], result.files.first.path!];
    }
  } else {
    return [null, null];
  }
}*/
loadfile3() async {
  final uiset = Get.put(UIPart());
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'xls', 'xlsx', 'ppt', 'pptx', 'doc', 'docx'],
  );

  if (result != null) {
    uiset.setfilelen(result.files.length);
    if (uiset.filelen > 1) {
      return [null, null];
    } else {
      String newFileName =
          result.files.first.name.replaceAll(RegExp(r'\s+'), '');
      String newPath = result.files.first.path!.replaceAll(RegExp(r'\s+'), '');

      // 공백 제거된 파일 경로 및 이름으로 복사
      File originalFile = File(result.files.first.path!);

      await originalFile.copy(newPath);

      return [newFileName.split('.')[0], newPath];
    }
  } else {
    return [null, null];
  }
}
