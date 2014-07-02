import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.util.HashSet;
import java.util.Set;

import RQLibrary.EncodingSymbol;

public class Treatment extends Thread {
    final static int size_int = 4;
    byte[][] matrice;
    long[] temps = new long[1000];
    private  final Set<EncodingSymbol> received_packets = new HashSet<EncodingSymbol>();
    int RTT;
    boolean start;
    boolean boucle;
    int nb;
    
    Treatment(int rtt) {
	
	RTT = rtt;
	
	for (int i = 0; i < temps.length; i++) {
	    temps[i] = 0;
	}
	nb = 0;
	start = true;
	boucle = true;
	start();
	
    }
    
    int get_nb() {
	return this.nb;
    }
    
    void set_end_boucle() {
	boucle = false;
    }
    
    public static final int byte_array_to_int(byte[] byte_array) {
	int interger = 0;
	for (int i = 0; i < size_int; i++) {
	    interger = (interger << 8) + (byte_array[i] & 0xff);
	}
	return interger;
    }
    
    public void run() {
	// look and compare all time if > RTT pop it
	while (boucle) {
	    for (int i = 0; i < temps.length; i++) {
		
		if ( temps[i] != 0 ) {
		   
		    /*
		    if ( System.currentTimeMillis() - temps[i] > 500 ) {
			ByteArrayInputStream bis = new ByteArrayInputStream(matrice[i]);
			try {
			    nb++;
			    temps[i] = 0;
			    ObjectInput in = new ObjectInputStream(bis);
			    
			    received_packets.add((EncodingSymbol) in.readObject());
			} catch (ClassNotFoundException e) {
			    e.printStackTrace();
			} catch (IOException e) {
			    // TODO Auto-generated catch block
			    e.printStackTrace();
			}
			
		    }*/
		    
		   if ( System.currentTimeMillis() - temps[i] > 500 ) {
			  
			nb++;
			temps[i] = 0;
			
			received_packets.add((EncodingSymbol) treat_packet(matrice[i]));
			
		    } 
		
		}
		
	    }
	    
	    try {
		Thread.sleep(10);
	    } catch (InterruptedException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	    }
	    
	}
	
    }
    
    EncodingSymbol treat_packet(byte[] packet) {
	int T=192;
	byte[] sbn = new byte[4];
	byte[] esi = new byte[4];
	byte[] data = new byte[T];
	
	System.arraycopy(packet, 0, sbn, 0, size_int);
	System.arraycopy(packet, size_int, esi, 0, size_int);
	System.arraycopy(packet, size_int * 2, data, 0, T);
	//System.out.println("      SBN      "+byte_array_to_int(sbn)+"            ESI                "+byte_array_to_int(esi));
	
	EncodingSymbol symbols = new EncodingSymbol(byte_array_to_int(sbn), byte_array_to_int(esi), data);
	
	return symbols;
    }
    
    void add_packet(byte[] packet) {
	// Add a packet and write the entering time
	if ( start ) {
	    matrice = new byte[1000][packet.length];
	    start = !start;
	}
	for (int i = 0; i < temps.length; i++) {
	    if ( temps[i] == 0 ) {
		temps[i] = System.currentTimeMillis();
		System.arraycopy(packet, 0, matrice[i], 0, packet.length);
		break;
	    }
	    
	}
				
    }
    
    Set<EncodingSymbol> get_encoding_symbol() {
	Set<EncodingSymbol> tmp = new HashSet<EncodingSymbol>();
	synchronized(received_packets){
	tmp.addAll(received_packets);
	}
	return tmp;
	
    }
    
}
