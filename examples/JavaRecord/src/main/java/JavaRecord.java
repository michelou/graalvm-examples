import org.graalvm.polyglot.HostAccess;

public class JavaRecord {
    @HostAccess.Export public int x;
    @HostAccess.Export public String s;

    @HostAccess.Export
    public String name() {
        return "foo";
    }
}
