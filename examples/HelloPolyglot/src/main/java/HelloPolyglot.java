import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.Engine;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.util.Base64;
import java.util.Set;

public class HelloPolyglot {

    public static void main(String[] args) {
        System.out.println("Hello Java!");
     // evaluate("java",      "System.out.println(\"Hello Espresso!\");");
        evaluate("js",        "print('Hello JavaScript!');");
        evaluate("python",    "print('Hello Python!')");
        evaluate("R",         "print('Hello R!');");
        evaluate("ruby",      "puts 'Hello Ruby!'");
     // evaluate("smalltalk", "Transcript show: 'Hello Smalltalk'.");
     // evaluate("wasm",      loadAssemblyFile("HelloPolyglot.wasm"));
    }

    private static Set<String> ids = Engine.create().getLanguages().keySet();
    static {
        System.out.println("Available languages: " + ids.toString());
    }

    private static void evaluate(String languageId, String code) {
        if (!ids.contains(languageId)) {
            System.err.println("Language " + languageId + " not supported on this platform");
            return;
        }
        try (Context context = createContext(languageId)) {
            context.eval(languageId, code);
        }
    }

    private static Context createContext(String languageId) {
        // R and smalltalk currently require the allowAllAccess
        // flag to be set to true to run the example.
        switch (languageId) {
            case "java":
                return Context.newBuilder().allowNativeAccess(true).build();
            case "R":
            case "smalltalk":
                return Context.newBuilder().allowAllAccess(true).build();
            default:
                return Context.create();
        }
    }

    private static String loadAssemblyFile0(String fileName) {
        ClassLoader cl = HelloPolyglot.class.getClassLoader();
        InputStream is = cl.getResourceAsStream(fileName);
        if (is == null) {
            throw new IllegalArgumentException("file not found! " + fileName);
        }
        try {
            File file = new File(cl.getResource(fileName).getFile());
         
            //File is found
            System.out.println("File Found : " + file.exists());

            //Read File Content
            return new String(Files.readAllBytes(file.toPath()));
        } catch (Exception e) {
            return "";
        }
    }

    private static String loadAssemblyFile(String fileName) {
        ClassLoader cl = HelloPolyglot.class.getClassLoader();
        InputStream is = cl.getResourceAsStream(fileName);
        if (is == null) {
            throw new IllegalArgumentException("File not found! " + fileName);
        }
        try {
            ByteArrayOutputStream result = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            for (int length; (length = is.read(buffer)) != -1;) {
                result.write(buffer, 0, length);
            }
            // StandardCharsets.UTF_8.name() > JDK 7
            // return result.toString();
            return new String(Base64.getEncoder().encode(result.toByteArray()));
        } catch (Exception e) {
            return "";
        }
    }

}
