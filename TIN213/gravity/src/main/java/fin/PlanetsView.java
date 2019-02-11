import java.awt.*;

public class PlanetsView extends Canvas {
    private final static int PLOTWIDTH = 400;
    private final static int PLOTHEIGHT = 400;

    private final static int WIDTH = 400;
    private final static int HEIGHT = 400;

    private Image image;
    private Graphics graphics;

    PlanetsView(Panel panel) {
        panel.add(this);
        setSize(WIDTH, HEIGHT);
        setBackground(Color.BLACK);

        image = createImage(WIDTH, HEIGHT);
        graphics = image.getGraphics();
    }

    public void showPlanet(Planet p) {
        int diameter = p.getRadius() * 2;
        graphics.setColor(p.getColor());
        int pixelx = (int) Math.round(PLOTWIDTH * (p.getX() + 10) / 20);
        int pixely = (int) Math.round(PLOTHEIGHT * (10 - p.getY()) / 20);
        graphics.fillOval(pixelx - diameter / 2, pixely - diameter / 2, diameter, diameter);
    }

    public void clear() {
        graphics.setColor(Color.BLACK);
        graphics.fillRect(0, 0, WIDTH, HEIGHT);
    }

    @Override
    public synchronized void paint(Graphics g) {
        g.drawImage(image, 0, 0, WIDTH, HEIGHT, this);
    }
}
