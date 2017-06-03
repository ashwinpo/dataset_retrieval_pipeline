import java.io.*;
import java.util.HashSet;
import java.util.LinkedList;

/**
 * Read and write files.
 */
public class IO {

    /**
     * Read from a file and return the content as a collection of strngs.
     */
    public static LinkedList<String> readFromFile(String filename) {
        try {
            if (!new File(filename).exists()) {
                return new LinkedList<>();
            }
            BufferedReader reader = new BufferedReader(new FileReader(filename));
            LinkedList<String> content = new LinkedList<>();
            while (true) {
                String s = reader.readLine();
                if (s == null) {
                    break;
                }
                content.add(s);
            }
			reader.close();
            return content;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Write a collection of strings to a file.
     */
    public static void writeFile(Iterable<String> content, String filename) {
        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(filename));
            for (String s : content) {
                writer.write(s + "\n");
            }
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
