#bin/bash
dbusername='DBUSERNAME'
dbpassword='DBPASSWORD'
hostname='localhost'
backupfolderpath="CURRENT_PATH/backup"
days=7 # 7D period
today=`date +%F-%H-%M-%S`
wwwpath="/PATH/TO/WWW"
rclone_path="remote:bucketname"
RCLONE_CONFIG="CURRENT_PATH/rclone.conf" #DO NOT CHANGE IT IF YOU DO NOT KNOW IT
export RCLONE_CONFIG

#read -a dbs <<< `mysql -u $dbusername -p$dbpassword -h $hostname --silent -N -e 'show databases'`
mysql -u $dbusername -p$dbpassword -h $hostname --silent -N -e 'show databases' > CURRENT_PATH/current_dbs.txt
dbs=( $( cat CURRENT_PATH/current_dbs.txt ) )
#read -a wwwfs <<< `ls $wwwpath`
ls $wwwpath > CURRENT_PATH/current_wwwfs.txt
wwwfs=( $( cat CURRENT_PATH/current_wwwfs.txt ) )

rdbl=( $( cat CURRENT_PATH/db_ignore.txt ) )
rfsl=( $( cat CURRENT_PATH/www_ignore.txt ) )

for rd in "${rdbl[@]}"; do
  for i in "${!dbs[@]}"; do
    if [[ ${dbs[i]} = "$rd" ]]; then
      unset 'dbs[i]'
    fi
  done
done

for rw in "${rfsl[@]}"; do
  for i in "${!wwwfs[@]}"; do
    if [[ ${wwwfs[i]} = "$rw" ]]; then
      unset 'wwwfs[i]'
    fi
  done
done

#echo "DB LIST: ${dbs[@]}"
#echo "WWW LIST: ${wwwfs[@]}"

find $backupfolderpath/mysql/ -mindepth 1 -mtime +$days -name "*.gz" -delete
find $backupfolderpath/www/ -mindepth 1 -mtime +$days -name "*.bz2" -delete
#remove today's backup
rm $backupfolderpath/mysql/`date +%F`*.gz
rm $backupfolderpath/www/`date +%F`*.bz2

for db in "${dbs[@]}"
do
	pass=0
	if [ -z "${db// }" ]; then
        	pass=1
		echo "Nothing to do!"
	fi
	if [ "$pass" -eq 0 ]; then
		filename="$backupfolderpath/mysql/$today-$db.sql.gz"
		echo "Backing Up $filename now!"
		mysqldump -u$dbusername -p$dbpassword -h$hostname -e --opt -c $db | gzip -c -9 > $filename
		echo ".. done"
	fi
done

for www in "${wwwfs[@]}"
do
	pass=0
	if [ -z "${www// }" ]; then
                pass=1
		echo "Nothing to do!"
        fi
	if [ "$pass" -eq 0 ]; then
		filename="$backupfolderpath/www/$today-$www.tar.bz2"
		echo "Backing Up $wwwpath/$www to $filename now!"
		tar JcpfP $filename $wwwpath/$www --warning=no-file-changed
		echo ".. done"
	fi
done
#Starting  Backup to Cloud
rclone sync $backupfolderpath $rclone_path
