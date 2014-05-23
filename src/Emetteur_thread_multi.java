import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;

public class Emetteur_thread_multi extends Thread {
    
    final static int FLAG_PUSH = 999999999;
    final static int size_int = 4;
    InetAddress groupeIP;
    private int port;
    private byte[] ACK_NACK;
    MulticastSocket socketEmission;
    private int parameter_test;
    
    Emetteur_thread_multi(InetAddress groupeIP, int port) throws Exception {
	this.groupeIP = groupeIP;
	this.port = port;
	this.ACK_NACK = new byte[size_int];
	this.parameter_test = 0;
	socketEmission = new MulticastSocket();
    }
    
    public byte[] get_ACK_NACK() {
	return this.ACK_NACK;
    }
    
    public void set_ACK_NACK(int change_byte) {
	for (int i = 0; i < size_int; i++) {
	    
	    this.ACK_NACK[i] = (byte) (change_byte >>> ((3 - i) * 8));
	}
    }
    
    public void set_parameter_test(int parameter) {
	this.parameter_test = parameter;
    }
    
    public byte[] parameter_test(byte[] Message_before) {
	byte[] Message_after = new byte[size_int];
	byte[] Message_temp = new byte[size_int];
	
	switch (this.parameter_test) {
	case 1:
	    Message_after = Message_before;
	    break;
	default:
	    Message_after = Message_before;
	}
	
	return Message_after;
    }
    
    public void run() {
	try {
	    // send_thing();
	} catch (Exception exc) {
	    System.out.println(exc);
	}
    }
    
    void send_thing() throws Exception {
	byte[] contenuMessage = new byte[size_int];
	DatagramPacket message;
	System.arraycopy(this.ACK_NACK, 0, contenuMessage, 0, size_int);
	
	message = new DatagramPacket(parameter_test(contenuMessage), contenuMessage.length, groupeIP, port);
	
	// Thread.sleep(1);
	Thread.sleep(500);
	socketEmission.send(message);
    }
}
