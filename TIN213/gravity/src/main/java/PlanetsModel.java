import java.awt.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class PlanetsModel {
    /**
     * The gravitational constant.
     */
    private static final double G = 4 * Math.PI * Math.PI;

    private final List<Observer> observers = new ArrayList<>();
    private final List<Planet> planets = new ArrayList<>();
    /**
     * Pre-allocated array for the accelerations of the planets.
     */
    private final Vector2 accelerations[];

    public PlanetsModel() {
        planets.add(new Planet(0, 0, 0, 0, 1, 20, Color.YELLOW));
        planets.add(new Planet(1, 0, 0, 2 * Math.PI, 1. / 332946, 5, Color.GREEN));
        planets.add(new Planet(5.2, 0, 0, 14 * 2 * Math.PI / 30, 0.001, 10, Color.RED));

        accelerations = new Vector2[planets.size()];
    }

    /**
     * Returns the instantaneous acceleration of \c planet1 wrt the gravitational force of \c planet2.
     *
     * @param p1 The planet to calculate the acceleration for.
     * @param p2 The planet whose gravitational force we consider.
     * @return The instantaneous acceleration of the specified planet.
     */
    private static Vector2 calcAcceleration(Planet p1, Planet p2) {
        Vector2 dp = p2.getPos().sub(p1.getPos()); // Vector from planet1 to planet2
        double r2 = dp.dot(dp), r = Math.sqrt(r2); // r is distance, r2 is squared distance
        return dp.mul(G * p2.mass / (r * r2)); // Calculate acceleration using Newton's teachings
    }

    /**
     * Calculates the current accelerations of the planets at the corresponding indices in the given array.
     */
    private void calcAccelerations(Vector2 accelerations[]) {
        assert accelerations.length == planets.size() : "Size mismatch between accelerations and planets lists.";

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

    /**
     * Steps forward the simulation by the specified delta time.
     * <p>
     * The current implementation uses the Verlet algorithm. WARNING: Not thread-safe!
     *
     * @param dt The delta time to step forward by.
     */
    public void update(double dt) {
        calcAccelerations(accelerations);

        // Decrease time step with the maximum of the accelerations of the planets
        dt *= G * G / Arrays.stream(accelerations).mapToDouble(Vector2::length2).filter(a -> a != 0).max().orElse(G * G);

        for (int i = 0, length = planets.size(); i < length; ++i) {
            Planet planet = planets.get(i);
            planet.updateVelocity(accelerations[i].mul(.5), dt);
            planet.updatePosition(dt);
        }

        calcAccelerations(accelerations);
        for (int i = 0, length = planets.size(); i < length; ++i) {
            Planet planet = planets.get(i);
            planet.updateVelocity(accelerations[i].mul(.5), dt);
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
