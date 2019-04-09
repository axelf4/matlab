class RatNumTest2 {

	private static void fail(int nr) {
		System.out.println("RatNumTest2: Error number " + nr);
		System.exit(1);
	}

	public static void divTester() {
		RatNum r, r2;

		// Tests for the constructors
		r = new RatNum(9);
		if (r.getNumerator() != 9 || r.getDenominator() != 1) {
			fail(1);
		}
		r = new RatNum(4, 9);
		if (r.getNumerator() != 4 || r.getDenominator() != 9) {
			fail(2);
		}
		r = new RatNum(49, 168);
		if (r.getNumerator() != 7 || r.getDenominator() != 24) {
			fail(3);
		}
		r2 = new RatNum(r);
		if (r2.getNumerator() != 7 || r2.getDenominator() != 24) {
			fail(4);
		}
		r = new RatNum();
		if (r.getNumerator() != 0 || r.getDenominator() != 1) {
			fail(5);
		}
		if (r2.getNumerator() == 0 || r2.getDenominator() == 1) {
			fail(6);
		}
		r = new RatNum(5);
		if (r.getNumerator() != 5 || r.getDenominator() != 1) {
			fail(7);
		}
		r = new RatNum(20, 4);
		if (r.getNumerator() != 5 || r.getDenominator() != 1) {
			fail(8);
		}
		r = new RatNum(0,1);
		if (r.getNumerator() != 0 || r.getDenominator() != 1) {
			fail(9);
		}

		// Tests with negative arguments
		r = new RatNum(-49, 168);
		if (r.getNumerator() != -7 || r.getDenominator() != 24) {
			fail(10);
		}
		r = new RatNum(49, -168);
		if (r.getNumerator() != -7 || r.getDenominator() != 24) {
			fail(11);
		}
		r = new RatNum(-49, -168);
		if (r.getNumerator() != 7 || r.getDenominator() != 24) {
			fail(12);
		}

		// Tests for the exceptions
		boolean ok = false;
		try {
			r = new RatNum(5,0);
		}
		catch (NumberFormatException e1) {ok = true;}
		catch (Exception e2) {}
		if (!ok) {
			fail(13);
		}
	}

	public static void main(String[] arg) {
		divTester();
		System.out.println("No errors!");
	}
}
