// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:get/get.dart';
import '../../GetPart/UIPart.dart';
import 'home.dart';

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
// loadfile3(context) async {
//   final uiset = Get.put(UIPart());
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['pdf', 'xls', 'xlsx', 'ppt', 'pptx', 'doc', 'docx'],
//   );

//   if (result != null) {
//     uiset.setfilelen(result.files.length);
//     if (uiset.filelen > 1) {
//       return [null, null];
//     } else {
//       String filepath = result.files.first.path!;
//       String newFileName =
//           result.files.first.name.replaceAll(RegExp(r'\s+'), '');
//       String newPath = result.files.first.path!.replaceAll(RegExp(r'\s+'), '');

//       //await originalFile.copy(newPath);
//       // 새로운 경로에 파일 복사
//       //originalFile.copy(newPath);
//       // await FileSaver.instance.saveFile(
//       //     name: newFileName,
//       //     file: originalFile,
//       //     ext: 'pdf',
//       //     mimeType: MimeType.pdf);
//       await copyFileUsingIOSink(context, filepath);

//       //return [newFileName.split('.')[0], newPath];
//     }
//   } else {
//     //return [null, null];
//   }
// }
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
      // String newFileName =
      //     result.files.first.name.replaceAll(RegExp(r'\s+'), '');
      //String newPath = result.files.first.path!.replaceAll(RegExp(r'\s+'), '');

      // 공백 제거된 파일 경로 및 이름으로 복사
      File originalFile = File(result.files.first.path!);
      //String fileName = result.files.first.name.split('\\').last.split('.')[0];
      String fileName = result.files.first.name
          .split('.')
          .sublist(0, result.files.first.name.split('.').length - 1)
          .join('.')
          .replaceAll('.', '-')
          .replaceAll(' ', '');

      print('Filename : ' + fileName);

      //await originalFile.copy(newPath);
      //String fileName = getFileName(result.files.first.path!);
      //String fileName = getFileName(newPath);
      String ext = originalFile.path.split('\\').last.split('.').last;
      print('EXT : ' + ext);
      String newFileName = fileName; // 새 파일명 초기값
      String directory = originalFile.parent.path;
      String newFilePath = '$directory\\$newFileName.$ext'; // 새 파일 경로

      int count = 1;
      while (await File(newFilePath).exists()) {
        newFileName = '$fileName($count)';
        newFilePath = '$directory\\$newFileName.$ext'; // 중복되지 않는 새 파일명 생성
        count++;
      }

      try {
        //await originalFile.copy(newFilePath);
        await originalFile.rename(newFilePath); // 파일 이름 변경
        print('File name changed to: $newFileName');
        return [newFileName, newFilePath];
      } catch (e) {
        print('Error renaming the file: $e');
        return [null, null];
      }
    }
  } else {
    return [null, null];
  }
}

String getFileName(String filePath) {
  List<String> splitParts = filePath.split(
      RegExp(r'\.(pdf|xls?|xlsx?|ppt?|pptx?|doc?|docx?)')); // 지원하는 확장자 기준으로 나눔
  if (splitParts.isNotEmpty) {
    String fileName = splitParts[0]; // 확장자 이전의 부분을 가져옴
    print(fileName);
    int lastIndex = fileName.lastIndexOf(RegExp(r'\\|\/'));
    print('결과 : ' + fileName.substring(lastIndex + 1).trim());
    return fileName.substring(lastIndex + 1).trim(); // 파일명만 추출
  }
  return filePath; // 지원하는 확장자가 없을 경우 전체 경로 반환
}
