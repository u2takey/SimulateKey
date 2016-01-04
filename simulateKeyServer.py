#!/usr/bin/env python  
from twisted.internet.protocol import Protocol, Factory
from twisted.internet import reactor
import Quartz


class IphoneChat(Protocol):
    def connectionMade(self):
        #self.transport.write("""connected""")
        self.factory.clients.append(self)
        print "clients are ", self.factory.clients
	
    def connectionLost(self, reason):
        self.factory.clients.remove(self)
        
    def dokey(self, chi):
        print chi
        if chi == 54:
            chi = 0
        if chi < 127:
            event = Quartz.CGEventCreateKeyboardEvent(None, chi, True)
        elif chi < 256:
            chi = chi - 127
            event = Quartz.CGEventCreateKeyboardEvent(None, chi, False)
        Quartz.CGEventPost(1, event)
        
    def dataReceived(self, data):
        print data
        if len(data) >= 1:
            codes = data.split(":")
            for i, command in enumerate(codes):
                if(len(command) > 0):
                    self.dokey(int(command))

    def message(self, message):
        self.transport.write(message + '\n')




factory = Factory()
factory.protocol = IphoneChat
factory.clients = []

reactor.listenTCP(9999, factory, backlog=50, interface= "0.0.0.0")
print "server started"
reactor.run()

