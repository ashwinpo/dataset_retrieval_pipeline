/**
 * Sort {@link #record} by descending orders of {@link #score}.
 */
public class ComparableRecord<T>  implements Comparable<ComparableRecord<T>> {
    T record;
    double score;

    public ComparableRecord(T record, double score) {
        this.record = record;
        this.score = score;
    }
    public int compareTo(ComparableRecord<T> other) {
        return -Double.compare(score, other.score);
    }
}
