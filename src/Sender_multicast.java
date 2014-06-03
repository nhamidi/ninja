/* 
 * Copyright 2014 Jose Lopes and Hamidi Nassim
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import java.io.File;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.MulticastSocket;
import java.net.SocketException;
import java.nio.file.Files;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Random;

import java.io.ByteArrayOutputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;
import RQLibrary.Encoder;
import RQLibrary.EncodingPacket;
import RQLibrary.EncodingSymbol;
import RQLibrary.SourceBlock;

public class Sender_multicast {
    final static int FLAG_PUSH = 999999999;
    final static int size_int = 4;
    static Random randomGenerator = new Random();
    final static int ID_PACKET = randomGenerator.nextInt(100);
    
    // final static double redondance = 1.00;
    
    public static final byte[] intToByteArray(int value) {
	return new byte[] { (byte) (value >>> 24), (byte) (value >>> 16), (byte) (value >>> 8), (byte) value };
    }
    
    public static void main(String[] args) throws Exception {
	if ( args.length != 7 ) {
	    StringBuilder s = new StringBuilder();
	    s.append("Usage: \n");
	    s.append("    java -jar Sender.jar pathToFile expectedLoss overhead destIP portNumber\n");
	    s.append("\n        - pathToFile  : path to the file that shall be sent.");
	    s.append("\n        - overhead    : the necessary symbol overhead needed for decoding (usually between 0 and 2).");
	    s.append("\n        - destIP      : the IP address of the receiver.");
	    s.append("\n        - portNumber  : the port the receiver will be listening on.");
	    s.append("\n        - nb of recv  : the number of receivers will be listening.");
	    s.append("\n        - redondance  : Para de test.");
	    s.append("\n        - historic    : if you want historic.");
	    
	    System.out.println(s.toString());
	    System.exit(1);
	}
	
	/**
	 * Test on parameters
	 */
	double redondance = Double.valueOf(args[5]);
	Boolean historique = Boolean.valueOf(args[5]);
	// open file and convert to bytes
	String fileName = args[0];
	File file = new File(fileName);
	int length_of_the_file = (int) file.length();
	
	byte[] data = null;
	try {
	    data = Files.readAllBytes(file.toPath());
	} catch (IOException e1) {
	    System.err.println("Could not open file.");
	    e1.printStackTrace();
	    System.exit(1);
	}
	
	// check loss
	float percentageLoss = 99;
	
	// check overhead
	int overhead = -1;
	
	try {
	    overhead = Integer.valueOf(args[1]);
	} catch (NumberFormatException e) {
	    System.err.println("Invalid overhead value. (must be a positive integer)");
	    System.exit(-1);
	}
	
	if ( overhead < 0 ) {
	    System.err.println("Invalid overhead value. (must be a positive integer)");
	    System.exit(-1);
	}
	
	// get IP and transform to InetAddress
	InetAddress destIP = null;
	
	try {
	    destIP = InetAddress.getByName(args[2]);
	} catch (UnknownHostException e2) {
	    e2.printStackTrace();
	    System.err.println("invalid IP");
	    System.exit(1);
	}
	int nb_of_recv;
	
	nb_of_recv = Integer.valueOf(args[4]);
	if ( nb_of_recv < 0 ) {
	    System.err.println("Invalid number of user (must be above 0)");
	    System.exit(-1);
	}
	
	// check destination port
	int destPort = -1;
	
	try {
	    destPort = Integer.valueOf(args[3]);
	} catch (NumberFormatException e) {
	    System.err.println("Invalid destination port. (must be above 1024)");
	    System.exit(-1);
	}
	
	if ( destPort < 1024 || destPort >= 65535 ) {
	    System.err.println("Invalid destination port. (must be above 1024)");
	    System.exit(-1);
	}
	
	Recepteur_thread_multi reception_thread = new Recepteur_thread_multi(destPort + 1, destIP, nb_of_recv,historique);
	
	/**
	 * End of the tests on the parameter
	 */
	// System.out.println("Transmiting file " + fileName + " to "
	// + destIP.toString() + ":" + destPort + "\n");
	
	/**
	 * preparation for the encoding
	 */
	
	// create a new Encoder instance (usually one per file)
	Encoder encoder = new Encoder(data, percentageLoss, overhead);
	// System.out.println("# repair symbols: " +
	// encoder.getNumRepairSymbols()
	// + " (per block)");
	// array that will contain the encoded symbols
	EncodingPacket[] encoded_symbols = null;
	
	// array of source blocks
	SourceBlock[] source_blocks = null;
	int no_blocks;
	
	// total number of source symbols (for all source blocks)
	int Kt = encoder.getKt();
	// System.out.println("# source symbols: " + Kt);
	
	// partition the data into source blocks
	source_blocks = encoder.partition();
	no_blocks = source_blocks.length;
	// System.out.println("# source blocks: " + no_blocks);
	
	/*
	 * try { System.out .println("\nPress 'Enter' to continue and start sending the file."); System.in.read(); } catch (IOException e2) {
	 * e2.printStackTrace(); }
	 */
	
	// boolean test1=true;
	// creation of the listenning socket in a thread
	int nb_packet = -2;
	reception_thread.start();
	
	reception_thread.set_total_number_of_packets((int) Math.round((float) length_of_the_file / 192));
	long before = System.currentTimeMillis();
	while (reception_thread.get_status_end_loop()) {
	    
	    /**
	     * built of the socket
	     */
	    
	    // open UDP socket
	    MulticastSocket clientSocket = null;
	    try {
		clientSocket = new MulticastSocket();
	    } catch (SocketException e1) {
		e1.printStackTrace();
		System.err.println("Error opening socket.");
		System.exit(1);
	    }
	    
	    // allocate memory for all the encoded symbols
	    encoded_symbols = new EncodingPacket[no_blocks];
	    // EncodingPacket[] encoded_symbols_reparation = new
	    // EncodingPacket[no_blocks];
	    /*
	     * encode each block and send the respective encoded symbols
	     */
	    for (int block = 0; block < no_blocks; block++) {
		// the block we'll be encoding+sending
		SourceBlock sb = source_blocks[block];
		if ( !reception_thread.get_status_end_loop() ) {
		    break;
		}
		
		// /////////////////////////////////////////////////////
		// System.out.println("Sending block: " + block + " K: "
		// + sb.getK());
		// ///////////////////////////////////////////////////////////////////////////////:problem
		// encode 'sb'
		encoded_symbols[block] = encoder.encode(sb);
		
		EncodingSymbol[] symbols = encoded_symbols[block].getEncoding_symbols();
		int no_symbols = symbols.length;
		/*
		 * serialize and send the encoded symbols
		 */
		ObjectOutput out = null;
		byte[] serialized_data = null;
		
		try {
		    // //////////////////////////////////////////////////////////
		    // serialize and send each encoded symbol

		    int k = (int) Math.round((float) Kt * redondance) + 1;
		   //  System.out.println("                                                    "+k);
		    
		    for (int i = 0; i < no_symbols; i++) {
			
			// see the current state of the receiver
			if ( !reception_thread.get_status_end_loop() ) {
			    break;
			}
			// simple serialization
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			out = new ObjectOutputStream(bos);
			out.writeObject(symbols[i]);
			serialized_data = bos.toByteArray();
			out.close();
			bos.close();
			// setup an UDP packet with the serialized symbol
			// and
			// the destination info
			
			byte[] byte_array = { 0, 0, 0, 0 };
			byte[] packet_id = { 0, 0, 0, 0 };
			byte[] serialized_data_with_length = new byte[serialized_data.length + 2 * size_int];
			nb_packet++;
			
			if ( i > k ) {
			    
			    byte_array = intToByteArray(FLAG_PUSH);
			    packet_id = intToByteArray(ID_PACKET);
			    
			    System.arraycopy(byte_array, 0, serialized_data_with_length, 0, size_int);
			    System.arraycopy(packet_id, 0, serialized_data_with_length, size_int, size_int);
			    
			    System.arraycopy(serialized_data, 0, serialized_data_with_length, size_int * 2, serialized_data.length);
			    DatagramPacket sendPacket = new DatagramPacket(serialized_data_with_length, serialized_data_with_length.length, destIP, destPort);
			    clientSocket.send(sendPacket);
			    for (int u = 1; u < 5000; u++) {
				if ( reception_thread.get_need_more() ) {
				    
				    reception_thread.set_need_more(false);
				    break;
				}
				
				Thread.sleep(1);
			    }
			    
			    // k = k + (int) Math.round((float)
			    // reception_thread.get_number_of_packets()*
			    // redondance);
			    k = k + reception_thread.get_number_of_packets();
			    // System.out.println("   j'ai fini                         "+k);
			    reception_thread.reset_number_of_packets();
			    
			} else {
			    byte_array = intToByteArray(length_of_the_file);
			    packet_id = intToByteArray(ID_PACKET);
			    System.arraycopy(byte_array, 0, serialized_data_with_length, 0, size_int);
			    System.arraycopy(packet_id, 0, serialized_data_with_length, size_int, size_int);
			    
			    System.arraycopy(serialized_data, 0, serialized_data_with_length, size_int * 2, serialized_data.length);
			    
			    DatagramPacket sendPacket = new DatagramPacket(serialized_data_with_length, serialized_data_with_length.length, destIP, destPort);
			    clientSocket.send(sendPacket);
			     Thread.sleep(34);
			    //Thread.sleep(1);
			}
		    }
		} catch (IOException e) {
		    e.printStackTrace();
		    System.err.println("Socket error.");
		    System.exit(1);
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}
		
	    }
	    // close the socket
	    try {
		clientSocket.close();
		Thread.sleep(1);
	    } catch (InterruptedException e) {
		e.printStackTrace();
	    }
	}
	int total_overhead = (nb_packet - Kt) * 192;
	float total_overhead_pourcent = 100 * ((float) total_overhead / (float) (Kt * 192));
	nb_packet = nb_packet + reception_thread.get_nb_ack();
	/*
	 * System.out.println("Overhead : " + total_overhead + " octets soit :" + total_overhead_pourcent + "%"); System.out.println("Nombre total d’ACK : " +
	 * reception_thread.get_nb_ack()); System.out.println("Delai total d’envoi au premie récepteur: " + reception_thread.get_time_1());
	 * System.out.println("Delai total d’envoi : " + reception_thread.get_time_2());
	 */
	long time_2 = System.currentTimeMillis() - before;
	System.out.println(total_overhead);
	System.out.println(total_overhead_pourcent);
	System.out.println(reception_thread.get_nb_ack());
	System.out.println(reception_thread.get_time_1());
	System.out.println(reception_thread.get_time_2());
	System.out.println((float) ((float) reception_thread.get_time_2() - (float) reception_thread.get_time_1()) / (float) reception_thread.get_time_1());
	// System.out.println(time_2);
	
	reception_thread.join();
    }
}
