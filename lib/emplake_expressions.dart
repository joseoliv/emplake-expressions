import 'dart:convert';
import 'dart:io';

import 'package:emplake_expressions/expression_compiler.dart';

import 'expression_kinds.dart';
import 'main.dart';

(Set<String>, Map<String, String>) generateAllExpressions() {
  var exprSet = <String>{};
  var numberToExprMap = <String, String>{};
  for (int a = 0; a < 10; a++) {
    for (int b = 0; b < 10; b++) {
      for (int c = 0; c < 10; c++) {
        for (int d = 0; d < 10; d++) {
          var number = '$a$b$c$d';
          outterFor:
          for (var exprKind in expressionKinds) {
            var e = exprKind
                .replaceAll('a', '$a')
                .replaceAll('b', '$b')
                .replaceAll('c', '$c')
                .replaceAll('d', '$d');
            for (var op in ['+', '-', '*', '/', '**']) {
              /// replace first 'op' in 'e' by op
              var e2 = e.replaceFirst('op', op);
              if (!e2.contains('op')) {
                if (isExprTrue(e2)) {
                  numberToExprMap[number] = e2;
                  exprSet.add(e2);
                  break outterFor;
                }
              } else {
                for (var op in ['+', '-', '*', '/', '**']) {
                  var e3 = e2.replaceFirst('op', op);
                  if (!e3.contains('op')) {
                    if (isExprTrue(e3)) {
                      numberToExprMap[number] = e3;
                      exprSet.add(e3);
                      break outterFor;
                    }
                  } else {
                    for (var op in ['+', '-', '*', '/', '**']) {
                      var e4 = e3.replaceFirst('op', op);
                      if (e4.contains('op')) {
                        print('Error: $e contains "op"');
                      } else {
                        if (isExprTrue(e2)) {
                          numberToExprMap[number] = e2;
                          exprSet.add(e2);
                          break outterFor;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return (exprSet, numberToExprMap);
}

(int, int, int, int) numbersFromStr(String number) {
  if (number.length != 4) {
    throw '$number size != 4';
  }
  // assign to a the int value of number
  return (
    int.parse(number[0]),
    int.parse(number[1]),
    int.parse(number[2]),
    int.parse(number[3])
  );
}

List<String> allCombinations() {
  List<String> r = [];
  for (int a = 0; a < 10; a++) {
    for (int b = 0; b < 10; b++) {
      for (int c = 0; c < 10; c++) {
        for (int d = 0; d < 10; d++) {
          r.add('$a$b$c$d');
        }
      }
    }
  }
  return r;
}

(Set<String>, Map<String, String>) generateExprForList({
  required List<String> strNumberList,
  required List<String> exprKinds,
  required List<String> binaryOperators,
  required File outputFile,
  int startIndexLast = -1,
}) {
  var numbersWithSolutionSet = <String>{};
  var numberToExprMap = <String, String>{};

  if (startIndexLast >= 0) {
    /// read numberToExprMap from outputFile
    if (outputFile.existsSync()) {
      var strJson = outputFile.readAsStringSync();
      var dynMap = jsonDecode(strJson);
      dynMap.forEach((key, value) {
        numberToExprMap[key] = value;
        numbersWithSolutionSet.add(key);
      });
    }
  }

  int numberCount = 0;
  var startTime = DateTime.now();
  var encoder = JsonEncoder.withIndent('  ');
  for (final number in strNumberList) {
    int numberInt = int.parse(number);
    if (numberInt < startIndexLast) {
      continue;
    }
    var (a, b, c, d) = numbersFromStr(number);
    print('number = $number');
    if (numberCount >= 1000) {
      numberCount = 0;
      var strJsonFormatted = encoder.convert(numberToExprMap);

      /// overwrite everything in the file
      outputFile.writeAsStringSync(strJsonFormatted);
    }
    ++numberCount;
    outterFor:
    for (var exprKind in exprKinds) {
      var e = exprKind
          .replaceAll('a', '$a')
          .replaceAll('b', '$b')
          .replaceAll('c', '$c')
          .replaceAll('d', '$d');
      for (var op in binaryOperators) {
        /// replace first 'op' in 'e' by op
        var e2 = e.replaceFirst('op', op);
        if (!e2.contains('op')) {
          if (isExprTrue(e2)) {
            numberToExprMap[number] = e2;
            numbersWithSolutionSet.add(number);
            break outterFor;
          }
        } else {
          for (var op in binaryOperators) {
            var e3 = e2.replaceFirst('op', op);
            if (!e3.contains('op')) {
              if (isExprTrue(e3)) {
                numberToExprMap[number] = e3;
                numbersWithSolutionSet.add(number);
                break outterFor;
              }
            } else {
              for (var op in binaryOperators) {
                var e4 = e3.replaceFirst('op', op);
                if (e4.contains('op')) {
                  print('Error: $e contains "op"');
                } else {
                  if (isExprTrue(e2)) {
                    numberToExprMap[number] = e2;
                    numbersWithSolutionSet.add(number);
                    //print('counter = $counter, "$number": $e4');
                    break outterFor;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  var timeSeconds = DateTime.now().difference(startTime).inSeconds;
  print('numberCounter = $numberCount, timeSeconds = $timeSeconds');
  numberCount = 0;
  var strJsonFormatted = encoder.convert(numberToExprMap);

  /// overwrite everything in the file
  outputFile.writeAsStringSync(strJsonFormatted);

  print('fullCounter = $numberCount');
  return (numbersWithSolutionSet, numberToExprMap);
}

void generateAllExpressionsToFile({String outputFile = r'Z:\allExpr.json'}) {
  var f = File(outputFile);
  var encoder = JsonEncoder.withIndent('  ');
  var (exprSet, numberToExprMap) = generateAllExpressions();
  print('exprSet size = ${exprSet.length}');
  print('numberToExprMap size = ${numberToExprMap.length}');
  var strJsonFormatted = encoder.convert(numberToExprMap);

  f.writeAsStringSync(strJsonFormatted);
}

/// the solutions are generated to the assets folder
void generateSolutionsByLevel({
  String baseDir = r'Z:\current-projects\emplake-data',
  int startIndex = 0,
  int endIndex = -1,

  /// skip all numbers till starIndexLast in the list of all numbers
  int startIndexLast = -1,
}) {
  var encoder = JsonEncoder.withIndent('  ');

  var strNumberList = allCombinations();

  var baseDirectory = Directory(baseDir);
  if (!baseDirectory.existsSync()) {
    baseDirectory.createSync();
  }

  /// find file whose name starts with allExprWithUnaryOp
  var allExprWithUnaryOpFiles = baseDirectory.listSync().where((f) {
    return f.path.contains('allExprWithUnaryOp');
  }).toList();
  List<String> allExprWithUnaryOp;
  if (allExprWithUnaryOpFiles.isEmpty) {
    allExprWithUnaryOp = allExpressionKindsUnaryOperators(
        exprList: expressionKinds00 + expressionKinds11 + expressionKinds22);

    /// save allExprWithUnaryOp as .json file name baseDir\\allExprWithUnaryOp${allExprWithUnaryOp.length}.json
    var strJsonFormatted = encoder.convert(allExprWithUnaryOp);
    var f =
        File('$baseDir\\allExprWithUnaryOp${allExprWithUnaryOp.length}.json');
    f.writeAsStringSync(strJsonFormatted);
  } else {
    /// read .json file allExprWithUnaryOp[0] and convert it to a List<String>
    var f = allExprWithUnaryOpFiles[0];

    /// convert f to a File object
    if (f is File) {
      var strJson = f.readAsStringSync();
      List<dynamic> dynList = jsonDecode(strJson);

      /// convert dynList to allExprWithUnaryOp
      allExprWithUnaryOp = dynList.map((elem) => elem as String).toList();
    } else {
      throw 'Error: ${f.path} is not a File';
    }
  }
  int emptyIndex = 0;
  for (var exprKind in expressionKindOpList) {
    if (exprKind.$2.isEmpty) {
      break;
    }
    ++emptyIndex;
  }
  expressionKindOpList[emptyIndex] = (
    ['+', '-', '*', '/', '**'],
    allExprWithUnaryOp,
  );
  if (endIndex == -1) {
    endIndex = expressionKindOpList.length;
  }

  if (startIndex > 0) {
    for (int i = 0; i < startIndex; i++) {
      // read file
      var f = File('$baseDir\\${exprToFilename(expressionKindOpList[i], i)}');
      if (!f.existsSync()) {
        print('File ${f.path} does not exist');
        return;
      }
      var strJson = f.readAsStringSync();
      var numberToExprMap = jsonDecode(strJson);
      var newStrNumberSet = <String>[];

      for (int i = 0; i < strNumberList.length; i++) {
        if (!numberToExprMap.containsKey(strNumberList[i])) {
          newStrNumberSet.add(strNumberList[i]);
        }
      }
      strNumberList = newStrNumberSet;
    }
  }

  for (int n = startIndex; n < endIndex; n++) {
    var exprKinds = expressionKindOpList[n].$2;
    var outputFile =
        File('$baseDir\\${exprToFilename(expressionKindOpList[n], n)}');
    var (numbersWithSolutionSet, numberToExprMap) = generateExprForList(
      strNumberList: strNumberList,
      exprKinds: exprKinds,
      binaryOperators: expressionKindOpList[n].$1,
      outputFile: outputFile,
      startIndexLast:
          n == expressionKindOpList.length - 1 ? startIndexLast : -1,
    );

    /// save numberToExprMap as a JSON file to file '$baseOutputFilename$endFilename' of the
    /// assets folder
    // var encoder = JsonEncoder.withIndent('  ');
    // var strJsonFormatted = encoder.convert(numberToExprMap);
    //// write strJsonFormatted to file in the assets folder

    // outputFile.writeAsStringSync(strJsonFormatted);
    var newStrNumberList = <String>[];
    for (int i = 0; i < strNumberList.length; i++) {
      if (!numbersWithSolutionSet.contains(strNumberList[i])) {
        newStrNumberList.add(strNumberList[i]);
      }
    }
    strNumberList = newStrNumberList;
  }
}

/// read all files from baseDir that start with 'solutionsUsing' and end with .json.
/// Each json file is a map from strings to strings. The keys are the numbers and the values are the expressions.
/// Join the maps of all files into a single map and save it to a file named 'allSolutions.json' in the baseDir.
/// Collect all keys of the maps into a set named allNumbersWithSolutions. Subtract the set taken from
/// allCombinations() and save the result to a file named 'allNumbersWithoutSolutions.json' in the baseDir.
void collectAllSolutions(
    {String baseDir = r'Z:\current-projects\emplake-data'}) {
  var baseDirectory = Directory(baseDir);
  if (!baseDirectory.existsSync()) {
    baseDirectory.createSync();
  }
  var allSolutions = <String, String>{};
  var allFiles = baseDirectory.listSync().where((f) {
    return f.path.contains('solutionsUsing') && f.path.endsWith('.json');
  }).toList();
  for (var f in allFiles) {
    if (f is File) {
      var strJson = f.readAsStringSync();
      var numberToExprMap = jsonDecode(strJson);
      numberToExprMap.forEach((key, value) {
        allSolutions[key] = value;
      });
    }
  }
  var outputFile = File('$baseDir\\allSolutions-${allSolutions.length}.json');
  var encoder = JsonEncoder.withIndent('  ');

  /// convert allSolutions to a list of tuples (String, String) and sort it according to the first element
  StringBuffer buf = mapToOrderedJsonString(allSolutions);

  //var strJsonFormatted = encoder.convert(allSolutions);
  outputFile.writeAsStringSync(buf.toString());

  var allNumbersWithSolutions = allSolutions.keys.toSet();
  var allNumbers = allCombinations();
  var allNumbersWithoutSolutions =
      allNumbers.toSet().difference(allNumbersWithSolutions).toList();
  allNumbersWithoutSolutions.sort();
  var outputFile2 = File(
      '$baseDir\\allNumbersWithoutSolutions-${allNumbersWithoutSolutions.length}.json');

  var strJsonFormatted2 = encoder.convert(allNumbersWithoutSolutions);
  outputFile2.writeAsStringSync(strJsonFormatted2);
}

StringBuffer mapToOrderedJsonString(Map<String, String> allSolutions) {
  List<(String, String)> allSolutionsList = [];
  for (var key in allSolutions.keys) {
    allSolutionsList.add((key, allSolutions[key]!));
  }
  allSolutionsList.sort((a, b) => a.$1.compareTo(b.$1));
  var buf = StringBuffer();
  buf.writeln('{');
  for (var elem in allSolutionsList) {
    buf.writeln('  "${elem.$1}": "${elem.$2}",');
  }
  buf.writeln('}');
  return buf;
}
