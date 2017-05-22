import java.util.Hashtable;
import java.util.LinkedList;
import java.io.File;

/**
 * Created by belon on 5/8/2017.
 */
public class Stemmer {
    public static final String NOT_FOUND_STRING = null;
    public static final int NOT_FOUND_INT = -1;

    private static Hashtable<String, String> mapping;
    private static Hashtable<String, Integer> mappingToIndex;

    static {
        if (!new File(Constants.MAPPING_FILE).exists()) {
            System.out.println("Fail to find mapping file");
            mapping = null;
        } else {
            mapping = new Hashtable<>();
            mappingToIndex = new Hashtable<>();
            String[] input = IO.readFromFile(Constants.MAPPING_FILE).get(0).split("[ ]");
            for (int i = 0; i < input.length; i += 2) {
                mapping.put(input[i], input[i + 1]);
                if (!mappingToIndex.containsKey(input[i + 1])) {
                    mappingToIndex.put(input[i + 1], mappingToIndex.size());
                }
            }
        }
    }

    private static String removeNumbers(String s) {
        StringBuilder stringBuilder = new StringBuilder();
        int i = 0;
        while (i < s.length()) {
            boolean hasNumber = false;
            while (i < s.length() && s.charAt(i) <= '9' && s.charAt(i) >= '0') {
                i++;
                hasNumber = true;
            }
            if (hasNumber) {
                stringBuilder.append("(num)");
            }
            if (i < s.length()) {
                stringBuilder.append(s.charAt(i));
                i++;
            }
        }
        return stringBuilder.toString();
    }

    public static String stem(String s) {
        String s0 = removeNumbers(s.toLowerCase());
        if (s0.length() > 0 && mapping.containsKey(s0)) {
            return mapping.get(s0);
        } else {
            return NOT_FOUND_STRING;
        }
    }

    public static int getIndex(String s) {
        String s0 = removeNumbers(s.toLowerCase());
        if (s0.length() > 0 && mapping.containsKey(s0)) {
            return mappingToIndex.get(mapping.get(s0));
        } else {
            return NOT_FOUND_INT;
        }
    }

    public static int getIndexSize() {
        return mappingToIndex.size();
    }
}
