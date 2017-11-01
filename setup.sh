## Run everything as sudo
#    Version 1.0 brought to you by wookieware 2017
#
#   This shell script downloads apache2 and setups up DHCP, FTP and tftp server_args
#
#   DANGER WILL ROBINSON!!!!!!!! Verifiy proper deployment of the BOOT server
#
# ----Build the ONIE server, Enter the following commands:
#     sudo setup.sh
#     sudo ufw allow 'Apache Full'
#
# ----Copy the ONIE Boot file to /var/www and rename the file to
# ----onie-installer.
#
#
# ----IF this is running in a VM make sure the nic is set to bridged.
#--------------------------------------------------------------------------------

chmod 777 ./setup.sh
apt-get update
apt-get -y upgrade
apt-get -y install git
apt-get -y install python-pip
apt-get -y install apache2
apt-get -y install nano
apt -y autoremove

apt-get -y install isc-dhcp-server
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd_bak.conf
echo 'default-lease-time 3600;' > /etc/dhcp/dhcpd.conf
echo 'authoritative;' >> /etc/dhcp/dhcpd.conf
echo 'max-lease-time 3600;' >> /etc/dhcp/dhcpd.conf
echo 'ddns-update-style none;' >> /etc/dhcp/dhcpd.conf
echo 'subnet 172.20.0 netmask 255.255.255.0 {' >> /etc/dhcp/dhcpd.conf
echo '    range 172.20.0.10 172.20.0.250;' >> /etc/dhcp/dhcpd.conf
echo '    option tftp-server-name "172.20.0.3";' >> /etc/dhcp/dhcpd.conf
echo '    option bootfile-name "boot.py";' >> /etc/dhcp/dhcpd.conf
echo '    option default-url "http://172.20.0.2/onie-installer";' >> /etc/dhcp/dhcpd.conf
echo '}' >> /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
#
# Seup the tftp server.
#
apt-get -y install xinetd tftpd tftp
echo 'service tftp' > /etc/xinetd.d/tftp
echo '{' >> /etc/xinetd.d/tftp
echo 'protocol = udp' >> /etc/xinetd.d/tftp
echo 'port = 69' >> /etc/xinetd.d/tftp
echo 'socket_type = dgram' >> /etc/xinetd.d/tftp
echo 'wait = yes' >> /etc/xinetd.d/tftp
echo 'server = /usr/sbin/in.tftpd' >> /etc/xinetd.d/tftp
echo 'server_args = /opt/tftpboot' >> /etc/xinetd.d/tftp
echo 'disable = no' >> /etc/xinetd.d/tftp
echo 'user = nobody' >> /etc/xinetd.d/tftp
echo '}' >> /etc/xinetd.d/tftp
#Edit these to match your tftpboot directory
chmod -R 777 /opt/tftpboot
chown -R nobody /opt/tftpboot
service xinetd restart
#
# Seup the FTP server.
#
apt-get -y install vsftpd
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
sed -i 's/#local_umask/local_umask/' /etc/vsftpd.conf
sed -i 's/#chroot_local_user/chroot_local_user/' /etc/vsftpd.conf
echo 'allow_writeable_chroot=YES' >> /etc/vsftpd.conf
echo 'pasv_enable=YES' >> /etc/vsftpd.conf
echo 'pasv_min_port=40000' >> /etc/vsftpd.conf
echo 'pasv_max_port=40100' >> /etc/vsftpd.conf
service vsftpd restart
