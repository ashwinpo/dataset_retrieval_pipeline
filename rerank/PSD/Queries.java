import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;

/**
 * Created by belon on 5/9/2017.
 */
public class Queries {
    private static LinkedList<int[]> queries;
    private static LinkedList<String> names;

    static {
        HashSet<String> uselessWords = new HashSet<>(Arrays.asList( "look", "for", "search", "find", "all",
                "data", "of", "types", "related", "to", "across", "database", "databases", "type", "on", ""
        ));
        LinkedList<String> input = IO.readFromFile(Constants.QUERY_FILE);
        names = new LinkedList<>();
        queries = new LinkedList<>();
        for (String s : input) {
            if (s.trim().length() == 0) {
                continue;
            }
            if (s.startsWith(">")) {
                names.add(s.substring(1).trim());
                continue;
            }
            String[] line = s.toLowerCase().split(Constants.SPLIT);
            int start = 0;
            while (start < line.length && uselessWords.contains(line[start])) {
                start++;
            }
            int end = line.length - 1;
            while (start < end && uselessWords.contains(line[end])) {
                end--;
            }
            int[] query = new int[end - start + 1];
            for (int i = start; i <= end; i++) {
                query[i - start] = Stemmer.getIndex(line[i]);
            }
            queries.add(query);
        }
    }

    public static int getQuerySize() {
        return queries.size();
    }

    public static String queryName(int index) {
        return names.get(index);
    }

    public static int[] getQuery(int index) {
        return queries.get(index).clone();
    }
}
