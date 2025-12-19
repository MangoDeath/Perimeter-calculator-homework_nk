package models;

import java.util.ArrayList;

public class Shape {
    private ArrayList<Point> container = new ArrayList<>();

    public void addPoint(Point z) {
        container.add(z);
    }

    public double calculatePerimeter() {
        double perimeter = 0.0;

        for (int i = 0; i < container.size() - 1; i++) {
            perimeter += container.get(i).distance(container.get(i + 1));
        }


        perimeter += container.get(container.size() - 1).distance(container.get(0));

        return perimeter;
    }
}