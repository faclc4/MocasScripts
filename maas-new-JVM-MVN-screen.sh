# Upstart script for WoL 
cat <<"EOF" >/etc/init/wol.conf
start on (started network-interface
          or started network-manager
          or started networking)

script
    for interface in $(cut -d: -f1 /proc/net/dev | tail -n +3); do
        logger -t 'wakeonlan init script' enabling wake on lan for $interface
        ethtool -s $interface wol g
    done
end script
EOF

# Include public_keys for gsd user
mkdir -p /home/gsd/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHFzxu6HYUd9qQdtJvyPQLb0HJe255jA3BnyToQRz+R27nYetVaFKLwmscsx30exflZKWERxXPN5NhQ12Rhs6Cahx8BLNp94P9/jzFfHYPaHlBwv4ScM+QcGNn+XA7w/pV1nAboxe+iKr3DKcaUMmqXwlCC2Jmr/7WsSK2l5/b2o9KzqjoU+jAgUQZ45MNW5MtYPFYserhGkdhJh+mY1AWY5uMZYqCvcvXDUCVLf9wWzWhQnsxRWT35M/1F5lQMXVdxIsets7LKpHQG0qRNalMoimfO7aRnmWGaFVIoLN++To+oMACKpWHbc/XcPVjYGhT1kqh8cVL1V+UAL3cqhlv" >> /home/gsd/.ssh/authorized_keys

if [ -z "$1" ]
then
    echo "no argument" >> maas.log
else
    wget --no-check-certificate -qO- https://bootler.lsd.di.uminho.pt/api/v1/keys/$1 >> /home/gsd/.ssh/authorized_keys
fi

chown -R gsd:gsd /home/gsd/.ssh
chmod 700 /home/gsd/.ssh
chmod 600 /home/gsd/.ssh/authorized_keys

# Replace /etc/hosts with real IP address
interface=$(ip route | grep default | awk '{ print $5; exit }')
address=$(ifconfig $interface | egrep '([0-9]{1,3}\.){3}[0-9]{1,3}' -o | head -1)
escaped_address=$(echo $address | sed -E 's/\./\\\./g')
search_address=127\.0\.1\.1
sed -i.bak "s/$search_address/$escaped_address/g" /etc/hosts

if [ -f /etc/ntp.conf ]; then
    sed -i.bak "s/0.ubuntu.pool.ntp.org/pool.ntp.org/g" /etc/ntp.conf
fi

if [ -f /etc/openntpd/ntpd.conf ]; then
    sed -i.bak "s/0.debian.pool.ntp.org/pool.ntp.org/g" /etc/openntpd/ntpd.conf
fi

#Install Oracle JVM 8 

sudo add-apt-repository ppa:webupd8team/java;
sudo apt-get update;
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections;
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections;
sudo apt-get -y install oracle-java8-installer

#Install Maven2
sudo apt-get -y install maven2

#Install Screen
sudo apt-get -y install screen


