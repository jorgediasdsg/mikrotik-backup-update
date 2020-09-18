#!/bin/bash
#
#   Script Backup Mikrotik
#
#   Features:
#   - Create backup user into Routerboard
#   - Connect with ssh key
#   - Make dump Backup and Export file
#   - Verify version Firmware and model
#   - Run update commands.
#   - Copy to server backup file
#   - Send email report.
#
#   Contributors
#   - ST Duwe CBMSC
#   - Sgt Leonardo CBMSC
#   - Sd Jorge CBMSC
#
########################################
#   Start script
########################################
### Variable errors.
errors=0
### Function convert time.
tempo() {
	temp=$(($2-$1))
	hora=$(($temp/3600)) && temp=$(($temp%3600))
	if [ $hora -lt 10 ]; then
		hora=0$hora
	fi
	min=$(($temp/60))
	if [ $min -lt 10 ]; then
		min=0$min
	fi
	seg=$(($temp%60))
	if [ $seg -lt 10 ]; then
		seg=0$seg
	fi
	temp=$hora'h '$min'min '$seg'seg'
}
sshmk(){
	#Function use ssh with key
	ssh -n -o ConnectTimeout=10 -o BatchMode=yes -o LogLevel=quiet -o UserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no $sshuser@$ip $1;
}
scpmk(){
	#Function send user and pass
	scp -o ConnectTimeout=10 -o LogLevel=quiet -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no $sshuser@$ip$1; 
}
sshpassmk(){
	#Function send user and pass
	sshpass -p $password_default ssh -n -o ConnectTimeout=10 -o LogLevel=quiet -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no $userdefault@$ip $1; 
}
scppassmk(){
	#Function send user and pass
   sshpass -p $password_default scp -o LogLevel=quiet -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no $1; 
}
testusermk(){
	ssh -n -o ConnectTimeout=10 -o BatchMode=yes -o LogLevel=quiet -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no $sshuser@$ip ":log warning \"Server backup verify user key\"" 
}
### Function receive status error.
retur() {
        ret=$1
}
#Create files reports
echo "|       IP       |    CITY    |     PROBLEM      |" > /tmp/servers;
echo "|VERSION SW|FIRMATUAL/FIRMDISP.|        MODEL       |         IP         |      CITY    |" > /tmp/upgrade
### Function receive status error.
have_error() {
	ret=$1
	msgError=$2
	msgSuccess=$3
	msgErrorShort=$4
	if [ $ret -ne 0 ]; then
    	errors=$(($errors+1))
		echo "$msgError$city."
		echo "ERRO $ret"
		echo "$ip   $city $msgErrorShort" >> /tmp/servers
    else
        echo "$msgSuccess$city."
    fi
}
### Verify online server
online() {
        ping -c 1 -W 2 $ip
        up=$?
}
#Send key if server don't have the key.
verify_key(){
	testusermk;
	retur $?
	if [ $ret -ne 0 ]; then
		echo "Create backup user"
		scppassmk "/root/.ssh/id_rsa.pub $userdefault@$ip:/"
		sshpassmk "/user remove bkmk"
	    sshpassmk "/user add name=bkmk group=full password=randomkeyrandomkeyrandomkey comment=Usuario-Bkp disabled=no"
	    sshpassmk "/user ssh-keys  import  public-key-file=id_rsa.pub user=bkmk"
		testusermk;
		have_error $? "Error to create user " "User backup create at " "User"
		if [ $ret -eq 0 ]; then
	        capture_data
        fi
	else
		echo "Backup user was created $city"
        capture_data
	fi
}
capture_data(){
	modelo=$(sshmk "system routerboard print" | grep model | sed "s/.*: //");
	versao=$(sshmk "system resource print" | grep version | sed "s/.*: //; s/ (.*//");
	firmwareupgrade=$(sshmk "system routerboard print" | grep upgrade-firm | sed "s/.*: //");
	firmwarecurrent=$(sshmk "system routerboard print" | grep current-firm | sed "s/.*: //");
	echo "$versao		$firmwarecurrent/$firmwareupgrade	$modelo 	$ip		$city" >> /tmp/upgrade
	create_file
}
create_file(){
#	verify_key
	sshmk ":log warning \"BACKUP_SERVER_CONNECTED\""
	sshmk "/system backup save name=mikrotik"
	sshmk ":log warning \"BACKUP_CREATE\""
	sshmk "/export file=export"
	sshmk ":log warning \"EXPORT_CREATE\""
   	have_error $? "There was an error creating the MIKROTIK backup file for " "Successful creation of MIKROTIK backup file from"
    if [ $ret -eq 0 ]; then
        echo "Backup file from $city created"
			copy_file
	fi
}
##Command that copies the backup file to the backup machine.
copy_file
	if [ ! -d "$folder_destiny/$directory" ]; then
		echo "Create folder $folder_destiny/$directory"
		mkdir $folder_destiny/$directory
	fi
	scpmk ":/mikrotik.backup $folder_destiny/$directory/"
	sshmk ":log warning \"Copied server backup\""
	scpmk ":/export.rsc $folder_destiny/$directory/"
	sshmk ":log warning \"Exported server backup\""
	have_error $? "Error copy file backup from " "Success copied file backup from " "Copy" 
    if [ $ret -eq 0 ]; then
		remove_files
    fi
}

##Remove the backup file from mikrotik.
remove_files
	sshmk "/file remove mikrotik.backup"
	sshmk ":log warning \"Backup server removed file\""
	sshmk "/file remove export.rsc"
	sshmk ":log warning \"Backup server export file\""
	have_error $? "Error removing temporary mikrotik files " "Success removing temporary mikrotik files " "Removing"  
    if [ $ret -eq 0 ]; then
		rename_file
    fi
}
#
##Rename file backup
rename_file(){
	mv $folder_destiny/$directory/mikrotik.backup $folder_destiny/$directory/$city.backup
	have_error $? "Error rename backup from " "Success rename backup from " "rename backup"  
	mv $folder_destiny/$directory/export.rsc $folder_destiny/$directory/$city.rsc
	have_error $? "Error rename export from " "Success rename export from " "rename export"  
	if [ $ret -eq 0 ]; then
		run_update
    fi
}

### Functions remove olds logs.
exclude_olds() {
    echo "Delete logs before $days days ..."
    find $folder/log/ -not -name ".*" -type f -mtime +$days -exec  rm -v {} +
}
run_update(){
	# The flag y in the city list make update in the mikrotis
	echo "Update=$update_device"
	if [[ "$update_device" != "y" ]]; then
		sshmk ":log warning \"This server not needs update\""
		echo "Update not solicited for this equipament"
	else
		sshmk ":log warning \"This server needs update\""
		echo "Update solicited for this equipament"
		#Removed Lines commenteds
		grep -v "^#" $commands_update > commands_filtred
			while read CMD01; do
				sshmk "$CMD01"
			done < commands_filtred
	fi
}
### Reporte time used per router.
resumo() {
    x=0
    echo "SUMMARY OF BACKUP TIME BY MIKROTIK AND TOTAL TIME:"
    while read IP directory CIDADE; do
        x=$(($x+1))
        echo "TEMPO ${sync_time_[$x]}   BACKUP  $directory   $city"
    done < $folder/citys
    tempo $start_time $end_time && full_time=$temp
    echo "Total time:         $full_time"
}

#Remove temporary files
remove_tmps(){

#	echo "remove temporary files."
    rm -rf $folder/citys
	rm -rf $folder_destiny/*/mikrotik.backup
	#Change owner folder.
	chown -R mikrotik:mikrotik $folder_destiny/*
}

#Main Function
backup_mikrotik(){
	start_time=`date +%s`
	x=0
	echo Data: `date +%A', '%d/%m/%Y' '%X' '%Z`
    echo "================================================================================"
    echo "START BACKUPS MIKROTIKS ..."
	echo "================================================================================"
	echo > /tmp/servers
	echo ""
	grep -v "^#" $servers > $folder/citys
	cat $folder/citys | wc -l > /tmp/up
	export total_up=`cat /tmp/up`
		while read ip directory city update_device; do
			x=$(($x+1))
			echo ""
			echo "================================================================================"
			echo ""
	        echo "Run mikrotik backup from $city."
	        echo ""
			online
			if [ $up -eq 0 ]; then
				sync_ini_[$x]=`date +%s`
				verify_key $ip $directory $city
			    sync_end_[$x]=`date +%s`
				tempo ${sync_ini_[$x]} ${sync_end_[$x]} && sync_time_[$x]=$temp
				echo ""
				echo "Time used ${sync_time_[$x]}."
			else
			    errors=$(($errors+1))
				echo "Router inaccessible - Backup from $city does not run."
			        echo ""
				echo "================================================================================"
	                	echo ""
				echo "$ip $city offline" >> /tmp/servers
			fi
		done < $folder/citys
	exclude_olds
        echo ""
        echo "================================================================================"
        echo ""
        end_time=`date +%s`
        resumo
		echo ""
        echo "================================================================================"
	remove_tmps
        echo "TOTAL DE errors: $errors/$total_up"
        echo "--------------------------------------------------------------------------------"
        echo "Router have erros:"
        cat /tmp/servers
        echo "================================================================================"
        echo Data: `date +%A', '%d/%m/%Y' '%X' '%Z`
        echo ""
        echo $errors > /tmp/errors
}
backup_mikrotik