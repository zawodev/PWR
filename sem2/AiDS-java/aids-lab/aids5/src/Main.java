public class Main {
    public static int AlgebraicONP(String expression) {
        ListStack<Integer> stack = new ListStack<>();
        for (int i = 0; i < expression.length(); i++) {
            char c = expression.charAt(i);
            if (Character.isDigit(c)) {
                int operand = c - '0';
                stack.push(operand);
            }
            else if (c == '+' || c == '-' || c == '*' || c == '/' || c == '^') {
                int operand2 = stack.pop();
                int operand1 = stack.pop();
                int result = performAlgebraicOperation(operand1, operand2, c);
                stack.push(result);
            }
            //System.out.println(stack);
        }
        return stack.pop();
    }
    private static int performAlgebraicOperation(int operand1, int operand2, char operator) {
        switch (operator) {
            case '+':
                return operand1 + operand2;
            case '-':
                return operand1 - operand2;
            case '*':
                return operand1 * operand2;
            case '/':
                return operand1 / operand2;
            case '^':
                return (int)(Math.pow(operand1, operand2));
            default:
                throw new IllegalArgumentException("Invalid operator: " + operator);
        }
    }

    public static int LogicONP(String expression, boolean p, boolean q, boolean r, boolean s) {
        ListStack<Boolean> stack = new ListStack<>();

        for (int i = 0; i < expression.length(); i++) {
            char c = expression.charAt(i);
            if (c == 'p') {
                stack.push(p);
            }
            else if (c == 'q') {
                stack.push(q);
            }
            else if (c == 'r') {
                stack.push(r);
            }
            else if (c == 's') {
                stack.push(s);
            }
            else if (c == '∧' || c == '∨' || c == '⇒' || c == '⇔') {
                boolean operand2 = stack.pop();
                boolean operand1 = stack.pop();
                boolean result = performLogicalOperation(operand1, operand2, c);
                stack.push(result);
            }
            //System.out.println(stack);
        }
        return stack.pop() ? 1 : 0;
    }

    private static boolean performLogicalOperation(boolean operand1, boolean operand2, char operator) {
        switch (operator) {
            case '∨':  // or operator
                return operand1 || operand2;
            case '∧':  // and operator
                return operand1 && operand2;
            case '⇒':  // implikacja operator
                return !operand1 || operand2;
            case '⇔':  // "wtedy i tylko wtedy" operator
                //System.out.print(operand1);
                //System.out.print(operand2);
                return operand1 == operand2;
                //return (!operand1 && !operand2) || (operand1 && operand2);
            default:
                throw new IllegalArgumentException("Invalid operator: " + operator);
        }
    }

    public static void main(String[] args) {
        //String algebraicExpression = "5*((3-7)*2-3*(5+1))-3";
        String algebraicExpression = "1+2^4+3";
        //String algebraicExpression = "3+2-4-1+5";
        //String algebraicExpression = "3+4*2/(1-5)^2";
        int algebraicResult = AlgebraicONP(ONP.convert(algebraicExpression));
        System.out.println("Algebraic Expression Result: " + algebraicResult);

        /*
        ⇒
        ⇔
        ⌐
        ¬
        ∧
        ∨
        */
        String logicalExpression = "(p∧q)∨(r⇒s)";
        //String logicalExpression = "p⇒q⇒r";
        boolean p = false;
        boolean q = true;
        boolean r = false;
        boolean s = true;
        int logicalResult = LogicONP(ONP.convert(logicalExpression), p, q, r, s);
        System.out.println("Logical Expression Result: " + logicalResult);
    }
}