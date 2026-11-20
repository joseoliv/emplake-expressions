import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';

void stringListToExcel(List<String> numberList, String filename) {
  File file = File(filename);
  // //setting some configurations for excel
  // var bytes = file.readAsBytesSync();
  // Excel excel = Excel.decodeBytes(bytes);
  Excel excel = Excel.createExcel();
  Sheet sheetObject = excel['Sheet1'];
  sheetObject.insertRow(0);
  sheetObject.insertRow(1);
  sheetObject.insertColumn(0);
  sheetObject.insertColumn(1);

  var cell = sheetObject.cell(CellIndex.indexByString("A1"));
  cell.value = TextCellValue('Number'); // dynamic values support provided;

  //Updating excel values logic
  for (int i = 0; i < numberList.length; ++i) {
    sheetObject.insertRow(i + 2);
    var cell = sheetObject.cell(CellIndex.indexByString("A${i + 2}"));
    cell.value =
        TextCellValue(numberList[i]); // dynamic values support provided;
  }

  //saving excel
  file
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.encode()!);
}

void stringListToSpreedSheet(List<String> numberList, String filename) {}

void createSpreedSheetFromNumberList() {
  var baseDir = r'Z:\current-projects\emplake-data';
  var filename = r'allNumbersWithoutSolutions-324.json';
  var txtFilename =
      r'Z:\current-projects\emplake-data\allNumbersWithoutSolutions-324.txt';
  var excelFilename =
      r'Z:\current-projects\emplake-data\allNumbersWithoutSolutions-324.xlsx';
  var file = File('$baseDir\\$filename');
  var numberListStr = file.readAsStringSync();
  var numberDynList = jsonDecode(numberListStr);
  List<String> numberList = [];
  var buf = StringBuffer();
  for (var number in numberDynList) {
    var strNumber = number.toString().trim();
    if (strNumber.isEmpty || strNumber.length > 4) {
      continue;
    }
    numberList.add(number.toString());
    buf.writeln(number.toString());
  }
  File(txtFilename).writeAsStringSync(buf.toString());
  stringListToExcel(numberList, excelFilename);
}
