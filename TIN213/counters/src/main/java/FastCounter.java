public class FastCounter extends CounterModel {
    /**
     * The value by which to step by in a call.
     */
    private final int step;

    public FastCounter(int init, int max, int step) {
        super(init, max);
        if (step < 0) throw new IllegalArgumentException("Step cannot be negative.");
        this.step = step;
    }

    public FastCounter() {
        super(0, 15);
        step = 5;
    }

    /**
     * Increment `step` times.
     */
    public void upMany() {
        for (int i = 0; i < step; ++i) increment();
    }

    /**
     * Decrement `step` times.
     */
    public void downMany() {
        for (int i = 0; i < step; ++i) decrement();
    }

    /**
     * Returns the number of times this counter de-/increments when calling the *Many methods.
     *
     * @return The step size.
     */
    public int getStep() {
        return step;
    }
}
