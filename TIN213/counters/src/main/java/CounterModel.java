public class CounterModel {
    protected int value;
    protected final int max;

    public CounterModel() {
        this(0, 10);
    }

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
     * Decrements the value by one WITHOUT wrapping.
     */
    public void decrement() {
        --value;
    }

    /**
     * Sets the value of the counter to zero.
     */
    public void reset() {
        value = 0;
    }

    /**
     * Returns the value of this counter.
     * @return The value of this counter.
     */
    public int getValue() {
        return value;
    }
}
