import java.util.HashSet;
import java.util.LinkedList;

/**
 * Created by belon on 5/9/2017.
 */
public class OriginalFile {
    private static HashSet<String> selectedFields;

    static {
        selectedFields = new HashSet<>();
        LinkedList<String> input = IO.readFromFile(Constants.FIELD_FILE);
        for (String s: input) {
            if (s.trim().length() > 0 && s.startsWith(" ")) {
                String ss = s.trim().toLowerCase();
                if (!selectedFields.contains(ss)) {
                    selectedFields.add(ss);
                }
            }
        }
    }

    public static int[] read(int index) {
        return read(Constants.FILE_PATH + index + ".json");
    }

    public static int[] read(String filename) {
        LinkedList<String> input = IO.readFromFile(filename);
        LinkedList<Integer> output = new LinkedList<>();
        for (String s : input) {
            String[] ss = s.toLowerCase().split("[:]", 2);
            if (ss.length < 2) {
                continue;
            }
            ss[0] = ss[0].trim();
            ss[1] = ss[1].trim();
            String[] sss = ss[0].split("[.]", 2);
            if (!selectedFields.contains(ss[0]) && (sss.length < 2 || !selectedFields.contains(sss[1]))) {
                continue;
            }
            String[] line = s.split(Constants.SPLIT);
            for (String s0 : line) {
                int index = Stemmer.getIndex(s0);
                if (Stemmer.NOT_FOUND_INT != index) {
                    output.add(index);
                }
            }
        }
        int[] res = new int[output.size()];
        for (int i = 0; i < output.size(); i++) {
            res[i] = output.get(i);
        }
        return res;
    }
}
