#!/bin/bash

sqlplus / as sysdba << EOF
show parameter name
#ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
exit
EOF
