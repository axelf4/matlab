import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class TestCounterModel {
    
    @Test
    public void testNewCounter() {
        CounterModel counter = new CounterModel();
        assertEquals(0, counter.getValue());
    }
    
    @Test
    public void testIncrement() {
        CounterModel counter = new CounterModel();
        counter.increment();
        assertEquals(1, counter.getValue());
    }
    
    @Test
    public void testDecrement() {
        CounterModel counter = new CounterModel();
        counter.increment();
        counter.decrement();
        assertEquals(0, counter.getValue());
    }
    
    @Test
    public void testReset() {
        CounterModel counter = new CounterModel();
        counter.increment();
        counter.increment();
        counter.reset();
        assertEquals(0, counter.getValue());
    }
    
    // Different counters should have different values
    @Test
    public void testTwoCounters() {
        CounterModel counter1 = new CounterModel();
        CounterModel counter2 = new CounterModel();
        counter1.increment();
        counter2.increment();
        counter2.increment();
        assertEquals(1, counter1.getValue());
        assertEquals(2, counter2.getValue());
    }

    // A counter with a maximum of three incremented four times should wrap around once
    @Test
    public void testIncrementMaxThree() {
        CounterModel counter = new CounterModel(0, 3);
        for (int i = 0; i < 4; ++i) counter.increment();
        assertEquals(1, counter.getValue());
    }

    // A counter with a maximum of three decremented should wrap around once
    @Test
    public void testDecrementWrap() {
        CounterModel counter = new CounterModel(0, 3);
        counter.decrement();
        assertEquals(2, counter.getValue());
    }

    @Test
    public void testDefaultConsSetsMaxValue() {
        CounterModel counter = new CounterModel();
        assertEquals(10, counter.max);
    }
}
