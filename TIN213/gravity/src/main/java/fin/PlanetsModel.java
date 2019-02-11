import java.util.*;
import java.awt.Color;

public class PlanetsModel {
    private static final double G = 4 * Math.PI * Math.PI;

    private PlanetsView view;

	private final List<Planet> planets = new ArrayList<>();

    public PlanetsModel(PlanetsView view) {
        this.view = view;

		planets.add(new Planet(0, 0, 0, 0, 10, 20, Color.RED));
		planets.add(new Planet(1, 0, 0, 2 * Math.PI, 1, 10, Color.RED));
    }

    public void update(double dt) {
        // TODO Calculate the new positions and velocities of the planets

        view.clear();
		planets.stream().forEach(view::showPlanet);
        view.repaint();
    }
}
