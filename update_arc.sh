#!/bin/sh
set -e
os_v=el7

echo "================== START PREPARATIONS ================================================================"

yum clean metadata

cd /
echo  "wget 'https://source.coderefinery.org/nordugrid/arc/-/jobs/artifacts/hackathon2022/download?job=packages_${os_v}' -O artifacts.zip"; 
wget https://source.coderefinery.org/nordugrid/arc/-/jobs/artifacts/hackathon2022/download?job=build_${os_v} -O /artifacts.zip; 
echo "unzip /artifacts.zip"; 
unzip artifacts.zip; 


echo "Preparing local repo for installation"
printf "yum list installed\n"
yum list installed | grep createrepo
if [ $? -eq 1 ]; then yum install -y createrepo; fi;

#printf "mkdir -p /rpmbuild/RPMS/{noarch,x86_64}"
#mkdir -p /rpmbuild/RPMS/{noarch,x86_64}

printf "cd /rpmbuild/RPMS/noarch\n"
cd /rpmbuild/RPMS/noarch
printf "createrepo .\n"
createrepo .
printf "cd ../x86_64\n"
cd ../x86_64
printf "createrepo .\n"
createrepo .


cat > /etc/yum.repos.d/nordugrid-hackathon.repo <<EOF
[nordugrid-hackathon]
name=NorduGrid - $basearch - CI
baseurl=file:///rpmbuild/RPMS/x86_64
enabled=1
gpgcheck=0

[nordugrid-hackathon-noarch]
name=NorduGrid - noarch - CI
baseurl=file:///rpmbuild/RPMS/noarch
enabled=1
gpgcheck=0
EOF


printf "cat /etc/yum.repos.d/nordugrid-hackathon.repo\n"
cat /etc/yum.repos.d/nordugrid-hackathon.repo

printf '\n\n======== START Install and start ARC  ==========\n'

printf "\nInstalling client packages"
printf "yum update -y nordugrid-arc-client\n"
yum update -y nordugrid-arc-client
printf "yum update -y nordugrid-arc-plugins-arcrest\n"
yum update -y nordugrid-arc-plugins-arcrest

printf "\nInstalling server packages"
printf "yum update -y nordugrid-arc-arex\n"
yum update -y nordugrid-arc-arex 
printf "yum update -y nordugrid-arc-gridftpd\n"
yum update -y nordugrid-arc-gridftpd



printf "arcctl reservice start -a\n"
arcctl service restart -a
printf "arcctl service list\n"
arcctl service list
printf "\n\n======== END Install and start ARC  =========="

echo "================== END PREPARATIONS ===================="

