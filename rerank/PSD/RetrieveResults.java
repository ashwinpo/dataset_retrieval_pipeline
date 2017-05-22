import java.util.LinkedList;

/**
 * Created by belon on 5/9/2017.
 */
public class RetrieveResults {
    private static LinkedList<Integer>[] results;

    static {
        results = new LinkedList[Queries.getQuerySize()];
        for (int i = 0; i < results.length; i++) {
            results[i] = new LinkedList<>();
            LinkedList<String> input = IO.readFromFile(Constants.RETRIEVAL_PATH + Queries.queryName(i) + "_hit_id.txt");
            for (String s : input) {
                results[i].add(Integer.parseInt(s));
            }
        }
    }

    public static LinkedList<Integer> getRetrieves(int index) {
        return results[index];
    }
}
