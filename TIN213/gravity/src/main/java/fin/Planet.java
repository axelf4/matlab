import java.awt.*;

public class Planet {
	private double x, y, vx, vy;
	private final double mass;

	private final int radius;
	private final Color color;

	public Planet(double x, double y, double vx, double vy, double mass, int radius, Color color) {
		this.x = x;
		this.y = y;
		this.vx = vx;
		this.vy = vy;
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
        return x;
    }

    public double getY() {
        return y;
    }

    public double getVX() {
        return vx;
    }

    public double getVY() {
        return vy;
    }
}
