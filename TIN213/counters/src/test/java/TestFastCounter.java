import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class TestFastCounter {
    @Test
    void testDownManyOnce() {
        FastCounter counter = new FastCounter(0, 5, 2);
        counter.downMany();
        assertEquals(3, counter.getValue());
    }
}
