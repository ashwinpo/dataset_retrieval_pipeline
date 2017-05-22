/**
 * Created by belon on 5/9/2017.
 */
public class Score {
    private static final double MU = 2500;
    private static final double BONUS = 5;
    private static final double EPS = 1e-8;

    public static double computeScore(int[] fileContent, int[] query) {
        int C = Statistics.getAllCounts();
        double score = 0;
        for (int i : query) {
            if (i == Stemmer.NOT_FOUND_INT) {
                continue;
            }
            int sum = 0;
            for (int j : fileContent) {
                if (j == i) {
                    sum ++;
                }
            }
            if (sum > 0) {
                sum += BONUS;
            } else {
                if (Statistics.getStat(i) == 0) {
                    score += Math.log(EPS / MU);
                    continue;
                }
            }
            score += Math.log((sum + MU * Statistics.getStat(i) / C) / (fileContent.length + MU));
        }
        return score;
    }
}
