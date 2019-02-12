import java.util.*;
import java.awt.Color;

public class PlanetsModel {
    /**
     * The gravitational constant.
     */
    private static final double G = 4 * Math.PI * Math.PI;

    private final List<Observer> observers = new ArrayList<>();
    private final List<Planet> planets = new ArrayList<>();
    /**
     * Pre-allocated array for the accelerations of the planets. WARNING: Not thread-safe!
     */
    private final Vector2 accelerations[];

    public PlanetsModel() {
        planets.add(new Planet(0, 0, 0, 0, 1, 20, Color.YELLOW));
        planets.add(new Planet(1, 0, 0, 2 * Math.PI, 1. / 332946, 5, Color.GREEN));
        planets.add(new Planet(5.2, 0, 0, 14 * 2 * Math.PI / 30, 0.001, 10, Color.RED));

        accelerations = new Vector2[planets.size()];
    }

    /**
     * Returns the instantaneous acceleration of \c planet1 wrt. the gravitational force of \c planet2.
     *
     * @param planet1 The planet to calculate the acceleration for.
     * @param planet2 The planet whose gravitational force we consider.
     * @return The instantaneous acceleration of the specified planet.
     */
    private static Vector2 calcAcceleration(Planet planet1, Planet planet2) {
        Vector2 p1 = new Vector2(planet1.x, planet1.y), p2 = new Vector2(planet2.x, planet2.y);
        Vector2 dp = p2.sub(p1);
        double r2 = dp.dot(dp), r = Math.sqrt(r2);
        return dp.mul(G * planet2.mass / (r * r2)); // Calculate acceleration using Newton's teachings
    }

    /**
     * Calculates the current acceleartions of the planets at the corresponding indices in the given array.
     */
    private void calcAccelerations(Vector2 accelerations[]) {
        assert accelerations.length == planets.size() : "Size mismatch between accelerations and planets.";

        // Acceleration is applied linearly
        for (int i = 0; i < planets.size(); ++i) {
            Planet p1 = planets.get(i);
            accelerations[i] = Vector2.ZERO;

            for (Planet p2 : planets) {
                if (p1 == p2) continue;
                accelerations[i] = accelerations[i].add(calcAcceleration(p1, p2));
            }
        }
    }

    public void update(double dt) {
        // Calculate the new positions and velocities of the planets using the Verlet algorithm

        calcAccelerations(accelerations);
        for (int i = 0, length = planets.size(); i < length; ++i) {
            Planet planet = planets.get(i);
            Vector2 a = accelerations[i];
            planet.x += planet.vx * dt + .5 * a.x * dt * dt;
            planet.y += planet.vy * dt + .5 * a.y * dt * dt;
            planet.vx += .5 * a.x * dt;
            planet.vy += .5 * a.y * dt;
        }

        calcAccelerations(accelerations);
        for (int i = 0, length = planets.size(); i < length; ++i) {
            Planet planet = planets.get(i);
            Vector2 a = accelerations[i];
            planet.vx += .5 * a.x * dt;
            planet.vy += .5 * a.y * dt;
        }

        observers.forEach(Observer::update); // Notify observers
    }

    public List<Planet> getPlanets() {
        return planets;
    }

    /**
     * Add an observer to be notified when this model changes.
     *
     * @param observer The observer to add.
     */
    public void addObserver(Observer observer) {
        observers.add(observer);
    }

    /**
     * Implementors can be added as observers to be notified when model changes.
     */
    public interface Observer {
        /**
         * Called when the model has changed.
         */
        void update();
    }
}
