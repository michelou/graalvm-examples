import static org.junit.Assert.*;
import org.junit.Test;

public class CountUppercaseJUnitTest {

    private static String sentence = "In 2019 I would like to run ALL languages in one VM.";

    @Test
    public void test() {
        long total = CountUppercase.computeTotal(sentence);
        assertEquals("Total of uppercases is 69999993", total, 69999993);
    }

}
