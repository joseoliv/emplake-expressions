import 'dart:math';

const maximumPossibleValue = 32536;
const maxNumberExp = 9;

Map<String, int Function(int, int)> operatorMap = {
  '+': (int left, int right) {
    if ((left.toDouble()) + (right.toDouble()) > maximumPossibleValue) {
      throw 'Number too big: $left + $right';
    }
    return left + right;
  },
  '-': (int left, int right) {
    return left - right;
  },
  '*': (int left, int right) {
    if ((left.toDouble()) * (right.toDouble()) > maximumPossibleValue) {
      throw 'Number too big: $left * $right';
    }
    var r = left * right;
    if (r.abs() > maximumPossibleValue) {
      throw 'Number too big: $r';
    }
    return r;
  },
  '/': (int left, int right) {
    if (right == 0) {
      throw 'Division by zero';
    }
    if (left % right != 0) {
      throw "Invalid expression: the division of $left by $right leaves a rest";
    }
    return left ~/ right;
  },
  '**': (int left, int right) {
    // absolute value of left and right
    if (left.abs() > maxNumberExp || right.abs() > maxNumberExp) {
      throw 'Number too big for exponential: $left ** $right';
    }
    var r = pow(left, right);
    if (r > maximumPossibleValue) {
      throw 'Number too big: $r';
    }
    return r as int;
  },
};

const List<int> factorial = [
  1,
  1,
  2,
  6,
  24,
  120,
  720,
  5040,
  40320,
  362880,
  3628800,
  39916800,
  479001600
];

Map<String, int Function(int)> unaryOperatorMap = {
  '-': (int right) {
    return -right;
  },
  'sqrt2': (int right) {
    if (right < 0) {
      throw 'Negative number for square root';
    }
    int r = sqrt(right).toInt();
    if (r * r != right) {
      throw 'Invalid square root';
    }
    return r;
  },
  'sqrt3': (int right) {
    int r = pow(right, 1 / 3).toInt();
    if (r * r * r != right) {
      throw 'Invalid cubic root';
    }
    return r;
  },
  '!': (int right) {
    if (right < 0) {
      throw 'Negative number for factorial';
    }
    if (right > 9) {
      throw 'Number too big for factorial: $right';
    }
    return factorial[right];
  },
};

abstract class Expr {
  int eval({Map<String, int> variableValueMap = const {}});
}

class ExprOp extends Expr {
  ExprOp({required this.left, required this.op, required this.right});
  Expr left, right;
  String op;
  @override
  int eval({Map<String, int> variableValueMap = const {}}) {
    var opFunc = operatorMap[op];
    if (opFunc == null) {
      throw "Operator '$op' does not exist";
    }
    var evalLeft = left.eval(variableValueMap: variableValueMap);
    var evalRight = right.eval(variableValueMap: variableValueMap);
    return opFunc(evalLeft, evalRight);
  }
}

class NumExpr extends Expr {
  NumExpr(this.number);
  int number;
  @override
  int eval({Map<String, int> variableValueMap = const {}}) {
    return number;
  }
}

class ParentExpr extends Expr {
  ParentExpr(this.expr);
  Expr expr;
  @override
  int eval({Map<String, int> variableValueMap = const {}}) {
    return expr.eval(variableValueMap: variableValueMap);
  }
}

class PrefixUnaryExpr extends Expr {
  PrefixUnaryExpr(this.op, this.expr);
  String op;
  Expr expr;
  @override
  int eval({Map<String, int> variableValueMap = const {}}) {
    var opFunc = unaryOperatorMap[op];
    if (opFunc == null) {
      throw "Operator '$op' does not exist";
    }
    return opFunc(expr.eval(variableValueMap: variableValueMap));
  }
}

class PostFixUnaryExpr extends Expr {
  PostFixUnaryExpr(this.op, this.expr);
  String op;
  Expr expr;
  @override
  int eval({Map<String, int> variableValueMap = const {}}) {
    var opFunc = unaryOperatorMap[op];
    if (opFunc == null) {
      throw "Operator '$op' does not exist";
    }
    return opFunc(expr.eval(variableValueMap: variableValueMap));
  }
}

class Variable extends Expr {
  Variable(this.name);
  String name;

  @override
  int eval({Map<String, int> variableValueMap = const {}}) {
    if (variableValueMap.containsKey(name)) {
      return variableValueMap[name]!;
    }
    throw 'Variable $name not defined';
  }
}

class ParseExpr {
  ParseExpr()
      : input = '',
        index = 0,
        sizeInput = 0,
        token = '',
        variables = {} {
    next();
  }

  String input;
  int index;
  int sizeInput;
  String token;
  Set<String> variables;
  //
  void init(String input, {Set<String> variables = const {}}) {
    this.input = input;
    index = 0;
    sizeInput = input.length;
    token = '';
    this.variables = variables;
    next();
  }

  //
  void next() {
    while (index < sizeInput && input[index] == ' ') {
      ++index;
    }
    if (index >= sizeInput) {
      token = '';
      return;
    }
    var s = input[index];
    ++index;
    if (s == '*' && index < sizeInput && input[index] == '*') {
      ++index;
      token = '**';
    } else {
      if (RegExp(r'[a-zA-Z]').hasMatch(s)) {
        token = s;
        while (index < sizeInput &&
            RegExp(r'[a-zA-Z0-9]').hasMatch(input[index])) {
          token += input[index];
          ++index;
        }
      } else {
        token = s;
      }
    }
  }

  /// Expr ::= T { ('+' | '-' ) T }
  /// T    ::= F { ('*' | '/' ) F }
  /// F    ::=  G { '**' G }
  /// G    ::= I [ '!' ]
  /// I    ::=  { '-' | 'sqrt1' | 'sqrt3' } numExpr
  /// numExpr    ::= Num | Var | '(' Expr ')'
  /// Var ::= an identifier
  ///
  Expr parse() {
    var e = expr();
    if (token != '') {
      throw 'End of expression expected';
    }
    return e;
  }

  Expr expr() {
    var leftTerm = term();
    while (token == '+' || token == '-') {
      var op = token;
      next();
      var rightTerm = term();
      leftTerm = ExprOp(left: leftTerm, op: op, right: rightTerm);
    }
    return leftTerm;
  }

  Expr term() {
    var leftF = parseF();
    while (token == '*' || token == '/') {
      var op = token;
      next();
      var rightF = parseF();
      leftF = ExprOp(left: leftF, op: op, right: rightF);
    }
    return leftF;
  }

  Expr parseF() {
    var leftExponential = parseG();
    while (token == '**') {
      next();
      var rightExponential = parseG();
      leftExponential =
          ExprOp(left: leftExponential, op: '**', right: rightExponential);
    }
    return leftExponential;
  }

  Expr parseG() {
    var leftUnary = parseI();
    if (token == '!') {
      next();
      return PostFixUnaryExpr('!', leftUnary);
    }
    return leftUnary;
  }

  Expr parseI() {
    if (token == '-') {
      next();
      var e = parseI();
      return PrefixUnaryExpr('-', e);
    } else if (token == 'sqrt2') {
      next();
      var e = parseI();
      return PrefixUnaryExpr('sqrt2', e);
    } else if (token == 'sqrt3') {
      next();
      var e = parseI();
      return PrefixUnaryExpr('sqrt3', e);
    } else {
      return numVarExpr();
    }
  }

  Expr numVarExpr() {
    if (RegExp(r'[0-9]+$').hasMatch(token)) {
      /// convert token to an int number n
      var n = int.tryParse(token);
      if (n == null) {
        throw "Number expected";
      }
      next();
      return NumExpr(n);
    } else if (token == '(') {
      next();
      var e = expr();
      if (token != ')') {
        throw '\')\' expected at position $index';
      }
      next();
      return ParentExpr(e);
      // } else if ('abcd'.contains(token)) {
      //   next();
      //   return NumExpr(0);
    } else if (variables.contains(token)) {
      var variableName = token;
      if (!variables.contains(variableName)) {
        throw 'Variable $variableName not defined';
      }
      next();
      return Variable(token);
    } else {
      throw 'Unexpected character at position $index';
    }
  }

  /// Function ::= Id '(' Id ')' '=' Expr
  Expr parseFunction() {
    if (!RegExp(r'[A-Za-z][A-Za-z0-9]*$').hasMatch(token)) {
      throw 'Function name expected';
    }
    next();
    if (token != '(') {
      throw '( expected';
    }
    next();

    var e = expr();
    if (token != '') {
      throw 'End of expression expected';
    }
    return e;
  }
}

bool isExprTrue(String exprStr) {
  if (!exprStr.contains('=')) {
    return false;
  } else {
    var exprList = exprStr.split('=');
    if (exprList.length != 2) {
      return false;
    }
    ParseExpr leftParse = ParseExpr();
    leftParse.init(exprList[0]);
    ParseExpr rightParse = ParseExpr();
    rightParse.init(exprList[1]);
    try {
      var leftTree = leftParse.parse();
      var leftValue = leftTree.eval(variableValueMap: const {});
      var rightTree = rightParse.parse();
      var rightValue = rightTree.eval(variableValueMap: const {});
      return leftValue == rightValue;
    } catch (e) {
      return false;
    }
  }
}
