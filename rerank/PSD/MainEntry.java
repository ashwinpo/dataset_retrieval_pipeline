import java.util.Collections;
import java.util.LinkedList;

/**
 * Created by belon on 5/8/2017.
 */
public class MainEntry {

    public static void main(String[] args) {
        LinkedList<String> output = new LinkedList<>();
        for (int i = 0; i < Queries.getQuerySize(); i++) {
            int[] query = Queries.getQuery(i);
	    System.out.println("Query: " + i);
            String queryName = Queries.queryName(i);
            LinkedList<Integer> retrieve = RetrieveResults.getRetrieves(i);
            LinkedList<ComparableRecord<Integer>> compareFiles = new LinkedList<>();
            for (int j : retrieve) {
                int[] fileContent = OriginalFile.read(j);
                double score = Score.computeScore(fileContent, query);
                compareFiles.add(new ComparableRecord<>(j, score));
            }
            Collections.sort(compareFiles);
            for (int j = 0; j < compareFiles.size(); j++) {
                output.add(queryName + " 0 " + compareFiles.get(j).record + " " + (j + 1) + " "
                        + compareFiles.get(j).score + " auto-run");
            }
        }
        IO.writeFile(output, Constants.OUTPUT_FILE);
    }
}
