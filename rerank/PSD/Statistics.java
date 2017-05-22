import java.io.File;
import java.util.LinkedList;

/**
 * Created by belon on 5/9/2017.
 */
public class Statistics {
    private static int[] counts;

    static {
        if (!new File(Constants.STAT_FILE).exists()) {
            getStatistics();
        }
        String[] input = IO.readFromFile(Constants.STAT_FILE).get(0).split("[,]");
        counts = new int[input.length];
        for (int i = 0; i < input.length; i++) {
            counts[i] = Integer.parseInt(input[i]);
        }
    }

    private static void getStatistics() {
        File[] files = new File(Constants.FILE_PATH).listFiles();
        int[] counts = new int[Stemmer.getIndexSize()];
        System.out.println("This process may take a long time. But you can terminate it and redo it anytime.");
        for (File file : files) {
            int[] fileContent = OriginalFile.read(file.getAbsolutePath());
            for (int i : fileContent) {
                counts[i]++;
            }
        }
        StringBuilder stringBuilder = new StringBuilder();
        int sum = 0;
        for (int i : counts) {
            sum += i;
            stringBuilder.append(i).append(',');
        }
        stringBuilder.append(sum);
        LinkedList<String> output = new LinkedList<>();
        output.add(stringBuilder.toString());
        IO.writeFile(output, Constants.STAT_FILE);
    }

    public static int getStat(int i) {
        return counts[i];
    }

    public static int getAllCounts() {
        return counts[counts.length - 1];
    }
}
