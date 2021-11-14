import org.graalvm.polyglot.Context;

public class Main {

    public static void main(String[] args) {
        Context context = Context.create();

        JavaRecord record = new JavaRecord();
        context.getBindings("js").putMember("javaRecord", record);

        context.eval("js", "javaRecord.x = 42");
        context.eval("js", "javaRecord.s = 'hello'");
        assert record.x == 42;
        assert record.s == "hello";

        context.eval("js", "javaRecord.name()").asString().equals("foo");
    }

}
