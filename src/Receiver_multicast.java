import java.io.ByteArrayInputStream;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.SocketException;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.UnknownHostException;
import java.nio.file.Files;
import java.util.Random;

import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.util.ConcurrentModificationException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import RQLibrary.Encoder;
import RQLibrary.EncodingPacket;
import RQLibrary.EncodingSymbol;
import RQLibrary.Partition;
import RQLibrary.SingularMatrixException;
import RQLibrary.SourceBlock;

public class Receiver_multicast {
    private static Set<EncodingSymbol> received_packets_2 = new HashSet<EncodingSymbol>();
    
    final static int size_int = 4;
    final static int ACK = -2;
    final static int NACK = -1;
    // final static double redondance = 1.00;
    
    final static int FLAG_PUSH = 999999999;
    final static int FLAG_STOP = 111111111;
    
    public static void print_in_file(long message, int port) {
	try {
	    File file = new File("/home/tai/workspace/stage_pfe/bin/histo/time_division_r_final"+port+".txt");
	    
	    // if file doesnt exists, then create it
	    if ( !file.exists() ) {
		file.createNewFile();
	    }
	    
	    FileWriter fw = new FileWriter(file.getAbsoluteFile(), true);
	    BufferedWriter bw = new BufferedWriter(fw);
	    bw.write(String.valueOf(message) + "\n");
	    bw.close();
	    
	} catch (IOException e) {
	    e.printStackTrace();
	}
    }
    
    // Simulate a lost of the canal
    public static boolean packet_is_lost(float percentageLoss) {
	Random randomGenerator = new Random();
	int rand = randomGenerator.nextInt(100);
	if ( rand < (int) percentageLoss ) {
	    return true;
	}
	return false;
	
    }
    
    public static final int byte_array_to_int(byte[] byte_array) {
	int interger = 0;
	for (int i = 0; i < size_int; i++) {
	    interger = (interger << 8) + (byte_array[i] & 0xff);
	}
	return interger;
    }
    
    public static final int look_for_the_answer(InetAddress groupeIP, int port) throws IOException {
	int packetData = 0;
	MulticastSocket socketReception;
	socketReception = new MulticastSocket(port);
	socketReception.joinGroup(groupeIP);
	byte[] receiveData = new byte[500];
	DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
	
	try {
	    socketReception.receive(receivePacket);
	    byte[] packetData_2 = receivePacket.getData();
	    
	    packetData = byte_array_to_int(packetData_2);
	    
	} catch (Exception exc) {
	    System.out.println(exc);
	}
	
	socketReception.close();
	return packetData;
    }
    
    byte[] serialized_data = new byte[256];
    
    public static void main(String[] args) throws Exception {
	
	if ( args.length != 7 ) {
	    StringBuilder s = new StringBuilder();
	    s.append("Usage: \n");
	    s.append("    java -jar Receiver.jar pathToFile fileSize overhead port\n");
	    s.append("\n        - pathToFile  : path to store the received file.");
	    s.append("\n        - overhead    : the necessary symbol overhead needed for decoding (usually between 0 and 2).");
	    s.append("\n        - destIP      : the IP address for the multicast.");
	    s.append("\n        - portNumber  : the port the receiver will be listening on.");
	    s.append("\n        - canalloss   : the loss due to the canal.");
	    s.append("\n        - test   : Para de test.");
	    s.append("\n        - redondance  : Para de test.");
	    System.out.println(s.toString());
	    System.exit(1);
	}
	
	double redondance = Double.valueOf(args[6]);
	
	String fileName = args[0];
	
	// check fileSize
	long fileSize = 0;
	
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
	InetAddress sendIP = null;
	
	try {
	    sendIP = InetAddress.getByName(args[2]);
	} catch (UnknownHostException e2) {
	    e2.printStackTrace();
	    System.err.println("invalid IP");
	    System.exit(1);
	}
	
	// check source port
	int src_port = -1;
	
	try {
	    src_port = Integer.valueOf(args[3]);
	} catch (NumberFormatException e) {
	    System.err.println("Invalid port. (must be above 1024)");
	    System.exit(-1);
	}
	
	if ( src_port < 1024 || src_port >= 65535 ) {
	    System.err.println("Invalid port. (must be above 1024)");
	    System.exit(-1);
	}
	
	float canalloss = -1;
	
	try {
	    canalloss = Integer.valueOf(args[4]);
	} catch (NumberFormatException e) {
	    System.err.println("Invalid network loss percentage. (must be a float in [0.0, 100.0[)");
	    System.exit(-1);
	}
	
	if ( canalloss < 0 || canalloss >= 100 ) {
	    System.err.println("Invalid network loss percentage. (must be a float in [0.0, 100.0[)");
	    System.exit(-1);
	}
	boolean lol = true;
	int para_test = Integer.valueOf(args[5]);
	
	Emetteur_thread_multi sending_thread = new Emetteur_thread_multi(sendIP, src_port + 1);
	sending_thread.set_parameter_test(para_test);
	
	System.out.println("Listening for file " + fileName + " (" + fileSize + " bytes) at port " + src_port + "\n");
	/**
	 * preparation for the decoding
	 */
	sending_thread.start();
	// the RTT
	int RTT = 5000;
	Treatment treatment_thread = new Treatment(RTT);
	
	/**
	 * Get the first packet to get the size of the file
	 */
	MulticastSocket serverSocket_for_the_size = null;
	try {
	    serverSocket_for_the_size = new MulticastSocket(src_port);
	    serverSocket_for_the_size.joinGroup(sendIP);
	} catch (SocketException e1) {
	    e1.printStackTrace();
	    System.err.println("Error opening socket.");
	    System.exit(1);
	}
	byte[] receiveData_for_the_size = new byte[500];
	// create a UDP packet
	DatagramPacket receivePacket_for_the_size = new DatagramPacket(receiveData_for_the_size, receiveData_for_the_size.length);
	
	serverSocket_for_the_size.receive(receivePacket_for_the_size);
	
	if ( lol ) {
	    print_in_file(System.currentTimeMillis(), src_port);
	    lol = false;
	}
	
	// get the packet's payload
	byte[] packetData_for_the_size = receivePacket_for_the_size.getData();
	for (int i = 0; i < size_int; i++) {
	    fileSize = (fileSize << 8) + (packetData_for_the_size[i] & 0xff);
	}
	byte[] first_packet_data = new byte[receivePacket_for_the_size.getData().length - size_int * 2];
	System.arraycopy(receivePacket_for_the_size.getData(), size_int * 2, first_packet_data, 0, first_packet_data.length);
	treatment_thread.add_packet(first_packet_data);
	serverSocket_for_the_size.close();
	// create a new Encoder instance (usually one per file) and for that
	// get the file size
	Encoder encoder = new Encoder((int) fileSize);
	
	// total number of source symbols (for all source blocks)overhead
	int Kt = encoder.getKt();
	System.out.println("# source symbols: " + Kt);
	
	// number of source blocks
	int no_blocks = encoder.Z;
	System.out.println("# source blocks: " + no_blocks);
	
	// the minimum amount of symbols we'll be waiting for before trying
	// to
	// decode
	int total_symbols = Kt + no_blocks * overhead;
	
	Partition KZ = new Partition(Kt, no_blocks);
	int KL = KZ.get(1);
	int KS = KZ.get(2);
	int ZL = KZ.get(3);
	
	/**
	 * built of the socket
	 * 
	 */
	// create socket and wait for packets
	int re_send_for_a_lost = 0;
	int number_of_received_packets = 0;
	
	boolean successfulDecoding = false;
	
	int nb_of_utils_packet = total_symbols;
	int compteur_utils_packet = 0;
	long before_2 = System.currentTimeMillis();
	int id_data_packet;
	
	while (!successfulDecoding) {
	    MulticastSocket serverSocket = null;
	    try {
		serverSocket = new MulticastSocket(src_port);
		serverSocket.joinGroup(sendIP);
	    } catch (SocketException e1) {
		e1.printStackTrace();
		System.err.println("Error opening socket.");
		System.exit(1);
	    }
	    try {
		System.out.println("\nWaiting for packets...");
		// wait for all the symbols that we need...
		int flag = 0;
		total_symbols = total_symbols * 2;
		
		int b = 1;
		for (int recv = 0; recv < total_symbols; recv++) {
		    b++;
		    
		    compteur_utils_packet++;
		    /**
		     * reception of the response and add noise
		     */
		    // test of a delay in a ack
		    if ( para_test == 5 && (nb_of_utils_packet - 2) >= compteur_utils_packet ) {
			if ( (nb_of_utils_packet - 2) == compteur_utils_packet ) {
			    para_test++;
			}
			continue;
		    }
		    
		    // allocate some memory for receiving the packets
		    byte[] receiveData = new byte[500];
		    byte[] packetData;
		    
		    DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
		    // set the timeout for the receiver
		    int reception_timer = 2 * RTT;
		    serverSocket.setSoTimeout(reception_timer);
		    try {
			number_of_received_packets++;
			serverSocket.receive(receivePacket);
			
		    } catch (java.net.SocketTimeoutException e) {
			// call the sending thread
			sending_thread.set_ACK_NACK(NACK);
			
			sending_thread.send_thing();
			System.out.println("Socket bloquée");
			recv--;
			compteur_utils_packet--;
			continue;
		    }
		    packetData = new byte[receivePacket.getData().length - size_int * 2];
		    
		    byte[] flag_push = new byte[size_int];
		    byte[] data_id = new byte[size_int];
		    System.arraycopy(receivePacket.getData(), 0, flag_push, 0, size_int);
		    System.arraycopy(receivePacket.getData(), size_int, data_id, 0, size_int);
		    
		    System.arraycopy(receivePacket.getData(), size_int * 2, packetData, 0, packetData.length);
		    
		    id_data_packet = byte_array_to_int(data_id);
		    flag = byte_array_to_int(flag_push);
		    if ( packet_is_lost(canalloss) ) {
			re_send_for_a_lost++;
			recv--;
			compteur_utils_packet--;
			continue;
		    }
		    
		    // System.out.println("  flag push     "+flag+"   id packet   "+id_data_packet);
		    // Add packet to the rtt queue
		    
		    treatment_thread.add_packet(packetData);
		    
		    // retard of FLAG
		    if ( ((nb_of_utils_packet - 4) < compteur_utils_packet) && para_test == 6 ) {
			para_test++;
			flag = FLAG_PUSH;
			System.out.println("                                       " + nb_of_utils_packet);
			System.out.println("                                       " + compteur_utils_packet);
		    }
		    
		    // lost of a PUSH flag
		    if ( flag == FLAG_PUSH && para_test == 2 ) {
			System.out.println("          je decode");
			para_test = 10;
			continue;
		    }
		    
		    // got a flag and enough packets decode
		    if ( flag == FLAG_PUSH ) {
			//System.out.println(nb_of_utils_packet + " ce que j'ai besoin " + compteur_utils_packet + " ce que j'ai vraiment " + b);
			if ( nb_of_utils_packet <= compteur_utils_packet ) {
			    System.out.println("          je decode");
			    break;
			}
			System.out.println("          je peux pas decoder");
			sending_thread.set_ACK_NACK((nb_of_utils_packet - compteur_utils_packet));
			sending_thread.send_thing();
			recv--;
			continue;
			
		    }
		    if ( nb_of_utils_packet < compteur_utils_packet ) {
			continue;
		    }
		}
		
	    } catch (IOException e) {
		e.printStackTrace();
		System.err.println("Socket error.");
	    }
	    serverSocket.close();
	    /**
	     * organize into source blocks
	     */
	   
	    int maxESI = -1;
	    
	    while (nb_of_utils_packet >= treatment_thread.get_nb()) {
		Thread.sleep(10);
	    }
	    
	    // print_in_file("\n apres sortie traitement   \n",src_port);
	    print_in_file(System.currentTimeMillis(), src_port);
	    final Set<EncodingSymbol> received_packets = treatment_thread.get_encoding_symbol();
	    
	    System.out.println("                                    nb of packet pop'up: " + received_packets.size());
	    sending_thread.set_ACK_NACK(ACK);
	    sending_thread.send_thing();
	    System.out.println("           envoie ACK 1 bon");
	    
	    // order received packets
	    received_packets_2 = received_packets;
	    EncodingSymbol[][] aux_2= null;
	    EncodingSymbol[][] aux;
	    try{
	    synchronized (received_packets) {
		
		for (EncodingSymbol es : received_packets) {
		    
		    if ( es.getESI() > maxESI )
			maxESI = es.getESI();
		}
		
		Iterator<EncodingSymbol> it = received_packets.iterator();
		aux_2 = new EncodingSymbol[no_blocks][maxESI + 1];
		
		while (it.hasNext()) {
		    EncodingSymbol pack = it.next();
		    aux_2[pack.getSBN()][pack.getESI()] = pack;
		}
	    }
	    }
	    catch(ConcurrentModificationException e)
	    {
		e.printStackTrace();
	    }
	    aux = aux_2;
	    
	    /**
	     * decoding
	     */
	 // where the decoded data will be stored
	    byte[] decoded_data = null;
	    SourceBlock[] blocks = new SourceBlock[no_blocks];
	    boolean decodage=true;
	    if (decodage){
	    
	    
	    successfulDecoding = true;
	    
	    // for each block
	    for (int sblock = 0; sblock < no_blocks; sblock++) {
		try {
		    // get the time before decoding
		    
		    long before = System.currentTimeMillis();
		    
		    // decode
		    if ( sblock < ZL )
			blocks[sblock] = Encoder.decode(new EncodingPacket(0, aux[sblock], KL, Encoder.MAX_PAYLOAD_SIZE));
		    else
			blocks[sblock] = Encoder.decode(new EncodingPacket(0, aux[sblock], KS, Encoder.MAX_PAYLOAD_SIZE));
		    
		    // get time after decoding
		    long after = System.currentTimeMillis();
		    
		    long diff = (long) (after - before);
		    // print_in_file(" \n apres décodage \n",src_port);
		    print_in_file(System.currentTimeMillis(), src_port);
		    System.out.println("\nSuccessfuint lly decoded block: " + sblock + " (in " + diff + " milliseconds)");
		    
		} catch (SingularMatrixException e) {
		    // Decoding failed
		    System.out.println("\nDecoding failed!");
		    successfulDecoding = false;
		    sending_thread.set_ACK_NACK(NACK);
		    sending_thread.send_thing();
		    continue;
		} catch (RuntimeException e) {
		    // Decoding failed not enough packets
		    int nb_packets_lost = Integer.parseInt(e.getMessage());
		    compteur_utils_packet = 0;
		    sending_thread.set_ACK_NACK(nb_packets_lost);
		    nb_of_utils_packet = nb_packets_lost;
		    successfulDecoding = false;
		    
		    // Retard of an ACK 4 sec
		    if ( para_test == 3 ) {
			Recepteur_thread_multi recep_thread = new Recepteur_thread_multi(src_port, sendIP, 1, false);
			recep_thread.start();
			
			for (int u = 1; u < 4000; u++) {
			    if ( recep_thread.get_number_of_packets() == FLAG_PUSH ) {
				break;
			    }
			    
			    Thread.sleep(1);
			}
			sending_thread.send_thing();
			recep_thread.join();
			para_test = 10;
			continue;
		    } else
			sending_thread.send_thing();
		    continue; // where the source blocks will be stored
		}
		if ( successfulDecoding )
		    continue;
		
	    }
	    }
	    
	    // if the decoding was successful for all blocks, we can unpartition
	    // the
	    // data
	    if ( successfulDecoding ) {
		
		decoded_data = encoder.unPartition(blocks);
		// and finally, write the decoded data to the file
		File file = new File(fileName);
		
		try {
		    if ( file.exists() )
			file.createNewFile();
		    
		    /*
		     * while (true) { // Lost of an ACK if ( para_test == 1 ) { if ( look_for_the_answer(sendIP, src_port) == FLAG_PUSH ) {
		     * sending_thread.set_ACK_NACK(ACK); sending_thread.send_thing(); System.out.println("           envoie ACK 1 mauvais"); break; }
		     * 
		     * // Retard of an ACK 4 sec } else if ( para_test == 3 ) { Recepteur_thread_multi recep_thread = new Recepteur_thread_multi(src_port,
		     * sendIP, 1, false); recep_thread.start();
		     * 
		     * for (int u = 1; u < 4000; u++) { if ( recep_thread.get_number_of_packets() == FLAG_PUSH ) { break; }
		     * 
		     * Thread.sleep(1); } sending_thread.set_ACK_NACK(ACK); sending_thread.send_thing();
		     * System.out.println("           envoie ACK 1 mauvais 3"); recep_thread.join(); break; } // If no lost else {
		     * sending_thread.set_ACK_NACK(ACK); sending_thread.send_thing(); System.out.println("           envoie ACK 1 bon"); break;
		     * 
		     * } }
		     */
		    
		    // Terminate the thread
		    treatment_thread.set_end_boucle();
		    treatment_thread.join();
		    
		    long time = System.currentTimeMillis() - before_2;
		    
		    Files.write(file.toPath(), decoded_data);
		    // Print the result
		    System.out.println("nb reiceive packets: " + number_of_received_packets);
		    System.out.println((float) (100 * re_send_for_a_lost) / 834);
		    int total_overhead = (number_of_received_packets - total_symbols) * 192;
		    
		    System.out.println("Delai total d’envoi du message : " + time);
		    break;
		    
		} catch (IOException e) {
		    System.err.println("Could not open file.");
		    e.printStackTrace();
		    System.exit(1);
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}
	    }
	}
    }
}
