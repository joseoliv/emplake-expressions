import 'dart:io';

import 'package:emplake_expressions/expression_compiler.dart';

import 'emplake_expressions.dart';
import 'expression_kinds.dart';

void main() {
  calcExpr();
  //createSpreedSheetFromNumberList();
  //testExpressionKindWithAllNumbers();
  //collectAllSolutions();
  //parseAllExpressionKind();
  //generateSolutionsByLevel(startIndex: 7, endIndex: -1, );
  // print(allExpressionKindsUnaryMinus().length);
  // print('\n');
  // print(allExpressionKindsUnaryMinus());

  //print(isExprTrue('2 = sqrt3 8 + (3 ** 5)!'));
  // generateAllExpressionsToFile();
}

void testExpressionKindWithAllNumbers() {
  var exprKinds = [
    'a op b = c op d',
  ];

  var (numbersWithSolutionSet, numberToExprMap) = generateExprForList(
      strNumberList: ['9999'],
      exprKinds: exprKinds,
      binaryOperators: '+ - * / **'.split(' '),
      outputFile:
          File(r'Z:\current-projects\emplake-data\a_op_b_eq_c_op_d.json'));
  print(numberToExprMap);
}

void parseAllExpressionKind() {
  var p = ParseExpr();
  p.init(
    'a op b = c op d',
  );
  try {
    Expr e = p.parse();
    print(e);
  } catch (e) {
    print('Error: ');
  }
  var allExprKind = <String>[];
  for (var exprKind in [
    expressionKinds00,
    expressionKinds11,
    expressionKinds22
  ]) {
    allExprKind.addAll(exprKind);
    //var list = allExpressionKindsUnaryOperators(exprList: exprKind);
    for (var strExpr in exprKind) {
      p.init(strExpr.replaceAll('op', '+'));
    }
  }
  var list = allExpressionKindsUnaryOperators(exprList: allExprKind);
  print('allExpressionKindsUnaryOperators: ${list.length}');
  int countCorrect = 0;
  int countIncorrect = 0;
  var newList = <String>[];

  /// get the current time
  var startTime = DateTime.now();
  int count = 0;
  for (var strExpr in list) {
    if (strExpr.contains('sqrt2 -')) {
      continue;
    }
    p.init(strExpr.replaceAll('op', '+'));
    try {
      p.parse();
      countCorrect++;
      newList.add(strExpr);
      // print('countCorrect: $countCorrect');
      // print(strExpr);
    } catch (e) {
      countIncorrect++;
      print('countIncorrect: $countIncorrect');
      print('Error: $strExpr');
    }
    ++count;
    if (count % 1000 == 0) {
      /// print the time elapsed in seconds from currentTime
      var timeSeconds = DateTime.now().difference(startTime).inSeconds;

      print('count: $count, timeSeconds: $timeSeconds');
    }
  }
  print('countCorrect: $countCorrect');
}

List<String> allExpressionKindsUnaryOperators(
    {required List<String> exprList,
    List<String> unaryOperators = const ['', 'sqrt2 ', 'sqrt3 ']}) {
  //
  //
  Set<String> extractOperands(String expression) {
    final operandPattern = RegExp(r'[a-d]|\([^()]*\)');
    return operandPattern
        .allMatches(expression)
        .map((match) => match.group(0)!)
        .toSet();
  }

  void generateAllCombinations(Set<String> operands,
      Map<String, String> currentMap, List<String> results, String expression) {
    if (operands.isEmpty) {
      String modifiedExpression = expression;
      currentMap.forEach((original, modified) {
        modifiedExpression =
            modifiedExpression.replaceAll(original, modified.trim());
      });
      results.add(modifiedExpression);
      return;
    }

    final operand = operands.first;
    final remainingOperands = operands.skip(1).toSet();

    for (var unary in unaryOperators) {
      currentMap[operand] = unary + operand;
      generateAllCombinations(
          remainingOperands, currentMap, results, expression);

      ///### changed here, José
      currentMap[operand] = '$operand!';
      generateAllCombinations(
          remainingOperands, currentMap, results, expression);

      currentMap.remove(operand); // Clean up for the next iteration
    }
  }

  List<String> allGeneratedExpressions = [];

  for (var expr in exprList) {
    final operands = extractOperands(expr);
    final generatedCombinations = <String>[];
    generateAllCombinations(operands, {}, generatedCombinations, expr);
    allGeneratedExpressions.addAll(generatedCombinations);
  }

  return allGeneratedExpressions;
}

void testForSpecificNumber() {
  var (numbersWithSolutionSet, numberToExprMap) = generateExprForList(
    strNumberList: [
      '2252',
      '2272',
    ],
    exprKinds: ['((a op b)! + c) = d', 'a = (-(b op c))!/d'],
    binaryOperators: ['+', '-', '*', '/', '**'],
    outputFile: File(r'z:\exprs.json'),
  );
  print(numberToExprMap);
}

void calcExpr() {
  try {
    print(isExprTrue('(0! + 6 - 4)! = 6'));
    print(isExprTrue('(0! -(6 - 8))! = 6'));
    print(isExprTrue('(1 + sqrt3 (6 + sqrt2 4))! = 6'));
    print(isExprTrue('(1 + sqrt3(6 + sqrt3 8))! = 6'));

    print(isExprTrue('sqrt3 ((2 - 2)! + 7) = 2'));
    print(isExprTrue('sqrt3 ((2 - 2)! + 7) = sqrt2 4'));
  } catch (e) {
    print('Error: ${e.toString()}');
  }
}
