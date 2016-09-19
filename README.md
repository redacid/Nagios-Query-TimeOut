# Nagios Query TimeOut
nagios_check_timeout.sh - Check Query timeout mysql, mongo, sphinx for nagios in ms.

For check sphinx need https://github.com/OndrejP/nagios-check-sphinxsearch.

Usage: ./nagios_check_timeout.sh sphinx host

mongo_query.js - auth and query for mongo, needed by nagios_check_timeout.sh


Example:

define command{
        command_name    check_timeout_sphinx
        command_line    /scripts/check_timeout.sh sphinx $HOSTNAME$
        }


define service{
        use                             local-service         ; Name of service template to use
        host_name                       host1
        service_description             Sphinx query timeout
        check_command                   check_timeout_sphinx
        }
