#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4


tcp='/usr/lib/nagios/plugins/check_tcp'
http='/usr/lib/nagios/plugins/check_http'
mongo='/usr/bin/mongo'
mysql='/usr/bin/mysql'
sphinx='/usr/lib/nagios/plugins/check_sphinxsearch_query'

mysql_user='nagios'
mysql_pass='password'
mysql_base='database'


# $1 - type of query(tcp,http,mysql...)
# $2 - host
# $3 - port

case "$1" in

        "tcp")
                $tcp -H $2 -p $3 | cut -d " " -f4
        ;;

        "http")
                $http -H $2 -p $3 | cut -d " " -f10
        ;;

        "mysql")
                #start=`date +%s`
                start=$((`date +%s` * 100 + (10#`date +%N` / 10000000)))
                $mysql -u$mysql_user -p$mysql_pass -h $2 $mysql_base -e "select max(mi_news_id) from mi_en_news;" > /dev/null
                #end=`date +%s`
                end=$((`date +%s` * 100 + (10#`date +%N` / 10000000)))
                duration=$(( $end - $start ))
                #echo $duration

                if [ "$duration" -gt 500 ]; then
                        echo "Critical - timeout:${duration}ms"
                        exit $STATE_CRITICAL
                else
                        echo "OK - timeout:${duration}ms"
                        exit $STATE_OK

                fi
        ;;
        "mongo")
                start=$((`date +%s` * 100 + (10#`date +%N` / 10000000)))
                $mongo --host $2 mi < /scripts/mongo_query.js | grep "_id"  > /dev/null
                end=$((`date +%s` * 100 + (10#`date +%N` / 10000000)))
                duration=$(( $end - $start ))
                #echo $duration

                if [ "$duration" -gt 300 ]; then
                        echo "Critical - timeout:${duration}ms"
                        exit $STATE_CRITICAL
                else
                        echo "OK - timeout:${duration}ms"
                        exit $STATE_OK

                fi
        ;;
        "sphinx")
                start=$((`date +%s` * 100 + (10#`date +%N` / 10000000)))
                sresult=`$sphinx --host=$2 -q why -w 500000 -c 100 | grep "Failed to open" | wc -l`
                #echo $sresult
                if [ "$sresult" -eq 1 ]; then
                        echo "Critical - Failed to open connection:"
                        exit $STATE_CRITICAL
                fi
                #$sphinx --host=$2 -q why -w 500000 -c 100  > /dev/null
                end=$((`date +%s` * 100 + (10#`date +%N` / 10000000)))
                duration=$(( $end - $start ))
                #echo $duration

                if [ "$duration" -gt 300 ]; then
                        echo "Critical - timeout:${duration}ms"
                        exit $STATE_CRITICAL
                else
                        echo "OK - timeout:${duration}ms"
                        exit $STATE_OK

                fi
        ;;
esac
