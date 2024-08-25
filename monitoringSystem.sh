#!/bin/bash



# Monitoring System Resources for a Proxy Server

HOSTNAME=$(hostname)

DATE=$(date "+%Y-%M-%D %H:%M:%S")

Diskusage=$(df -h --output=source,fstype,size,used,avail,pcent,target | \
    awk 'NR==1 || $1 ~ /^\// {printf "%-20s %-10s %-10s %-10s %-10s %-10s %-20s\n", $1, $2, $3, $4, $5, $6, $7}')

Mem_usage=$(free)

System_load=$(uptime | awk -F'load average: ' '{print $2}')
Cpu_breakdown=$(mpstat 1 1 | awk '/Average/ {print "User: " $3 "%\nSystem: " $5 "%\nIdle: " $12 "%"}')
top10_cpuMemory=$(top -b -n 1 -d1 | head -n18)


cpuSmemory_usage=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6)

ss_command=$(ss -H state established | wc -l)

netstat_command=$(netstat -an | grep -c ESTABLISHED)

packet_drops=$(ip -s link)

mbIn_out=$(
ip -s link | awk '/^[0-9]+:/ {iface=$2} /RX:/ {getline; rx_bytes=$1} /TX:/ {getline; tx_bytes=$1; rx_mb=rx_bytes/1024/1024; tx_mb=tx_bytes/1024/1024; printf "Interface: %s, Received: %.2f MB, Transmitted: %.2f MB\n", iface, rx_mb, tx_mb}')




echo " All Monitoring system info is in /tmp/usagereport.kindly check it "

echo " ALl monitoring system info of $HOSTNAME on  $DATE ">/tmp/usagereport

echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport

#Display the top 10 applications consuming the most CPU and memory. 

echo "Displaying the top 10 application which are consuming the most cpu and memory : ">>/tmp/usagereport

echo " ">>/tmp/usagereport
echo " ">>/tmp/usagereport

echo "$top10_cpuMemory=">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport





#Network Monitoring

echo "Number of concurrent connections to the server  ">>/tmp/usagereport  
echo " ">>/tmp/usagereport
if command -v ss &> /dev/null
then 
	echo -e " Using ss for counting  the concurrent connection : $ss_command  ">>/tmp/usagereport
else command -v netstat &> /dev/null
	echo -e " Using netstat for counting the concurrent connection : $netstat_command  ">>/tmp/usagereport
fi


echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport



#Packet drops

echo -e " showing packet drops on : ">>/tmp/usagereport
echo " ">>/tmp/usagereport

echo "$packet_drops  ">>/tmp/usagereport


echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport



#Number of MB in and out

echo -e "Number of MB in and out on  : ">>/tmp/usagereport
echo " ">>/tmp/usagereport

echo "$mbIn_out  ">>/tmp/usagereport

echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport


# Displaying the disk space usage by mouted partition 
echo -e " Displaying the disk space usage by mouted partition " >>/tmp/usagereport
echo " ">>/tmp/usagereport

echo -e "$Diskusage">>/tmp/usagereport 

echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport
echo "----------------------------"
echo "----------------------------"

# Highlight partitions using more than 80% of the space. 

echo " Highlight partitions using more than 80% of the space. "

readarray -t disk <<< "$(df -h | awk '{print $5}' | tail -n +2 | tr -d %)"
  for i in "${disk[@]}"
  do
    if [ $i -gt 95 ]
      then
           df -h | grep --color -E "$i%|$"
    fi
 done 




 # Current System Load Average


echo " Current System Load Average ">>/tmp/usagereport
 
echo -e " $System_load ">>/tmp/usagereport
echo " ">>/tmp/usagereport

echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport


#Show the current load average for the system.include a breakdown of CPU usage (user, system, idle, etc.).

echo " Show the current load average for the system. Include a breakdown of CPU usage (user, system, idle, etc.)." >>/tmp/usagereport
echo " ">>/tmp/usagereport

if command -v mpstat &> /dev/null
then
         echo "$Cpu_breakdown " >>/tmp/usagereport

else
	 echo "mpstat command not found. Please install the sysstat package to get CPU usage details.">>/tmp/usagereport
fi



echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport



# Memory Usage:

# Display total, used, and free memory.

echo " Memory Usage:Display total, used, and free memory and swap memory usage.">>/tmp/usagereport
echo -e " $Mem_usage">>/tmp/usagereport


echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport



#. Process Monitoring: Display the number of active processes.

echo "Process Monitoring: Display the number of active processes.">>/tmp/usagereport

echo "$(ps)">>/tmp/usagereport

echo "----------------------------">>/tmp/usagereport

echo "----------------------------">>/tmp/usagereport



#Show top 5 processes in terms of CPU and memory usage.

echo "Show top 5 processes in terms of  memory usage.">>/tmp/usagereport
echo " $cpuSmemory_usage">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport
echo "----------------------------">>/tmp/usagereport

echo "----------------------------"
echo "----------------------------"

#Service Monitoring:Include a section to monitor the status of essential services like sshd, nginx/apache, iptables, etc.


echo "Service Monitoring:Include a section to monitor the status of essential services like sshd, nginx/apache, iptables, etc."
services=("sshd" "nginx" "apache2" "iptables")
for service in "${services[@]}"; do
        # Check if the service exists
        if systemctl list-units --type=service | grep -q "^${service}.service"
	then
            status=$(systemctl is-active "$service")
            echo -n "$service: "
            if [ "$status" = "active" ]
            then
                echo -e "\033[1;32m$service is running\033[0m"
            else
                echo -e "\033[1;31m$service is not running\033[0m"
            fi
        else
            echo "$service: \033[1;33mService not found\033[0m"
        fi
    done

echo "----------------------------"
echo "----------------------------"




#Provide command-line switches to view specific parts of the dashboard, e.g., -cpu, -memory, - network, etc.

dashboard_info(){
echo " switches to view specific parts of the dashboard, e.g., -cpu, -memory, - network, etc.  "


echo "Provide an option "
echo "cpu for  Cpu Usage "
echo "memory for memory usage "
echo " network for network usage "

read choice

case $choice in
	cpu )

		echo "Providing cpu usage info "
		top -bn1 | grep "Cpu(s)"
		;;
 
	memory )
	      echo "Providing network usage info "
	      free -h
	      ;;

	network )
	      echo "Providing network usage info "
	      ifstat
	      ;;
	*)
        echo "Enter something rom  {-cpu|-memory|-network}"
	
              ;;


esac
}
dashboard_info

