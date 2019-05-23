
redis_list="192.168.211.128:8001 192.168.211.128:8002 192.168.211.128:8003 192.168.211.128:8004 192.168.211.128:8005 192.168.211.128:8006"
for info in ${redis_list}
    do
        echo "开始执行:$info"  
        ip=`echo $info | cut -d : -f 1`
        port=`echo $info | cut -d : -f 2`
		keys=`redis-cli -h $ip -p $port keys '*'` 
		for key in ${keys}
			do
				echo $key
				redis-cli -h $ip -p $port -c del $key
			done
    done
    echo "完成"
