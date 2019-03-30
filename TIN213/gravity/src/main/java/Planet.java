import java.awt.*;

public class Planet {
    public final double mass;
    private final int radius;
    private final Color color;
    private Vector2 pos, vel;

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

    public Vector2 getPos() {
        return pos;
    }

    public void updateVelocity(Vector2 a, double dt) {
        vel = vel.add(a.mul(dt));
    }

    public void updatePosition(double dt) {
        pos = pos.add(vel.mul(dt));
    }
}
