#
# Regular cron jobs for the tpmac package
#
0 4	* * *	root	[ -x /usr/bin/tpmac_maintenance ] && /usr/bin/tpmac_maintenance
