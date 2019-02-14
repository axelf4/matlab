import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class TestFastCounter {
    @Test
    public void testDownManyOnce() {
        FastCounter counter = new FastCounter(4, 5, 2);
        counter.downMany();
        assertEquals(2, counter.getValue());
    }

    @Test
    public void testUpManyOnce() {
        FastCounter counter = new FastCounter(0, 5, 2);
        counter.upMany();
        assertEquals(2, counter.getValue());
    }

    @Test
    public void testDownManyOnceWraps() {
        FastCounter counter = new FastCounter(0, 5, 2);
        counter.downMany();
        assertEquals(3, counter.getValue());
    }

    @Test
    public void testUpManyOnceWraps() {
        FastCounter counter = new FastCounter(0, 5, 2);
        for (int i = 0; i < 3; ++i) counter.upMany();
        assertEquals(1, counter.getValue());
    }

    @Test
    public void testDefaultConsIsntStupid() {
        FastCounter counter = new FastCounter();
        assertEquals(0, counter.getValue());
        assertEquals(5, counter.getStep());
        assertEquals(15, counter.max);
    }

    @Test
    public void testConstructorWithActualParameters() {
        FastCounter counter = new FastCounter(0, 5, 2);
        assertEquals(2, counter.getStep());
        assertEquals(0, counter.getValue());
        assertEquals(5, counter.max);
    }

    @Test
    public void testGetStep() {
        assertEquals(5, new FastCounter(0, 15, 5).getStep()); // Who could've guessed?! It works!
    }
}
