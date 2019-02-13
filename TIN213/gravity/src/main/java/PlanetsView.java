import javax.swing.*;
import java.awt.*;
import java.awt.image.VolatileImage;
import java.awt.event.*;

public class PlanetsView extends JPanel implements PlanetsModel.Observer {
    private final static int PLOTWIDTH = 400;
    private final static int PLOTHEIGHT = 400;

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
	 *
	 * You won't believe it when you find out.
	 */
	public JButton getStartStopButton() {
		return startStopButton;
	}

	private class ViewCanvas extends JPanel {
		/** Backbuffer. */
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

					double w = getWidth(), h = getHeight(), scale = Math.min(w / PLOTWIDTH, h / PLOTHEIGHT);
					// Scale from component coordinates to plot coordinates, maintaining 1:1 aspect ratio
					g2d.scale(scale, scale);
					// Translate (0,0) to always be the center of the component
					g2d.translate((w / scale - PLOTWIDTH) / 2, (h / scale - PLOTHEIGHT) / 2);

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

    @Override
    public void update() {
		canvas.repaint();
    }
}
