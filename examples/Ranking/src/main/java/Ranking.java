package nl.avisi;

import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.infra.Blackhole;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Warmup(iterations = 3)
@Measurement(iterations = 3)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@Fork(1)
public class Ranking {

    @Benchmark
    public void rank(Blackhole sink) {
        String[] files = getPlayFiles();
        Arrays.stream(files)
              .flatMap(Ranking::fileLines)
              .flatMap(line -> Arrays.stream(line.split(",")))
              .map(word -> word.replaceAll("[^a-zA-Z]", ""))
              .filter(word -> word.length() > 0)
              .map(word -> word.toLowerCase())
              .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()))
              .entrySet().stream()
              .sorted((a, b) -> -a.getValue().compareTo(b.getValue()))
              .limit(10)
              .forEach(e -> sink.consume(e));
    }

    private static Stream<String> fileLines(String path) {
        try {
            return Files.lines(Paths.get(path));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private static boolean doPrint = true;
    private static String[] getPlayFiles() {
        String classPath = Ranking.class.getProtectionDomain().getCodeSource().getLocation().getPath();
        File parentFile = new File(classPath).getParentFile();
        List<String> files = new ArrayList<String>();
        for (File file: parentFile.listFiles(new java.io.FilenameFilter() {
            @Override
            public boolean accept(File directory, String fileName) {
                return fileName.matches("chart2000.*\\.csv$"); //"play[0-9]*\\.txt$"
            }
        })) {
            files.add(file.getAbsolutePath());
        }
        if (doPrint) {
            System.out.println("files=" + files.toString());
            doPrint = false;
        }
        return files.toArray(new String[0]);
    }
}
