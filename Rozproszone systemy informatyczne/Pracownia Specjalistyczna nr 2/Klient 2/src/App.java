import java.rmi.Naming;
import java.util.Scanner;

public class App {
    public static void main(String[] args) {
        String name = "Ulti";
        String host = "localhost";
        String service = "Chat";
        System.setProperty("java.security.policy", "security.policy");
        System.setSecurityManager(new SecurityManager());
        try {
            String[] details = {name, host, service};
            MyServerInt server = (MyServerInt) Naming.lookup("//"+host+"/Chat");
            ChatI chatI = new ChatClientImpl(server);
            server.registerListener("Piotrek", chatI);
            System.out.println("Client Listen RMI Server is running...\n");
            Scanner scanner = new Scanner(System.in);
            while (true) {
                String message = scanner.nextLine();
                server.sendMessageToServer(message);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
