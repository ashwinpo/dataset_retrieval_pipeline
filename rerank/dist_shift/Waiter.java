/**
 * Created by Administrator on 2/16/2017.
 */
public class Waiter {
    public static void wait(int time) {
        try {
            Thread.sleep(time);
        } catch (Exception e) {
            ;
        }
    }
}
