/// P ::= n | \sqrt2 P | \sqrt3 P | P !
library;

///  a b c d     are the numbers optionally preceded by unary - or root of 2 or 3 (any number of them)
///  and postfixed by !
/// Options:
///    a = b op c op d
///    a op b = c op d
///    a op b op c = d
///
///    a = b op (c op d)
///    a op b = c op d
///    a op b op c = d
///
/*
 square root, cubic root,  ! (postfixed)

I want you to generate all possible expression kinds between
four integer numbers  named a, b, c, and d. 
They are all single-digit, between 0 and 9. Between them there can 
be binary an binary operation named 'op' and  unary - . Parenthesis can be used. The 
expressions are left associated. Hence, "a op b op c op d" is "((a op b) op c) op d"
In the generated expression, there should be an equal sign, =. 

The answer should be all possible expression kinds given in the format
of a Dart language list of string. Then, the answer should be something
as

const expressionKinds = [
  'a = b op c op d',
  'a op b = c op d',
  'a op b op c = d',
  'a op (b op c) = d',
  ...
];
*/

const expressionKinds = [
  'a = b op c op d',
  'a op b = c op d',
  'a op b = c op d',
  'a op b op c = d',
  'a = -b op c op d',
  'a op b op -c = d',
  'a op b op c = -d',
  'a = b op (c op d)',
  'a = -(b op c) op d',
  'a = -b op (c op d)',
  '-(a op b) = c op d',
  'a op b = -(c op d)',
  'a op (b op c) = d',
  '-(a op b) op c = d',
  'a op -(b op c) = d',
  '-a op (b op c) = d',
];

List<String> expressionKinds00 = [
  'a = b op c op d',
  'a = (b op c) op d',
  'a = b op (c op d)',
  'a op b = c op d',
  'a op b op c = d',
  '(a op b) op c = d',
  'a op (b op c) = d',
];

List<String> expressionKinds11 = [
  'a = -b op c op d',
  'a = (-b op c) op d',
  'a = -b op (c op d)',

  'a = b op -c op d',
  'a = (b op -c) op d',
  'a = b op (-c op d)',

  'a = b op c op -d',
  'a = (b op c) op -d',
  'a = b op (c op -d)',

  //
  '-a = -b op c op d',
  '-a = (-b op c) op d',
  '-a = -b op (c op d)',

  '-a = b op -c op d',
  '-a = (b op -c) op d',
  '-a = b op (-c op d)',

  '-a = b op c op -d',
  '-a = (b op c) op -d',
  '-a = b op (c op -d)',

  //
  'a = -b op -c op d',
  'a = (-b op -c) op d',
  'a = -b op (-c op d)',

  'a = -b op c op -d',
  'a = (-b op c) op -d',
  'a = -b op (c op -d)',

  'a = b op -c op -d',
  'a = (b op -c) op -d',
  'a = b op (-c op -d)',
  //
  '-a = -b op -c op d',
  '-a = (-b op -c) op d',
  '-a = -b op (-c op d)',

  '-a = -b op c op -d',
  '-a = (-b op c) op -d',
  '-a = -b op (c op -d)',

  '-a = b op -c op -d',
  '-a = (b op -c) op -d',
  '-a = b op (-c op -d)',

  '-a = -b op -c op -d',
  '-a = (-b op -c) op -d',
  '-a = -b op (-c op -d)',

  //
  'a op b op c = d',
  '(a op b) op c = d',
  'a op (b op c) = d',

  '-a op b op c = d',
  'a op -b op c = d',
  'a op b op -c = d',
  'a op b op c = -d',

  '-a op -b op c = d',
  '(-a op -b) op c = d',
  '-a op (-b op c) = d',

  '-a op b op -c = d',
  '(-a op b) op -c = d',
  '-a op (b op -c) = d',

  '-a op b op c = -d',
  '(-a op b) op c = -d',
  '-a op (b op c) = -d',

  'a op -b op -c = d',
  '(a op -b) op -c = d',
  'a op (-b op -c) = d',
  'a op -b op c = -d',
  '(a op -b) op c = -d',
  'a op (-b op c) = -d',

  'a op b op -c = -d',
  '(a op b) op -c = -d',
  'a op (b op -c) = -d',

  'a op -b op -c = -d',
  '(a op -b) op -c = -d',
  'a op (-b op -c) = -d',

  '-a op -b op -c = -d',
  '(-a op -b) op -c = -d',
  '-a op (-b op -c) = -d',
];

List<String> expressionKinds22 =
    expressionKinds11.map((elem) => elem.replaceAll('(', '-(')).toList();

List<(List<String>, List<String>)> expressionKindOpList = [
  (['+', '-', '*', '/'], expressionKinds00),
  (['+', '-', '*', '/', '**'], expressionKinds00),
  (['+', '-', '*', '/'], expressionKinds11),
  (['+', '-', '*', '/', '**'], expressionKinds11),
  (['+', '-', '*', '/'], expressionKinds22),
  (['+', '-', '*', '/', '**'], expressionKinds22),
  (['+', '-', '*', '/', '**'], []),
  (['+', '-', '*', '/', '**'], ['((a op b)! + c) = d', 'a = (-(b op c))!/d']),
];

List<String> expressionKinds33 = [];

Map<String, String> opToOperatorName = {
  '+': 'plus',
  '-': 'minus',
  '*': 'times',
  '/': 'divided by',
  '!': 'factorial',
  '**': 'power',
  'sqrt2': 'square root',
  'sqrt3': 'cubic root',
};

String exprToFilename((List<String>, List<String>) exprKind, int n) {
  var s = exprKind.$1.map((elem) => opToOperatorName[elem]).join('_');
  return 'solutionsUsing_${s.replaceAll(' ', '_')}_$n.json';
}

/*

I will give you a list of expressions between quotes named exprList. Each list element has '=' and 'op' that represents a binary operator. Your task is produce a longer list in which each possible operand is surrounded by the unary operators '!' (postfixed), 'sqrt2' (prefixed), and 'sqrt3' (prefixed). An operand is either one of the letters 'a', 'b', 'c', and 'd' (but not 'op', which represents an operand) or anything between parenthesis. For example, from 'a = (b op c) op d' you should produce 'a! = sqrt2 (b op c) op d!', 
'sqrt3 a = (b op c)! op d', etc. Produce all combinations of expressions with operands. So, some expressions in the result will have just one unary operator, such as 'sqrt2 a = (b op c) op d', others will have two or more unary operators. The list exprList follows.

  'a = b op c op d',
  'a = (b op c) op d',
  'a op b = c op d',
  'a op b = c op d',
  'a op b op c = d',
  '(a op b) op c = d',
  'a = -b op c op d',
  'a = (-b op c) op d',
  'a op b op -c = d',
  '(a op b) op -c = d',
  'a op b op c = -d',
  '(a op b) op c = -d',
  'a = b op (c op d)',
  'a = -(b op c) op d',
  'a = -b op (c op d)',
  '-(a op b) = c op d',
  'a op b = -(c op d)',
  'a op (b op c) = d',
  '-(a op b) op c = d',
  'a op -(b op c) = d',
  '-a op (b op c) = d',

*/

List<String> allExpressionKindsUnaryMinus() {
  List<String> exprList = [
    'a = b op c op d',
    'a op b = c op d',
    'a op b op c = d',
  ];

  List<String> generateExpressions(String expr) {
    List<String> results = [];

    // Split expression by ' ' which separates operands and operators
    var parts = expr.split(' ');

    // All possible placements of unary '-'
    for (int i = 0; i < parts.length; i++) {
      if (parts[i] != 'op' && parts[i] != '=' && !parts[i].startsWith('(')) {
        var newParts = List<String>.from(parts);
        newParts[i] = '-${newParts[i]}';
        results.add(newParts.join(' '));
      }
    }

    // All possible placements of parentheses
    void addParentheses(int start, int end) {
      if (start >= end) return;

      var withParens = List<String>.from(parts);
      withParens.insert(start, '(');
      withParens.insert(end + 1, ')');
      results.add(withParens.join(' '));

      for (var i = start + 2; i < end - 1; i += 2) {
        addParentheses(start, i);
        addParentheses(i + 2, end);
      }
    }

    for (var i = 1; i < parts.length - 1; i += 2) {
      for (var j = i + 2; j < parts.length; j += 2) {
        addParentheses(i - 1, j);
      }
    }

    return results.toSet().toList(); // Remove duplicates and return
  }

  List<String> allGeneratedExpressions = [];
  for (var expr in exprList) {
    allGeneratedExpressions.addAll(generateExpressions(expr));
  }

  return allGeneratedExpressions;
}
