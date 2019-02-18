import javax.swing.*;

public class PlanetsController {
    private static final double dt = 0.01;
    private final PlanetsModel model;
    private boolean running = true;

    public PlanetsController(PlanetsModel model, PlanetsView view) {
        this.model = model;

        view.getStartStopButton().addActionListener(e -> running = !running);
    }

    public void run() {
        // FIXME Replace Timer with Thread.yield() in a loop
        Timer timer = new Timer(10, e -> {
            // FIXME Find accurate delta time using System.nanoTime()
            if (running) {
                model.update(dt);
            }
        });
        timer.start();
    }
}
