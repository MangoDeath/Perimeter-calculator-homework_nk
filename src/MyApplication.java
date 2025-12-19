import models.Point;
import models.Shape;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Locale;
import java.util.Scanner;

public class MyApplication {
    public static void main(String[] args)throws FileNotFoundException  {

            // Задаём файл для чтения
            File file = new File("C:/Users/user/IdeaProjects/lalla/src/source.txt");

            Scanner sc = new Scanner(file).useLocale(Locale.US);

            // Создаём объект Shape
            Shape shape = new Shape();


            while (sc.hasNext()) {
                if (sc.hasNextDouble()) {
                    double x = sc.nextDouble();

                    if (sc.hasNextDouble()) {
                        double y = sc.nextDouble();

                        Point point = new Point(x, y);
                        shape.addPoint(point);
                        System.out.println("Добавлена точка: " + point);
                    }                }
            }
            System.out.println( shape.calculatePerimeter());
        }
    }
