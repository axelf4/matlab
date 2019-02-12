import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class PlanetsController extends Panel {
    private PlanetsModel model;
    private static final double dt = 0.01;
    private boolean running = true;

    public PlanetsController(PlanetsModel model) {
        this.model = model;

        Button startStopButton = new Button("Start / Stop"); // TODO move button to view where it goddamn should be
        startStopButton.addActionListener(e -> running = !running);
        this.add(startStopButton);
    }

    public void run() {
        Timer timer = new Timer(10, new SecListener());
        timer.start();
    }

    public class SecListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            if (running) {
                model.update(dt);
            }
        }
    }
}
