public class FastCounter extends CounterModel {
    /** The value by which to step by in a call. */
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

    public void upMany() {
        value = (value + step) % max;
    }

    public void downMany() {
        value = (value + max - step) % max;
    }

    public int getStep() {
        return step;
    }
}
