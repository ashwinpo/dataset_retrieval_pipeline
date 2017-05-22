import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;

import java.util.LinkedList;
import java.util.List;
/**
 * Created by belon on 5/10/2017.
 */
public class Google {
    public static WebDriver driver;

    public static void main(String[] args) {
        driver = new ChromeDriver();
        LinkedList<String> input = IO.readFromFile("question.txt");
        LinkedList<String> output = new LinkedList<>();
        for (String s : input) {
            if (s.trim().length() != 0 && s.charAt(0) != '>') {
                output.add(search(s));
            } else {
                output.add(s);
            }
        }
        IO.writeFile(output, "google2.txt");
        driver.close();
    }

    public static String search(String query) {
        driver.navigate().to("https://www.google.com/");
        driver.findElement(By.id("lst-ib")).sendKeys(query);
        driver.findElement(By.id("lst-ib")).sendKeys(Keys.ENTER);
        Waiter.wait(1000);
        List<WebElement> results = driver.findElements(By.className("g"));
        List<String> output = new LinkedList<>();
        for (WebElement element : results) {
            try {
                output.add(element.findElement(By.className("r")).getText());
                output.add(element.findElement(By.className("st")).getText());
            } catch (Exception e) {
                ;
            }
        }
        return merge(output);
    }

    public static String merge(List<String> output) {
        StringBuilder stringBuilder = new StringBuilder();
        for (String s : output) {
            s = s.trim().replace("\n", " ");
            stringBuilder.append(s);
        }
        return stringBuilder.toString();
    }
}
