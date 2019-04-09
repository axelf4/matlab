import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RatNum implements Cloneable {
	private final int a, b;

	public RatNum() {
		this(0, 1);
	}

	public RatNum(int a) {
		this(a, 1);
	}

	public RatNum(int a, int b) {
		if (b == 0) throw new NumberFormatException("Denominator = 0");

		if (b < 0) {
			a *= -1;
			b *= -1;
		}

		if (a != 0) {
			final int gcd = gcd(a, b);
			a /= gcd;
			b /= gcd;
		}

		this.a = a;
		this.b = b;
	}

	public RatNum(RatNum r) {
		this(r.a, r.b);
	}

	public RatNum(String s) {
		this(parse(s));
	}

	public static RatNum parse(String s) {
		Pattern pattern = Pattern.compile("(?<a>-?\\d+)(?:/(?<b>-?\\d+))?");
		Matcher matcher = pattern.matcher(s);
		if (!matcher.matches()) throw new NumberFormatException();
		String a = matcher.group("a"), b = matcher.group("b");
		if (b != null) return new RatNum(Integer.parseInt(a), Integer.parseInt(b));
		else return new RatNum(Integer.parseInt(a));
	}

	/**
	 * Returns the greatest common divisor of the two specified numbers.
	 *
	 * @param a The first number.
	 * @param b The second number.
	 * @return A positive integer.
	 * @throws IllegalArgumentException If a or b are zero.
	 */
	static int gcd(int a, int b) {
		if (a == 0 || b == 0) throw new IllegalArgumentException();
		if (a == b) return a;
		a = Math.abs(a);
		b = Math.abs(b);
		int shift;
		// Store and divide by greatest common power of 2
		for (shift = 0; ((a | b) & 1) == 0; ++shift, a >>>= 1, b >>>= 1) ;
		while ((a & 1) == 0) a >>>= 1; // Ignore non-common two-factors
		do {
			while ((b & 1) == 0) b >>>= 1; // Remove non-common two-factors
			// a and b are odd; swap if necessary
			if (a > b) {
				a ^= b;
				b ^= a;
				a ^= b;
			}
		} while ((b -= a) != 0);

		return a << shift;
	}

	public int getNumerator() {
		return a;
	}

	public int getDenominator() {
		return b;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		if (a / b != 0) builder.append(a / b);
		if (b != 1) builder.append(String.format(" %d/%d", a % b, b));
		return builder.toString();
	}

	public double toDouble() {
		return (double) a / b;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;
		RatNum ratNum = (RatNum) o;
		return a == ratNum.a && b == ratNum.b;
	}

	@Override
	public int hashCode() {
		return 31 * a + b;
	}

	public boolean lessThan(RatNum r) {
		return toDouble() < r.toDouble();
	}

	public RatNum add(RatNum r) {
		return new RatNum(a * r.b + r.a * b, b * r.b);
	}

	public RatNum sub(RatNum r) {
		return new RatNum(a * r.b - r.a * b, b * r.b);
	}

	public RatNum mul(RatNum r) {
		return new RatNum(a * r.a, b * r.b);
	}

	public RatNum div(RatNum r) {
		return new RatNum(a * r.b, b * r.a);
	}

	@Override
	protected Object clone() {
		return new RatNum(this);
	}
}
