import javax.swing.*;
import java.awt.*;

public class Main {
    public static void main(String[] args) {
        JFrame frame = new JFrame("Newtonian Gravity Simulation");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        PlanetsModel model = new PlanetsModel();

        PlanetsView view = new PlanetsView(model);
        model.addObserver(view);
        frame.getContentPane().add(view, BorderLayout.CENTER);

        PlanetsController controller = new PlanetsController(model, view);

        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);

        controller.run();
    }
}
