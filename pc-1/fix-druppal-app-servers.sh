

for DRUPPAL_VM in $(govc ls /Datacenter/vm/*/ | grep druppalapp-web) 
do 
    echo "post boot script on $DRUPPAL_VM"
    DB_VM=$(echo $DRUPPAL_VM | sed 's/web/db/g')``
    DB_IP=$(govc vm.ip $DB_VM)
    DRUPPAL_IP=$(govc vm.ip $DRUPPAL_VM)
    ansible -i $DRUPPAL_IP, -m shell -a 'grep host /var/www/my_drupal/web/sites/default/settings.php' --extra-vars "ansible_user=root ansible_password=ps0lab!" all
    #ansible -i $DRUPPAL_IP, -m shell -a "sed 's/host.*/\'host\' => \'$DB_IP\'/g\'  /var/www/my_drupal/web/sites/default/settings.php | grep host" --extra-vars "ansible_user=root ansible_password=ps0lab!" all

    ansible -i $DRUPPAL_IP, -m shell -a "cat sed \'s/host.*/abc/g\'  /var/www/my_drupal/web/sites/default/settings.php | grep host" --extra-vars "ansible_user=root ansible_password=ps0lab!" all
 #   ansible -i $DRUPPAL_IP, -m service -a "name=php-fpm state=restarted" --extra-vars "ansible_user=root ansible_password=ps0lab!" all

done