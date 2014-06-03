import java.io.ByteArrayInputStream;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.SocketException;
import java.io.File;
import java.io.IOException;
import java.net.UnknownHostException;
import java.nio.file.Files;
import java.util.Random;

import java.io.ObjectInput;
import java.io.ObjectInputStream;
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
    final static int size_int = 4;
    final static int ACK = -2;
    final static int NACK = -1;
    // final static double redondance = 1.00;
    
    final static int FLAG_PUSH = 999999999;
    final static int FLAG_STOP = 111111111;
    
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
    
    public static byte[] parameter_test(byte[] receivePacket, int parameter_test) {
	
	byte[] packetData = receivePacket;
	
	switch (parameter_test) {
	case 1:
	    
	    break;
	case 10:
	    
	    break;
	case 20:
	    
	    break;
	default:
	}
	
	return packetData;
    }
    
    public static final int look_for_the_answer(InetAddress groupeIP, int port) throws IOException {
	int packetData = 0;
	MulticastSocket socketReception;
	socketReception = new MulticastSocket(port);
	socketReception.joinGroup(groupeIP);
	byte[] receiveData = new byte[51024];
	DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
	
	try {
	    socketReception.receive(receivePacket);
	    byte[] packetData_2 = receivePacket.getData();
	    
	    packetData = byte_array_to_int(packetData_2);
	    /*
	     * for (int l = 0; l < size_int; l++) { packetData = (packetData << 8) + (packetData_2[l] & 0xff); }
	     */
	    
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
	
	int para_test = Integer.valueOf(args[5]);
	
	Emetteur_thread_multi sending_thread = new Emetteur_thread_multi(sendIP, src_port + 1);
	sending_thread.set_parameter_test(para_test);
	
	// Recepteur_thread Reception_thread = new Recepteur_thread(src_port+2);
	/**
	 * End of the tests on the parameter
	 */
	System.out.println("Listening for file " + fileName + " (" + fileSize + " bytes) at port " + src_port + "\n");
	/**
	 * preparation for the decoding
	 */
	int number_of_ack = 0;
	sending_thread.start();
	// create a new Encoder instance (usually one per file) and for that
	// get the file size
	// //////////////////////
	MulticastSocket serverSocket_for_the_size = null;
	try {
	    serverSocket_for_the_size = new MulticastSocket(src_port);
	    serverSocket_for_the_size.joinGroup(sendIP);
	} catch (SocketException e1) {
	    e1.printStackTrace();
	    System.err.println("Error opening socket.");
	    System.exit(1);
	}
	byte[] receiveData_for_the_size = new byte[51024];
	// create a UDP packet
	DatagramPacket receivePacket_for_the_size = new DatagramPacket(receiveData_for_the_size, receiveData_for_the_size.length);
	
	serverSocket_for_the_size.receive(receivePacket_for_the_size);
	
	// get the packet's payload
	byte[] packetData_for_the_size = receivePacket_for_the_size.getData();
	for (int i = 0; i < size_int; i++) {
	    fileSize = (fileSize << 8) + (packetData_for_the_size[i] & 0xff);
	}
	byte[] first_packet_data = new byte[receivePacket_for_the_size.getData().length - size_int * 2];
	System.arraycopy(receivePacket_for_the_size.getData(), size_int * 2, first_packet_data, 0, first_packet_data.length);
	
	// ////////////////////////
	
	serverSocket_for_the_size.close();
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
	// sending_thread.start();
	// create socket and wait for packets
	int re_send_for_a_lost = 0;
	int number_of_received_packets = 0;
	
	boolean successfulDecoding = false;
	Set<EncodingSymbol> received_packets = new HashSet<EncodingSymbol>();
	//int nb_of_utils_packet = (int) Math.round((float) total_symbols * redondance);
	 int nb_of_utils_packet =total_symbols;
	
	int compteur_utils_packet = -1;
	long before_2 = System.currentTimeMillis();
	int id_data_packet;
	int compteur=0;
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
		for (int recv = 0; recv < total_symbols; recv++) {
		    compteur++;
		    compteur_utils_packet++;
		    /**
		     * reception of the response and add noise
		     */
		    // allocate some memory for receiving the packets
		    if ( para_test == 5 && (nb_of_utils_packet - 2) >= compteur_utils_packet ) {
			if ( (nb_of_utils_packet - 2) == compteur_utils_packet ) {
			    // compteur_utils_packet=0;
			    para_test++;
			}
			continue;
		    }
		    
		    byte[] receiveData = new byte[51024];
		    byte[] packetData;
		    
		    DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
		    // set the time to wait before close the socket
		    int reception_timer = 2000;
		    serverSocket.setSoTimeout(reception_timer);
		    try {
			number_of_received_packets++;
			serverSocket.receive(receivePacket);
			// System.out.println("                 Socket ");
			
		    } catch (java.net.SocketTimeoutException e) {
			// call the sending thread
			sending_thread.set_ACK_NACK(NACK);
			
			sending_thread.send_thing();
			System.out.println("Socket bloquée");
			number_of_ack++;
			recv--;
			compteur_utils_packet--;
			continue;
		    }
		    // If the packets is lost
		    ////////////////////////////////////////////
		    Thread.sleep(30);
		    if ( packet_is_lost(canalloss) ) {
			re_send_for_a_lost++;
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
		    
		    
		    if ( ((nb_of_utils_packet - 4) < compteur_utils_packet) && para_test == 6 ) {
			para_test++;
			flag = FLAG_PUSH;
			System.out.println("                                       " + nb_of_utils_packet);
			System.out.println("                                       " + compteur_utils_packet);
		    }
		    
		    packetData = parameter_test(packetData, para_test);
		    System.out.println("    fin     "+nb_of_utils_packet+"    maintenant      "+ compteur);
		    
		    if ( flag == FLAG_PUSH && para_test == 2 ) {
			System.out.println("          je decode");
			para_test = 10;
			continue;
		    }
		    
		    
		    if ( flag == FLAG_PUSH ) {
			if ( nb_of_utils_packet < compteur_utils_packet ) {
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
		    
		    ByteArrayInputStream bis = new ByteArrayInputStream(packetData);
		    ObjectInput in = null;
		    try {
			in = new ObjectInputStream(bis);
			received_packets.add((EncodingSymbol) in.readObject());
		    } catch (ClassNotFoundException e) {
			e.printStackTrace();
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
	    
	    // order received packets
	    int maxESI = -1;
	    
	    for (EncodingSymbol es : received_packets)
		if ( es.getESI() > maxESI )
		    maxESI = es.getESI();
	    
	    Iterator<EncodingSymbol> it = received_packets.iterator();
	    EncodingSymbol[][] aux = new EncodingSymbol[no_blocks][maxESI + 1];
	    while (it.hasNext()) {
		EncodingSymbol pack = it.next();
		aux[pack.getSBN()][pack.getESI()] = pack;
	    }
	    
	    /**
	     * decoding
	     */
	    
	    // where the decoded data will be stored
	    byte[] decoded_data = null;
	    
	    // where the source blocks will be stored
	    SourceBlock[] blocks = new SourceBlock[no_blocks];
	    
	    successfulDecoding = true;
	    
	    // for each block
	    for (int sblock = 0; sblock < no_blocks; sblock++) {
		//System.out.println("\nDecoding block: " + sblock);
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
		    System.out.println("\nSuccessfuint lly decoded block: " + sblock + " (in " + diff + " milliseconds)");
		    
		} catch (SingularMatrixException e) {
		    System.out.println("\nDecoding failed!");
		    successfulDecoding = false;
		    sending_thread.set_ACK_NACK(NACK);
		    sending_thread.send_thing();
		    number_of_ack++;
		    continue;
		} catch (RuntimeException e) {
		    // nb of missing packets
		    int nb_packets_lost = Integer.parseInt(e.getMessage());
		    compteur_utils_packet = 0;
		    sending_thread.set_ACK_NACK(nb_packets_lost);
		     nb_of_utils_packet = nb_packets_lost;
		    // nb_packets_lost * redondance);
		   // nb_of_utils_packet = (int) Math.round((float) nb_packets_lost * (1 + ((float) nb_packets_lost / (float) nb_of_utils_packet)));
		    
		    // re_send_for_a_lost=0;
		    
		    successfulDecoding = false;
		    if ( para_test == 3 ) {
			Recepteur_thread_multi recep_thread = new Recepteur_thread_multi(src_port, sendIP, 1, false);
			recep_thread.start();
			
			for (int u = 1; u < 4000; u++) {
			    if ( recep_thread.get_number_of_packets() == FLAG_PUSH ) {
				// System.out.println("                                                            "+u);
				break;
			    }
			    
			    Thread.sleep(1);
			}
			sending_thread.send_thing();
			recep_thread.join();
			para_test=10;
			continue;
		    } else
			sending_thread.send_thing();
		    number_of_ack++;
		    continue;
		}
		// ///////////////////////////////////////////////////////////
		if ( successfulDecoding )
		    continue;
		
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
		    
		    while (true) {
			
			if ( para_test == 1 ) {
			    if ( look_for_the_answer(sendIP, src_port) == FLAG_PUSH ) {
				sending_thread.set_ACK_NACK(ACK);
				sending_thread.send_thing();
				System.out.println("           envoie ACK 1 mauvais");
				break;
			    }
			    
			} else if ( para_test == 3 ) {
			    Recepteur_thread_multi recep_thread = new Recepteur_thread_multi(src_port, sendIP, 1, false);
			    recep_thread.start();
			    
			    for (int u = 1; u < 4000; u++) {
				// System.out.println("numéros affichés              "
				// + recep_thread.get_number_of_packets());
				if ( recep_thread.get_number_of_packets() == FLAG_PUSH ) {
				    break;
				}
				
				Thread.sleep(1);
			    }
			    sending_thread.set_ACK_NACK(ACK);
			    sending_thread.send_thing();
			    System.out.println("           envoie ACK 1 mauvais 3");
			    recep_thread.join();
			    break;
			}
			
			else {
			    sending_thread.set_ACK_NACK(ACK);
			    sending_thread.send_thing();
			    System.out.println("           envoie ACK 1 bon");
			    break;
			    
			}
		    }
		    long time = System.currentTimeMillis() - before_2;
		    
		    Files.write(file.toPath(), decoded_data);
		    number_of_ack++;
		    // System.out.println("nb of symboles : " + total_symbols);
		    System.out.println("nb reiceive packets: " + number_of_received_packets);
		    System.out.println((float)(100*re_send_for_a_lost)/452);
		    int total_overhead = (number_of_received_packets - total_symbols) * 192;
		    // System.out.println("Nombre total d’ACK : " +
		    // number_of_ack);
		    
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
