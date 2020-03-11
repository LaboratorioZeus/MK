# jul/30/2019 12:15:54 by RouterOS 6.45.2
# software Version 1.0
# model = RB760iGS
# serial number = A8150AF8544E
#OPinguçoChegou!

#atualizar

# Variaveis
:global Empresa "FullPack.Domain";
:global NomeProvedor "MHnet";
:global User "rivaembalagens";
:global Pw "15315";
:global StartIP "192.168.1";
:global AdrWithMasc "192.168.1.0/24";
:global Network "192.168.1.0";
:global RangeDHCP "192.168.1.2-192.168.1.254";
:global Gateway "192.168.1.1";
:global DNSServer "192.168.1.1";
:global NTPServer "192.168.1.1";
:global DNSMHNET "187.45.96.96,187.45.97.97";
:global DNSP4 "177.38.8.108 ";
:global IPZeus "187.45.121.77";


/interface pppoe-client
add add-default-route=yes disabled=no interface=ether1 name=$NomeProvedor password=$Pw user=$User

/interface
##desativar todas a interfaces que nao estao conectadas

/interface list
add name=WAN
add name=LAN
/interface list member
add interface=$NomeProvedor list=WAN
add interface=ether2 list=LAN
/ip pool
add name=dhcp ranges=$RangeDHCP
/ip dhcp-server
add address-pool=dhcp disabled=no interface=ether2 name=dhcp
/ip address
add address=$AdrWithMasc interface=ether2 network=$Network
/ip dhcp-server network
add address=$AdrWithMasc dns-server=$DNSServer domain=$Empresa gateway=\
    $Gateway netmask=24 ntp-server=$NTPServer
/ip dns
set allow-remote-requests=yes servers="8.8.8.8,8.8.4.4,177.38.8.108,\
    200.192.112.8,208.67.222.222,208.67.220.220" #MHNET #P4 TELECOM  
/
#Regras Firewall
/ip firewall address-list
add address=$AdrWithMasc list=Permitido
add address=$IPZeus list=Permitido

/ip firewall filter
add action=drop chain=input comment="Bloqueia consulta externa DNS" dst-port=\
    53 in-interface-list=WAN protocol=udp
#Redirecionamento de Portas
/ip firewall nat
add action=dst-nat chain=dstnat dst-port=8080 log=yes protocol=tcp \
    to-addresses=10.0.0.150 to-ports=8080
add action=dst-nat chain=dstnat dst-port=6036 log=yes protocol=tcp \
    to-addresses=10.0.0.150 to-ports=6036    
add action=masquerade chain=srcnat out-interface-list=WAN
/
#NTP Server
/system clock
set time-zone-name=America/Sao_Paulo
/system ntp client
set enabled=yes primary-ntp=200.160.7.186 secondary-ntp=201.49.148.135
/system ntp server
set broadcast=yes broadcast-addresses=10.0.0.255 enabled=yes
/
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set winbox address=$AdrWithMasc 
set winbox address=$IPZeus  #NAO FUNCIONA COM A VIRGULA #Rede interna do BEEéééé 72.20.0.49/32
set api-ssl disabled=yes
/

/tool romon
set enabled=yes secrets=LojaZ&usROMON654 id=00:00:00:00:00:07
#00:00:00:00:00:07 Ultimo ID 11/01/2020

##VPN Servidor
:global IpExternoServidor "";
:global NomeServidor "";
:global NomeCliente "";
/interface bridge
add name=Bridge-Loopback
/
/ip address
add address=172.16.20.0 interface=Bridge-Loopback network=172.16.20.0
/ip pool
add name=RemotoL2TP-pool ranges=10.1.0.2-10.1.0.254
/
/ppp profile
set *FFFFFFFE local-address=172.16.20.0 remote-address=RemotoL2TP
#Se tem Ad E Usar Site-to-Client Usar RADIUS
/ppp secret
    add name=$NomeServidor password=LojaZ&us654IPseguro profile=default-encryption service=l2tp
/
/ip firewall filter
add action=accept chain=input dst-port=1701,500,4500 log=yes protocol=udp
add action=accept chain=input log=yes protocol=ipsec-esp
/
/interface l2tp-server server
set authentication=chap,mschap1,mschap2 enabled=yes ipsec-secret=LojaZ&us654paraiP53c \
    use-ipsec=required
/ip firewall nat
    add action=accept chain=srcnat dst-address=10.1.0.0/24 src-address=\
    10.0.0.0/24
/ip route
    add distance=1 dst-address=10.1.0.0/24 gateway=<l2tp-$NomeCliente>

##VPN Client
/interface l2tp-client

add allow=chap,mschap1,mschap2 connect-to=$IpExternoServidor disabled=no0 \
    ipsec-secret=LojaZ&us654paraiP53c name=l2tp-$NomeServidor password=LojaZ&us654IPseguro use-ipsec=yes user=$NomeCliente
/ip route
add distance=1 dst-address=10.0.0.0/24 gateway=l2tp-$NomeServidor
/ip firewall nat
add action=accept chain=srcnat dst-address=10.0.0.0/24 src-address=\
    10.1.0.0/24


