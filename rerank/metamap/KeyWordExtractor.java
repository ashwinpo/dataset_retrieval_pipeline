import java.io.*;
import java.util.*;

public class KeyWordExtractor {
    public static void main(String[] args) {
        if (args.length != 2) {
            System.out.println("Usage: java KeyWordExtractor $INPUT_PATH $OUTPUT_FILE");
            return;
        }
        File[] files = new File(args[0]).listFiles();
        LinkedList<String> output = new LinkedList<>();
        for (File file : files) {
            String filename = file.getAbsolutePath();
            String queryId = file.getName().split("[_]")[0];
            output.add(">" + queryId);
            output.add(getResult(filename));
        }
        IO.writeFile(output, args[1]);
    }
    public static String getResult(String filename) {
        try {
            LinkedList<String> input = IO.readFromFile(filename);
            StringBuilder stringBuilder = new StringBuilder();
            HashSet<String> words = new HashSet<>();
            for (String s : input) {
                if (!s.startsWith(" ")) {
                    continue;
                }
                int p = 0;
                while (true) {
                    char c = s.charAt(p);
                    if ((c <= 'z' && c >= 'a') || (c <= 'Z' && c >= 'A')) {
                        break;
                    }
                    p++;
                }
                String s0 = s.substring(p);
                int i1 = s0.indexOf('[');
                int i2 = s0.indexOf('(');
                int i;
                if (i1 == -1) {
                    i = i2;
                } else if (i2 == -1) {
                    i = i1;
                } else {
                    i = Math.min(i1, i2);
                }
                if (i == -1) {
                    continue;
                }
                s0 = s0.substring(0, i);
                s0 = s0.trim().toLowerCase();
                if (!words.contains(s0) && !s0.contains("find") && !s0.contains("database") && !s0.contains("attribute")) {
                    words.add(s0);
                    stringBuilder.append(s0).append(' ');
                }
            }
            return stringBuilder.toString();
        }
        catch(Exception e){
            e.printStackTrace();
            return "";
        }
    }
}
