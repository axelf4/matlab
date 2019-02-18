import javax.swing.*;
import java.awt.*;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.geom.Ellipse2D;
import java.awt.image.VolatileImage;

public class PlanetsView extends JPanel implements PlanetsModel.Observer {
    private final static int PLOT_WIDTH = 400;
    private final static int PLOT_HEIGHT = 400;

    private final static int WIDTH = 400;
    private final static int HEIGHT = 400;

    private final PlanetsModel model;
    private final ViewCanvas canvas = new ViewCanvas();
    private final JButton startStopButton = new JButton("Start / Stop");

    PlanetsView(PlanetsModel model) {
        this.model = model;
        setPreferredSize(new Dimension(WIDTH, HEIGHT));
        setLayout(new BorderLayout());

        add(canvas, BorderLayout.CENTER);
        add(startStopButton, BorderLayout.SOUTH);
    }

    /**
     * 5 out of 7 Florida men couldn't guess what this method does.
     * <p>
     * You won't believe it when you find out.
     */
    public JButton getStartStopButton() {
        return startStopButton;
    }

    @Override
    public void update() {
        canvas.repaint();
    }

    private class ViewCanvas extends JPanel {
        /**
         * Backbuffer.
         */
        private VolatileImage image;

        ViewCanvas() {
            setBackground(Color.BLACK);

            addComponentListener(new ComponentAdapter() {
                @Override
                public void componentResized(ComponentEvent e) {
                    image = null; // Force recreation of offscreen image
                    repaint();
                }
            });
        }

        public void showPlanet(Graphics2D g, Planet p) {
            double diameter = p.getRadius() * 2;
            g.setColor(p.getColor());
            double pixelX = PLOT_WIDTH * (p.getX() + 10) / 20, pixelY = PLOT_HEIGHT * (10 - p.getY()) / 20;
            g.fill(new Ellipse2D.Double(pixelX - diameter / 2, pixelY - diameter / 2, diameter, diameter));
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

                    double w = getWidth(), h = getHeight(), scale = Math.min(w / PLOT_WIDTH, h / PLOT_HEIGHT);
                    // Scale from component coordinates to plot coordinates, maintaining 1:1 aspect ratio
                    g2d.scale(scale, scale);
                    // Translate (0,0) to always be the center of the component
                    g2d.translate((w / scale - PLOT_WIDTH) / 2, (h / scale - PLOT_HEIGHT) / 2);

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

    }
}
