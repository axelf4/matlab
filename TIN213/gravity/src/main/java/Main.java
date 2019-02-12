import javax.swing.*;
import java.awt.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

public class Main {

    public static void main(String[] args) {
        JFrame frame = new JFrame("Newtonian Gravity Simulation");
        Panel panel = new Panel();
        frame.add(panel, BorderLayout.CENTER);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        PlanetsModel model = new PlanetsModel();
        PlanetsView view = new PlanetsView(model);
        model.addObserver(view);
        panel.add(view);
        PlanetsController controller = new PlanetsController(model);

        frame.add(controller, BorderLayout.SOUTH);
        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);

        controller.run();
    }
}
