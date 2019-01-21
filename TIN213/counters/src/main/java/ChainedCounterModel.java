public class ChainedCounterModel extends CounterModel {
    /**
     * Counter that will be incremented after this counter wraps around.
     */
    private final CounterModel next;

    public ChainedCounterModel(int init, int max, CounterModel next) {
        super(init, max);
        this.next = next;
    }

    @Override
    public void increment() {
        super.increment();
        if (0 == value) next.increment(); // Value is zero after increment iff we wrapped around
    }
}
