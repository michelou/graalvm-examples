import org.graalvm.polyglot.Context;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class MainJUnitTest {

    @Test
    public void test() {
        Context context = Context.create();

        JavaRecord record = new JavaRecord();
        context.getBindings("js").putMember("javaRecord", record);

        context.eval("js", "javaRecord.x = 42");
        assertEquals("JavaRecord", record.x, 42);
    }

}
