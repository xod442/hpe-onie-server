# HPE Open Network Install Environment and COmware ZTP server!!!!

    THIS IS EASY, YOU CAN DO IT   


   This shell script downloads apache2 and setups up DHCP, FTP and tftp server
   It must be ran on an Ubuntu linux workstation, it can be a VM as well.

   This is also a ZTP server for HPE Comware switches

   

   DANGER WILL ROBINSON!!!!!!!! Verify proper deployment of the BOOT server

# Build the ONIE server, install Ubuntu, and Git and nano
     Do yourself a favor and use a gui version here: https://ubuntu-mate.org/download/
     Install the Linux image on a server or in a VM, Once you can log in, open a command window (CTRL-T) and...

     sudo apt-get install git

     sudo apt-get install nano

     cd /opt

     git clone https://github.com/xod442/hpe_onie_server.git

# Change directory:
     cd hpe_onie_git

# Edit the setup.sh and modify lines in the DHCP section to match your needs
     sudo nano setup.sh

# Default addresses are for 172.20.0.0/24 network...change them to what you want!!
     echo 'subnet 172.20.0 netmask 255.255.255.0 {' >> /etc/dhcp/dhcpd.conf
     echo '    range 172.20.0.10 172.20.0.250;' >> /etc/dhcp/dhcpd.conf
     echo '    option tftp-server-name "172.20.0.3";' >> /etc/dhcp/dhcpd.conf
     echo '    option bootfile-name "boot.py";' >> /etc/dhcp/dhcpd.conf
     echo '    option default-url "http://172.20.0.2/onie-installer";' >> /etc/dhcp/dhcpd.conf

# Save the setup.sh
    (inside nano) CTRL+O (Letter O) and the CTRL+X to exit nano editor

# Run this script:     
     sudo setup.sh

# Set the firewall policy     
     sudo ufw allow 'Apache Full'

# (Optional) Verify the web server is operational
     sudo systemctl status apache2

# Point browser to server IP address to see if webserver responds

##################################################################################
 Copy the Vendor ONIE Boot file to /var/www and rename the file to onie-installer.
##################################################################################

 Boot the Altoline switch
