import java.util.*;

public class RatNumTest1 {

	private static void test(int m, int n, int correctResult) {
		System.out.print("The numbers are " + m + " and " + n + ".\t");
		int z = 0;
		try {
			z = RatNum.gcd(m,n);
		}
		catch (IllegalArgumentException e1) {
			if (m==0 || n==0) {
				System.out.println("Correct IllegalArgumentException generated");
			} else {
				System.out.println("Incorrect IllegalArgumentException generated" +
						"  *************");
			}
			return;
		}
		catch (Exception e2) {
			System.out.print(e2.getMessage());
			System.out.println("Incorrect exception generated *************");
			return;
		}
		if (m==0 || n==0) {
			System.out.print("gcd should generate IllegalArgumentException");
			System.out.println("  *************");
			return;
		}
		System.out.print("Your result: " + z +
				".\tCorrect result: " + correctResult + ".");
		if (z != correctResult) {
			System.out.println("  *************");
		} else {
			System.out.println();
		}
	}

	public static void main (String[] arg) {
		test(1, 1, 1);
		test(12, 1, 1);
		test(12, 2, 2);
		test(12, 14, 2);
		test(22, 14, 2);
		test(39, 15, 3);
		test(40, 12, 4);
		test(168, 49, 7);
		test(143, 7, 1);
		test(7, 143, 1);
		test(1260, 36, 36);
		test(36, 1260, 36);
		test(15775, 100, 25);
		test(100, 15775, 25);
		test(15776, 100, 4);
		test(15775, 12, 1);
		test(0, 12, 0);
		test(12, 0, 0);
		test(0, 0, 0);
		test(-6, 39, 3);
		test(39, -6, 3);
		test(-6, -39, 3);
	}
}
