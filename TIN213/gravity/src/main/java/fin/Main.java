import java.awt.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

public class Main {

    public static void main(String[] args) {
        Frame frame = new Frame("Newtonian Gravity Simulation");
        Panel panel = new Panel();
        frame.add(panel, BorderLayout.CENTER);
        frame.addWindowListener(new WindowAdapter() {	// remove this if you don't want the program
            public void windowClosing(WindowEvent e) {		// to quit when close-box is clicked
                System.exit(0);
            }});
        frame.pack();
        PlanetsView view = new PlanetsView(panel);
        PlanetsModel model = new PlanetsModel(view);
        PlanetsController controller = new PlanetsController(model);
        frame.add(controller, BorderLayout.SOUTH);
        frame.pack();
        frame.setLocation(400, 0);
        frame.setVisible(true);


        controller.run();
    }
}
