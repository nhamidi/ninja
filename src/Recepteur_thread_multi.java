import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;

public class Recepteur_thread_multi extends Thread {
    
    final static int FLAG_PUSH = 999999999;
    final static int size_int = 4;
    final static int ACK = -2;
    final static int NACK = -1;
    // private int port;
    private MulticastSocket socketReception;
    private boolean end_loop;
    int packetData;
    private int number_of_packets;
    private int end_reception;
    private int nb_of_receiver;
    private int total_symb;
    private long time_1;
    private long time_2;
    private int nb_ack;
    private long before;
    private boolean need_more;
    
    public Recepteur_thread_multi(int port, InetAddress groupeIP, int nb_of_recv) throws IOException {
	// this.port = port;
	this.end_loop = true;
	this.need_more = false;
	this.socketReception = new MulticastSocket(port);
	this.socketReception.joinGroup(groupeIP);
	this.number_of_packets = 5;
	this.end_reception = 1;
	this.packetData = 0;
	this.nb_of_receiver = nb_of_recv;
	this.total_symb = 1;
	this.time_1 = 0;
	this.time_2 = 0;
	this.nb_ack = 0;
	
    }
    
    public boolean get_need_more() {
	return this.need_more;
    }
    
    public void set_need_more(boolean var) {
	this.need_more = var;
    }
    
    public boolean get_status_end_loop() {
	return this.end_loop;
    }
    
    public void change_status_end_loop() {
	this.end_loop = false;
    }
    
    public void set_total_number_of_packets(int nb_packet) {
	this.total_symb = nb_packet;
    }
    
    public int get_number_of_packets() {
	return this.number_of_packets;
    }
    
    public void set_number_of_packets(int nb_packets) {
	if ( this.number_of_packets < nb_packets ) {
	    // this.number_of_packets = nb_packets;
	    this.need_more = true;
	    // this.number_of_packets = (int) Math.round((float) ((nb_packets
	    // *this.total_symb) + nb_packets* nb_packets)/ (this.total_symb
	    // *nb_packets));
	    this.number_of_packets = (int) Math.round((((float) nb_packets / (float) this.total_symb) + 1) * (float) nb_packets);
	    
	    set_total_number_of_packets(this.number_of_packets);
	    // System.out.println("                 avant pourcent       "+
	    // nb_packets+"        après pourcent              "+
	    // this.number_of_packets);
	    
	    // System.out.println("          " +(int) Math.round((float)
	    // ((nb_packets * this.total_symb) + nb_packets* nb_packets)/
	    // (this.total_symb * nb_packets)));
	    
	}
	this.need_more = true;
	
    }
    
    public void reset_number_of_packets() {
	this.number_of_packets = 5;
    }
    
    public long get_time_1() {
	return this.time_1;
    }
    
    public long get_time_2() {
	return this.time_2;
    }
    
    public int get_nb_ack() {
	return this.nb_ack;
    }
    
    public void run() {
	before = System.currentTimeMillis();
	
	while (true) {
	    byte[] receiveData = new byte[51024];
	    
	    DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
	    
	    try {
		socketReception.receive(receivePacket);
		byte[] packetData_2 = receivePacket.getData();
		for (int l = 0; l < size_int; l++) {
		    this.packetData = (this.packetData << 8) + (packetData_2[l] & 0xff);
		    
		}
		this.need_more = false;
	    } catch (Exception exc) {
		System.out.println(exc);
	    }
	    // System.out.println("numéros receptionné       " +
	    // this.packetData);
	    this.nb_ack++;
	    
	    if ( this.packetData == FLAG_PUSH ) {
		set_number_of_packets(this.packetData);
		break;
	    }
	    
	    if ( this.packetData == NACK ) {
		this.need_more = true;
		set_number_of_packets(5);
		// nb_ack++;
		continue;
	    }
	    
	    if ( this.packetData == ACK ) {
		this.packetData = -5;
		
		// set_number_of_packets(0);
		// nb_ack++;
		if ( time_1 == 0 ) {
		    time_1 = System.currentTimeMillis() - before;
		}
		end_reception++;
		if ( end_reception > this.nb_of_receiver ) {
		    this.number_of_packets = 0;
		    this.change_status_end_loop();
		    time_2 = System.currentTimeMillis() - before;
		    break;
		}
	    } else {
		set_number_of_packets(this.packetData);
		
		// nb_ack++;
	    }
	}
    }
}
