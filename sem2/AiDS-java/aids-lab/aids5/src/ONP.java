import java.util.Stack;
public class ONP {
    static ListStack stack = new ListStack();
    @SuppressWarnings("unchecked")
    public static String convert(String statement) {
        String result = "";
        boolean sign = true;

        //statement = statement.replaceAll(" ","");

        for (int i=0; i<statement.length(); i++) {
            if (statement.charAt(i) == '(') {
                stack.push("(");
                sign = true;
                result += " ";
            } else if (statement.charAt(i) == ')') {
                result += " " + getFromStackUntilBracket();
                sign = false;
            } else if ((statement.charAt(i) == '+' ||
                    statement.charAt(i) == '-' ||
                    statement.charAt(i) == '*' ||
                    statement.charAt(i) == '^' ||
                    statement.charAt(i) == '¬' ||
                    statement.charAt(i) == '∧' ||
                    statement.charAt(i) == '∨' ||
                    statement.charAt(i) == '⇒' ||
                    statement.charAt(i) == '⇔' ||
                    statement.charAt(i) == '/') && !sign) {
                result += " " + getFromStack(statement.substring(i, i+1));
                sign = true;
            } else {
                if (sign && statement.charAt(i) == '-') {
                    result += " ";
                }
                result += " " + statement.charAt(i);
                sign = false;
            }
            //System.out.println(result);
            //System.out.println(stack);
        }
        //System.out.println(result);
        result += getAllFromStack();
        System.out.println(result);
        //result = result.replaceAll("  ", " ");

        return result;
    }
    private static String getFromStackUntilBracket() {
        String result = "";
        String c = null;
        if (!stack.isEmpty()) {
            c = (String) stack.pop();
            while (!c.equals("(")){
                result = result + " " + c;
                if (stack.isEmpty()) break;
                c = (String) stack.pop();
            }
        }
        if (result.length() > 0) {
            result = " " + result;
        }
        return result;
    }
    @SuppressWarnings("unchecked")
    private static String getFromStack(String operator) {
        String result = "";
        String c = null;
        if (!stack.isEmpty()) {
            c = (String) stack.pop();
            boolean fix = true;
            while(hasHigherPrecedence(c.charAt(0), operator.charAt(0))){
            //while (((operator.equals("+") || operator.equals("-")) && !c.equals("(")) || ((operator.equals("/") || operator.equals("*")) && (c.equals("/") || c.equals("*")))){
                fix = false;
                result += c;
                if (stack.isEmpty()) break;
                c = (String) stack.pop();
            }
            if(!stack.isEmpty() || fix)stack.push(c);
        }
        stack.push(operator);

        return result;
    }
    private static boolean hasHigherPrecedence(char operator1, char operator2) {
        int precedence1 = getPrecedence(operator1);
        int precedence2 = getPrecedence(operator2);

        if (precedence1 == precedence2) {
            return isLeftAssociative(operator1);
        }

        return precedence1 > precedence2;
    }
    private static boolean isLeftAssociative(char operator) {
        return operator != '^' && operator != '⇒';
    }
    private static int getPrecedence(char operator) {
        switch (operator) {
            case '^', '¬':
                return 5;
            case '*', '/', '∧':
                return 4;
            case '+':
            case '-':
            case '∨':
                return 3;
            case '⇒':
                return 2;
            case '⇔':
                return 1;
            default:
                return 0; // domyślnnie dla nawiasów
        }
    }
    private static String getAllFromStack() {
        String result = "";
        String c = null;
        while (!stack.isEmpty()){
            c = (String) stack.pop();
            result += " " + c;
        }
        return result;
    }

}