import javax.swing.*;
import java.awt.*;
import java.awt.image.VolatileImage;

public class PlanetsView extends JPanel implements PlanetsModel.Observer {
    private final static int PLOTWIDTH = 400;
    private final static int PLOTHEIGHT = 400;

    private final static int WIDTH = 400;
    private final static int HEIGHT = 400;

    private final PlanetsModel model;
    private VolatileImage image;

    PlanetsView(PlanetsModel model) {
        this.model = model;

        setPreferredSize(new Dimension(WIDTH, HEIGHT));
        setBackground(Color.BLACK);
    }

    public void showPlanet(Graphics2D g, Planet p) {
        int diameter = p.getRadius() * 2;
        g.setColor(p.getColor());
        int pixelx = (int) Math.round(PLOTWIDTH * (p.getX() + 10) / 20);
        int pixely = (int) Math.round(PLOTHEIGHT * (10 - p.getY()) / 20);
        g.fillOval(pixelx - diameter / 2, pixely - diameter / 2, diameter, diameter);
    }

    private void clear(Graphics g) {
        g.setColor(Color.BLACK);
        g.fillRect(0, 0, getWidth(), getHeight());
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        try {
            do {
                if (image == null || image.validate(getGraphicsConfiguration()) == VolatileImage.IMAGE_INCOMPATIBLE)
                    image = createVolatileImage(getWidth(), getHeight());
                Graphics2D g2d = image.createGraphics();
                g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

                clear(g2d); // Clear screen

                // TODO if (callback != null) callback.draw(new Java2DGraphics(g2d, getWidth(), getHeight()), delta);
                model.getPlanets().forEach(planet -> showPlanet(g2d, planet));

                g2d.dispose();
            } while (image.contentsLost());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            g.drawImage(image, 0, 0, getWidth(), getHeight(), this);
            image.flush();
            g.dispose();
        }

        Toolkit.getDefaultToolkit().sync();
    }

    @Override
    public void update() {
        repaint();
    }
}
