import java.io.*;
import java.util.*;

class RatNumTest3 {

	private static void divTester() {
		// Tests for equals and clone
		RatNum x = new RatNum(6,2);
		RatNum y = new RatNum(0);
		RatNum z = new RatNum(0,1);
		RatNum w = new RatNum(75,25);
		if (x.equals(y) || !y.equals(z) || !x.equals(w)) {
			System.out.println("RatNumTest3: Equality test failed");
		}

		y = (RatNum) x.clone();

		if (!y.equals(x) || y==x) {
			System.out.println("RatNumTest3: Test of clone failed");
		}

		// Test for toDouble
		for (int i=1; i<=9; i++) {
			for (int j=0; j <= 2*i; j++) {
				if( Math.abs(new RatNum(j, i).toDouble() - (double)j/i) > 1.0e-13) {
					System.out.println("RatNumTest3: Test of toDouble failed for " + j + "/" + i);
				}
			}
		}
	}

	public static void main(String[] arg) throws IOException {
		RatNumTest2.divTester();
		divTester();
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		System.out.println("Enter an expression of the form a/b ? c/d, where ? is one of the characters + - * / = <");
		while (true) {
			System.out.print("> ");  System.out.flush();
			String s = in.readLine();
			if (s == null)
				break;
			Scanner sc = new Scanner(s);
			String[] a = new String[3];
			int i;
			for(i=0; i<3 && sc.hasNext(); i++)
				a[i] = sc.next();
			if (i > 0 ) {
				System.out.print(s + "\t--> ");
				if (i != 3 || sc.hasNext())
					System.out.println("Invalid expression!");
				else
					try {
						RatNum r1 = RatNum.parse(a[0]);
						String op = a[1];
						char c = op.charAt(0);
						RatNum r2 = new RatNum(a[2]);
						if (op.length() != 1 || "+-*/=<".indexOf(c) < 0)
							System.out.println("Invalid operator!");
						else {
							RatNum res = null;
							if (c == '+')
								res = r1.add(r2);
							else if (c == '-')
								res = r1.sub(r2);
							else if (c == '*')
								res = r1.mul(r2);
							else  if (c == '/')
								res = r1.div(r2);
							else if (c == '=')
								System.out.println(r1.equals(r2));
							else if (c == '<')
								System.out.println(r1.lessThan(r2));
							if ("+-*/".indexOf(c) >= 0)
								if (res == null)
									System.out.println("Error in addition, subtraction, multiplication or division");
								else
									System.out.println(res);
						}
					}
					catch (NumberFormatException e) {
						System.out.println("NumberFormatException: " + e.getMessage());
					}
			}
		}
	}
}
