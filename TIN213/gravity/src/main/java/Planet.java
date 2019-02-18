import java.awt.*;

public class Planet {
    public final double mass;
    private final int radius;
    private final Color color;
    public Vector2 pos, vel;

    public Planet(double x, double y, double vx, double vy, double mass, int radius, Color color) {
        pos = new Vector2(x, y);
        vel = new Vector2(vx, vy);
        this.mass = mass;
        this.radius = radius;
        this.color = color;
    }

    public int getRadius() {
        return radius;
    }

    public Color getColor() {
        return color;
    }

    public double getX() {
        return pos.x;
    }

    public double getY() {
        return pos.y;
    }
}
