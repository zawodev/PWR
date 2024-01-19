package Shape;

import Point.Point;

public interface ITriangleSingleton {
    Triangle createTriangleSingleton(Point p1, Point p2, Point p3, boolean filled);
}
