 #!/bin/bash
 
 #Ports: Hier eintragen welche Ports geöffnet werden sollen
 SERVICES_UDP="" #freigegebene UDP-Ports 
 SERVICES_TCP="22 80" #freigegebene TCP-Ports (Hier sshd und http)
 
#Alle vorhandenen Regeln löschen
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -t nat -X
iptables -t mangle -X

#Grundregeln
iptables -P OUTPUT  ACCEPT
iptables -P INPUT   DROP
iptables -P FORWARD DROP

#Sicherheit
iptables -N other_packets								#Tabelle "other_packets" erzeugen
iptables -A other_packets -p ALL -m state --state INVALID -j DROP			#Kaputte Pakete verwerfen
iptables -A other_packets -p icmp -m limit --limit 1/s -j ACCEPT			#ICMP auf max. 1 Paket/Sekunde limitieren
iptables -A other_packets -p ALL -j RETURN						#Tabelle "other_packets" verlassen

iptables -N service_sec								#Tabelle "services_sec" erzeugen
iptables -A service_sec -p tcp --syn -m limit --limit 2/s -j ACCEPT			#SYN-Flood Attacken
iptables -A service_sec -p tcp ! --syn -m state --state NEW -j DROP			#TCP-SYN-Pakete ohne Status NEW verwerfen
iptables -A service_sec -p tcp --tcp-flags ALL NONE -m limit --limit 1/h -j ACCEPT	#Portscanner ausschalten
iptables -A service_sec -p tcp --tcp-flags ALL ALL -m limit --limit 1/h -j ACCEPT	#Portscanner ausschalten
iptables -A service_sec -p ALL -j RETURN						#Tabelle "services" verlassen

iptables -N reject_packets								#Tabelle "reject_packets" erzeugen
iptables -A reject_packets -p tcp -j REJECT --reject-with tcp-reset			#TCP Pakete(Protokoll) zurückweisen
iptables -A reject_packets -p udp -j REJECT --reject-with icmp-port-unreachable	#UDP Pakete(Protokoll) zurückweisen
iptables -A reject_packets -p icmp -j REJECT --reject-with icmp-host-unreachable	#ICMP Pakete(Protokoll) zurückweisen (bei mehr als 1Paket/Sekunde [s.o.])
iptables -A reject_packets -j REJECT --reject-with icmp-proto-unreachable		#Alle anderen Pakete(Protokolle) zurückweisen 
iptables -A reject_packets -p ALL -j RETURN						#Tabelle "reject_packets" verlassen

#Dienste
iptables -N services									#Tabelle für die Dienste erzeugen
for port in $SERVICES_TCP ; do								#Für jeden TCP Port (oben definiert) folgendes tun:
       iptables -A services -p tcp --dport $port -j service_sec			#Bei Verbindungen auf TCP Port "$port in die Tabelle "services_sec" springen
       iptables -A services -p tcp --dport $port -j ACCEPT				#Bei Verbindungen auf TCP Port "$port Verbindung zulassen
done
for port in $SERVICES_UDP ; do								 #Für jeden UDP Port (oben definiert) folgendes tun:
       iptables -A services -p udp --dport $port -j service_sec			#Bei Verbindungen auf UDP Port "$port" in die Tabelle "services_sec" springen
       iptables -A services -p udp --dport $port -j ACCEPT				#Bei Verbindungen auf UDP Port "$port Verbindung zulassen
done
iptables -A services -p ALL -j RETURN							#Tabelle "services" verlassen

#INPUT
iptables -A INPUT -p ALL -i lo -j ACCEPT						#Alle Pakete vom Loopback Interface zulassen
iptables -A INPUT -p ALL -m state --state ESTABLISHED,RELATED -j ACCEPT		#Bereits vorhandene Verbindungen zulassen
iptables -A INPUT -p ALL -j other_packets						#In die Tabelle "other_packets" springen
iptables -A INPUT -p ALL -j services							#In die Tabelle "services" gehen
iptables -A INPUT -p ALL -m limit --limit 10/s -j reject_packets			#Nicht erlaubte Pakete zurückweisen, max 10Pakete/Sekunde (Tabelle "reject_Packets")
iptables -A INPUT -p ALL -j DROP							#Alles andere verwerfen

#OUTPUT:
iptables -A OUTPUT -p ALL -j ACCEPT							#Ausgehende Pakete erlauben

#Speichern
iptables-save -f /etc/iptables/iptables.rules
