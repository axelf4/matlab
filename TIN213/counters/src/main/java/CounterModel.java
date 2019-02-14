public class CounterModel {
    /**
     * The max value before wrapping around.
     */
    protected final int max;
    /**
     * The current value of this counter.
     */
    private int value;

    /**
     * Creates a new CounterModel and initializes value to `0` and max to `10`.
     */
    public CounterModel() {
        this(0, 10);
    }

    /**
     * Creates a new CounterModel with the specified parameters.
     */
    public CounterModel(int init, int max) {
        value = init;
        this.max = max;
    }

    /**
     * Increments the value by one, wrapping if necessary.
     */
    public void increment() {
        value = (value + 1) % max;
    }

    /**
     * Decrements the value by one wrapping around if instead of going negative.
     * <p>
     * Contrary to the specification this implementation does wrapping.
     */
    public void decrement() {
        value = (value + max - 1) % max;
    }

    /**
     * Sets the value of the counter to zero.
     */
    public void reset() {
        value = 0;
    }

    /**
     * Returns the value of this counter.
     *
     * @return The value of this counter.
     */
    public int getValue() {
        return value;
    }
}
