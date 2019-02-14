import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class TestChainedCounterModel {
    @Test
    public void testCallNextAfterWrap() {
        CounterModel next = new CounterModel();
        ChainedCounterModel counter = new ChainedCounterModel(0, 1, next);
        counter.increment();
        assertEquals(0, counter.getValue());
        assertEquals(1, next.getValue());
    }
}
