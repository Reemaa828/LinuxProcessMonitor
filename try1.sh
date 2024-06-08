#!/usr/bin/bash -i


config_file_load(){
    if [ -f confgg.conf ]; then
        source confgg.conf
    else 
    echo "#creating a config file" > confgg.conf
    echo "UPDATE_INTERVAL=3" >> confgg.conf
    echo "CPU_ALERT_THRESHOLD=89" >> confgg.conf
    echo "MEMORY_THRESHOLD=30" >> confgg.conf
    source confgg.conf
    fi
}

configuration_edits(){
    config_file_load
    while true; do
    echo "-----edit config file-----"
    echo "1) update intervals time"
    echo "2) update cpu threshold"
    echo "3) update memory threshold"
    echo "4) exit "
    echo "--------------------------"
    read num
    case $num in
    1) read -p "enter the update: " UPDATE_INTERVAL; sed -i "s|^U.*|UPDATE_INTERVAL=$UPDATE_INTERVAL|" confgg.conf ;;
    2) read -p "enter the update: " CPU_ALERT_THRESHOLD; sed -i "s|^C.*|CPU_ALERT_THRESHOLD=$CPU_ALERT_THRESHOLD|" confgg.conf ;;
    3) read -p "enter the update: " MEMORY_THRESHOLD;  sed -i "s|^M.*|MEMORY_THRESHOLD=$MEMORY_THRESHOLD|"  confgg.conf;;
    4) exit 0 ;;
    *) echo -e "\033[37;41mInvalid Input \033[0m" 
    ;;
    esac
    done
}

log_activity(){
   timestamp=$(date +'%d-%m-%Y %H:%M:%S')
   echo -e " $timestamp\n$1\n\n " >> log.txt
}



list_all_processes(){
 ps -A -o user,pid,%cpu,%mem,start,time,command
 log_activity "listing processes"
}


process_info(){
    read -p "enter process pid: " pid
    ps -p $pid u 
    log_activity "process information of pid=$pid"

}

kill_process(){
    read -p "enter process pid: " pid
    kill $pid
    echo -e "\033[37;41m Process has been terminated! \033[0m"
    log_activity "terminate process of pid=$pid"
}

process_statistics(){
    echo -e "\033[32mthe number of processes:\033[0m`ps aux | wc -l`"
    echo -e "\n\033[32mthe memory usage:\033[0m\n `free -h | head -n 2 `"
    echo -e "\n\033[32mthe memory\033[0m `uptime | awk '{print $6,$7,$8,$9,$10}'`"
    log_activity "displaying the process statistics"
}

real_monitor_processes(){
    log_activity "monitoring processes real time"
    while true;do
    ps aux | head -10
    resources_alerts
    sleep $UPDATE_INTERVAL
    clear
    sleep 0.5
    done
}

search_filter_processes(){
    log_activity "searching a process"
    echo "filer and search the processes by: "
    select search in "name" "user" "Resourse usage"; do
    if [ "$search" = "name" ]; then
    read -p "enter the name of process: " name
    ps aux | grep "$name"
    break
    elif [ "$search" = "user" ]; then
    read -p "enter the user " user
    ps --User "$user"  u
    break
    else 
    ps aux --sort -%cpu | head -2
    break
    fi
    done
}

resources_alerts(){
    high_cpu=`ps aux | head -n 10 | awk -v threshold=$CPU_ALERT_THRESHOLD '$3 > threshold {print $0}'`
    high_mem=`ps aux | head -n 10 |awk -v threshold1=$MEMORY_THRESHOLD '$4 > threshold1 {print $0}'`
    if [ -n "$high_cpu" ]; then
    echo -e "\t\t\t\033[1;31;47m❌ HIGH CPU LOAD\033[0m "
    fi
    if [ -n "$high_mem" ]; then
    echo -e "\t\t\t\033[1;31;47m❌ HIGH MEMORY USAGE \033[0m"
    fi

}

Display_menu(){
    echo -e "\033[37;41mCHOOSE AN OPERATION TO BE DONE TO AS PROCESS\033[0m"
    echo -e "1)\tlist all processes"
    echo -e "2)\tprocess information"
    echo -e "3)\tterminate a process"
    echo -e "4)\toverall statistics"
    echo -e "5)\treal time monitoring"
    echo -e "6)\tsearch for a process"
    echo -e "7)\tconfiguration editing"
    echo -e "8)\texit the menu"
    echo -e "\033[37;41m+++++++++++++++++++++++++++++++++++++++++++++\033[0m"
}
config_file_load
while true; do
Display_menu
read num
case $num in
1) clear; list_all_processes
;;
2) clear; process_info 
;;
3) clear; kill_process
;;
4) clear; process_statistics
;;
5) clear; real_monitor_processes
;;
6) clear; search_filter_processes
;;
7) clear; log_activity "editing in config file the configurations"; configuration_edits; 
;;
8) clear; echo -e "\t\t\t\033[37;41m bye! \033[0m"; log_activity "exiting the script"; exit 0
;;
*) echo -e "\033[37;41mInvalid Input \033[0m"
;;
esac
echo " "
done
