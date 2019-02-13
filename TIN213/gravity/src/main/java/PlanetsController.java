import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class PlanetsController {
    private PlanetsModel model;
    private static final double dt = 0.01;
    private boolean running = true;

    public PlanetsController(PlanetsModel model, PlanetsView view) {
        this.model = model;

        view.getStartStopButton().addActionListener(e -> running = !running);
    }

    public void run() {
        Timer timer = new Timer(10, e -> {
			// FIXME Find accurate delta time using System.nanoTime()
			if (running) {
				model.update(dt);
			}
		});
        timer.start();
    }
}
