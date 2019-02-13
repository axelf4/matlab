/**
 * An immutable two-dimensional vector.
 *
 * Methods allocate new instances and are by design slower than their mutable counterparts.
 * If this somehow is of any concern what so ever then maybe you shouldn't be using Java.
 * Besides it maps closer to hardware SIMD registers and opens up for fearless concurrency.
 *
 * Here's to looking out for Project Valhalla.
 */
public class Vector2 {
    /** The zero-vector. */
    public static final Vector2 ZERO = new Vector2();
    public static final Vector2 I_HAT = new Vector2(1, 0), J_HAT = new Vector2(0, 1);
	/** This positive bad boy is very pretty close to zero. */
    private static final double EPSILON = 1e-6;

    /**
     * The x-component of the vector.
     */
    public final double x,
    /**
     * The y-component of the vector.
     */
    y;

    /**
     * Initializes the vector to the zero-vector.
     */
    public Vector2() {
        this(0, 0);
    }

	/** Initializes the vector to the specified components. */
    public Vector2(double x, double y) {
        this.x = x;
        this.y = y;
    }

    public Vector2(int x, int y) {
        this((double) x, (double) y);
    }

    /**
     * Returns the sum of the two vectors.
     */
    public Vector2 add(Vector2 v) {
        return new Vector2(x + v.x, y + v.y);
    }

    /**
     * Returns this vector scaled by the specified scalar.
     */
    public Vector2 mul(double s) {
        return new Vector2(s * x, s * y);
    }

    /**
     * Returns this vector negated.
     */
    public Vector2 neg() {
        return new Vector2(-x, -y);
    }

    public Vector2 sub(Vector2 v) {
        return add(v.neg());
    }

    /**
     * Returns the vector dot product of the two vectors.
     */
    public double dot(Vector2 v) {
        return x * v.x + y * v.y;
    }

    public Vector2 normalize() {
        return this.mul(1. / Math.sqrt(dot(this)));
    }

    public boolean epsilonEquals(Vector2 v) {
        return Math.abs(v.x - x) <= EPSILON && Math.abs(v.y - y) <= EPSILON;
    }
}
