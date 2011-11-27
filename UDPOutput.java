import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;

import java.io.DataOutputStream;
import java.io.ByteArrayOutputStream;

/**
 *	This class implements a simple UDP server.
 *
 *	@author Alex Olwal
 *
 *	@see java.net.DatagramPacket
 *	@see java.net.DatagramSocket
 *
 */

public class UDPOutput
{
  //the port that the data will be sent from
  int sendFromPort;

  //the host and the port of the recipient to send data to
  String sendToHost;
  int sendToPort;

  DatagramSocket socket;
  DatagramPacket packet;
  InetAddress recipient;

  /**
   * 	 Creates and initializes a new UDPServer, sending data from the specified port to the specified 
   * 	 port on the recipient. 
   * 	
   * 	 @param sendToHost The name or ip address of the recipient
   * 	 @param sendToPort The port that the data will be sent to on the recipient
   * 	 @param sendFromPort The port that we will send data from
   * 	 
   	 */
  public UDPOutput(String sendToHost, int sendToPort, int sendFromPort)
  {
    this.sendFromPort = sendFromPort;
    this.sendToHost = sendToHost;
    this.sendToPort = sendToPort;

    try
    {
      socket = new DatagramSocket(sendFromPort);
      recipient = InetAddress.getByName(sendToHost);
    }
    catch (java.net.SocketException e) { 
      System.err.println("UDPOutput.init(): " + e); 
    }
    catch (java.net.UnknownHostException e) { 
      System.err.println("UDPOutput.init(): " + e); 
    }
  }

  /**
   * 	 *	Sends the provided byte array.
   * 	 *
   * 	 *	@param buffer The byte array to be sent to the recipient.
   * 	 *
   	 */
  public void send(byte[] buffer)
  {
    packet = new DatagramPacket(buffer, buffer.length, recipient, sendToPort);
    try 
    { 
      socket.send(packet); 
    } 
    catch (java.io.IOException e) 
    { 
      System.err.println("UDPOutput.send(...): " + e); 
    }
  }

  public void send(String data)
  {
//      System.out.println(data);
    send(data.getBytes());
  }
}



