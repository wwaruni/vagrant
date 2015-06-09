#!/usr/bin/env bash

echo "Running bootstrap......."

if [ ! -f "/home/vagrant/.bootstrapped" ]
then 
    cat > ~/.boto <<BOTO_CONF
BOTO_CONF

    echo "First time it seems ............"
    locale-gen en_AU.UTF-8

    apt-get update
    apt-get -q -y upgrade

    apt-get -q -y install python-setuptools
    apt-get -q -y install python-pip

    pip install boto --upgrade
    pip install awscli --upgrade

    echo 'Australia/Melbourne' > /etc/timezone
    dkpg-reconfigure -f noninteractive tzdata

    apt-get -q -y install puppet git

    wget --quiet https://github.com/wwaruni/puppet/blob/master/solvup.dev.zip -O solvup.zip

    unzip solvup.zip
    rsync -rCcvz solvup.dev/ /etc/puppet/
    puppet apply --verbose --debug /etc/puppet/manifest/init.pp

    if [! -d "/var/www/solvup.com" ];
    then
        mkdir -p /var/www/solvup.com
    fi

    git clone https://gexchai:Altona3025@github.com/Conduct/RIA_RepairsTicGroup.git

    mv RIA_RepairsTicGroup/* /var/www/solvup.com/
    
    touch /home/vagrant/.bootstrapped
fi

echo "Done!"
