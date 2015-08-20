#
#
#            Nim's Runtime Library
#        (c) Copyright 2015 Andreas Rumpf
#
#    See the file "LICENSE.txt", included in this
#    distribution, for details about the copyright.
#

import
  sdl

when defined(windows):
  const
    NetLibName = "SDL_net.dll"
elif defined(macosx):
  const
    NetLibName = "libSDL_net.dylib"
else:
  const
    NetLibName = "libSDL_net.so"
const                         #* Printable format: "%d.%d.%d", MAJOR, MINOR, PATCHLEVEL *
  MAJOR_VERSION* = 1
  MINOR_VERSION* = 2
  PATCHLEVEL* = 5        # SDL_Net.h constants
                         #* Resolve a host name and port to an IP address in network form.
                         #   If the function succeeds, it will return 0.
                         #   If the host couldn't be resolved, the host portion of the returned
                         #   address will be INADDR_NONE, and the function will return -1.
                         #   If 'host' is NULL, the resolved host will be set to INADDR_ANY.
                         # *
  INADDR_ANY* = 0x00000000
  INADDR_NONE* = 0xFFFFFFFF #***********************************************************************
                            #* UDP network API                                                     *
                            #***********************************************************************
                            #* The maximum channels on a a UDP socket *
  MAX_UDPCHANNELS* = 32   #* The maximum addresses bound to a single UDP socket channel *
  MAX_UDPADDRESSES* = 4

type  # SDL_net.h types
      #***********************************************************************
      #* IPv4 hostname resolution API                                        *
      #***********************************************************************
  PIPAddress* = ptr IPAddress
  IPAddress*{.final.} = object  #* TCP network API
    host*: uint32             # 32-bit IPv4 host address */
    port*: uint16             # 16-bit protocol port */

  PTCPSocket* = ptr TCPSocket
  TCPSocket*{.final.} = object  # UDP network API
    ready*: int
    channel*: int
    remoteAddress*: IPAddress
    localAddress*: IPAddress
    sflag*: int

  PUDP_Channel* = ptr UDP_Channel
  UDP_Channel*{.final.} = object
    numbound*: int
    address*: array[0..MAX_UDPADDRESSES - 1, IPAddress]

  PUDPSocket* = ptr UDPSocket
  UDPSocket*{.final.} = object
    ready*: int
    channel*: int
    address*: IPAddress
    binding*: array[0..MAX_UDPCHANNELS - 1, UDP_Channel]

  PUDPpacket* = ptr UDPpacket
  PPUDPpacket* = ptr PUDPpacket
  UDPpacket*{.final.} = object  #***********************************************************************
                                 #* Hooks for checking sockets for available data                       *
                                 #***********************************************************************
    channel*: int             #* The src/dst channel of the packet *
    data*: pointer            #* The packet data *
    length*: int              #* The length of the packet data *
    maxlen*: int              #* The size of the data buffer *
    status*: int              #* packet status after sending *
    address*: IPAddress       #* The source/dest address of an incoming/outgoing packet *

  PSocket* = ptr Socket
  Socket*{.final.} = object
    ready*: int
    channel*: int

  PSocketSet* = ptr SocketSet
  SocketSet*{.final.} = object  # Any network socket can be safely cast to this socket type *
    numsockets*: int
    maxsockets*: int
    sockets*: PSocket

  PGenericSocket* = ptr GenericSocket
  GenericSocket*{.final.} = object
    ready*: int
{.deprecated: [TSocket: Socket, TSocketSet: SocketSet, TIPAddress: IpAddress,
        TTCPSocket: TCPSocket, TUDP_Channel: UDP_Channel, TUDPSocket: UDPSocket,
        TUDPpacket: UDPpacket, TGenericSocket: GenericSocket].}

proc version*(x: var Version)
  #* Initialize/Cleanup the network API
  #   SDL must be initialized before calls to functions in this library,
  #   because this library uses utility functions from the SDL library.
  #*
proc init*(): int{.cdecl, importc: "SDLNet_Init", dynlib: NetLibName.}
proc quit*(){.cdecl, importc: "SDLNet_Quit", dynlib: NetLibName.}
  #* Resolve a host name and port to an IP address in network form.
  #   If the function succeeds, it will return 0.
  #   If the host couldn't be resolved, the host portion of the returned
  #   address will be INADDR_NONE, and the function will return -1.
  #   If 'host' is NULL, the resolved host will be set to INADDR_ANY.
  # *
proc resolveHost*(address: var IPAddress, host: cstring, port: uint16): int{.
    cdecl, importc: "SDLNet_ResolveHost", dynlib: NetLibName.}
  #* Resolve an ip address to a host name in canonical form.
  #   If the ip couldn't be resolved, this function returns NULL,
  #   otherwise a pointer to a static buffer containing the hostname
  #   is returned.  Note that this function is not thread-safe.
  #*
proc resolveIP*(ip: var IPAddress): cstring{.cdecl,
    importc: "SDLNet_ResolveIP", dynlib: NetLibName.}
  #***********************************************************************
  #* TCP network API                                                     *
  #***********************************************************************
  #* Open a TCP network socket
  #   If ip.host is INADDR_NONE, this creates a local server socket on the
  #   given port, otherwise a TCP connection to the remote host and port is
  #   attempted.  The address passed in should already be swapped to network
  #   byte order (addresses returned from SDLNet_ResolveHost() are already
  #   in the correct form).
  #   The newly created socket is returned, or NULL if there was an error.
  #*
proc tcpOpen*(ip: var IPAddress): PTCPSocket{.cdecl,
    importc: "SDLNet_TCP_Open", dynlib: NetLibName.}
  #* Accept an incoming connection on the given server socket.
  #   The newly created socket is returned, or NULL if there was an error.
  #*
proc tcpAccept*(server: PTCPSocket): PTCPSocket{.cdecl,
    importc: "SDLNet_TCP_Accept", dynlib: NetLibName.}
  #* Get the IP address of the remote system associated with the socket.
  #   If the socket is a server socket, this function returns NULL.
  #*
proc tcpGetPeerAddress*(sock: PTCPSocket): PIPAddress{.cdecl,
    importc: "SDLNet_TCP_GetPeerAddress", dynlib: NetLibName.}
  #* Send 'len' bytes of 'data' over the non-server socket 'sock'
  #   This function returns the actual amount of data sent.  If the return value
  #   is less than the amount of data sent, then either the remote connection was
  #   closed, or an unknown socket error occurred.
  #*
proc tcpSend*(sock: PTCPSocket, data: pointer, length: int): int{.cdecl,
    importc: "SDLNet_TCP_Send", dynlib: NetLibName.}
  #* Receive up to 'maxlen' bytes of data over the non-server socket 'sock',
  #   and store them in the buffer pointed to by 'data'.
  #   This function returns the actual amount of data received.  If the return
  #   value is less than or equal to zero, then either the remote connection was
  #   closed, or an unknown socket error occurred.
  #*
proc tcpRecv*(sock: PTCPSocket, data: pointer, maxlen: int): int{.cdecl,
    importc: "SDLNet_TCP_Recv", dynlib: NetLibName.}
  #* Close a TCP network socket *
proc tcpClose*(sock: PTCPSocket){.cdecl, importc: "SDLNet_TCP_Close",
                                       dynlib: NetLibName.}
  #***********************************************************************
  #* UDP network API                                                     *
  #***********************************************************************
  #* Allocate/resize/free a single UDP packet 'size' bytes long.
  #   The new packet is returned, or NULL if the function ran out of memory.
  # *
proc allocPacket*(size: int): PUDPpacket{.cdecl,
    importc: "SDLNet_AllocPacket", dynlib: NetLibName.}
proc resizePacket*(packet: PUDPpacket, newsize: int): int{.cdecl,
    importc: "SDLNet_ResizePacket", dynlib: NetLibName.}
proc freePacket*(packet: PUDPpacket){.cdecl, importc: "SDLNet_FreePacket",
    dynlib: NetLibName.}
  #* Allocate/Free a UDP packet vector (array of packets) of 'howmany' packets,
  #   each 'size' bytes long.
  #   A pointer to the first packet in the array is returned, or NULL if the
  #   function ran out of memory.
  # *
proc allocPacketV*(howmany: int, size: int): PUDPpacket{.cdecl,
    importc: "SDLNet_AllocPacketV", dynlib: NetLibName.}
proc freePacketV*(packetV: PUDPpacket){.cdecl,
    importc: "SDLNet_FreePacketV", dynlib: NetLibName.}
  #* Open a UDP network socket
  #   If 'port' is non-zero, the UDP socket is bound to a local port.
  #   This allows other systems to send to this socket via a known port.
  #*
proc udpOpen*(port: uint16): PUDPSocket{.cdecl, importc: "SDLNet_UDP_Open",
    dynlib: NetLibName.}
  #* Bind the address 'address' to the requested channel on the UDP socket.
  #   If the channel is -1, then the first unbound channel will be bound with
  #   the given address as it's primary address.
  #   If the channel is already bound, this new address will be added to the
  #   list of valid source addresses for packets arriving on the channel.
  #   If the channel is not already bound, then the address becomes the primary
  #   address, to which all outbound packets on the channel are sent.
  #   This function returns the channel which was bound, or -1 on error.
  #*
proc udpBind*(sock: PUDPSocket, channel: int, address: var IPAddress): int{.
    cdecl, importc: "SDLNet_UDP_Bind", dynlib: NetLibName.}
  #* Unbind all addresses from the given channel *
proc udpUnbind*(sock: PUDPSocket, channel: int){.cdecl,
    importc: "SDLNet_UDP_Unbind", dynlib: NetLibName.}
  #* Get the primary IP address of the remote system associated with the
  #   socket and channel.  If the channel is -1, then the primary IP port
  #   of the UDP socket is returned -- this is only meaningful for sockets
  #   opened with a specific port.
  #   If the channel is not bound and not -1, this function returns NULL.
  # *
proc udpGetPeerAddress*(sock: PUDPSocket, channel: int): PIPAddress{.cdecl,
    importc: "SDLNet_UDP_GetPeerAddress", dynlib: NetLibName.}
  #* Send a vector of packets to the the channels specified within the packet.
  #   If the channel specified in the packet is -1, the packet will be sent to
  #   the address in the 'src' member of the packet.
  #   Each packet will be updated with the status of the packet after it has
  #   been sent, -1 if the packet send failed.
  #   This function returns the number of packets sent.
  #*
proc udpSendV*(sock: PUDPSocket, packets: PPUDPpacket, npackets: int): int{.
    cdecl, importc: "SDLNet_UDP_SendV", dynlib: NetLibName.}
  #* Send a single packet to the specified channel.
  #   If the channel specified in the packet is -1, the packet will be sent to
  #   the address in the 'src' member of the packet.
  #   The packet will be updated with the status of the packet after it has
  #   been sent.
  #   This function returns 1 if the packet was sent, or 0 on error.
  #*
proc udpSend*(sock: PUDPSocket, channel: int, packet: PUDPpacket): int{.
    cdecl, importc: "SDLNet_UDP_Send", dynlib: NetLibName.}
  #* Receive a vector of pending packets from the UDP socket.
  #   The returned packets contain the source address and the channel they arrived
  #   on.  If they did not arrive on a bound channel, the the channel will be set
  #   to -1.
  #   The channels are checked in highest to lowest order, so if an address is
  #   bound to multiple channels, the highest channel with the source address
  #   bound will be returned.
  #   This function returns the number of packets read from the network, or -1
  #   on error.  This function does not block, so can return 0 packets pending.
  #*
proc udpRecvV*(sock: PUDPSocket, packets: PPUDPpacket): int{.cdecl,
    importc: "SDLNet_UDP_RecvV", dynlib: NetLibName.}
  #* Receive a single packet from the UDP socket.
  #   The returned packet contains the source address and the channel it arrived
  #   on.  If it did not arrive on a bound channel, the the channel will be set
  #   to -1.
  #   The channels are checked in highest to lowest order, so if an address is
  #   bound to multiple channels, the highest channel with the source address
  #   bound will be returned.
  #   This function returns the number of packets read from the network, or -1
  #   on error.  This function does not block, so can return 0 packets pending.
  #*
proc udpRecv*(sock: PUDPSocket, packet: PUDPpacket): int{.cdecl,
    importc: "SDLNet_UDP_Recv", dynlib: NetLibName.}
  #* Close a UDP network socket *
proc udpClose*(sock: PUDPSocket){.cdecl, importc: "SDLNet_UDP_Close",
                                       dynlib: NetLibName.}
  #***********************************************************************
  #* Hooks for checking sockets for available data                       *
  #***********************************************************************
  #* Allocate a socket set for use with SDLNet_CheckSockets()
  #   This returns a socket set for up to 'maxsockets' sockets, or NULL if
  #   the function ran out of memory.
  # *
proc allocSocketSet*(maxsockets: int): PSocketSet{.cdecl,
    importc: "SDLNet_AllocSocketSet", dynlib: NetLibName.}
  #* Add a socket to a set of sockets to be checked for available data *
proc addSocket*(theSet: PSocketSet, sock: PGenericSocket): int{.
    cdecl, importc: "SDLNet_AddSocket", dynlib: NetLibName.}
proc tcpAddSocket*(theSet: PSocketSet, sock: PTCPSocket): int
proc udpAddSocket*(theSet: PSocketSet, sock: PUDPSocket): int
  #* Remove a socket from a set of sockets to be checked for available data *
proc delSocket*(theSet: PSocketSet, sock: PGenericSocket): int{.
    cdecl, importc: "SDLNet_DelSocket", dynlib: NetLibName.}
proc tcpDelSocket*(theSet: PSocketSet, sock: PTCPSocket): int
  # SDLNet_DelSocket(set, (SDLNet_GenericSocket)sock)
proc udpDelSocket*(theSet: PSocketSet, sock: PUDPSocket): int
  #SDLNet_DelSocket(set, (SDLNet_GenericSocket)sock)
  #* This function checks to see if data is available for reading on the
  #   given set of sockets.  If 'timeout' is 0, it performs a quick poll,
  #   otherwise the function returns when either data is available for
  #   reading, or the timeout in milliseconds has elapsed, which ever occurs
  #   first.  This function returns the number of sockets ready for reading,
  #   or -1 if there was an error with the select() system call.
  #*
proc checkSockets*(theSet: PSocketSet, timeout: int32): int{.cdecl,
    importc: "SDLNet_CheckSockets", dynlib: NetLibName.}
  #* After calling SDLNet_CheckSockets(), you can use this function on a
  #   socket that was in the socket set, to find out if data is available
  #   for reading.
  #*
proc socketReady*(sock: PGenericSocket): bool
  #* Free a set of sockets allocated by SDL_NetAllocSocketSet() *
proc freeSocketSet*(theSet: PSocketSet){.cdecl,
    importc: "SDLNet_FreeSocketSet", dynlib: NetLibName.}
  #***********************************************************************
  #* Platform-independent data conversion functions                      *
  #***********************************************************************
  #* Write a 16/32 bit value to network packet buffer *
proc write16*(value: uint16, area: pointer){.cdecl,
    importc: "SDLNet_Write16", dynlib: NetLibName.}
proc write32*(value: uint32, area: pointer){.cdecl,
    importc: "SDLNet_Write32", dynlib: NetLibName.}
  #* Read a 16/32 bit value from network packet buffer *
proc read16*(area: pointer): uint16{.cdecl, importc: "SDLNet_Read16",
    dynlib: NetLibName.}
proc read32*(area: pointer): uint32{.cdecl, importc: "SDLNet_Read32",
    dynlib: NetLibName.}

proc version(x: var Version) =
  x.major = MAJOR_VERSION
  x.minor = MINOR_VERSION
  x.patch = PATCHLEVEL

proc tcpAddSocket(theSet: PSocketSet, sock: PTCPSocket): int =
  result = addSocket(theSet, cast[PGenericSocket](sock))

proc udpAddSocket(theSet: PSocketSet, sock: PUDPSocket): int =
  result = addSocket(theSet, cast[PGenericSocket](sock))

proc tcpDelSocket(theSet: PSocketSet, sock: PTCPSocket): int =
  result = delSocket(theSet, cast[PGenericSocket](sock))

proc udpDelSocket(theSet: PSocketSet, sock: PUDPSocket): int =
  result = delSocket(theSet, cast[PGenericSocket](sock))

proc socketReady(sock: PGenericSocket): bool =
  result = sock != nil and sock.ready == 1
