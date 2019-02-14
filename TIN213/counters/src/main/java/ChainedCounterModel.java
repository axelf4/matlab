/**
 * A CounterModel with an associated counter that is incremented after this counter wraps around.
 */
public class ChainedCounterModel extends CounterModel {
    /**
     * Counter that is incremented after this counter wraps around to the right.
     */
    private final CounterModel next;

    /**
     * Creates a new \c ChainedCounterModel and initializes it to the specified values.
     *
     * @param init The initial value.
     * @param max  The exclusive maximum value.
     * @param next The counter that is incremented after this counter wraps around.
     */
    public ChainedCounterModel(int init, int max, CounterModel next) {
        super(init, max);
        this.next = next != null ? next : new CounterModel(); // XXX For whatever reason next is allowed to be null
    }

    @Override
    public void increment() {
        super.increment();
        if (0 == getValue()) next.increment(); // Value is zero after increment iff we wrapped around
    }
}
