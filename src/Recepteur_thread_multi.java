import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;

public class Recepteur_thread_multi extends Thread {
    
    final static int FLAG_PUSH = 999999999;
    final static int size_int = 4;
    final static int ACK = -2;
    final static int NACK = -1;
     private int port;
    private MulticastSocket socketReception;
    private boolean end_loop;
    private boolean historic;
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
    private double redondancy;
    
    public Recepteur_thread_multi(int port, InetAddress groupeIP, int nb_of_recv, boolean historic) throws IOException {
	 this.port = port;
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
	this.historic = historic;
	redondancy = 1.00;
	
    }
    
    public static void print_in_file(String message,int port) {
	try {
	    File file = new File("/home/tai/workspace/stage_pfe/bin/histo/time_division_final"+port+".txt");
	    
	    // if file doesnt exists, then create it
	    if ( !file.exists() ) {
		file.createNewFile();
	    }
	    
	    FileWriter fw = new FileWriter(file.getAbsoluteFile(), true);
	    BufferedWriter bw = new BufferedWriter(fw);
	    bw.write(message + "\n");
	    bw.close();
	    
	} catch (IOException e) {
	    e.printStackTrace();
	}
    }
    
    public void set_redondancy(double val) {
	this.redondancy = val;
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
	this.need_more = true;
	if ( this.number_of_packets < nb_packets ) {
	    
	    if ( this.historic ) {
		//System.out.println("             "+nb_packets+ "       "+this.total_symb);
		//System.out.println("      Plost                "+ ((float) nb_packets / (float) this.total_symb));
		this.number_of_packets = (int) Math.round((((float) nb_packets / (float) this.total_symb) + 1) * (float) nb_packets)+5;
		
	    } else
		this.number_of_packets = nb_packets;
	    
	    set_total_number_of_packets(this.number_of_packets);
	    
	}
	
    }
    
    public void reset_number_of_packets() {
	this.number_of_packets = 10;
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
    
    public void set_time_simu() {
	this.before = System.currentTimeMillis();
    }
    
    public void run() {
	
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
	   //  System.out.println("On a recu :                "+this.packetData);
	    this.nb_ack++;
	    
	    try {
		Thread.sleep(5000);
	    } catch (InterruptedException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	    }
	    
	    if ( this.packetData == FLAG_PUSH ) {
		set_number_of_packets(this.packetData);
		break;
	    }
	    
	    if ( this.packetData == NACK ) {
		this.need_more = true;
		set_number_of_packets(1);
		continue;
	    }
	    
	    if ( this.packetData == ACK ) {
		
		if ( time_1 == 0 ) {
		    time_1 = System.currentTimeMillis() - before;
		}
		end_reception++;
		if ( end_reception > this.nb_of_receiver ) {
		    this.number_of_packets = 0;
		    this.change_status_end_loop();
		    time_2 = System.currentTimeMillis() - before;
		    print_in_file(String.valueOf(System.currentTimeMillis()),port);
		    break;
		}
	    } else {
		set_number_of_packets(this.packetData);
	    }
	}
    }
}
