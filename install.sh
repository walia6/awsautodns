SCRIPT="$(readlink --canonicalize-existing "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"
cd $SCRIPTPATH

#Get and build a standalone lua interpreter
curl -R -O http://www.lua.org/ftp/lua-5.4.2.tar.gz
tar zxf lua-5.4.2.tar.gz
rm -f lua-5.4.2.tar.gz
cd lua-5.4.2
mkdir top
sed -i '13s/.*/INSTALL_TOP= /opt/awsautodns/lua-5.4.2/top/' Makefile
make linux test
cd ..
cp lua-5.4.2/src/lua .
rm -rf lua-5.4.2/

#Clean up and install awsautodns.service
mv awsautodns.service /etc/systemd/system/.
rm -f install.sh
mkdir /opt/awsautodns
mv * /opt/awsautodns/.
cd /opt/awsautodns
rm -rf $SCRIPTPATH

#These lines have security implications, but is necessary in some distros (such as RHEL) due to a bug.
setenforce 0
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

systemctl enable awsautodns
systemctl start awsautodns
cat /var/log/awsautodns.log
