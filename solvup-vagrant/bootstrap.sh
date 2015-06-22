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

    wget --quiet https://github.com/wwaruni/puppet/raw/master/solvup.dev.zip -O solvup.zip

    sudo apt-get install unzip
    unzip  solvup.zip
    rsync -rCcvz solvup.dev/ /etc/puppet/
    puppet apply --verbose --debug /etc/puppet/manifest/init.pp

    sudo mkdir  /var/www/solvup_tic
    sudo mkdir  -p /var/www/solvup_tic/RIA_RepairsTicGroup

    curl -LOk  https://gexchai:Altona3025@github.com/Conduct/RIA_RepairsTicGroup/archive/release-2.52.zip

    unzip release-2.52.zip 


    sudo mv -f RIA_RepairsTicGroup-release-2.52/* /var/www/solvup_tic/RIA_RepairsTicGroup/
    sudo cp -f /var/www/solvup_tic/RIA_RepairsTicGroup/app/config/bootstrap_LIVE.php  /var/www/solvup_tic/RIA_RepairsTicGroup/app/config/bootstrap.php
    sudo cp -f /var/www/solvup_tic/RIA_RepairsTicGroup/app/config/core_LIVE.php /var/www/solvup_tic/RIA_RepairsTicGroup/app/config/core.php
    sudo cp -f /var/www/solvup_tic/RIA_RepairsTicGroup/app/config/database_LIVE.php /var/www/solvup_tic/RIA_RepairsTicGroup/app/config/database.php

    sudo mkdir -p /var/www/solvup_tic/RIA_RepairsTicGroup/app/tmp/cache
    sudo mkdir -p /var/www/solvup_tic/RIA_RepairsTicGroup/app/tmp/cache/models
    sudo mkdir -p /var/www/solvup_tic/RIA_RepairsTicGroup/app/tmp/cache/persistent
    
    sudo chmod -R 777 /var/www/solvup_tic/RIA_RepairsTicGroup/app/tmp
    sudo chown -R vagrant:vagrant /var/www/solvup_tic

    sudo rm -rf /etc/php5/apache2/conf.d/20-mcrypt.ini

    sudo ln -s   /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini

    sudo a2enmod ssl

    sudo service apache2 restart


    sudo mkdir -p /etc/apache2/ssl
    sudo openssl req -batch -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/solvup.key -out /etc/apache2/ssl/solvup.crt

    sudo a2ensite default-ssl.conf

    sudo service apache2 restart

    touch /home/vagrant/.bootstrapped
fi

echo "Done!"
