#! /bin/sh
SCRIPTNAME=${0##*/}
FILENAME="$(echo $(hostname))_$(echo $(date +%y%m%d_%H%M%S))_$(echo $SCRIPTNAME | cut -d '.' -f1).txt"
# FILENAME1="$(echo $(hostname))_$(echo $(date +%y%m%d_%H%M%S)).txt"
SV_UNIX_VARIABLE(){
    SERVICEDIR="/etc/sshd_config /etc/ssh/sshd_config /usr/local/etc/sshd_config /usr/local/sshd/etc/sshd_config /usr/local/ssh/etc/sshd_config"
    SERVICEDIR2="/etc/ftpusers /etc/ftpd/ftpusers /etc/proftpd.conf /etc/vsftpd/ftpusers /etc/vsftpd.ftpusers /etc/vsftpd/user_list /etc/vsftpd.user_list"
    SYSTEMFILESEARCH=".profile .cshrc .kshrc .login .bash_profile .bashrc .bash_login .exrc .netrc .history .sh_history .bash_history .dtprofile .rhosts"
    HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v '/bin/false' | grep -v 'nologin' | grep -v "#"`
    HOMEDIRS2=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v "#" | grep -v "/tmp" | grep -v "uucppublic" | uniq`
    VSFTP=$(find /etc/ -name "vsftpd.conf")
    PROFTP=$(find /etc/ -name "proftpd.conf")
}
EXTENDS_NUMPER(){
    if [ -e $1 ]; then
        TUMP=$(stat -c %a $1)
        TUMPl=$(echo $TUMP | awk '{print length}')
        SLINK_CHK=$(ls -ald $1 | awk '{print $11}')
        CHANGE_SLINK_CHK=$(readlink -f $1)
        SLINK_PER=$(stat -c %a $CHANGE_SLINK_CHK)
        SLINK_PERl=$(echo $SLINK_PER | awk '{print length}')
        if [ $TUMPl -lt 4 ] || [ $SLINK_PERl -lt 4 ]; then
            TUMP=$(echo 0$TUMP)
            SLINK_PER=$(echo 0$SLINK_PER)
        fi
        if [ -z "${SLINK_CHK}" ]; then
            TUMP2=$(ls -alLd $1)
            echo $TUMP $TUMP2
        elif [ -n "${SLINK_CHK}" ]; then
            SLINK_PRINT=$(ls -al $1)
            SLINK_PRINT2=$(ls -al $CHANGE_SLINK_CHK)
            echo "$TUMP $SLINK_PRINT"
            echo "$SLINK_PER $SLINK_PRINT2"
        fi
    fi
}
NUMPER(){
    if [ -d "$1" ] && [ -z "$2" ]; then
        find $1 | while read CMD_RESULT
        do
        EXTENDS_NUMPER $CMD_RESULT
        done
    elif [ -f "$1" ] && [ -z "$2" ]; then
        EXTENDS_NUMPER $1
    elif [ "$2" = "perm" ]; then
        find $1 | while read CMD_RESULT
        do
        EXTENDS_NUMPER $CMD_RESULT
        done
    elif [ "$2" = ".*" ]; then
        find $1 -name ".*" | while read CMD_RESULT
        do
        EXTENDS_NUMPER $CMD_RESULT
        done
    else
        echo N/A:$1
    fi
}
ROOT_CHK(){
    if [ "$(echo $UID)" = "0" ] || [ "$(echo $USER)" = "root" ] || [ "$(echo $EUID)" = "0" ]; then
        continue
    else
        echo
        echo "This User is Not Root Account"; echo ""; echo "If you cannot login to your Root account, Use sudo command"
        echo
        exit
    fi
    if [ "${1}" = "777" ]; then
        sudo chmod 777 $0
        break
    fi
    if [ "$(NUMPER $0 | awk '{print $1}')" = "0777" ]; then
        continue
    else
        echo
        echo "Permission for this script file is not 0777."
        echo
        exit
    fi
}
STEP0_SELECT(){
    #REM Script_Type_1="MacOS PC"
    Script_Type_2="Unix Server"
    #REM Script_Type_3="Apache"
    #REM Script_Type_4="Apache Tomcat"
    #REM Script_Type_5="NginX"
    #REM Script_Type_6="Mysql"
    #REM Script_Type_7="Oracle"
    #REM Script_Type_8="Docker"
    #REM Script_Type_9="WebtoB"
    #REM Script_Type_10="Jeus"
    #REM Script_Type_11="WebSphere"
    if [ -n "$Script_Type_1" ]; then
        OS_TYPE="MacOS PC"
        echo -n "Enter a user name : "
        read PC_USERNAME
        if  [ -z "${PC_USERNAME}" ]; then
            STEP0_SELECT
        else
            VALUE_CHECK_PRINT
        fi
    elif [ -n "$Script_Type_2" ]; then
        OS_TYPE="Unix Server"
        VALUE_FAIL_CHK
        SELECT_VS
        VS_START_CHECK="y"
    elif [ -n "$Script_Type_3" ]; then
        WEB_TYPE="Apache"
        Type="WEB"
        WEB_DIR_FILE_FAIL_CHK
    elif [ -n "$Script_Type_4" ]; then
        WEB_TYPE="Apache Tomcat"
        Type="WEB"
        WEB_DIR_FILE_FAIL_CHK
    elif [ -n "$Script_Type_5" ]; then
        WEB_TYPE="NginX"
        Type="WEB"
        WEB_DIR_FILE_FAIL_CHK
    elif [ -n "$Script_Type_6" ]; then
        DB_TYPE="Mysql"
        DBMS_DIR_FILE_FAIL_CHK
    elif [ -n "$Script_Type_7" ]; then
        DB_TYPE="Oracle"
        DBMS_DIR_FILE_FAIL_CHK
    elif [ -n "$Script_Type_8" ]; then
        DOCKER_TYPE="Docker"
        VALUE_FAIL_CHK
        SELECT_VS
        VS_START_CHECK="y"
    elif [ -n "$Script_Type_9" ]; then
        WEB_TYPE="WebtoB"
        Type="WEB"
        WEB_DIR_FILE_FAIL_CHK
    elif [ -n "$Script_Type_10" ]; then
        WEB_TYPE="Jeus"
        Type="WEB"
        WEB_DIR_FILE_FAIL_CHK
    elif [ -n "$Script_Type_11" ]; then
        WEB_TYPE="WebSphere"
        Type="WEB"
        WEB_DIR_FILE_FAIL_CHK
    else
        STEP1_OS_SELECT
    fi
}
STEP1_OS_SELECT(){
    echo
    echo
    echo "===================================================================================================="
    echo   This is a UNIX OS server script.
    echo   The OS is selected and run by default.
    echo 
    echo   [Procedure]
    echo   Step 1. Select WEB/WAS
    echo   Step 2. Select DBMS
    echo 
    echo "===================================================================================================="
    echo
    STEP1_OS_SELECT_VALUE=2
    if [ "${STEP1_OS_SELECT_VALUE}" = "1" ]; then
        OS_TYPE="MacOS PC"
        echo -n "Enter a user name : "
        read PC_USERNAME
        if [ -z "${PC_USERNAME}" ]; then
            STEP1_OS_SELECT
        else
            VALUE_CHECK_PRINT
        fi
    elif [ "${STEP1_OS_SELECT_VALUE}" = "2" ]; then
        OS_TYPE="Unix Server"
        STEP2_WEB_SELECT
    else
        echo -e "Incorrect selection. Select again."
        STEP1_OS_SELECT
    fi
}
STEP2_WEB_SELECT(){
    echo
    echo
    echo "===================================================================================================="
    echo
    echo "*STEP 1. Select [WEB/WAS] type."
    echo 
    echo "0. Do net check"
    echo "1.[Apache]"
    echo "2.[Apache Tomcat]"
    echo "3.[NginX]"
    echo "===================================================================================================="
    echo
    echo -n "Select (ex. 1) : "
    read STEP2_WEB_SELECT_VALUE
    if [ "${STEP2_WEB_SELECT_VALUE}" = "0" ]; then
        STEP3_DBMS_SELECT
    elif [ "${STEP2_WEB_SELECT_VALUE}" = "1" ]; then
        WEB_TYPE="Apache"
        WEB_DIR_FILE_FAIL_CHK
    elif [ "${STEP2_WEB_SELECT_VALUE}" = "2" ]; then
        WEB_TYPE="Apache Tomcat"
        WEB_DIR_FILE_FAIL_CHK
    elif [ "${STEP2_WEB_SELECT_VALUE}" = "3" ]; then
        WEB_TYPE="NginX"
        WEB_DIR_FILE_FAIL_CHK
    else
        echo -e "Incorrect selection. Select again."
        STEP2_WEB_SELECT
    fi
}
WEB_DIR_FILE_FAIL_CHK(){
    if [ "${WEB_TYPE}" = "Apache" ]; then
        echo
        echo "Enter the '/conf/httpd.conf' file path or Enter the 'apache2.conf' file path."
        echo "Example Path : /etc/httpd or /etc/apache2"
        echo
        echo -n "Enter the installtion directory. (ex. /etc/httpd or /etc/apache2) : "
        read HTTP_DIR
        HTTP_CONF=$HTTP_DIR/conf/httpd.conf
        HTTP_CONF2=$HTTP_DIR/apache2.conf
        if [ -e "${HTTP_CONF}" ]; then
            HTTP_CONF2=""
        elif [ -e "${HTTP_CONF2}" ]; then
            HTTP_CONF="$HTTP_CONF2"
            HTTP_CONF2="$HTTP_DIR/conf-available/security.conf"
        fi
        if [ -e "${HTTP_CONF}" ]; then
            if [ "$Type" = "WEB" ]; then
                VALUE_CHECK_PRINT
            else
                STEP3_DBMS_SELECT
            fi
        else
            echo "Path not found. Re-enter."
            WEB_DIR_FILE_FAIL_CHK
        fi
    elif [ "${WEB_TYPE}" = "Apache Tomcat" ]; then
        echo
        echo "Enter the '/conf/server.xml' file path."
        echo "Example Path : /usr/local/tomcat/"
        echo
        echo -n "Enter the Tomcat installtion directory. (ex. /usr/local/tomcat/) : "
        read TOMCAT_DIR
        TOMCAT_CONF=$TOMCAT_DIR/conf/server.xml
        if [ -e "${TOMCAT_CONF}" ]; then 
            if [ "$Type" = "WEB" ]; then
                VALUE_CHECK_PRINT
            else
                STEP3_DBMS_SELECT 
            fi
        else
            echo "Path not found. Re-enter."
            WEB_DIR_FILE_FAIL_CHK
        fi
    elif [ "${WEB_TYPE}" = "NginX" ]; then
        echo
        echo "Enter the 'nginx.conf' file path."
        echo "Example Path : /etc/nginx/nginx.conf"
        echo
        echo -n "Enter the NginX installtion directory. (ex. /etc/nginx) : "
        read NGINX_DIR
        NGINX_CONF=$NGINX_DIR/nginx.conf
        if [ ! -e "${NGINX_CONF}" ]; then
            echo "'nginx.conf' file path not found. Re-enter."
            WEB_DIR_FILE_FAIL_CHK
        else
            echo
            echo "Enter the directory path where the file '/conf.d/*.conf'."
            echo "Example Path : /etc/nginx/conf.d"
            echo
            echo -n "Enter the NginX Include Configuration files directory. (ex. /etc/nginx/conf.d) : "
            read NGINX_DIR2
            if [ -e "${NGINX_DIR2}" ]; then
                if [ "$Type" = "WEB" ]; then
                    VALUE_CHECK_PRINT
                else
                    STEP3_DBMS_SELECT
                fi
            else
                    echo "Include Configuration files directory path not found. Re-enter."
                    WEB_DIR_FILE_FAIL_CHK
            fi
        fi
    elif [ "${WEB_TYPE}" = "WebtoB" ]; then
        echo
        echo "Enter the 'WebtoB' file path"
        echo "Example Path : /usr/webtob"
        echo
        echo -n "Enter the installtion directory. (ex. /usr/webtob) : "
        read WEBTOB_DIR
        WEBTOB_CONF=$WEBTOB_DIR
        WEBTOB_CONF_2=$WEBTOB_DIR/config/http.m
        if [ -e "${WEBTOB_CONF_2}" ]; then
            if [ "$Type" = "WEB" ]; then
                VALUE_CHECK_PRINT
            else
                STEP3_DBMS_SELECT
            fi
        else
            echo "Path not found. Re-enter."
            WEB_DIR_FILE_FAIL_CHK
        fi
    elif [ "${WEB_TYPE}" = "Jeus" ]; then
        echo
        echo "Enter the 'Jeus' file path"
        echo "Example Path : /opt/jeus"
        echo
        echo -n "Enter the installtion directory. (ex. /opt/jeus) : "
        read JEUS_DIR
        JEUS_CONF=$JEUS_DIR
        JEUS_CONF_2=$JEUS_DIR/config/domain.xml
        if [ -e "${JEUS_CONF_2}" ]; then
            if [ "$Type" = "WEB" ]; then
                VALUE_CHECK_PRINT
            else
                STEP3_DBMS_SELECT
            fi
        else
            echo "Path not found. Re-enter."
            WEB_DIR_FILE_FAIL_CHK
        fi
    elif [ "${WEB_TYPE}" = "WebSphere" ]; then
        echo
        echo "Enter the 'WebSphere' file path"
        echo "Example Path : /usr/IBM/WebSphere/AppServer"
        echo
        echo -n "Enter the installtion directory. (ex. /usr/IBM/WebSphere/AppServer) : "
        read WEBSPHERE_DIR
        WEBSPHERE_DIR=$WEBSPHERE_DIR
        if [ -e "${WEBSPHERE_DIR}" ]; then
            if [ "$Type" = "WEB" ]; then
                VALUE_CHECK_PRINT
            else
                STEP3_DBMS_SELECT
            fi
        else
            echo "Path not found. Re-enter."
            WEB_DIR_FILE_FAIL_CHK
        fi
    fi
}
STEP3_DBMS_SELECT(){
    echo
    echo
    echo "===================================================================================================="
    echo
    echo "*STEP 2. Select [DBMS] type."
    echo 
    echo "0. Do net check"
    echo "1.[MySQL(MariaDB)]"
    echo "2.[Oracle]"
    echo "===================================================================================================="
    echo
    echo -n "Select (ex. 1) : "
    read STEP3_DBMS_SELECT_VALUE
    if [ "${STEP3_DBMS_SELECT_VALUE}" = "0" ]; then
        VALUE_CHECK_PRINT
    elif [ "${STEP3_DBMS_SELECT_VALUE}" = "1" ]; then
        DB_TYPE="Mysql"
        DBMS_DIR_FILE_FAIL_CHK
    elif [ "${STEP3_DBMS_SELECT_VALUE}" = "2" ]; then
        DB_TYPE="Oracle"
        DBMS_DIR_FILE_FAIL_CHK
    else
        echo -e "Incorrect selection. Select again."
        STEP3_DBMS_SELECT
    fi
}
STEP4_DOCKER_SELECT(){
    echo
    echo
    echo "===================================================================================================="
    echo
    echo "*STEP 3. Select [Docker] type."
    echo 
    echo "0. Do net check"
    echo "1.[Docker]"
    echo "===================================================================================================="
    echo
    echo -n "Select (ex. 1) : "
    read STEP4_DOCKER_SELECT_VALUE
    if [ "${STEP4_DOCKER_SELECT_VALUE}" = "0" ]; then
        VALUE_CHECK_PRINT
    elif [ "${STEP4_DOCKER_SELECT_VALUE}" = "1" ]; then
        DOCKER_TYPE="Docker"
        VALUE_CHECK_PRINT
    else
        echo -e "Incorrect selection. Select again."
        STEP4_DOCKER_SELECT
    fi
}
DBMS_DIR_FILE_FAIL_CHK(){
    if [ "${DB_TYPE}" = "Mysql" ]; then
        echo
        echo "Enter the 'my.cnf' file path."
        echo "Example Path : /etc"
        echo
        echo -n "Enter the directory of the my.cnf. (ex. /etc) : " 
        read MYSQL_DIR
        MYSQL_CONF=$MYSQL_DIR/my.cnf
        if [ -e "${MYSQL_CONF}" ]; then
            MYSQL_ID_CHK=y
            DBMS_ID_PW
        else
            echo "Path not found. Re-enter."
            DBMS_DIR_FILE_FAIL_CHK
        fi
    elif [ "${DB_TYPE}" = "Mariadb" ]; then
        echo
        echo "Enter the 'my.cnf' file path."
        echo "Example Path : /etc"
        echo
        echo -n "Enter the directory of the my.cnf (ex. /etc) : "
        read MARIADB_DIR
        MARIADB_CONF=$MARIADB_DIR/my.cnf
        if [ -e "${MARIADB_CONF}" ]; then
            MARIADB_ID_CHK=y
            DBMS_ID_PW
        else
            echo "Path not found. Re-enter."
            DBMS_DIR_FILE_FAIL_CHK
        fi
    elif [ "${DB_TYPE}" = "Oracle" ]; then
        echo
        echo "Enter the '/dbs/, /network/' folder path."
        echo "Example Path : /app/oracle/product/11.2.0/dbhome_1"
        echo
        echo -n "Enter the Oracle home directory. (ex. /app/oracle/product/11.2.0/dbhome_1) : "
        read ORACLE_DIR
        ORACLE_DIR_DBS=$ORACLE_DIR/dbs
        ORACLE_DIR_NETWORK=$ORACLE_DIR/network
        if [ -e "${ORACLE_DIR}" ] && [ -e "${ORACLE_DIR_DBS}" ] && [ -e "${ORACLE_DIR_NETWORK}" ]; then
            ORACLE_ID_CHK=y
            DBMS_MANAGE_ID_INPUT
            DBMS_INSTANCE_CHK
            DBMS_ID_PW
        else
            echo "Path not found. Re-enter."
            DBMS_DIR_FILE_FAIL_CHK
        fi
    fi
}
DBMS_MANAGE_ID_INPUT(){
    echo
    echo "Enter the 'Oracle' management account. (ex. oracle)"
    echo -n "Enter the [Management ID] : "
    read ORACLE_MANAGE_ID
    if [ -z "${ORACLE_MANAGE_ID}" ]; then
        echo
        echo "Oracle management ID value does not exist. Please check the parameter values."
        echo
        DBMS_MANAGE_ID_INPUT
    else
        break
    fi
}
DBMS_INSTANCE_CHK(){
    echo 
    echo "Select [Instance] type."
    echo 
    echo "1.[Single Instance]"
    echo "2.[Multiple Instances]"
    echo
    echo -n "Select (ex. 1) : "
    read DBMS_INSTANCE_CHK_VALUE
    if [ "${DBMS_INSTANCE_CHK_VALUE}" = "1" ]; then
        ORACLE_INSTANCE_TYPE="single"
    elif [ "${DBMS_INSTANCE_CHK_VALUE}" = "2" ]; then
        ORACLE_INSTANCE_TYPE="multiple"
    else
        echo -e "Incorrect selection. Select again."
        DBMS_INSTANCE_CHK   
    fi
}
DBMS_ID_PW(){
    if [ "${MYSQL_ID_CHK}" = "y" ]; then
        echo
        echo "Enter the 'Mysql' Login account."
        echo "1. IF set [root ID] password"
        echo "2. IF set [root ID] password is NuLL"
        echo -n "Select (ex. 1) : "
        read SELECT_MYSQL_ID
        if [ "${SELECT_MYSQL_ID}" = "1" ]; then
            echo -n "Enter the [root ID] : "
            read MYSQL_ID
            echo -n "Enter the [root Password] : "
            read MYSQL_PW
            MYSQL_MARIADB_LOGIN="mysql -u $MYSQL_ID -p$MYSQL_PW"
            VALUE_CHECK_PRINT
        elif [ "${SELECT_MYSQL_ID}" = "2" ]; then
            echo -n "Enter the [root ID] : "
            read MYSQL_ID
            MYSQL_PW="NULL"
            MYSQL_MARIADB_LOGIN="mysql -u $MYSQL_ID"
            VALUE_CHECK_PRINT
        else
            echo -e "Incorrect selection. Select again."
            DBMS_ID_PW
        fi
    elif [ "${MARIADB_ID_CHK}" = "y" ]; then
        echo
        echo "Enter the 'MariadB' Login account."
        echo "1. IF set [root ID] password"
        echo "2. IF set [root ID] password is NuLL"
        echo -n "Select (ex. 1) : "
        read SELECT_MARIADB_ID
        if [ "${SELECT_MARIADB_ID}" = "1" ]; then
            echo -n "Enter the [root ID] : "
            read MARIADB_ID
            echo -n "Enter the [root Password] : "
            read MARIADB_PW
            MYSQL_MARIADB_LOGIN="mysql -u $MARIADB_ID -p$MARIADB_PW"
            VALUE_CHECK_PRINT
        elif [ "${SELECT_MARIADB_ID}" = "2" ]; then
            echo -n "Enter the [root ID] : "
            read MARIADB_ID
            MARIADB_PW="NULL"
            MYSQL_MARIADB_LOGIN="mysql -u $MARIADB_ID"
            VALUE_CHECK_PRINT
        else
            echo -e "Incorrect selection. Select again."
            DBMS_ID_PW
        fi
    elif [ "${ORACLE_ID_CHK}" = "y" ]; then
        echo
        echo "Enter the 'Oracle' Login account."
        echo "1. IF set [sys ID] password"
        echo "2. IF set [sys ID] password is NuLL"
        echo -n "Select (ex. 1) : "
        read SELECT_ORACLE_ID
        if [ "${SELECT_ORACLE_ID}" = "1" ]; then
            echo -n "Enter the [sys ID] : "
            read ORACLE_ID
            echo -n "Enter the [sys Password] : "
            read ORACLE_PW
            if [ "${ORACLE_INSTANCE_TYPE}" = "single" ]; then
                ORACLE_LOGIN="$ORACLE_ID/$ORACLE_PW as sysdba"
            elif [ "${ORACLE_INSTANCE_TYPE}" = "multiple" ]; then
                ORACLE_LOGIN="$ORACLE_ID/$ORACLE_PW"
            fi
            VALUE_CHECK_PRINT
        elif [ "${SELECT_ORACLE_ID}" = "2" ]; then
            echo -n "Enter the [sys ID] : "
            read ORACLE_ID
            ORACLE_PW="NULL"
            if [ "${ORACLE_INSTANCE_TYPE}" = "single" ]; then
                ORACLE_LOGIN="$ORACLE_ID/$ORACLE_PW as sysdba"
            elif [ "${ORACLE_INSTANCE_TYPE}" = "multiple" ]; then
                ORACLE_LOGIN="$ORACLE_ID/$ORACLE_PW"
            fi
            VALUE_CHECK_PRINT
        else
            echo -e "Incorrect selection. Select again."
            DBMS_ID_PW
        fi
    fi
}
CLEAR_VALUE(){
    USER_INPUT1=
    USER_INPUT2=
    USER_INPUT3=
    USER_INPUT4=
    USER_INPUT5=
    USER_INPUT6=
    USER_INPUT7=
    USER_INPUT8=
    OS_TYPE=
    PC_USERNAME=
    WEB_TYPE=
    HTTP_DIR=
    HTTP_CONF=
    TOMCAT_DIR=
    TOMCAT_CONF=
    NGINX_DIR=
    NGINX_DIR2=
    NGINX_CONF=
    DB_TYPE=
    MYSQL_DIR=
    MYSQL_CONF=
    MARIADB_DIR=
    MARIADB_CONF=
    ORACLE_DIR=
    ORACLE_DIR_DBS=
    ORACLE_DIR_NETWORK=
    MYSQL_ID=
    MYSQL_PW=
    MARIADB_ID=
    MARIADB_PW=
    MYSQL_MARIADB_LOGIN=
    ORACLE_MANAGE_ID=
    ORACLE_ID=   
    ORACLE_PW=
    ORACLE_LOGIN=
    DBMS_INSTANCE_CHK_VALUE=
    ORACLE_INSTANCE_TYPE=
    STEP1_OS_SELECT_VALUE=
    STEP2_WEB_SELECT_VALUE=
    STEP3_DBMS_SELECT_VALUE=
    VS_PC=
    VS_SV=
    VS_HTTP=
    VS_NGINX=
    VS_TOMCAT=
    VS_WEBTOB=
    VS_JEUS=
    VS_WEBSPHERE=
    VS_MYSQL=
    VS_MARIADB=
    VS_ORACLE=
    Type=
    DOCKER_TYPE=
    VS_DOCKER=
    WEBTOB_DIR=
    WEBTOB_CONF=
    WEBTOB_CONF_2=
    JEUS_DIR=
    JEUS_CONF=
    JEUS_CONF_2=
    WEBSPHERE_DIR=
}
VALUE_FAIL_CHK(){
    if [ "${USER_INPUT2}" = "apache" ]; then
        if [ "${HTTP_DIR}" = "" ] || [ -z "${HTTP_DIR}" ]; then 
            echo "Apache Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${HTTP_DIR}" ];then
            echo "Apache Dir path not found. Please check the parameter values."
            exit
        fi
    fi
    if [ "${USER_INPUT2}" = "apache tomcat" ]; then
        if [ "${TOMCAT_DIR}" = "" ] || [ -z "${TOMCAT_DIR}" ]; then 
            echo "Apache Tomcat Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${TOMCAT_DIR}" ];then
            echo "Apache Tomcat Dir path not found. Please check the parameter values."
            exit
        fi
    fi
    if [ "${USER_INPUT2}" = "nginx" ]; then
        if [ "${NGINX_DIR}" = "" ] || [ -z "${NGINX_DIR}" ] || [ -z "${NGINX_DIR2}" ] || [ -z "${NGINX_DIR2}" ]; then 
            echo "NingX Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${NGINX_DIR}" ]; then 
            echo "NginX Dir path not found. Please check the parameter values."
            exit
        fi
        if [ ! -d "${NGINX_DIR2}" ]; then
            echo "NginX conf.d Dir path not found. Please check the parameter values."
            exit
        fi
    fi
    if [ "${USER_INPUT2}" = "WebtoB" ]; then
        if [ "${WEBTOB_DIR}" = "" ] || [ -z "${WEBTOB_DIR}" ]; then 
            echo "WebtoB Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${WEBTOB_DIR}" ];then
            echo "WebtoB Dir path not found. Please check the parameter values."
            exit
        fi
    fi
    if [ "${USER_INPUT2}" = "Jeus" ]; then
        if [ "${JEUS_DIR}" = "" ] || [ -z "${JEUS_DIR}" ]; then 
            echo "Jeus Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${JEUS_DIR}" ];then
            echo "Jeus Dir path not found. Please check the parameter values."
            exit
        fi
    fi
    if [ "${USER_INPUT2}" = "WebSphere" ]; then
        if [ "${WEBSPHERE_DIR}" = "" ] || [ -z "${WEBSPHERE_DIR}" ]; then 
            echo "WebSphere Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${WEBSPHERE_DIR}" ];then
            echo "WebSphere Dir path not found. Please check the parameter values."
            exit
        fi
    fi
    if [ "${USER_INPUT2}" = "mysql" ] || [ "${USER_INPUT4}" = "mysql" ]; then
        if [ "${MYSQL_DIR}" = "" ] || [ -z "${MYSQL_DIR}" ]; then 
            echo "MySQL DB Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${MYSQL_DIR}" ]; then
            echo "MySQL DB Dir path not found. Please check the parameter values."
            exit
        fi
        if [ "${MYSQL_ID}" = "" ] || [ -z "${MYSQL_ID}" ]; then 
            echo "MySQL DB ID value does not exist. Please check the parameter values."
            exit
        fi
        if [ "${MYSQL_PW}" = "" ] || [ -z "${MYSQL_PW}" ]; then 
            echo "MySQL DB PW value does not exist. Please check the parameter values."
            exit
        fi
    fi
    if [ "${USER_INPUT2}" = "mariadb" ] || [ "${USER_INPUT4}" = "mariadb" ]; then
        if [ "${MARIADB_DIR}" = "" ] || [ -z "${MARIADB_DIR}" ]; then 
            echo "Mariadb DB Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${MARIADB_DIR}" ];then 
            echo "Mariadb DB Dir path not found. Please check the parameter values."
            exit
        fi
        if [ "${MARIADB_ID}" = "" ] || [ -z "${MARIADB_ID}" ]; then 
            echo "Mariadb DB ID value does not exist. Please check the parameter values."
            exit 
        fi
        if [ "${MARIADB_PW}" = "" ] || [ -z "${MARIADB_PW}" ]; then 
            echo "Mariadb DB PW value does not exist.S Please check the parameter values."
            exit
        fi
    fi
    if [ "${USER_INPUT2}" = "oracle" ] || [ "${USER_INPUT4}" = "oracle" ]; then
        if [ "${ORACLE_DIR}" = "" ] || [ -z "${ORACLE_DIR}" ]; then 
            echo "Oracle DB Dir value does not exist. Please check the parameter values."
            exit
        fi
        if [ ! -d "${ORACLE_DIR}" ];then 
            echo "Oracle DB Dir path not found. Please check the parameter values."
            exit
        fi
        if [ "${ORACLE_MANAGE_ID}" = "" ] || [ -z "${ORACLE_MANAGE_ID}" ]; then 
            echo "Oracle management ID value does not exist. Please check the parameter values."
            exit
        fi
        if [ "${ORACLE_ID}" = "" ] || [ -z "${ORACLE_ID}" ]; then 
            echo "Oracle DB ID value does not exist. Please check the parameter values."
            exit
        fi
        if [ "${ORACLE_PW}" = "" ] || [ -z "${ORACLE_PW}" ]; then 
            echo "Oracle DB PW value does not exist. Please check the parameter values."
            exit
        fi
    fi
}
SELECT_VS(){
    if [ "${OS_TYPE}" = "MacOS PC" ]; then VS_PC="y"; fi
    if [ "${OS_TYPE}" = "Unix Server" ]; then VS_SV="y"; fi
    if [ "${WEB_TYPE}" = "Apache" ]; then 
        HTTP_CONF=$HTTP_DIR/conf/httpd.conf
        HTTP_CONF2=$HTTP_DIR/apache2.conf
        if [ -e "${HTTP_CONF}" ]; then
            HTTP_CONF=$HTTP_DIR/conf/httpd.conf
            VS_HTTP="y"
        elif [ -e "${HTTP_CONF2}" ]; then
            HTTP_CONF=$HTTP_DIR/apache2.conf
            VS_HTTP="y"
        fi
    fi
    if [ "${WEB_TYPE}" = "Apache Tomcat" ]; then
        TOMCAT_CONF=$TOMCAT_DIR/conf/server.xml
        VS_TOMCAT="y"
    fi
    if [ "${WEB_TYPE}" = "NginX" ]; then
        NGINX_CONF=$NGINX_DIR/nginx.conf
        VS_NGINX="y"
    fi
    if [ "${WEB_TYPE}" = "WebtoB" ]; then
        WEBTOB_CONF_2=$WEBTOB_DIR/config/http.m
        VS_WEBTOB="y"
    fi
    if [ "${WEB_TYPE}" = "Jeus" ]; then
        JEUS_CONF_2=$JEUS_CONF/config/domain.xml
        VS_JEUS="y"
    fi
    if [ "${WEB_TYPE}" = "WebSphere" ]; then
        VS_WEBSPHERE="y"
    fi
    if [ "${DB_TYPE}" = "Mysql" ]; then
        MYSQL_CONF=$MYSQL_DIR/my.cnf
        VS_MYSQL="y"
    fi
    if [ "${DB_TYPE}" = "Mariadb" ]; then
        MARIADB_CONF=$MARIADB_DIR/my.cnf
        VS_MARIADB="y"
    fi
    if [ "${DB_TYPE}" = "Oracle" ]; then 
        ORACLE_DIR_DBS=$ORACLE_DIR/dbs
        ORACLE_DIR_NETWORK=$ORACLE_DIR/network
        VS_ORACLE="y"
    fi 
    if [ "${DOCKER_TYPE}" = "Docker" ]; then VS_DOCKER="y"; fi
}
VALUE_CHECK_PRINT(){
    echo
    echo
    echo "Check all input values"
    echo "===================================================================================================="
    echo
    if [ -n "${OS_TYPE}" ]; then echo "OS Type                   : ${OS_TYPE}";fi
    if [ -n "${PC_USERNAME}" ]; then echo "PC User Name              : ${PC_USERNAME}";fi
    if [ -n "${WEB_TYPE}" ]; then echo; echo "WEB Type                  : ${WEB_TYPE}";fi
    if [ -n "${HTTP_DIR}" ]; then echo "Apache Dir                : ${HTTP_DIR}";fi
    if [ -n "${TOMCAT_DIR}" ]; then echo "Apache Tomcat Dir         : ${TOMCAT_DIR}";fi
    if [ -n "${NGINX_DIR}" ]; then echo "NginX Dir                 : ${NGINX_DIR}";fi
    if [ -n "${NGINX_DIR}" ]; then echo "NginX conf.d Dir          : ${NGINX_DIR2}";fi
    if [ -n "${WEBTOB_DIR}" ]; then echo "WebtoB Dir                : ${WEBTOB_DIR}";fi
    if [ -n "${JEUS_DIR}" ]; then echo "Jeus Dir                : ${JEUS_DIR}";fi
    if [ -n "${WEBSPHERE_DIR}" ]; then echo "WebSphere Dir                : ${WEBSPHERE_DIR}";fi
    if [ -n "${DB_TYPE}" ]; then echo; echo "DB Type                   : ${DB_TYPE}";fi
    if [ -n "${MYSQL_DIR}" ]; then echo "Mysql Dir                 : ${MYSQL_DIR}";fi
    if [ -n "${MARIADB_DIR}" ]; then echo "MariaDB Dir               : ${MARIADB_DIR}";fi
    if [ -n "${ORACLE_DIR}" ]; then echo "Oracle Dir                : ${ORACLE_DIR}";fi
    if [ -n "${MYSQL_ID}" ]; then echo "MySQL ID                  : ${MYSQL_ID}";fi
    if [ -n "${MARIADB_ID}" ]; then echo "MariaDB ID                : ${MARIADB_ID}";fi
    if [ -n "${ORACLE_MANAGE_ID}" ]; then echo "Oracle management ID      : ${ORACLE_MANAGE_ID}";fi
    if [ -n "${ORACLE_INSTANCE_TYPE}" ]; then echo "Oracle INSTANCE TYPE      : ${ORACLE_INSTANCE_TYPE}";fi
    if [ -n "${ORACLE_ID}" ]; then echo "Oracle ID                 : ${ORACLE_ID}";fi
    if [ -n "${MYSQL_PW}" ]; then echo "MySQL PW                  : ${MYSQL_PW}";fi
    if [ -n "${MARIADB_PW}" ]; then echo "MariaDB PW                : ${MARIADB_PW}";fi
    if [ -n "${ORACLE_PW}" ]; then echo "Oracle PW                 : ${ORACLE_PW}";fi
    if [ -n "${DOCKER_TYPE}" ]; then echo; echo "Docker Type               : ${DOCKER_TYPE}";fi
    echo
    echo "===================================================================================================="
    echo "Check and select all entered information. (1. Correct, 2. Re-enter)"
    echo -n "Select (ex. 1) : "
    read VALUE_SELECT
    if [ "${VALUE_SELECT}" = "1" ]; then
        VALUE_FAIL_CHK
        SELECT_VS
        VS_START_CHECK="y"
    elif [ "${VALUE_SELECT}" = "2" ]; then
        CLEAR_VALUE
        STEP0_SELECT
    else
        VALUE_CHECK_PRINT
    fi
}
clear
if [ "${2}" = "777" ] || [ "${3}" = "777" ] || [ "${4}" = "777" ] || [ "${5}" = "777" ] || [ "${6}" = "777" ] || [ "${7}" = "777" ] || [ "${8}" = "777" ] || [ "${9}" = "777" ] || [ "${10}" = "777" ] || [ "${11}" = "777" ]; then 
    ROOT_CHK 777
else
    ROOT_CHK
fi
if [ -n "${1}" ]; then
    USER_INPUT1=$(echo ${1} | tr [A-Z] [a-z] )
    USER_INPUT2=$(echo ${2} | tr [A-Z] [a-z] )
    USER_INPUT3=$(echo ${3} | tr [A-Z] [a-z] )
    USER_INPUT4=$(echo ${4} | tr [A-Z] [a-z] )
    USER_INPUT5=$(echo ${5} | tr [A-Z] [a-z] )
    USER_INPUT6=$(echo ${6} | tr [A-Z] [a-z] )
    USER_INPUT7=$(echo ${7} | tr [A-Z] [a-z] )
    USER_INPUT8=$(echo ${8} | tr [A-Z] [a-z] )
    USER_INPUT9=$(echo ${9} | tr [A-Z] [a-z] )
    USER_INPUT10=$(echo ${10} | tr [A-Z] [a-z] )
    if [ "${USER_INPUT1}" = "?" ]; then
        echo 
        echo   "Parameter format."
        echo   "- VS "pc/sv" "apache/apache tomcat/nginx" "web/was dir" "mysql/mariadb/oracle" '(oracle)management id' '(oracle)instance type' "db dir" "id" "pw" "777""
        echo   "- VS "pc/sv" "apache/apache tomcat/nginx" "web/was dir" "mysql/mariadb/oracle" '(oracle)management id' '(oracle)instance type' "db dir" "id" "pw" "/f" "777""
        echo 
        echo   "The example."
        echo   "- VS "pc"    "user name""
        echo   "- VS "sv""
        echo   "- VS "sv"    "httpd"    "web dir"    "777""
        echo   "- VS "sv"    "NginX"    "web dir"    "conf.d dir""   
        echo   "- VS "sv"    "MySQL"    "web dir"    "mysql"     "db dir"    "id"        "pw""    
        echo   "- VS "sv"    "MariaDB"  "web dir"    "mariadb"   "db dir"    "id"        "pw""    
        echo   "- VS "sv"    "Oracle"   "db dir"     "oracle"    "single"    "id"        "pw""     
        echo   "- VS "sv"    "httpd"    "web dir"    "Oracle"    "db dir"    "oracle"    "multiple"    "id"    "NULL""
        echo    
        echo   "Start right away^(Forced Start^). Enter /f at the end"
        echo   "- VS "pc"    "user name"        "/f""
        echo   "- VS "sv"    "/f""
        echo   "- VS "sv"    "httpd"           "web dir"    "/f""    
        echo   "- VS "sv"    "apache tomcat"   "web dir"    "mysql"    "db dir"   "id"        "pw"         "/f"    "777""    
        echo   "- VS "sv"    "mysql"           "db dir"     "id"       "pw"       "/f"" 
        echo   "- VS "sv"    "Oracle"          "db dir"     "oracle"   "single"   "id"        "pw"         "/f""    
        echo   "- VS "sv"    "httpd"           "web dir"    "Oracle"   "db dir"   "oracle"    "multiple"   "id"    "NULL"    "/f"" 
        echo
        exit
    elif [ "${USER_INPUT1}" = "pc" ]; then
        OS_TYPE="MacOS PC"
        PC_USERNAME=${USER_INPUT2}
        if [ "${PC_USERNAME}" = "" ] || [ -z "${PC_USERNAME}" ]; then 
            echo "PC User Name value does not exist. Please check the parameter values."
            exit
        fi
        if [ "${USER_INPUT3}" = "/f" ]; then
            VS_PC="y"
            VS_START_CHECK="y"
        else
            VALUE_CHECK_PRINT
        fi
    elif [ "${USER_INPUT1}" = "sv" ]; then
        OS_TYPE="Unix Server"
        if [ "${USER_INPUT2}" = "apache" ] || [ "${USER_INPUT2}" = "apache tomcat" ] || [ "${USER_INPUT2}" = "nginx" ] || [ "${USER_INPUT2}" = "mysql" ] || [ "${USER_INPUT2}" = "mariadb" ] || [ "${USER_INPUT2}" = "oracle" ] || [ "${USER_INPUT2}" = "/f" ] || [ -z "${USER_INPUT2}" ] || [ "${USER_INPUT2}" = "777" ]; then
            if [ "${USER_INPUT2}" = "apache" ]; then 
                WEB_TYPE="Apache"
                HTTP_DIR=${USER_INPUT3}
            fi
            if [ "${USER_INPUT2}" = "apache tomcat" ]; then
                WEB_TYPE="Apache Tomcat"
                TOMCAT_DIR=${USER_INPUT3}
            fi
            if [ "${USER_INPUT2}" = "nginx" ]; then
                WEB_TYPE="NginX"
                NGINX_DIR=${USER_INPUT3}
                NGINX_DIR2=${USER_INPUT4}
            fi
            if [ "${USER_INPUT2}" = "mysql" ]; then
                DB_TYPE="Mysql"
                MYSQL_DIR=${USER_INPUT3}
                MYSQL_ID=${USER_INPUT4}
                MYSQL_PW=${USER_INPUT5}
                MYSQL_MARIADB_LOGIN="mysql -u $MYSQL_ID -p$MYSQL_PW"
            fi
            if [ "${USER_INPUT2}" = "mariadb" ]; then
                DB_TYPE="Mariadb"
                MARIADB_DIR=${USER_INPUT3}
                MARIADB_ID=${USER_INPUT4}
                MARIADB_PW=${USER_INPUT5}
                MYSQL_MARIADB_LOGIN="mysql -u $MARIADB_ID -p$MARIADB_PW"
            fi
            if [ "${USER_INPUT2}" = "oracle" ]; then
                DB_TYPE="Oracle"
                ORACLE_DIR=${USER_INPUT3}
                ORACLE_MANAGE_ID=${USER_INPUT4}
                ORACLE_INSTANCE_TYPE=${USER_INPUT5}
                ORACLE_ID=${USER_INPUT6}
                ORACLE_PW=${USER_INPUT7}
                if [ "${ORACLE_INSTANCE_TYPE}" = "single" ]; then
                    ORACLE_LOGIN="$ORACLE_ID/$ORACLE_PW as sysdba"
                elif [ "${ORACLE_INSTANCE_TYPE}" = "multiple" ]; then
                    ORACLE_LOGIN="$ORACLE_ID/$ORACLE_PW"
                fi
            fi
        else
            echo
            echo "Web Type or DBMS Type value does not exist. Please check the parameter values."
            echo
            exit
        fi
        if [ "${USER_INPUT4}" = "mysql" ] || [ "${USER_INPUT4}" = "mariadb" ] || [ "${USER_INPUT4}" = "oracle" ] || [ "${USER_INPUT4}" = "/f" ] || [ -z "${USER_INPUT4}" ] || [ "${USER_INPUT4}" = "777" ]; then
            if [ "${USER_INPUT4}" = "mysql" ]; then
                DB_TYPE="Mysql"
                MYSQL_DIR=${USER_INPUT5}
                MYSQL_ID=${USER_INPUT6}
                MYSQL_PW=${USER_INPUT7}
                MYSQL_MARIADB_LOGIN="mysql -u $MYSQL_ID -p$MYSQL_PW"
            fi
            if [ "${USER_INPUT4}" = "mariadb" ]; then
                DB_TYPE="Mariadb"
                MARIADB_DIR=${USER_INPUT5}
                MARIADB_ID=${USER_INPUT6}
                MARIADB_PW=${USER_INPUT7}
                MYSQL_MARIADB_LOGIN="mysql -u $MARIADB_ID -p$MARIADB_PW"
            fi
            if [ "${USER_INPUT4}" = "oracle" ]; then
                DB_TYPE="Oracle"
                ORACLE_DIR=${USER_INPUT5}
                ORACLE_MANAGE_ID=${USER_INPUT6}
                ORACLE_INSTANCE_TYPE=${USER_INPUT7}
                ORACLE_ID=${USER_INPUT8}
                ORACLE_PW=${USER_INPUT9}
                if [ "${ORACLE_INSTANCE_TYPE}" = "single" ]; then
                    ORACLE_LOGIN="$ORACLE_ID/$ORACLE_PW as sysdba"
                elif [ "${ORACLE_INSTANCE_TYPE}" = "multiple" ]; then
                    ORACLE_LOGIN="$ORACLE_ID/$ORACLE_PW"
                fi
            fi
        elif [ -n "${NGINX_DIR2}" ] || [ -n "${MYSQL_ID}" ] || [ -n "${MARIADB_ID}" ] || [ -n "${ORACLE_MANAGE_ID}" ]; then
            break
        else
            echo
            echo "DBMS Type value does not exist. Please check the parameter values."
            echo
            exit
        fi
       if [ "${USER_INPUT2}" = "/f" ] || [ "${USER_INPUT4}" = "/f" ] || [ "${USER_INPUT5}" = "/f" ] || [ "${USER_INPUT6}" = "/f" ] || [ "${USER_INPUT8}" = "/f" ] || [ "${USER_INPUT9}" = "/f" ] || [ "${USER_INPUT10}" = "/f" ]; then
            VALUE_FAIL_CHK
            VS_START_CHECK="y"
            SELECT_VS
        else
            VALUE_CHECK_PRINT
        fi
    else
        echo
        echo "The first parameter is "PC" or "SV". Please enter it again."
        echo
        exit
    fi
else
    CLEAR_VALUE;
    STEP0_SELECT
fi
SELECT_RUN_CMD(){
    if [ "${VS_PC}" = "y" ]; then VS_PC_GOTO; fi
    if [ "${VS_SV}" = "y" ]; then VS_SV_GOTO; fi
    if [ "${VS_HTTP}" = "y" ]; then VS_APACHE_HTTP_GOTO; fi 
    if [ "${VS_TOMCAT}" = "y" ]; then VS_APACHE_TOMCAT_GOTO; fi
    if [ "${VS_NGINX}" = "y" ]; then VS_NGINX_GOTO; fi
    if [ "${VS_WEBTOB}" = "y" ]; then VS_WEBTOB_GOTO; fi
    if [ "${VS_JEUS}" = "y" ]; then VS_JEUS_GOTO; fi
    if [ "${VS_WEBSPHERE}" = "y" ]; then VS_WEBSPHERE_GOTO; fi
    if [ "${VS_MYSQL}" = "y" ]; then VS_MYSQL_DB_GOTO; fi
    if [ "${VS_MARIADB}" = "y" ]; then VS_MARIA_DB_GOTO; fi
    if [ "${VS_ORACLE}" = "y" ]; then VS_ORACLE_DB_GOTO; fi
    if [ "${VS_DOCKER}" = "y" ]; then VS_DOCKER_GOTO; fi
    VS_COMMON_GOTO
}
VALUE_CHECK_RESULT_FILE_PRINT(){
    echo
    echo "Input values"
    echo "===================================================================================================="
    echo
    if [ -n "${OS_TYPE}" ]; then echo "OS Type                   : ${OS_TYPE}";fi
    if [ -n "${PC_USERNAME}" ]; then echo "PC User Name              : ${PC_USERNAME}";fi
    if [ -n "${WEB_TYPE}" ]; then echo; echo "WEB Type                  : ${WEB_TYPE}";fi
    if [ -n "${HTTP_DIR}" ]; then echo "Apache Dir                : ${HTTP_DIR}";fi
    if [ -n "${TOMCAT_DIR}" ]; then echo "Apache Tomcat Dir         : ${TOMCAT_DIR}";fi
    if [ -n "${NGINX_DIR}" ]; then echo "NginX Dir                 : ${NGINX_DIR}";fi
    if [ -n "${NGINX_DIR}" ]; then echo "NginX conf.d Dir          : ${NGINX_DIR2}";fi
    if [ -n "${WEBTOB_DIR}" ]; then echo "WebtoB Dir                : ${WEBTOB_DIR}";fi
    if [ -n "${JEUS_DIR}" ]; then echo "Jeus Dir                : ${JEUS_DIR}";fi
    if [ -n "${WEBSPHERE_DIR}" ]; then echo "WebSphere Dir                : ${WEBSPHERE_DIR}";fi
    if [ -n "${DB_TYPE}" ]; then echo; echo "DB Type                   : ${DB_TYPE}";fi
    if [ -n "${MYSQL_DIR}" ]; then echo "Mysql Dir                 : ${MYSQL_DIR}";fi
    if [ -n "${MARIADB_DIR}" ]; then echo "MariaDB Dir               : ${MARIADB_DIR}";fi
    if [ -n "${ORACLE_DIR}" ]; then echo "Oracle Dir                : ${ORACLE_DIR}";fi
    if [ -n "${MYSQL_ID}" ]; then echo "MySQL ID                  : ${MYSQL_ID}";fi
    if [ -n "${MARIADB_ID}" ]; then echo "MariaDB ID                : ${MARIADB_ID}";fi
    if [ -n "${ORACLE_MANAGE_ID}" ]; then echo "Oracle management ID      : ${ORACLE_MANAGE_ID}";fi
    if [ -n "${ORACLE_INSTANCE_TYPE}" ]; then echo "Oracle INSTANCE TYPE      : ${ORACLE_INSTANCE_TYPE}";fi
    if [ -n "${ORACLE_ID}" ]; then echo "Oracle ID                 : ${ORACLE_ID}";fi
    if [ -n "${DOCKER_TYPE}" ]; then echo; echo "Docker_TYPE               : ${DOCKER_TYPE}";fi
    echo
    echo "===================================================================================================="
    echo
}
VS_RESULT_FILE_PRINT(){
    echo "" > $FILENAME 2>&1
    echo "HostName :" $(hostname) >> $FILENAME 2>&1
    echo "IP Address :" $(hostname -I) >> $FILENAME 2>&1
    echo "Unix Version :" $(cat /etc/*-release | uniq | sed '5,$d') >> $FILENAME 2>&1
    echo "Account Shell :" $(echo $SHELL) >> $FILENAME 2>&1
    echo "VS File Name :" $SCRIPTNAME >> $FILENAME 2>&1
    echo "VS Execution Time :" $(date '+%F %T') >> $FILENAME 2>&1
    VALUE_CHECK_RESULT_FILE_PRINT >> $FILENAME 2>&1
}
VS_PC_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-001-01], [PC-MAC-002-01], -, -, -, -, -, -, - >> $FILENAME 2>&1
echo 'CMD : pwpolicy -u <username> -getpolicy' >> $FILENAME 2>&1
pwpolicy -u <username> -getpolicy >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/26] : [PC-MAC-001-01], [PC-MAC-002-01], -, -, -, -, -, -, -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-003-01] >> $FILENAME 2>&1
echo 'CMD : defaults -currentHost read com.apple.screensaver idleTime' >> $FILENAME 2>&1
defaults -currentHost read com.apple.screensaver idleTime >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [10/26] : [PC-MAC-003-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-003-02] >> $FILENAME 2>&1
echo 'CMD : osascript -e 'tell application "System Events" to tell security preferences to get require password to wake'' >> $FILENAME 2>&1
osascript -e 'tell application "System Events" to tell security preferences to get require password to wake' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [11/26] : [PC-MAC-003-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo 'CMD : cat /System/Library/LaunchDaemons/ftp.plist' >> $FILENAME 2>&1
cat /System/Library/LaunchDaemons/ftp.plist >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [12/26] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo -, -, - >> $FILENAME 2>&1
echo 'CMD : launchctl print-disabled system' >> $FILENAME 2>&1
launchctl print-disabled system >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [13/26] : -, -, -

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo 'CMD : sharing -l' >> $FILENAME 2>&1
sharing -l >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [16/26] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-004-01] >> $FILENAME 2>&1
echo 'CMD : sudo dscl . -read /Users/root Password' >> $FILENAME 2>&1
sudo dscl . -read /Users/root Password >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [17/26] : [PC-MAC-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-005-01] >> $FILENAME 2>&1
echo 'CMD : sudo launchctl list com.apple.screensharing' >> $FILENAME 2>&1
sudo launchctl list com.apple.screensharing >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [18/26] : [PC-MAC-005-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo 'CMD : sudo launchctl list com.apple.smbd' >> $FILENAME 2>&1
sudo launchctl list com.apple.smbd >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [19/26] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-006-01] >> $FILENAME 2>&1
echo 'CMD : cupsctl' >> $FILENAME 2>&1
cupsctl >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [20/26] : [PC-MAC-006-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-007-01], [PC-MAC-008-01], [PC-MAC-010-01] >> $FILENAME 2>&1
echo 'CMD : system_profiler SPApplicationsDataType' >> $FILENAME 2>&1
system_profiler SPApplicationsDataType >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [21/26] : [PC-MAC-007-01], [PC-MAC-008-01], [PC-MAC-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-009-01] >> $FILENAME 2>&1
echo 'CMD : defaults read /Library/Preferences/com.apple.alf globalstate' >> $FILENAME 2>&1
defaults read /Library/Preferences/com.apple.alf globalstate >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [23/26] : [PC-MAC-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-011-01] >> $FILENAME 2>&1
echo 'CMD : fdesetup status' >> $FILENAME 2>&1
fdesetup status >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [25/26] : [PC-MAC-011-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [PC-MAC-012-01] >> $FILENAME 2>&1
echo 'CMD : sw_vers -ProductVersion' >> $FILENAME 2>&1
sw_vers -ProductVersion >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [26/26] : [PC-MAC-012-01]

echo ==================================================================================================== >> $FILENAME 2>&1

}


VS_SV_GOTO(){

    SV_UNIX_VARIABLE

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-001-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/securetty' >> $FILENAME 2>&1
cat /etc/securetty >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/securetty"' >> $FILENAME 2>&1
NUMPER "/etc/securetty" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [001/175] : [SV-UNI-001-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-001-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/pam.d/login' >> $FILENAME 2>&1
cat /etc/pam.d/login >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/pam.d/login"' >> $FILENAME 2>&1
NUMPER "/etc/pam.d/login" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [002/175] : [SV-UNI-001-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-001-03], [SV-UNI-006-03] >> $FILENAME 2>&1
echo 'CMD : cat /etc/default/login' >> $FILENAME 2>&1
cat /etc/default/login >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/default/login"' >> $FILENAME 2>&1
NUMPER "/etc/default/login" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [003/175] : [SV-UNI-001-03], [SV-UNI-006-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-001-04], [SV-UNI-006-05], [SV-UNI-007-05], [SV-UNI-008-03], [SV-UNI-009-04], [SV-UNI-010-03] >> $FILENAME 2>&1
echo 'CMD : cat /etc/security/user' >> $FILENAME 2>&1
cat /etc/security/user >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/security/user"' >> $FILENAME 2>&1
NUMPER "/etc/security/user" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [004/175] : [SV-UNI-001-04], [SV-UNI-006-05], [SV-UNI-007-05], [SV-UNI-008-03], [SV-UNI-009-04], [SV-UNI-010-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-001-05] >> $FILENAME 2>&1
echo 'CMD : cat /etc/securetty console' >> $FILENAME 2>&1
cat /etc/securetty console >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/securetty console"' >> $FILENAME 2>&1
NUMPER "/etc/securetty console" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [005/175] : [SV-UNI-001-05]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-002-01], [SV-UNI-003-01], [SV-UNI-004-01], [SV-UNI-005-01], [SV-UNI-011-01], [SV-UNI-014-01], [SV-UNI-016-01], [SV-UNI-035-01], [SV-UNI-043-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/passwd' >> $FILENAME 2>&1
cat /etc/passwd >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/passwd"' >> $FILENAME 2>&1
NUMPER "/etc/passwd" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [006/175] : [SV-UNI-002-01], [SV-UNI-003-01], [SV-UNI-004-01], [SV-UNI-005-01], [SV-UNI-011-01], [SV-UNI-014-01], [SV-UNI-016-01], [SV-UNI-035-01], [SV-UNI-043-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-003-02], [SV-UNI-012-01], [SV-UNI-014-02], [SV-UNI-014-03] >> $FILENAME 2>&1
echo 'CMD : cat /etc/group' >> $FILENAME 2>&1
cat /etc/group >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/group"' >> $FILENAME 2>&1
NUMPER "/etc/group" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [008/175] : [SV-UNI-003-02], [SV-UNI-012-01], [SV-UNI-014-02], [SV-UNI-014-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-003-03] >> $FILENAME 2>&1
echo 'CMD : awk -F ':' '{print $3 $1}' /etc/group' >> $FILENAME 2>&1
awk -F ':' '{print $3 $1}' /etc/group >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [009/175] : [SV-UNI-003-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-005-02] >> $FILENAME 2>&1
echo 'CMD : last' >> $FILENAME 2>&1
last >> $FILENAME 2>&1
echo 'CMD : lastlog' >> $FILENAME 2>&1
lastlog >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/adm/wtmp"' >> $FILENAME 2>&1
NUMPER "/var/adm/wtmp" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/log/wtmp"' >> $FILENAME 2>&1
NUMPER "/var/log/wtmp" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/adm/authlog"' >> $FILENAME 2>&1
NUMPER "/var/adm/authlog" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/log/authlog"' >> $FILENAME 2>&1
NUMPER "/var/log/authlog" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/adm/sulog"' >> $FILENAME 2>&1
NUMPER "/var/adm/sulog" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/log/sulog"' >> $FILENAME 2>&1
NUMPER "/var/log/sulog" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [012/175] : [SV-UNI-005-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/pam.d/system-auth' >> $FILENAME 2>&1
cat /etc/pam.d/system-auth >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/pam.d/system-auth"' >> $FILENAME 2>&1
NUMPER "/etc/pam.d/system-auth" >> $FILENAME 2>&1
echo 'CMD : cat /etc/ssh/sshd_config' >> $FILENAME 2>&1
cat /etc/ssh/sshd_config >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/ssh/sshd_config"' >> $FILENAME 2>&1
NUMPER "/etc/ssh/sshd_config" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [013/175] : [SV-UNI-006-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/sudoers.d/90-cloud-init-users' >> $FILENAME 2>&1
cat /etc/sudoers.d/90-cloud-init-users >> $FILENAME 2>&1
echo 'CMD : cat /etc/sudoers/90-cloud-init-users' >> $FILENAME 2>&1
cat /etc/sudoers/90-cloud-init-users >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/sudoers.d/90-cloud-init-users"' >> $FILENAME 2>&1
NUMPER "/etc/sudoers.d/90-cloud-init-users" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/sudoers/90-cloud-init-users"' >> $FILENAME 2>&1
NUMPER "/etc/sudoers/90-cloud-init-users" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [014/175] : [SV-UNI-006-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-04] >> $FILENAME 2>&1
echo 'CMD : cat /etc/security/policy.conf' >> $FILENAME 2>&1
cat /etc/security/policy.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/security/policy.conf"' >> $FILENAME 2>&1
NUMPER "/etc/security/policy.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [016/175] : [SV-UNI-006-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-06] >> $FILENAME 2>&1
echo 'CMD : cat /tcb/files/auth/system/default' >> $FILENAME 2>&1
cat /tcb/files/auth/system/default >> $FILENAME 2>&1
echo 'CMD : NUMPER "/tcb/files/auth/system/default"' >> $FILENAME 2>&1
NUMPER "/tcb/files/auth/system/default" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [018/175] : [SV-UNI-006-06]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-07], [SV-UNI-007-06], [SV-UNI-008-04], [SV-UNI-009-05], [SV-UNI-010-04] >> $FILENAME 2>&1
echo 'CMD : cat /etc/default/security' >> $FILENAME 2>&1
cat /etc/default/security >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/default/security"' >> $FILENAME 2>&1
NUMPER "/etc/default/security" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [019/175] : [SV-UNI-006-07], [SV-UNI-007-06], [SV-UNI-008-04], [SV-UNI-009-05], [SV-UNI-010-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-08], [SV-UNI-007-07], [SV-UNI-008-05], [SV-UNI-009-06], [SV-UNI-010-05] >> $FILENAME 2>&1
echo 'CMD : cat /etc/ssh/sshd_config' >> $FILENAME 2>&1
cat /etc/ssh/sshd_config >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [020/175] : [SV-UNI-006-08], [SV-UNI-007-07], [SV-UNI-008-05], [SV-UNI-009-06], [SV-UNI-010-05]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-09] >> $FILENAME 2>&1
echo 'CMD : cat /etc/pam.d/common-auth' >> $FILENAME 2>&1
cat /etc/pam.d/common-auth >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [021/175] : [SV-UNI-006-09]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-010] >> $FILENAME 2>&1
echo 'CMD : cat /etc/pam.d/common-account' >> $FILENAME 2>&1
cat /etc/pam.d/common-account >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [022/175] : [SV-UNI-006-010]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-006-011] >> $FILENAME 2>&1
echo 'CMD : cat /etc/login.defs' >> $FILENAME 2>&1
cat /etc/login.defs >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [023/175] : [SV-UNI-006-011]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-007-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/pam.d/system-auth' >> $FILENAME 2>&1
cat /etc/pam.d/system-auth >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/pam.d/system-auth"' >> $FILENAME 2>&1
NUMPER "/etc/pam.d/system-auth" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [024/175] : [SV-UNI-007-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-007-02], [SV-UNI-008-01], [SV-UNI-009-02], [SV-UNI-010-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/login.defs' >> $FILENAME 2>&1
cat /etc/login.defs >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/login.defs"' >> $FILENAME 2>&1
NUMPER "/etc/login.defs" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [025/175] : [SV-UNI-007-02], [SV-UNI-008-01], [SV-UNI-009-02], [SV-UNI-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-007-03], [SV-UNI-009-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/security/pwquality.conf' >> $FILENAME 2>&1
cat /etc/security/pwquality.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/security/pwquality.conf"' >> $FILENAME 2>&1
NUMPER "/etc/security/pwquality.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [026/175] : [SV-UNI-007-03], [SV-UNI-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-007-04], [SV-UNI-008-02], [SV-UNI-009-03], [SV-UNI-010-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/default/passwd' >> $FILENAME 2>&1
cat /etc/default/passwd >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/default/passwd"' >> $FILENAME 2>&1
NUMPER "/etc/default/passwd" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [027/175] : [SV-UNI-007-04], [SV-UNI-008-02], [SV-UNI-009-03], [SV-UNI-010-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-007-08] >> $FILENAME 2>&1
echo 'CMD : cat /etc/pam.d/common-password' >> $FILENAME 2>&1
cat /etc/pam.d/common-password >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [031/175] : [SV-UNI-007-08]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-011-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/shadow ' >> $FILENAME 2>&1
cat /etc/shadow  >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/shadow"' >> $FILENAME 2>&1
NUMPER "/etc/shadow" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [049/175] : [SV-UNI-011-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-011-03] >> $FILENAME 2>&1
echo 'CMD : cat /etc/security/passwd' >> $FILENAME 2>&1
cat /etc/security/passwd >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/security/passwd"' >> $FILENAME 2>&1
NUMPER "/etc/security/passwd" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [050/175] : [SV-UNI-011-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-012-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/pam.d/su' >> $FILENAME 2>&1
cat /etc/pam.d/su >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/pam.d/su"' >> $FILENAME 2>&1
NUMPER "/etc/pam.d/su" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [052/175] : [SV-UNI-012-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-013-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/profile' >> $FILENAME 2>&1
cat /etc/profile >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/profile"' >> $FILENAME 2>&1
NUMPER "/etc/profile" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [053/175] : [SV-UNI-013-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-015-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/motd' >> $FILENAME 2>&1
cat /etc/motd >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/motd"' >> $FILENAME 2>&1
NUMPER "/etc/motd" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [057/175] : [SV-UNI-015-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-015-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/issue.net' >> $FILENAME 2>&1
cat /etc/issue.net >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/issue.net"' >> $FILENAME 2>&1
NUMPER "/etc/issue.net" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [058/175] : [SV-UNI-015-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-015-03] >> $FILENAME 2>&1
echo 'CMD : cat /etc/issue' >> $FILENAME 2>&1
cat /etc/issue >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/issue"' >> $FILENAME 2>&1
NUMPER "/etc/issue" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [059/175] : [SV-UNI-015-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-017-01] >> $FILENAME 2>&1
echo 'CMD : -' >> $FILENAME 2>&1
- >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [061/175] : [SV-UNI-017-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-018-01] >> $FILENAME 2>&1
echo 'CMD : cat ~/.rhosts' >> $FILENAME 2>&1
cat ~/.rhosts >> $FILENAME 2>&1
echo 'CMD : NUMPER ~/.rhosts' >> $FILENAME 2>&1
NUMPER ~/.rhosts >> $FILENAME 2>&1
echo 'CMD : cat /etc/hosts.equiv' >> $FILENAME 2>&1
cat /etc/hosts.equiv >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/hosts.equiv"' >> $FILENAME 2>&1
NUMPER "/etc/hosts.equiv" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [062/175] : [SV-UNI-018-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo -, - >> $FILENAME 2>&1
echo 'CMD : # NUMPER "/dev"' >> $FILENAME 2>&1
# NUMPER "/dev" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [063/175] : -, -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-019-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/inetd.conf' >> $FILENAME 2>&1
cat /etc/inetd.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/inetd.conf"' >> $FILENAME 2>&1
NUMPER "/etc/inetd.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [064/175] : [SV-UNI-019-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-019-02] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/xinetd.conf"' >> $FILENAME 2>&1
NUMPER "/etc/xinetd.conf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/xinetd.conf' >> $FILENAME 2>&1
cat /etc/xinetd.conf >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [065/175] : [SV-UNI-019-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-020-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/hosts"' >> $FILENAME 2>&1
NUMPER "/etc/hosts" >> $FILENAME 2>&1
echo 'CMD : cat /etc/hosts' >> $FILENAME 2>&1
cat /etc/hosts >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [066/175] : [SV-UNI-020-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-021-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/passwd"' >> $FILENAME 2>&1
NUMPER "/etc/passwd" >> $FILENAME 2>&1
echo 'CMD : cat /etc/passwd' >> $FILENAME 2>&1
cat /etc/passwd >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [067/175] : [SV-UNI-021-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-022-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/services"' >> $FILENAME 2>&1
NUMPER "/etc/services" >> $FILENAME 2>&1
echo 'CMD : cat /etc/services' >> $FILENAME 2>&1
cat /etc/services >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [068/175] : [SV-UNI-022-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-023-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/shadow"' >> $FILENAME 2>&1
NUMPER "/etc/shadow" >> $FILENAME 2>&1
echo 'CMD : cat /etc/shadow' >> $FILENAME 2>&1
cat /etc/shadow >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [069/175] : [SV-UNI-023-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-023-02] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/security/passwd"' >> $FILENAME 2>&1
NUMPER "/etc/security/passwd" >> $FILENAME 2>&1
echo 'CMD : cat /etc/security/passwd' >> $FILENAME 2>&1
cat /etc/security/passwd >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [070/175] : [SV-UNI-023-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-023-03] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/tcb/files/auth"' >> $FILENAME 2>&1
NUMPER "/tcb/files/auth" >> $FILENAME 2>&1
echo 'CMD : cat /tcb/files/auth' >> $FILENAME 2>&1
cat /tcb/files/auth >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [071/175] : [SV-UNI-023-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-024-01], [SV-UNI-061-01], [SV-UNI-061-04] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/syslog.conf"' >> $FILENAME 2>&1
NUMPER "/etc/syslog.conf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/syslog.conf' >> $FILENAME 2>&1
cat /etc/syslog.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/rsyslog.conf"' >> $FILENAME 2>&1
NUMPER "/etc/rsyslog.conf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/rsyslog.conf' >> $FILENAME 2>&1
cat /etc/rsyslog.conf >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [072/175] : [SV-UNI-024-01], [SV-UNI-061-01], [SV-UNI-061-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-025-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/at.allow"' >> $FILENAME 2>&1
NUMPER "/etc/at.allow" >> $FILENAME 2>&1
echo 'CMD : cat /etc/at.allow' >> $FILENAME 2>&1
cat /etc/at.allow >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [073/175] : [SV-UNI-025-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-025-02] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/at.deny"' >> $FILENAME 2>&1
NUMPER "/etc/at.deny" >> $FILENAME 2>&1
echo 'CMD : cat /etc/at.deny' >> $FILENAME 2>&1
cat /etc/at.deny >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [074/175] : [SV-UNI-025-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-025-03] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/cron.d/at.allow"' >> $FILENAME 2>&1
NUMPER "/etc/cron.d/at.allow" >> $FILENAME 2>&1
echo 'CMD : cat /etc/cron.d/at.allow' >> $FILENAME 2>&1
cat /etc/cron.d/at.allow >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [075/175] : [SV-UNI-025-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-025-04] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/cron.d/at.deny"' >> $FILENAME 2>&1
NUMPER "/etc/cron.d/at.deny" >> $FILENAME 2>&1
echo 'CMD : cat /etc/cron.d/at.deny' >> $FILENAME 2>&1
cat /etc/cron.d/at.deny >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [076/175] : [SV-UNI-025-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-025-05] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/adm/cron/at.allow"' >> $FILENAME 2>&1
NUMPER "/var/adm/cron/at.allow" >> $FILENAME 2>&1
echo 'CMD : cat /var/adm/cron/at.allow' >> $FILENAME 2>&1
cat /var/adm/cron/at.allow >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [077/175] : [SV-UNI-025-05]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-025-06] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/adm/cron/at.deny"' >> $FILENAME 2>&1
NUMPER "/var/adm/cron/at.deny" >> $FILENAME 2>&1
echo 'CMD : cat /var/adm/cron/at.deny' >> $FILENAME 2>&1
cat /var/adm/cron/at.deny >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [078/175] : [SV-UNI-025-06]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-025-07] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/usr/bin/at"' >> $FILENAME 2>&1
NUMPER "/usr/bin/at" >> $FILENAME 2>&1
echo 'CMD : cat /usr/bin/at' >> $FILENAME 2>&1
cat /usr/bin/at >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [079/175] : [SV-UNI-025-07]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-026-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/crontab"' >> $FILENAME 2>&1
NUMPER "/etc/crontab" >> $FILENAME 2>&1
echo 'CMD : cat /etc/crontab' >> $FILENAME 2>&1
cat /etc/crontab >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [080/175] : [SV-UNI-026-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-026-02] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/cron.*"' >> $FILENAME 2>&1
NUMPER "/etc/cron.*" >> $FILENAME 2>&1
echo 'CMD : cat /etc/cron.*' >> $FILENAME 2>&1
cat /etc/cron.* >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [081/175] : [SV-UNI-026-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-026-03] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/adm/cron/crontab"' >> $FILENAME 2>&1
NUMPER "/var/adm/cron/crontab" >> $FILENAME 2>&1
echo 'CMD : cat /var/adm/cron/crontab' >> $FILENAME 2>&1
cat /var/adm/cron/crontab >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/adm/cron/cron.*"' >> $FILENAME 2>&1
NUMPER "/var/adm/cron/cron.*" >> $FILENAME 2>&1
echo 'CMD : cat /var/adm/cron/cron.*' >> $FILENAME 2>&1
cat /var/adm/cron/cron.* >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [082/175] : [SV-UNI-026-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-027-01] >> $FILENAME 2>&1
echo 'CMD : for file in $SERVICEDIR2; do NUMPER "$file"; done' >> $FILENAME 2>&1
for file in $SERVICEDIR2; do NUMPER "$file"; done >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [083/175] : [SV-UNI-027-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-027-02] >> $FILENAME 2>&1
echo 'CMD : for file in $SERVICEDIR2; do cat "$file"; done' >> $FILENAME 2>&1
for file in $SERVICEDIR2; do cat "$file"; done >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [084/175] : [SV-UNI-027-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-028-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/hosts.lpd"' >> $FILENAME 2>&1
NUMPER "/etc/hosts.lpd" >> $FILENAME 2>&1
echo 'CMD : cat /etc/hosts.lpd' >> $FILENAME 2>&1
cat /etc/hosts.lpd >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [085/175] : [SV-UNI-028-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-029-01] >> $FILENAME 2>&1
echo 'CMD : env' >> $FILENAME 2>&1
env >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [086/175] : [SV-UNI-029-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo 'CMD : NUMPER "/usr -xdev -user root -type f -perm -02000" "perm"' >> $FILENAME 2>&1
NUMPER "/usr -xdev -user root -type f -perm -02000" "perm" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/usr -xdev -user root -type f -perm -04000" "perm"find /usr -xdev -user root -type f \( -perm -04000 -o -perm -02000 \) -exec ls -al  {}  \;' >> $FILENAME 2>&1
NUMPER "/usr -xdev -user root -type f -perm -04000" "perm"find /usr -xdev -user root -type f \( -perm -04000 -o -perm -02000 \) -exec ls -al  {}  \; >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [087/175] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo 'CMD : NUMPER "/sbin -xdev -user root -type f -perm -02000" "perm"' >> $FILENAME 2>&1
NUMPER "/sbin -xdev -user root -type f -perm -02000" "perm" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/sbin -xdev -user root -type f -perm -04000" "perm"find /sbin -xdev -user root -type f \( -perm -04000 -o -perm -02000 \) -exec ls -al  {}  \;' >> $FILENAME 2>&1
NUMPER "/sbin -xdev -user root -type f -perm -04000" "perm"find /sbin -xdev -user root -type f \( -perm -04000 -o -perm -02000 \) -exec ls -al  {}  \; >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [088/175] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-030-01] >> $FILENAME 2>&1
echo 'CMD : umask' >> $FILENAME 2>&1
umask >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [089/175] : [SV-UNI-030-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo 'CMD : NUMPER "/usr -xdev -user root -type f -perm -02000" "perm"' >> $FILENAME 2>&1
NUMPER "/usr -xdev -user root -type f -perm -02000" "perm" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/usr -xdev -user root -type f -perm -04000" "perm"' >> $FILENAME 2>&1
NUMPER "/usr -xdev -user root -type f -perm -04000" "perm" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [090/175] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo 'CMD : NUMPER "/sbin -xdev -user root -type f -perm -02000" "perm"' >> $FILENAME 2>&1
NUMPER "/sbin -xdev -user root -type f -perm -02000" "perm" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/sbin -xdev -user root -type f -perm -04000" "perm"' >> $FILENAME 2>&1
NUMPER "/sbin -xdev -user root -type f -perm -04000" "perm" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [091/175] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-031-01] >> $FILENAME 2>&1
echo 'CMD : for search in $SYSTEMFILESEARCH; do NUMPER "/$search"; done' >> $FILENAME 2>&1
for search in $SYSTEMFILESEARCH; do NUMPER "/$search"; done >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [093/175] : [SV-UNI-031-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-031-02] >> $FILENAME 2>&1
echo 'CMD : for dir in $HOMEDIRS; do for search in $SYSTEMFILESEARCH; do NUMPER "$dir/$search"; done; done' >> $FILENAME 2>&1
for dir in $HOMEDIRS; do for search in $SYSTEMFILESEARCH; do NUMPER "$dir/$search"; done; done >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [094/175] : [SV-UNI-031-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo 'CMD : NUMPER "/tmp" ".*"' >> $FILENAME 2>&1
NUMPER "/tmp" ".*" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/home" ".*"' >> $FILENAME 2>&1
NUMPER "/home" ".*" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/usr" ".*"' >> $FILENAME 2>&1
NUMPER "/usr" ".*" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var" ".*" ' >> $FILENAME 2>&1
NUMPER "/var" ".*"  >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [095/175] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-032-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/hosts.allow' >> $FILENAME 2>&1
cat /etc/hosts.allow >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/hosts.allow"' >> $FILENAME 2>&1
NUMPER "/etc/hosts.allow" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [096/175] : [SV-UNI-032-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-032-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/hosts.deny' >> $FILENAME 2>&1
cat /etc/hosts.deny >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/hosts.deny"' >> $FILENAME 2>&1
NUMPER "/etc/hosts.deny" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [097/175] : [SV-UNI-032-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-032-03] >> $FILENAME 2>&1
echo 'CMD : cat /var/adm/inetd.sec' >> $FILENAME 2>&1
cat /var/adm/inetd.sec >> $FILENAME 2>&1
echo 'CMD : NUMPER "/var/adm/inetd.sec"' >> $FILENAME 2>&1
NUMPER "/var/adm/inetd.sec" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [098/175] : [SV-UNI-032-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-033-02], [SV-UNI-033-03] >> $FILENAME 2>&1
echo 'CMD : NUMPER " / -xdev -nouser" "perm"' >> $FILENAME 2>&1
NUMPER " / -xdev -nouser" "perm" >> $FILENAME 2>&1
echo 'CMD : NUMPER " / -xdev -nogroup" "perm"' >> $FILENAME 2>&1
NUMPER " / -xdev -nogroup" "perm" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [099/175] : [SV-UNI-033-02], [SV-UNI-033-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-034-01], [SV-UNI-035-02] >> $FILENAME 2>&1
echo 'CMD : for dir in $HOMEDIRS; do NUMPER "$dir -maxdepth 1" "perm"; done' >> $FILENAME 2>&1
for dir in $HOMEDIRS; do NUMPER "$dir -maxdepth 1" "perm"; done >> $FILENAME 2>&1
echo 'CMD : for dir in $HOMEDIRS2; do NUMPER "$dir -maxdepth 1" "perm"; done' >> $FILENAME 2>&1
for dir in $HOMEDIRS2; do NUMPER "$dir -maxdepth 1" "perm"; done >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [101/175] : [SV-UNI-034-01], [SV-UNI-035-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-036-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/passwd' >> $FILENAME 2>&1
cat /etc/passwd >> $FILENAME 2>&1
echo 'CMD : for file2 in $SERVICEDIR2; do cat $file; done' >> $FILENAME 2>&1
for file2 in $SERVICEDIR2; do cat $file; done >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/passwd"' >> $FILENAME 2>&1
NUMPER "/etc/passwd" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [104/175] : [SV-UNI-036-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-037-01], [SV-UNI-037-02], [SV-UNI-046-01], [SV-UNI-046-02], [SV-UNI-046-03], [SV-UNI-049-01], [SV-UNI-049-02], [SV-UNI-049-03], [SV-UNI-049-04], [SV-UNI-049-05], [SV-UNI-051-01] >> $FILENAME 2>&1
echo 'CMD : ps -ef' >> $FILENAME 2>&1
ps -ef >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [105/175] : [SV-UNI-037-01], [SV-UNI-037-02], [SV-UNI-046-01], [SV-UNI-046-02], [SV-UNI-046-03], [SV-UNI-049-01], [SV-UNI-049-02], [SV-UNI-049-03], [SV-UNI-049-04], [SV-UNI-049-05], [SV-UNI-051-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-037-03], [SV-UNI-038-03], [SV-UNI-049-07] >> $FILENAME 2>&1
echo 'CMD : svcs -a' >> $FILENAME 2>&1
svcs -a >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [107/175] : [SV-UNI-037-03], [SV-UNI-038-03], [SV-UNI-049-07]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-038-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/named.conf' >> $FILENAME 2>&1
cat /etc/named.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/named.conf"' >> $FILENAME 2>&1
NUMPER "/etc/named.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [108/175] : [SV-UNI-038-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-038-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/named.boot' >> $FILENAME 2>&1
cat /etc/named.boot >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/named.boot"' >> $FILENAME 2>&1
NUMPER "/etc/named.boot" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [109/175] : [SV-UNI-038-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-039-01] >> $FILENAME 2>&1
echo 'CMD : named -v' >> $FILENAME 2>&1
named -v >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [111/175] : [SV-UNI-039-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-040-01], [SV-UNI-040-02], [SV-UNI-040-03], [SV-UNI-040-04], [SV-UNI-043-01], [SV-UNI-044-01], [SV-UNI-050-01], [SV-UNI-050-02], [SV-UNI-050-03], [SV-UNI-053-01], [SV-UNI-056-01], [SV-UNI-056-02], [SV-UNI-056-03] >> $FILENAME 2>&1
echo 'CMD : netstat -nap' >> $FILENAME 2>&1
netstat -nap >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [112/175] : [SV-UNI-040-01], [SV-UNI-040-02], [SV-UNI-040-03], [SV-UNI-040-04], [SV-UNI-043-01], [SV-UNI-044-01], [SV-UNI-050-01], [SV-UNI-050-02], [SV-UNI-050-03], [SV-UNI-053-01], [SV-UNI-056-01], [SV-UNI-056-02], [SV-UNI-056-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-040-05], [SV-UNI-042-02], [SV-UNI-046-04], [SV-UNI-050-04], [SV-UNI-051-02], [SV-UNI-056-04], [SV-UNI-056-05] >> $FILENAME 2>&1
echo 'CMD : inetadm' >> $FILENAME 2>&1
inetadm >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [116/175] : [SV-UNI-040-05], [SV-UNI-042-02], [SV-UNI-046-04], [SV-UNI-050-04], [SV-UNI-051-02], [SV-UNI-056-04], [SV-UNI-056-05]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-041-01], [SV-UNI-052-01], [SV-UNI-058-01], [SV-UNI-059-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/sendmail.cf' >> $FILENAME 2>&1
cat /etc/sendmail.cf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/sendmail.cf"' >> $FILENAME 2>&1
NUMPER "/etc/sendmail.cf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/mail/sendmail.cf' >> $FILENAME 2>&1
cat /etc/mail/sendmail.cf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/mail/sendmail.cf"' >> $FILENAME 2>&1
NUMPER "/etc/mail/sendmail.cf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/postfix/master.cf' >> $FILENAME 2>&1
cat /etc/postfix/master.cf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/postfix/master.cf"' >> $FILENAME 2>&1
NUMPER "/etc/postfix/master.cf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [117/175] : [SV-UNI-041-01], [SV-UNI-052-01], [SV-UNI-058-01], [SV-UNI-059-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-042-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/inetd.conf' >> $FILENAME 2>&1
cat /etc/inetd.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/inetd.conf"' >> $FILENAME 2>&1
NUMPER "/etc/inetd.conf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/xinetd.conf' >> $FILENAME 2>&1
cat /etc/xinetd.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/xinetd.conf"' >> $FILENAME 2>&1
NUMPER "/etc/xinetd.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [118/175] : [SV-UNI-042-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-042-03] >> $FILENAME 2>&1
echo 'CMD : cat /etc/xinetd.d/finger' >> $FILENAME 2>&1
cat /etc/xinetd.d/finger >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/xinetd.d/finger"' >> $FILENAME 2>&1
NUMPER "/etc/xinetd.d/finger" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [120/175] : [SV-UNI-042-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-045-01] >> $FILENAME 2>&1
echo 'CMD : for file2 in $SERVICEDIR2; do cat $file; done' >> $FILENAME 2>&1
for file2 in $SERVICEDIR2; do cat $file; done >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [124/175] : [SV-UNI-045-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-047-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/exports"' >> $FILENAME 2>&1
NUMPER "/etc/exports" >> $FILENAME 2>&1
echo 'CMD : cat /etc/exports' >> $FILENAME 2>&1
cat /etc/exports >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [129/175] : [SV-UNI-047-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-047-02] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/dfs/dfstab"' >> $FILENAME 2>&1
NUMPER "/etc/dfs/dfstab" >> $FILENAME 2>&1
echo 'CMD : cat /etc/dfs/dfstab' >> $FILENAME 2>&1
cat /etc/dfs/dfstab >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [130/175] : [SV-UNI-047-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-048-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/exports' >> $FILENAME 2>&1
cat /etc/exports >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/exports"' >> $FILENAME 2>&1
NUMPER "/etc/exports" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [131/175] : [SV-UNI-048-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-048-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/dfs/dfstab' >> $FILENAME 2>&1
cat /etc/dfs/dfstab >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/dfs/dfstab"' >> $FILENAME 2>&1
NUMPER "/etc/dfs/dfstab" >> $FILENAME 2>&1
echo 'CMD : cat /etc/dfs/sharetab' >> $FILENAME 2>&1
cat /etc/dfs/sharetab >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/dfs/sharetab"' >> $FILENAME 2>&1
NUMPER "/etc/dfs/sharetab" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [132/175] : [SV-UNI-048-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-049-06] >> $FILENAME 2>&1
echo 'CMD : ps -ef ' >> $FILENAME 2>&1
ps -ef  >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [138/175] : [SV-UNI-049-06]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-054-01], [SV-UNI-054-08] >> $FILENAME 2>&1
echo 'CMD : cat /etc/snmpd.conf' >> $FILENAME 2>&1
cat /etc/snmpd.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/snmpd.conf"' >> $FILENAME 2>&1
NUMPER "/etc/snmpd.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [148/175] : [SV-UNI-054-01], [SV-UNI-054-08]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-054-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/snmp/snmpd.conf' >> $FILENAME 2>&1
cat /etc/snmp/snmpd.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/snmp/snmpd.conf"' >> $FILENAME 2>&1
NUMPER "/etc/snmp/snmpd.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [149/175] : [SV-UNI-054-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-054-03], [SV-UNI-054-05] >> $FILENAME 2>&1
echo 'CMD : cat /etc/snmp/conf/snmpd.conf' >> $FILENAME 2>&1
cat /etc/snmp/conf/snmpd.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/snmp/conf/snmpd.conf"' >> $FILENAME 2>&1
NUMPER "/etc/snmp/conf/snmpd.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [150/175] : [SV-UNI-054-03], [SV-UNI-054-05]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-054-04] >> $FILENAME 2>&1
echo 'CMD : cat /SI/CM/config/snmp/snmpd.conf' >> $FILENAME 2>&1
cat /SI/CM/config/snmp/snmpd.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/SI/CM/config/snmp/snmpd.conf"' >> $FILENAME 2>&1
NUMPER "/SI/CM/config/snmp/snmpd.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [151/175] : [SV-UNI-054-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-054-06] >> $FILENAME 2>&1
echo 'CMD : cat /etc/sma/snmp/snmpd.conf' >> $FILENAME 2>&1
cat /etc/sma/snmp/snmpd.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/sma/snmp/snmpd.conf"' >> $FILENAME 2>&1
NUMPER "/etc/sma/snmp/snmpd.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [153/175] : [SV-UNI-054-06]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-054-07] >> $FILENAME 2>&1
echo 'CMD : cat /etc/snmpdv3.conf' >> $FILENAME 2>&1
cat /etc/snmpdv3.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/snmpdv3.conf"' >> $FILENAME 2>&1
NUMPER "/etc/snmpdv3.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [154/175] : [SV-UNI-054-07]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-055-01] >> $FILENAME 2>&1
echo 'CMD : ps -ef' >> $FILENAME 2>&1
ps -ef >> $FILENAME 2>&1
echo 'CMD : netstat -nap' >> $FILENAME 2>&1
netstat -nap >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [156/175] : [SV-UNI-055-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-055-02] >> $FILENAME 2>&1
echo 'CMD : ls -al /home/ec2-user/.ssh' >> $FILENAME 2>&1
ls -al /home/ec2-user/.ssh >> $FILENAME 2>&1
echo 'CMD : ls -al /home/ubuntu/.ssh' >> $FILENAME 2>&1
ls -al /home/ubuntu/.ssh >> $FILENAME 2>&1
echo 'CMD : ls -al /home/centos/.ssh' >> $FILENAME 2>&1
ls -al /home/centos/.ssh >> $FILENAME 2>&1
echo 'CMD : ls -al /home/rocky/.ssh' >> $FILENAME 2>&1
ls -al /home/rocky/.ssh >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [157/175] : [SV-UNI-055-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-057-01] >> $FILENAME 2>&1
echo 'CMD : rpm -qa' >> $FILENAME 2>&1
rpm -qa >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [163/175] : [SV-UNI-057-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-060-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/ntp.conf' >> $FILENAME 2>&1
cat /etc/ntp.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/ntp.conf"' >> $FILENAME 2>&1
NUMPER "/etc/ntp.conf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/chrony.conf' >> $FILENAME 2>&1
cat /etc/chrony.conf >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [166/175] : [SV-UNI-060-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-060-02] >> $FILENAME 2>&1
echo 'CMD : ntpq -p' >> $FILENAME 2>&1
ntpq -p >> $FILENAME 2>&1
echo 'CMD : chronyc sources -v' >> $FILENAME 2>&1
chronyc sources -v >> $FILENAME 2>&1
echo 'CMD : timedatectl' >> $FILENAME 2>&1
timedatectl >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [167/175] : [SV-UNI-060-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-061-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/rsyslog.conf/50-default.conf' >> $FILENAME 2>&1
cat /etc/rsyslog.conf/50-default.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/rsyslog.conf/50-default.conf"' >> $FILENAME 2>&1
NUMPER "/etc/rsyslog.conf/50-default.conf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/rsyslog.d/50-default.conf' >> $FILENAME 2>&1
cat /etc/rsyslog.d/50-default.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/rsyslog.d/50-default.conf"' >> $FILENAME 2>&1
NUMPER "/etc/rsyslog.d/50-default.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [169/175] : [SV-UNI-061-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-061-03] >> $FILENAME 2>&1
echo 'CMD : cat /etc/rsyslog.conf/20-ufw.conf' >> $FILENAME 2>&1
cat /etc/rsyslog.conf/20-ufw.conf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/rsyslog.conf/20-ufw.conf"' >> $FILENAME 2>&1
NUMPER "/etc/rsyslog.conf/20-ufw.conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [170/175] : [SV-UNI-061-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-062-01] >> $FILENAME 2>&1
echo 'CMD : lsb_release -a' >> $FILENAME 2>&1
lsb_release -a >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [172/175] : [SV-UNI-062-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-062-02] >> $FILENAME 2>&1
echo 'CMD : showrev -p' >> $FILENAME 2>&1
showrev -p >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [173/175] : [SV-UNI-062-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-062-03] >> $FILENAME 2>&1
echo 'CMD : osleve -s' >> $FILENAME 2>&1
osleve -s >> $FILENAME 2>&1
echo 'CMD : instfix -i | grep ML' >> $FILENAME 2>&1
instfix -i | grep ML >> $FILENAME 2>&1
echo 'CMD : instfix -i | grep SP' >> $FILENAME 2>&1
instfix -i | grep SP >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [174/175] : [SV-UNI-062-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-062-04] >> $FILENAME 2>&1
echo 'CMD : swlist -l product' >> $FILENAME 2>&1
swlist -l product >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [175/175] : [SV-UNI-062-04]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_APACHE_HTTP_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-APA-001-01], [SV-UNI-WEB-APA-002-01], [SV-UNI-WEB-APA-002-02], [SV-UNI-WEB-APA-003-01], [SV-UNI-WEB-APA-004-01], [SV-UNI-WEB-APA-004-02], [SV-UNI-WEB-APA-006-01], [SV-UNI-WEB-APA-008-01], [SV-UNI-WEB-APA-009-01], [SV-UNI-WEB-APA-010-01] >> $FILENAME 2>&1
echo 'CMD : cat $HTTP_CONF' >> $FILENAME 2>&1
cat $HTTP_CONF >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/14] : [SV-UNI-WEB-APA-001-01], [SV-UNI-WEB-APA-002-01], [SV-UNI-WEB-APA-002-02], [SV-UNI-WEB-APA-003-01], [SV-UNI-WEB-APA-004-01], [SV-UNI-WEB-APA-004-02], [SV-UNI-WEB-APA-006-01], [SV-UNI-WEB-APA-008-01], [SV-UNI-WEB-APA-009-01], [SV-UNI-WEB-APA-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-APA-005-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$HTTP_DIR/docs/manual"' >> $FILENAME 2>&1
NUMPER "$HTTP_DIR/docs/manual" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$HTTP_DIR/htdocs/manual"' >> $FILENAME 2>&1
NUMPER "$HTTP_DIR/htdocs/manual" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$HTTP_DIR/manual"' >> $FILENAME 2>&1
NUMPER "$HTTP_DIR/manual" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [07/14] : [SV-UNI-WEB-APA-005-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-APA-007-01], [SV-UNI-WEB-APA-007-02] >> $FILENAME 2>&1
echo 'CMD : cat $HTTP_CONF' >> $FILENAME 2>&1
cat $HTTP_CONF >> $FILENAME 2>&1
echo 'CMD : cat $HTTP_CONF2' >> $FILENAME 2>&1
cat $HTTP_CONF2 >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [09/14] : [SV-UNI-WEB-APA-007-01], [SV-UNI-WEB-APA-007-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-APA-011-01] >> $FILENAME 2>&1
echo 'CMD : httpd -v' >> $FILENAME 2>&1
httpd -v >> $FILENAME 2>&1
echo 'CMD : apache2 -v' >> $FILENAME 2>&1
apache2 -v >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [14/14] : [SV-UNI-WEB-APA-011-01]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_NGINX_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-NGX-001-01] >> $FILENAME 2>&1
echo 'CMD : cat $NGINX_CONF' >> $FILENAME 2>&1
cat $NGINX_CONF >> $FILENAME 2>&1
echo 'CMD : NUMPER "$NGINX_DIR2/*.conf" "perm"' >> $FILENAME 2>&1
NUMPER "$NGINX_DIR2/*.conf" "perm" >> $FILENAME 2>&1
echo 'CMD : find $NGINX_DIR2 -type f -name '*.conf' -exec cat {} \;' >> $FILENAME 2>&1
find $NGINX_DIR2 -type f -name '*.conf' -exec cat {} \; >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/10] : [SV-UNI-WEB-NGX-001-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-NGX-002-01], [SV-UNI-WEB-NGX-003-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$NGINX_DIR"' >> $FILENAME 2>&1
NUMPER "$NGINX_DIR" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [02/10] : [SV-UNI-WEB-NGX-002-01], [SV-UNI-WEB-NGX-003-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-NGX-004-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$NGINX_DIR/log"' >> $FILENAME 2>&1
NUMPER "$NGINX_DIR/log" >> $FILENAME 2>&1
echo 'CMD : NUMPER /var/log/nginx' >> $FILENAME 2>&1
NUMPER /var/log/nginx >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [04/10] : [SV-UNI-WEB-NGX-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-NGX-005-01], [SV-UNI-WEB-NGX-006-01], [SV-UNI-WEB-NGX-007-01], [SV-UNI-WEB-NGX-007-02], [SV-UNI-WEB-NGX-008-01] >> $FILENAME 2>&1
echo 'CMD : cat $NGINX_CONF' >> $FILENAME 2>&1
cat $NGINX_CONF >> $FILENAME 2>&1
echo 'CMD : NUMPER "$NGINX_DIR2/*.conf" "perm" ' >> $FILENAME 2>&1
NUMPER "$NGINX_DIR2/*.conf" "perm"  >> $FILENAME 2>&1
echo 'CMD : find $NGINX_DIR2 -type f -name '*.conf' -exec cat {} \;' >> $FILENAME 2>&1
find $NGINX_DIR2 -type f -name '*.conf' -exec cat {} \; >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [05/10] : [SV-UNI-WEB-NGX-005-01], [SV-UNI-WEB-NGX-006-01], [SV-UNI-WEB-NGX-007-01], [SV-UNI-WEB-NGX-007-02], [SV-UNI-WEB-NGX-008-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-NGX-009-01] >> $FILENAME 2>&1
echo 'CMD : nginx -v' >> $FILENAME 2>&1
nginx -v >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [10/10] : [SV-UNI-WEB-NGX-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_APACHE_TOMCAT_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-001-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$TOMCAT_DIR/webapps/admin.xml"' >> $FILENAME 2>&1
NUMPER "$TOMCAT_DIR/webapps/admin.xml" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$TOMCAT_DIR/webapps/manager.xml"' >> $FILENAME 2>&1
NUMPER "$TOMCAT_DIR/webapps/manager.xml" >> $FILENAME 2>&1
echo 'CMD : cat "$TOMCAT_DIR/webapps/admin.xml"' >> $FILENAME 2>&1
cat "$TOMCAT_DIR/webapps/admin.xml" >> $FILENAME 2>&1
echo 'CMD : cat "$TOMCAT_DIR/webapps/manager.xml"' >> $FILENAME 2>&1
cat "$TOMCAT_DIR/webapps/manager.xml" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/17] : [SV-UNI-WEB-TOM-001-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-001-02] >> $FILENAME 2>&1
echo 'CMD : cat $TOMCAT_DIR/conf/server.xml' >> $FILENAME 2>&1
cat $TOMCAT_DIR/conf/server.xml >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [02/17] : [SV-UNI-WEB-TOM-001-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-002-01], [SV-UNI-WEB-TOM-003-01] >> $FILENAME 2>&1
echo 'CMD : cat $TOMCAT_DIR/conf/tomcat-users.xml' >> $FILENAME 2>&1
cat $TOMCAT_DIR/conf/tomcat-users.xml >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [03/17] : [SV-UNI-WEB-TOM-002-01], [SV-UNI-WEB-TOM-003-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-004-01] >> $FILENAME 2>&1
echo 'CMD : ps -ef | grep tomcat' >> $FILENAME 2>&1
ps -ef | grep tomcat >> $FILENAME 2>&1
echo 'CMD : ps aux | grep java' >> $FILENAME 2>&1
ps aux | grep java >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [05/17] : [SV-UNI-WEB-TOM-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-005-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$TOMCAT_DIR/conf/tomcat-users.xml"' >> $FILENAME 2>&1
NUMPER "$TOMCAT_DIR/conf/tomcat-users.xml" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [06/17] : [SV-UNI-WEB-TOM-005-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-006-01] >> $FILENAME 2>&1
echo 'CMD : ls -ld "$TOMCAT_DIR/webapps"' >> $FILENAME 2>&1
ls -ld "$TOMCAT_DIR/webapps" >> $FILENAME 2>&1
echo 'CMD : ls -ld "$TOMCAT_DIR/server/webapps"' >> $FILENAME 2>&1
ls -ld "$TOMCAT_DIR/server/webapps" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [07/17] : [SV-UNI-WEB-TOM-006-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-007-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$TOMCAT_DIR/conf"' >> $FILENAME 2>&1
NUMPER "$TOMCAT_DIR/conf" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [08/17] : [SV-UNI-WEB-TOM-007-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-008-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$TOMCAT_DIR/logs"' >> $FILENAME 2>&1
NUMPER "$TOMCAT_DIR/logs" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [09/17] : [SV-UNI-WEB-TOM-008-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-009-01], [SV-UNI-WEB-TOM-010-01] >> $FILENAME 2>&1
echo 'CMD : cat $TOMCAT_DIR/conf/web.xml' >> $FILENAME 2>&1
cat $TOMCAT_DIR/conf/web.xml >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [10/17] : [SV-UNI-WEB-TOM-009-01], [SV-UNI-WEB-TOM-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-011-01] >> $FILENAME 2>&1
echo 'CMD : ls -ld "$TOMCAT_DIR/webapps/examples"' >> $FILENAME 2>&1
ls -ld "$TOMCAT_DIR/webapps/examples" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [12/17] : [SV-UNI-WEB-TOM-011-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-012-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
echo 'CMD : grep -Ei password|PW $TOMCAT_DIR/logs/catalina.out' >> $FILENAME 2>&1
grep -Ei 'password|PW' $TOMCAT_DIR/logs/catalina.out >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [13/17] : [SV-UNI-WEB-TOM-012-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-012-02] >> $FILENAME 2>&1
echo 'CMD : cat $TOMCAT_DIR/logs/catalina.out | tail -n 300' >> $FILENAME 2>&1
cat $TOMCAT_DIR/logs/catalina.out | tail -n 300 >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [14/17] : [SV-UNI-WEB-TOM-012-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-012-03] >> $FILENAME 2>&1
echo 'CMD : grep -Eirn "password|pw" $TOMCAT_DIR/logs' >> $FILENAME 2>&1
grep -Eirn "password|pw" $TOMCAT_DIR/logs >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [15/17] : [SV-UNI-WEB-TOM-012-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-013-01] >> $FILENAME 2>&1
echo 'CMD : sh $TOMCAT_DIR/bin/version.sh' >> $FILENAME 2>&1
sh $TOMCAT_DIR/bin/version.sh >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [16/17] : [SV-UNI-WEB-TOM-013-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-WEB-TOM-013-02] >> $FILENAME 2>&1
echo 'CMD : java -cp "$TOMCAT_DIR/lib/catalina.jar" org.apache.catalina.util.ServerInfo' >> $FILENAME 2>&1
java -cp "$TOMCAT_DIR/lib/catalina.jar" org.apache.catalina.util.ServerInfo >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [17/17] : [SV-UNI-WEB-TOM-013-02]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_WEBTOB_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WTB-001-01] >> $FILENAME 2>&1
echo 'CMD : ps -ef' >> $FILENAME 2>&1
ps -ef >> $FILENAME 2>&1
echo 'CMD : cat "$WEBTOB_CONF/config/http.m"' >> $FILENAME 2>&1
cat "$WEBTOB_CONF/config/http.m" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF/config/http.m"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF/config/http.m" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/10] : [WEB-WTB-001-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WTB-002-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF/docs"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF/docs" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [02/10] : [WEB-WTB-002-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WTB-003-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF/config/http.m"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF/config/http.m" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF/docs"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF/docs" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [03/10] : [WEB-WTB-003-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WTB-004-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF/log"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF/log" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [04/10] : [WEB-WTB-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WTB-005-01], [WEB-WTB-007-01], [WEB-WTB-008-01] >> $FILENAME 2>&1
echo 'CMD : cat "$WEBTOB_CONF/config/http.m"' >> $FILENAME 2>&1
cat "$WEBTOB_CONF/config/http.m" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF/config/http.m"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF/config/http.m" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [05/10] : [WEB-WTB-005-01], [WEB-WTB-007-01], [WEB-WTB-008-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WTB-006-01] >> $FILENAME 2>&1
echo 'CMD : cat "$WEBTOB_CONF/config/http.m"' >> $FILENAME 2>&1
cat "$WEBTOB_CONF/config/http.m" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF/config/http.m"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF/config/http.m" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF/docs"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF/docs" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [06/10] : [WEB-WTB-006-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WTB-009-01] >> $FILENAME 2>&1
echo 'CMD : cat $WEBTOB_CONF' >> $FILENAME 2>&1
cat $WEBTOB_CONF >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [09/10] : [WEB-WTB-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WTB-010-01] >> $FILENAME 2>&1
echo 'CMD : wsadmin' >> $FILENAME 2>&1
wsadmin >> $FILENAME 2>&1
echo 'CMD : wscfl -version' >> $FILENAME 2>&1
wscfl -version >> $FILENAME 2>&1
echo 'CMD : wl' >> $FILENAME 2>&1
wl >> $FILENAME 2>&1
echo 'CMD : $WEBTOB_CONF/bin/wscfl -v' >> $FILENAME 2>&1
$WEBTOB_CONF/bin/wscfl -v >> $FILENAME 2>&1
echo 'CMD : cat "$WEBTOB_CONF/version.txt"' >> $FILENAME 2>&1
cat "$WEBTOB_CONF/version.txt" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [10/10] : [WEB-WTB-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_JEUS_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-JEU-001-01] >> $FILENAME 2>&1
echo 'CMD : ps -ef | grep jeus' >> $FILENAME 2>&1
ps -ef | grep jeus >> $FILENAME 2>&1
echo 'CMD : cat "$JEUS_CONF/config/domain.xml"' >> $FILENAME 2>&1
cat "$JEUS_CONF/config/domain.xml" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$JEUS_CONF/config/domain.xml"' >> $FILENAME 2>&1
NUMPER "$JEUS_CONF/config/domain.xml" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/11] : [WEB-JEU-001-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-JEU-002-01], [WEB-JEU-003-01], [WEB-JEU-004-01] >> $FILENAME 2>&1
echo 'CMD : cat "$JEUS_CONF/config/security/SYSTEM_DOMAIN/accounts.xml"' >> $FILENAME 2>&1
cat "$JEUS_CONF/config/security/SYSTEM_DOMAIN/accounts.xml" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$JEUS_CONF/config/security/SYSTEM_DOMAIN/accounts.xml"' >> $FILENAME 2>&1
NUMPER "$JEUS_CONF/config/security/SYSTEM_DOMAIN/accounts.xml" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [02/11] : [WEB-JEU-002-01], [WEB-JEU-003-01], [WEB-JEU-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-JEU-005-01] >> $FILENAME 2>&1
echo 'CMD : cat "$JEUS_CONF"' >> $FILENAME 2>&1
cat "$JEUS_CONF" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBTOB_CONF"' >> $FILENAME 2>&1
NUMPER "$WEBTOB_CONF" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [05/11] : [WEB-JEU-005-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-JEU-006-01], [WEB-JEU-008-01] >> $FILENAME 2>&1
echo 'CMD : cat "$JEUS_CONF/config/domain.xml"' >> $FILENAME 2>&1
cat "$JEUS_CONF/config/domain.xml" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$JEUS_CONF/config/domain.xml"' >> $FILENAME 2>&1
NUMPER "$JEUS_CONF/config/domain.xml" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [06/11] : [WEB-JEU-006-01], [WEB-JEU-008-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-JEU-007-01] >> $FILENAME 2>&1
echo 'CMD : cat "$JEUS_CONF/log"' >> $FILENAME 2>&1
cat "$JEUS_CONF/log" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$JEUS_CONF/log"' >> $FILENAME 2>&1
NUMPER "$JEUS_CONF/log" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [07/11] : [WEB-JEU-007-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo - >> $FILENAME 2>&1
echo CMD Null >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [08/11] : -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-JEU-009-01] >> $FILENAME 2>&1
echo 'CMD : cat "$JEUS_CONF"' >> $FILENAME 2>&1
cat "$JEUS_CONF" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$JEUS_CONF"' >> $FILENAME 2>&1
NUMPER "$JEUS_CONF" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [10/11] : [WEB-JEU-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-JEU-010-01] >> $FILENAME 2>&1
echo 'CMD : jeusadmin -version' >> $FILENAME 2>&1
jeusadmin -version >> $FILENAME 2>&1
echo 'CMD : jeusadmin -fullversion' >> $FILENAME 2>&1
jeusadmin -fullversion >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [11/11] : [WEB-JEU-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_WEBSPHERE_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-001-01] >> $FILENAME 2>&1
echo 'CMD : ps -ef | grep java' >> $FILENAME 2>&1
ps -ef | grep java >> $FILENAME 2>&1
echo 'CMD : ps -ef | grep WebSphere' >> $FILENAME 2>&1
ps -ef | grep WebSphere >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/13] : [WEB-WSP-001-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-002-01], [WEB-WSP-007-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
echo "find $WEBSPHERE_DIR/profiles -path */templates -prune -o -path */config/cells/*/serverindex.xml -exec sh -c 'ls -alL {}; cat {}; echo' \;" >> $FILENAME 2>&1
find $WEBSPHERE_DIR/profiles -path "*/templates" -prune -o -path "*/config/cells/*/serverindex.xml" -exec sh -c 'ls -alL {}; cat {}; echo' \; >> $FILENAME 2>&1
echo "find $WEBSPHERE_DIR/profiles \( -name templates -type d -prune \) -o \( -name serverindex.xml -path */config/cells/* -exec sh -c 'ls -alL {}; cat {}; echo' \; \)" >> $FILENAME 2>&1
find $WEBSPHERE_DIR/profiles \( -name "templates" -type d -prune \) -o \( -name "serverindex.xml" -path "*/config/cells/*" -exec sh -c 'ls -alL {}; cat {}; echo' \; \) >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [02/13] : [WEB-WSP-002-01], [WEB-WSP-007-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-002-02] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
echo "find $WEBSPHERE_DIR/profiles -path */templates -prune -o -path */config/cells/*/virtualhosts.xml -exec sh -c 'ls -alL {}; cat {}; echo' \;" >> $FILENAME 2>&1
find $WEBSPHERE_DIR/profiles -path "*/templates" -prune -o -path "*/config/cells/*/virtualhosts.xml" -exec sh -c 'ls -alL {}; cat {}; echo' \; >> $FILENAME 2>&1
echo "find $WEBSPHERE_DIR/profiles \( -name templates -type d -prune \) -o \( -name virtualhosts.xml -path */config/cells/* -exec sh -c 'ls -alL {}; cat {}; echo' \; \)" >> $FILENAME 2>&1
find $WEBSPHERE_DIR/profiles \( -name "templates" -type d -prune \) -o \( -name "virtualhosts.xml" -path "*/config/cells/*" -exec sh -c 'ls -alL {}; cat {}; echo' \; \) >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [03/13] : [WEB-WSP-002-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-003-01] >> $FILENAME 2>&1
echo 'CMD : -' >> $FILENAME 2>&1
- >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [04/13] : [WEB-WSP-003-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-004-01] >> $FILENAME 2>&1
echo 'CMD : ls -alL "$WEBSPHERE_DIR"' >> $FILENAME 2>&1
ls -alL "$WEBSPHERE_DIR" >> $FILENAME 2>&1
echo 'CMD : ls -alL "$WEBSPHERE_DIR/profiles"' >> $FILENAME 2>&1
ls -alL "$WEBSPHERE_DIR/profiles" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [05/13] : [WEB-WSP-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-005-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
echo "find $WEBSPHERE_DIR -name security.xml -exec sh -c 'ls -alL {}; cat {}; echo' \;" >> $FILENAME 2>&1
find $WEBSPHERE_DIR -name "security.xml" -exec sh -c 'ls -alL {}; cat {}; echo' \; >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [06/13] : [WEB-WSP-005-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-006-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
echo "find $WEBSPHERE_DIR -name ibm-web-ext.xml -exec sh -c 'ls -alL {}; cat {}; echo' \;" >> $FILENAME 2>&1
find $WEBSPHERE_DIR -name "ibm-web-ext.xml" -exec sh -c 'ls -alL {}; cat {}; echo' \; >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [07/13] : [WEB-WSP-006-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-007-02] >> $FILENAME 2>&1
echo 'CMD : find $WEBSPHERE_DIR/profiles/*/config/cells/ -maxdepth 2 -type f -exec ls -alL {} \;' >> $FILENAME 2>&1
find $WEBSPHERE_DIR/profiles/*/config/cells/ -maxdepth 2 -type f -exec ls -alL {} \; >> $FILENAME 2>&1
echo 'CMD : ls -l $WEBSPHERE_DIR/profiles/*/config/cells/* | grep -v '^d'' >> $FILENAME 2>&1
ls -l $WEBSPHERE_DIR/profiles/*/config/cells/* | grep -v '^d' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [09/13] : [WEB-WSP-007-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-008-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBSPHERE_DIR/logs"' >> $FILENAME 2>&1
NUMPER "$WEBSPHERE_DIR/logs" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBSPHERE_DIR/profiles/*/logs"' >> $FILENAME 2>&1
NUMPER "$WEBSPHERE_DIR/profiles/*/logs" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [10/13] : [WEB-WSP-008-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-009-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
echo "find $WEBSPHERE_DIR -name ibm-web-ext.xml -exec sh -c 'ls -alL {}; cat {}; echo' \;" >> $FILENAME 2>&1
find $WEBSPHERE_DIR -name "ibm-web-ext.xml" -exec sh -c 'ls -alL {}; cat {}; echo' \; >> $FILENAME 2>&1
echo "find $WEBSPHERE_DIR/profiles/*/installedApps/*/*/*.war/WEB-INF -name web.xml -exec sh -c 'ls -alL {}; cat {}; echo' \;" >> $FILENAME 2>&1
find $WEBSPHERE_DIR/profiles/*/installedApps/*/*/*.war/WEB-INF -name web.xml -exec sh -c 'ls -alL {}; cat {}; echo' \; >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [11/13] : [WEB-WSP-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-010-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBSPHERE_DIR/samples/"' >> $FILENAME 2>&1
NUMPER "$WEBSPHERE_DIR/samples/" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$WEBSPHERE_DIR/profiles/*/installedApps/*/sample.ear"' >> $FILENAME 2>&1
NUMPER "$WEBSPHERE_DIR/profiles/*/installedApps/*/sample.ear" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [12/13] : [WEB-WSP-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [WEB-WSP-011-01] >> $FILENAME 2>&1
echo 'CMD : cat $WEBSPHERE_DIR/properties/version/WAS.product' >> $FILENAME 2>&1
cat $WEBSPHERE_DIR/properties/version/WAS.product >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [13/13] : [WEB-WSP-011-01]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_MYSQL_DB_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-001-01], [SV-UNI-DB-MYS-014-02], [SV-UNI-DB-MAR-014-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.user;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/70] : [SV-UNI-DB-MYS-001-01], [SV-UNI-DB-MYS-014-02], [SV-UNI-DB-MAR-014-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-002-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.user where user!='root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.user where user!='root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [02/70] : [SV-UNI-DB-MYS-002-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-003-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string from mysql.user where user='root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string from mysql.user where user='root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [03/70] : [SV-UNI-DB-MYS-003-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-004-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT user, failed_login_attempts FROM mysql.user"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT user, failed_login_attempts FROM mysql.user" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [04/70] : [SV-UNI-DB-MYS-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-004-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, user_attributes FROM mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, user_attributes FROM mysql.user;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [05/70] : [SV-UNI-DB-MYS-004-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo -, - >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE '%lifetime';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE '%lifetime';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [06/70] : -, -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-005-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE '%password%';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE '%password%';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [07/70] : [SV-UNI-DB-MYS-005-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-005-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE 'password_history';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE 'password_history';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [08/70] : [SV-UNI-DB-MYS-005-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-006-01], [SV-UNI-DB-MAR-006-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW plugins;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW plugins;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [09/70] : [SV-UNI-DB-MYS-006-01], [SV-UNI-DB-MAR-006-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-007-01], [SV-UNI-DB-MAR-007-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW global variables like '%password%';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW global variables like '%password%';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [10/70] : [SV-UNI-DB-MYS-007-01], [SV-UNI-DB-MAR-007-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-007-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string, password_expired, password_last_changed, password_lifetime, account_locked from mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string, password_expired, password_last_changed, password_lifetime, account_locked from mysql.user;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [11/70] : [SV-UNI-DB-MYS-007-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-007-03] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, password, password_last_changed FROM mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, password, password_last_changed FROM mysql.user;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [12/70] : [SV-UNI-DB-MYS-007-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-007-04] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, password_expired FROM mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, password_expired FROM mysql.user;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [13/70] : [SV-UNI-DB-MYS-007-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-007-05] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW PLUGINS LIKE 'validate_password';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW PLUGINS LIKE 'validate_password';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [14/70] : [SV-UNI-DB-MYS-007-05]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-007-06] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE 'valid%';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE 'valid%';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [15/70] : [SV-UNI-DB-MYS-007-06]

echo ==================================================================================================== >> $FILENAME 2>&1

echo -, [SV-UNI-DB-MYS-013-01], -, -, -, [SV-UNI-DB-MAR-013-01], - >> $FILENAME 2>&1
echo 'CMD : -' >> $FILENAME 2>&1
- >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [16/70] : -, [SV-UNI-DB-MYS-013-01], -, -, -, [SV-UNI-DB-MAR-013-01], -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-008-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,delete_priv from mysql.user where user<>'root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,delete_priv from mysql.user where user<>'root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [17/70] : [SV-UNI-DB-MYS-008-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-008-02], [SV-UNI-DB-MAR-008-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, db, select_priv from mysql.db where (db='mysql' and select_priv='Y') and user<>'root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, db, select_priv from mysql.db where (db='mysql' and select_priv='Y') and user<>'root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [18/70] : [SV-UNI-DB-MYS-008-02], [SV-UNI-DB-MAR-008-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-008-03], [SV-UNI-DB-MAR-008-03] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT DB,USER,TABLE_NAME, TABLE_PRIV from mysql.tables_priv where (db='mysql' and table_name='user') and table_priv='select';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT DB,USER,TABLE_NAME, TABLE_PRIV from mysql.tables_priv where (db='mysql' and table_name='user') and table_priv='select';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [19/70] : [SV-UNI-DB-MYS-008-03], [SV-UNI-DB-MAR-008-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-009-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT user,grant_priv FROM mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT user,grant_priv FROM mysql.user;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [20/70] : [SV-UNI-DB-MYS-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-009-02], [SV-UNI-DB-MAR-009-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT user,grant_priv FROM mysql.db;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT user,grant_priv FROM mysql.db;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [21/70] : [SV-UNI-DB-MYS-009-02], [SV-UNI-DB-MAR-009-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-010-01], - >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,Delete_priv from mysql.user where (select_priv='Y' or insert_priv='Y' or delete_priv='Y') and user<>'root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,Delete_priv from mysql.user where (select_priv='Y' or insert_priv='Y' or delete_priv='Y') and user<>'root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [22/70] : [SV-UNI-DB-MYS-010-01], -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-010-02], [SV-UNI-DB-MAR-010-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,Delete_priv from mysql.db where (select_priv='Y' or insert_priv='Y' or delete_priv='Y') and user<>'root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,Delete_priv from mysql.db where (select_priv='Y' or insert_priv='Y' or delete_priv='Y') and user<>'root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [23/70] : [SV-UNI-DB-MYS-010-02], [SV-UNI-DB-MAR-010-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-011-01], [SV-UNI-DB-MAR-011-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$MYSQL_CONF"' >> $FILENAME 2>&1
NUMPER "$MYSQL_CONF" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/my.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/my.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/my.cnf' >> $FILENAME 2>&1
cat /etc/my.cnf >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [24/70] : [SV-UNI-DB-MYS-011-01], [SV-UNI-DB-MAR-011-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-011-02] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$MYSQL_CONF"' >> $FILENAME 2>&1
NUMPER "$MYSQL_CONF" >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/mysql/my.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/mysql/my.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/mysql/my.cnf' >> $FILENAME 2>&1
cat /etc/mysql/my.cnf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/mysql/mysql.conf.d/mysql.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/mysql/mysql.conf.d/mysql.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/mysql/mysql.conf.d/mysql.cnf' >> $FILENAME 2>&1
cat /etc/mysql/mysql.conf.d/mysql.cnf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/mysql/mysql.conf.d/mysqld.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/mysql/mysql.conf.d/mysqld.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/mysql/mysql.conf.d/mysqld.cnf' >> $FILENAME 2>&1
cat /etc/mysql/mysql.conf.d/mysqld.cnf >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [25/70] : [SV-UNI-DB-MYS-011-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-012-01], [SV-UNI-DB-MAR-012-01] >> $FILENAME 2>&1
echo 'CMD : umask' >> $FILENAME 2>&1
umask >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [26/70] : [SV-UNI-DB-MYS-012-01], [SV-UNI-DB-MAR-012-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-014-01], [SV-UNI-DB-MAR-014-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, db from mysql.db;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, db from mysql.db;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [28/70] : [SV-UNI-DB-MYS-014-01], [SV-UNI-DB-MAR-014-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo -, - >> $FILENAME 2>&1
echo 'CMD : ntpq -p' >> $FILENAME 2>&1
ntpq -p >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [32/70] : -, -

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MYS-015-01], [SV-UNI-DB-MYS-016-01], [SV-UNI-DB-MAR-015-01], [SV-UNI-DB-MAR-016-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT version();"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT version();" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [33/70] : [SV-UNI-DB-MYS-015-01], [SV-UNI-DB-MYS-016-01], [SV-UNI-DB-MAR-015-01], [SV-UNI-DB-MAR-016-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-001-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.user;" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.global_priv;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.global_priv;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [35/70] : [SV-UNI-DB-MAR-001-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-002-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.user where user!='root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.user where user!='root';" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.global_priv where user!='root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user from mysql.global_priv where user!='root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [36/70] : [SV-UNI-DB-MAR-002-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-003-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string from mysql.user where user='root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string from mysql.user where user='root';" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, priv from mysql.global_priv where user='root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, priv from mysql.global_priv where user='root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [37/70] : [SV-UNI-DB-MAR-003-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-004-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE 'max_password_errors';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE 'max_password_errors';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [38/70] : [SV-UNI-DB-MAR-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-005-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE '%history';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW VARIABLES LIKE '%history';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [40/70] : [SV-UNI-DB-MAR-005-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-005-02], [SV-UNI-DB-MAR-006-03] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW PLUGINS LIKE 'password_reuse_check';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW PLUGINS LIKE 'password_reuse_check';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [41/70] : [SV-UNI-DB-MAR-005-02], [SV-UNI-DB-MAR-006-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-006-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW PLUGINS LIKE 'simple_password_check';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW PLUGINS LIKE 'simple_password_check';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [43/70] : [SV-UNI-DB-MAR-006-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-006-04] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SHOW PLUGINS LIKE 'Cracklib Password Check Plugin';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SHOW PLUGINS LIKE 'Cracklib Password Check Plugin';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [45/70] : [SV-UNI-DB-MAR-006-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-007-02] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string, password_expired, password_last_changed, password_lifetime, account_locked from mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string, password_expired, password_last_changed, password_lifetime, account_locked from mysql.user;" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string, password_expired, password_last_changed, password_lifetime, account_locked from mysql.global_priv;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, authentication_string, password_expired, password_last_changed, password_lifetime, account_locked from mysql.global_priv;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [47/70] : [SV-UNI-DB-MAR-007-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-007-03] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, password, password_last_changed FROM mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, password, password_last_changed FROM mysql.user;" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, password, password_last_changed FROM mysql.global_priv;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, password, password_last_changed FROM mysql.global_priv;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [48/70] : [SV-UNI-DB-MAR-007-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-007-04] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, password_expired FROM mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, password_expired FROM mysql.user;" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user, password_expired FROM mysql.global_priv;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user, password_expired FROM mysql.global_priv;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [49/70] : [SV-UNI-DB-MAR-007-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-008-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv from mysql.user where select_priv='Y' and user<>'root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv from mysql.user where select_priv='Y' and user<>'root';" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv from mysql.global_priv where select_priv='Y' and user<>'root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv from mysql.global_priv where select_priv='Y' and user<>'root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [51/70] : [SV-UNI-DB-MAR-008-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-009-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT user,grant_priv FROM mysql.user;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT user,grant_priv FROM mysql.user;" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT user,grant_priv FROM mysql.global_priv;"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT user,grant_priv FROM mysql.global_priv;" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [54/70] : [SV-UNI-DB-MAR-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-010-01] >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,Delete_priv from mysql.user where (select_priv='Y' or insert_priv='Y' or delete_priv='Y') and user<>'root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,Delete_priv from mysql.user where (select_priv='Y' or insert_priv='Y' or delete_priv='Y') and user<>'root';" >> $FILENAME 2>&1
echo 'CMD : $MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,Delete_priv from mysql.global_priv where (select_priv='Y' or insert_priv='Y' or delete_priv='Y') and user<>'root';"' >> $FILENAME 2>&1
$MYSQL_MARIADB_LOGIN -e "SELECT host, user,select_priv,insert_priv,Delete_priv from mysql.global_priv where (select_priv='Y' or insert_priv='Y' or delete_priv='Y') and user<>'root';" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [56/70] : [SV-UNI-DB-MAR-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-011-02] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/my.cnf.d/server.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/my.cnf.d/server.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/my.cnf.d/server.cnf' >> $FILENAME 2>&1
cat /etc/my.cnf.d/server.cnf >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [59/70] : [SV-UNI-DB-MAR-011-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-011-03] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/mysql/my.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/mysql/my.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/mysql/my.cnf' >> $FILENAME 2>&1
cat /etc/mysql/my.cnf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/mysql/mariadb.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/mysql/mariadb.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/mysql/mariadb.cnf' >> $FILENAME 2>&1
cat /etc/mysql/mariadb.cnf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/mysql/mariadb.conf.d/50-client.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/mysql/mariadb.conf.d/50-client.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/mysql/mariadb.conf.d/50-client.cnf' >> $FILENAME 2>&1
cat /etc/mysql/mariadb.conf.d/50-client.cnf >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/mysql/mariadb.conf.d/50-server.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/mysql/mariadb.conf.d/50-server.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/mysql/mariadb.conf.d/50-server.cnf' >> $FILENAME 2>&1
cat /etc/mysql/mariadb.conf.d/50-server.cnf >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [60/70] : [SV-UNI-DB-MAR-011-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-MAR-011-04] >> $FILENAME 2>&1
echo 'CMD : NUMPER "/etc/my.cnf.d/mariadb-server.cnf"' >> $FILENAME 2>&1
NUMPER "/etc/my.cnf.d/mariadb-server.cnf" >> $FILENAME 2>&1
echo 'CMD : cat /etc/my.cnf.d/mariadb-server.cnf' >> $FILENAME 2>&1
cat /etc/my.cnf.d/mariadb-server.cnf >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [61/70] : [SV-UNI-DB-MAR-011-04]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_ORACLE_DB_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-001-01], [SV-UNI-DB-ORA-002-01], [SV-UNI-DB-ORA-003-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
set pagesize 5000
col username format a20
col password format a20
col account_status format a20
SELECT username, password, account_status FROM dba_users;
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/27] : [SV-UNI-DB-ORA-001-01], [SV-UNI-DB-ORA-002-01], [SV-UNI-DB-ORA-003-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-004-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
set pagesize 5000
col username format a25
col profile format a25
col resource_name format a25
col limit format a25
select DU.username, DP.profile, DP.resource_name, DP.limit from dba_users DU INNER JOIN dba_profiles DP ON DP.profile = DU.profile where DU.account_status = 'OPEN' and DP.resource_name in ('FAILED_LOGIN_ATTEMPTS','PASSWORD_LOCK_TIME');
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [04/27] : [SV-UNI-DB-ORA-004-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-005-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
set pagesize 5000
col username format a25
col profile format a25
col resource_name format a25
col limit format a25
select DU.username, DP.profile, DP.resource_name, DP.limit from dba_users DU INNER JOIN dba_profiles DP ON DP.profile = DU.profile where DU.account_status = 'OPEN' and DP.resource_name in ('PASSWORD_REUSE_TIME','PASSWORD_REUSE_MAX');
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [05/27] : [SV-UNI-DB-ORA-005-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-006-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
set pagesize 5000
col username format a25
col profile format a25
col resource_name format a25
col limit format a25
select A.username, B.profile, B.resource_name, B.limit from dba_users A,dba_profiles B where A.profile = B.profile and B.resource_name = 'PASSWORD_VERIFY_FUNCTION' and A.account_status ='OPEN';
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [06/27] : [SV-UNI-DB-ORA-006-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-007-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
set pagesize 5000
col username format a25
col profile format a25
col resource_name format a25
col limit format a25
select DU.username, DP.profile, DP.resource_name, DP.limit from dba_users DU INNER JOIN dba_profiles DP ON DP.profile = DU.profile where DU.account_status = 'OPEN' and DP.resource_name in ('PASSWORD_LIFE_TIME' ,'PASSWORD_GRACE_TIME');
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [07/27] : [SV-UNI-DB-ORA-007-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-008-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
set pagesize 5000
col table_name format a25
col owner format a25
select table_name, owner from dba_tables where table_name='AUD$';
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [08/27] : [SV-UNI-DB-ORA-008-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-009-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
set pagesize 5000
col grantee format a20
col owner format a10
col table_name format a20
col privilege format a20
select grantee, privilege, owner, table_name from dba_tab_privs where (owner='SYS' or table_name like 'DBA_%') and privilege <> 'EXECUTE' and grantee not in ('PUBLIC', 'AQ_ADMINISTRATOR_ROLE', 'AQ_USER_ROLE', 'AURORA$JIS$UTILITY$', 'OSE$HTTP$ADMIN', 'TRACESVR', 'CTXSYS', 'DBA', 'DELETE_CATALOG_ROLE', 'EXECUTE_CATALOG_ROLE', 'EXP_FULL_DATABASE', 'GATHER_SYSTEM_STATISTICS', 'HS_ADMIN_ROLE', 'IMP_FULL_DATABASE', 'LOGSTDBY_ADMINISTRATOR', 'MDSYS','ODM', 'OEM_MONITOR', 'OLAPSYS', 'ORDSYS', 'OUTLN', 'RECOVERY_CATALOG_OWNER', 'SELECT_CATALOG_ROLE', 'SNMPAGENT', 'SYSTEM', 'WKSYS', 'WKUSER', 'WMSYS', 'WM_ADMIN_ROLE', 'XDB', 'LBACSYS', 'PERFSTAT', 'XDBADMIN') and grantee not in (select grantee from dba_role_privs where granted_role='DBA') order by grantee;
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [09/27] : [SV-UNI-DB-ORA-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-010-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
Select grantee||':'||owner||'.'||table_name from dba_tab_privs where grantable='YES' and owner not in ('SYS','MDSYS','ORDPLUGINS','ORDSYS','SYSTEM', 'WMSYS','SDB','LBACSYS') and grantee not in (select grantee from dba_role_privs where granted_role='DBA') order by grantee;
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [10/27] : [SV-UNI-DB-ORA-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-011-01], [SV-UNI-DB-ORA-011-02], [SV-UNI-DB-ORA-011-03] >> $FILENAME 2>&1
echo 'CMD : cat $ORACLE_DIR_DBS/init*.ora' >> $FILENAME 2>&1
cat $ORACLE_DIR_DBS/init*.ora >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [11/27] : [SV-UNI-DB-ORA-011-01], [SV-UNI-DB-ORA-011-02], [SV-UNI-DB-ORA-011-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-012-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$ORACLE_DIR_NETWORK/admin/listener.ora"' >> $FILENAME 2>&1
NUMPER "$ORACLE_DIR_NETWORK/admin/listener.ora" >> $FILENAME 2>&1
echo 'CMD : cat $ORACLE_DIR_NETWORK/admin/listener.ora' >> $FILENAME 2>&1
cat $ORACLE_DIR_NETWORK/admin/listener.ora >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [14/27] : [SV-UNI-DB-ORA-012-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-013-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
col USERNAME format a15
col sysdba format a15
col grantee format a15
col privilege format a15
SELECT USERNAME, sysdba FROM v\$PWFILE_USERS;
select grantee, privilege from dba_sys_privs where grantee not in ( 'SYS', 'SYSTEM', 'AQ_ADMINISTRATOR_ROLE', 'DBA ' ,'MDSYS' , 'LBACSYS', 'SCHEDULER_ADMIN', 'WMSYS') and admin_option='YES' and grantee not in (select grantee from dba_role_privs where granted_role='DBA');
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [15/27] : [SV-UNI-DB-ORA-013-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-014-01] >> $FILENAME 2>&1
echo 'CMD : NUMPER "$ORACLE_DIR -maxdepth 1" "perm"' >> $FILENAME 2>&1
NUMPER "$ORACLE_DIR -maxdepth 1" "perm" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$ORACLE_DIR/bin"' >> $FILENAME 2>&1
NUMPER "$ORACLE_DIR/bin" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$ORACLE_DIR/lib"' >> $FILENAME 2>&1
NUMPER "$ORACLE_DIR/lib" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$ORACLE_DIR/bin/oracle"' >> $FILENAME 2>&1
NUMPER "$ORACLE_DIR/bin/oracle" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$ORACLE_DIR_NETWORK"' >> $FILENAME 2>&1
NUMPER "$ORACLE_DIR_NETWORK" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$ORACLE_DIR_NETWORK/admin"' >> $FILENAME 2>&1
NUMPER "$ORACLE_DIR_NETWORK/admin" >> $FILENAME 2>&1
echo 'CMD : NUMPER "$ORACLE_DIR_DBS"' >> $FILENAME 2>&1
NUMPER "$ORACLE_DIR_DBS" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [16/27] : [SV-UNI-DB-ORA-014-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-014-02] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
select value from v\$parameter where name='spfile';
Select 'Control Files: '||value from v\$parameter where name='control_files';
select 'Control Files: '||value from v\$parameter where name='spfile';
select 'Logfile: '||member from v\$logfile;
select 'Datafile: '||name from v\$datafile;
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [17/27] : [SV-UNI-DB-ORA-014-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-015-01] >> $FILENAME 2>&1
echo 'CMD : su - oracle -c "umask"' >> $FILENAME 2>&1
su - oracle -c "umask" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [18/27] : [SV-UNI-DB-ORA-015-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-016-01] >> $FILENAME 2>&1
echo 'CMD : cat $ORACLE_DIR_NETWORK/admin/listener.ora' >> $FILENAME 2>&1
cat $ORACLE_DIR_NETWORK/admin/listener.ora >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [19/27] : [SV-UNI-DB-ORA-016-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-017-01] >> $FILENAME 2>&1
echo 'CMD : -' >> $FILENAME 2>&1
- >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [20/27] : [SV-UNI-DB-ORA-017-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-018-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
col name format a20
col value format a20
select name, value FROM v\$parameter WHERE name='remote_os_authent';
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [21/27] : [SV-UNI-DB-ORA-018-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-019-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
select grantee,granted_role from dba_role_privs where grantee='PUBLIC';
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [22/27] : [SV-UNI-DB-ORA-019-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-020-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
select distinct owner from dba_objects;
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [23/27] : [SV-UNI-DB-ORA-020-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-021-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
col name format a20
col value format a20
SELECT name, value FROM v\$parameter WHERE name='audit_trail';
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [24/27] : [SV-UNI-DB-ORA-021-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-022-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
col name format a20
col value format a20
select name, value from v\$parameter where name='resource_limit';
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [25/27] : [SV-UNI-DB-ORA-022-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [SV-UNI-DB-ORA-023-01], [SV-UNI-DB-ORA-024-01] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
su - "${ORACLE_MANAGE_ID}" -c "sqlplus $ORACLE_LOGIN" << EOF >> $FILENAME 2>&1
select banner from v\$version where banner like 'Oracle%';
exit
EOF
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [26/27] : [SV-UNI-DB-ORA-023-01], [SV-UNI-DB-ORA-024-01]

echo ==================================================================================================== >> $FILENAME 2>&1

}

VS_DOCKER_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-001-01] >> $FILENAME 2>&1
echo 'CMD : docker version' >> $FILENAME 2>&1
docker version >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [01/69] : [DCK-001-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-002-01] >> $FILENAME 2>&1
echo 'CMD : cat /etc/group' >> $FILENAME 2>&1
cat /etc/group >> $FILENAME 2>&1
echo 'CMD : ls -l /etc/group' >> $FILENAME 2>&1
ls -l /etc/group >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [02/69] : [DCK-002-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-003-01], [DCK-004-01], [DCK-005-01], [DCK-007-02] >> $FILENAME 2>&1
echo 'CMD : auditctl -l' >> $FILENAME 2>&1
auditctl -l >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [03/69] : [DCK-003-01], [DCK-004-01], [DCK-005-01], [DCK-007-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-003-02], [DCK-004-02], [DCK-005-02], [DCK-006-02], [DCK-007-03], [DCK-008-01], [DCK-008-02] >> $FILENAME 2>&1
echo 'CMD : ls -l /etc/audit/audit.rules' >> $FILENAME 2>&1
ls -l /etc/audit/audit.rules >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [04/69] : [DCK-003-02], [DCK-004-02], [DCK-005-02], [DCK-006-02], [DCK-007-03], [DCK-008-01], [DCK-008-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-006-01] >> $FILENAME 2>&1
echo 'CMD : ls -l /lib/systemd/system/docker.service' >> $FILENAME 2>&1
ls -l /lib/systemd/system/docker.service >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [09/69] : [DCK-006-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-007-01] >> $FILENAME 2>&1
echo 'CMD : systemctl show -p FragmentPath docker.socket' >> $FILENAME 2>&1
systemctl show -p FragmentPath docker.socket >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [11/69] : [DCK-007-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-009-01] >> $FILENAME 2>&1
echo 'CMD : docker network ls --quiet | xargs docker network inspect --format "{{ .Name}}: {{ .Options }}"' >> $FILENAME 2>&1
docker network ls --quiet | xargs docker network inspect --format "{{ .Name}}: {{ .Options }}" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [16/69] : [DCK-009-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-009-02], [DCK-010-02], [DCK-011-02] >> $FILENAME 2>&1
echo 'CMD : cat /etc/default/docker' >> $FILENAME 2>&1
cat /etc/default/docker >> $FILENAME 2>&1
echo 'CMD : ls -l /etc/default/docker' >> $FILENAME 2>&1
ls -l /etc/default/docker >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [17/69] : [DCK-009-02], [DCK-010-02], [DCK-011-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-009-03], [DCK-010-03], [DCK-011-03], [DCK-011-04] >> $FILENAME 2>&1
echo 'CMD : cat /lib/systemd/system/docker.service' >> $FILENAME 2>&1
cat /lib/systemd/system/docker.service >> $FILENAME 2>&1
echo 'CMD : ls -l /lib/systemd/system/docker.service' >> $FILENAME 2>&1
ls -l /lib/systemd/system/docker.service >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [18/69] : [DCK-009-03], [DCK-010-03], [DCK-011-03], [DCK-011-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-009-04], [DCK-010-04] >> $FILENAME 2>&1
echo 'CMD : cat /etc/docker/daemon.json' >> $FILENAME 2>&1
cat /etc/docker/daemon.json >> $FILENAME 2>&1
echo 'CMD : ls -l /etc/docker/daemon.json' >> $FILENAME 2>&1
ls -l /etc/docker/daemon.json >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [19/69] : [DCK-009-04], [DCK-010-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-010-01] >> $FILENAME 2>&1
echo 'CMD : docker search hello-world' >> $FILENAME 2>&1
docker search hello-world >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [20/69] : [DCK-010-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-011-01], [DCK-027-01] >> $FILENAME 2>&1
echo 'CMD : ps -ef' >> $FILENAME 2>&1
ps -ef >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [24/69] : [DCK-011-01], [DCK-027-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-012-01], [DCK-029-01] >> $FILENAME 2>&1
echo 'CMD : docker ps --quiet --all' >> $FILENAME 2>&1
docker ps --quiet --all >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [28/69] : [DCK-012-01], [DCK-029-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-012-02] >> $FILENAME 2>&1
echo 'CMD : docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}'' >> $FILENAME 2>&1
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [29/69] : [DCK-012-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-013-01], [DCK-014-01], [DCK-023-02] >> $FILENAME 2>&1
echo 'CMD : ls -l /lib/systemd/system/docker.service' >> $FILENAME 2>&1
ls -l /lib/systemd/system/docker.service >> $FILENAME 2>&1
echo 'CMD : cat /lib/systemd/system/docker.service' >> $FILENAME 2>&1
cat /lib/systemd/system/docker.service >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [30/69] : [DCK-013-01], [DCK-014-01], [DCK-023-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-013-02], [DCK-023-04] >> $FILENAME 2>&1
echo 'CMD : stat -c %U:%G /lib/systemd/system/docker.service' >> $FILENAME 2>&1
stat -c %U:%G /lib/systemd/system/docker.service >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [31/69] : [DCK-013-02], [DCK-023-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-014-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %a /lib/systemd/system/docker.service' >> $FILENAME 2>&1
stat -c %a /lib/systemd/system/docker.service >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [33/69] : [DCK-014-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-015-01] >> $FILENAME 2>&1
echo 'CMD : ls -l /lib/systemd/system/docker.socket' >> $FILENAME 2>&1
ls -l /lib/systemd/system/docker.socket >> $FILENAME 2>&1
echo 'CMD : cat /lib/systemd/system/docker.socket' >> $FILENAME 2>&1
cat /lib/systemd/system/docker.socket >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [34/69] : [DCK-015-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-015-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %U:%G /lib/systemd/system/docker.socket' >> $FILENAME 2>&1
stat -c %U:%G /lib/systemd/system/docker.socket >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [35/69] : [DCK-015-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-016-01] >> $FILENAME 2>&1
echo 'CMD : ls -l /lib/systemd/systemd/docker.socket' >> $FILENAME 2>&1
ls -l /lib/systemd/systemd/docker.socket >> $FILENAME 2>&1
echo 'CMD : cat /lib/systemd/systemd/docker.socket' >> $FILENAME 2>&1
cat /lib/systemd/systemd/docker.socket >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [36/69] : [DCK-016-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-016-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %a /lib/systemd/system/docker.socket' >> $FILENAME 2>&1
stat -c %a /lib/systemd/system/docker.socket >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [37/69] : [DCK-016-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-017-01], [DCK-018-01] >> $FILENAME 2>&1
echo 'CMD : ls -ld /etc/docker' >> $FILENAME 2>&1
ls -ld /etc/docker >> $FILENAME 2>&1
echo 'CMD : cat /etc/docker' >> $FILENAME 2>&1
cat /etc/docker >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [38/69] : [DCK-017-01], [DCK-018-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-017-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %U:%G /etc/docker' >> $FILENAME 2>&1
stat -c %U:%G /etc/docker >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [39/69] : [DCK-017-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-018-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %a /etc/docker' >> $FILENAME 2>&1
stat -c %a /etc/docker >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [41/69] : [DCK-018-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-019-01], [DCK-020-01] >> $FILENAME 2>&1
echo 'CMD : ls -l /var/run/docker.sock' >> $FILENAME 2>&1
ls -l /var/run/docker.sock >> $FILENAME 2>&1
echo 'CMD : cat /val/run/docker.sock' >> $FILENAME 2>&1
cat /val/run/docker.sock >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [42/69] : [DCK-019-01], [DCK-020-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-019-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %U:%G /var/run/docker.sock' >> $FILENAME 2>&1
stat -c %U:%G /var/run/docker.sock >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [43/69] : [DCK-019-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-020-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %a /var/run/docker.sock' >> $FILENAME 2>&1
stat -c %a /var/run/docker.sock >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [45/69] : [DCK-020-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-021-01], [DCK-022-01] >> $FILENAME 2>&1
echo 'CMD : ls -l /etc/docker/daemon.json' >> $FILENAME 2>&1
ls -l /etc/docker/daemon.json >> $FILENAME 2>&1
echo 'CMD : cat /etc/docker/daemon.json' >> $FILENAME 2>&1
cat /etc/docker/daemon.json >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [46/69] : [DCK-021-01], [DCK-022-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-021-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %U:%G /etc/docker/daemon.json' >> $FILENAME 2>&1
stat -c %U:%G /etc/docker/daemon.json >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [47/69] : [DCK-021-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-022-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %a /etc/docker/daemon.json' >> $FILENAME 2>&1
stat -c %a /etc/docker/daemon.json >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [49/69] : [DCK-022-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-023-01], [DCK-024-01] >> $FILENAME 2>&1
echo 'CMD : ls -l /etc/default/docker' >> $FILENAME 2>&1
ls -l /etc/default/docker >> $FILENAME 2>&1
echo 'CMD : cat /etc/default/docker' >> $FILENAME 2>&1
cat /etc/default/docker >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [50/69] : [DCK-023-01], [DCK-024-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-023-03] >> $FILENAME 2>&1
echo 'CMD : stat -c %U:%G /etc/default/docker' >> $FILENAME 2>&1
stat -c %U:%G /etc/default/docker >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [52/69] : [DCK-023-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-024-02] >> $FILENAME 2>&1
echo 'CMD : stat -c %a /etc/default/docker' >> $FILENAME 2>&1
stat -c %a /etc/default/docker >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [55/69] : [DCK-024-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-025-01] >> $FILENAME 2>&1
echo 'CMD : docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: User={{ .Config.User }}'' >> $FILENAME 2>&1
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: User={{ .Config.User }}' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [56/69] : [DCK-025-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-026-01] >> $FILENAME 2>&1
echo 'CMD : echo $DOCKER_CONTENT_TRUST' >> $FILENAME 2>&1
echo $DOCKER_CONTENT_TRUST >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [57/69] : [DCK-026-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-027-02] >> $FILENAME 2>&1
echo 'CMD : docker ps --quiet --all | xargs docker inspect --format "{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}"' >> $FILENAME 2>&1
docker ps --quiet --all | xargs docker inspect --format "{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}" >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [59/69] : [DCK-027-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-028-01] >> $FILENAME 2>&1
echo 'CMD : docker ps --quiet -a' >> $FILENAME 2>&1
docker ps --quiet -a >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [60/69] : [DCK-028-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-028-02] >> $FILENAME 2>&1
echo 'CMD : docker exec $INSTANCE_ID ps -el' >> $FILENAME 2>&1
docker exec $INSTANCE_ID ps -el >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [61/69] : [DCK-028-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-028-03] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
echo 'CMD : docker ps -q | xargs -I {} sh -c echo "Container ID: {}" && docker exec {} ps -el && echo "--------------------------------------"' >> $FILENAME 2>&1
docker ps -q | xargs -I {} sh -c 'echo "Container ID: {}" && docker exec {} ps -el && echo "--------------------------------------"' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [62/69] : [DCK-028-03]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-028-04] >> $FILENAME 2>&1
echo [DIRECT CMD] >> $FILENAME 2>&1
echo 'CMD : docker ps -q | xargs -I {} sh -c echo "Container ID: {}" && docker exec {} pgrep -fl sshd && echo "--------------------------------------"' >> $FILENAME 2>&1
docker ps -q | xargs -I {} sh -c 'echo "Container ID: {}" && docker exec {} pgrep -fl sshd && echo "--------------------------------------"' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [63/69] : [DCK-028-04]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-029-02] >> $FILENAME 2>&1
echo 'CMD : docker ps -a' >> $FILENAME 2>&1
docker ps -a >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [65/69] : [DCK-029-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-030-01] >> $FILENAME 2>&1
echo 'CMD : docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}:PidsLimit={{ .HostConfig.PidsLimit }}'' >> $FILENAME 2>&1
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}:PidsLimit={{ .HostConfig.PidsLimit }}' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [66/69] : [DCK-030-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-031-01] >> $FILENAME 2>&1
echo 'CMD : ifconfig' >> $FILENAME 2>&1
ifconfig >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [67/69] : [DCK-031-01]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-031-02] >> $FILENAME 2>&1
echo 'CMD : docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}'' >> $FILENAME 2>&1
docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [68/69] : [DCK-031-02]

echo ==================================================================================================== >> $FILENAME 2>&1

echo [DCK-032-01] >> $FILENAME 2>&1
echo 'CMD : docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}:UsernsMode ={{ .HostConfig.UsernsMode }}'' >> $FILENAME 2>&1
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}:UsernsMode ={{ .HostConfig.UsernsMode }}' >> $FILENAME 2>&1
echo [END] >> $FILENAME 2>&1
echo   COMPLETE [69/69] : [DCK-032-01]

echo ==================================================================================================== >> $FILENAME 2>&1

}


VS_COMMON_GOTO(){

echo ==================================================================================================== >> $FILENAME 2>&1

    echo [DIRECT CMD] >> $FILENAME 2>&1
    echo 'CMD : ifconfig' >> $FILENAME 2>&1
    ifconfig >> $FILENAME 2>&1

    echo ----------------------------------------------------- >> $FILENAME 2>&1

    echo "Check Internet Control : O(Connected), X(Disconnected)" >> $FILENAME 2>&1


    #. �߰�(���ɾ� ���� ���� Ȯ�� �Լ�)

    check_cmd_installed() {

        command -v "$1" >/dev/null 2>&1

    }


    check_url() {

        if [ -z "$1" ]; then

            return 1

        fi


        URL=$1

        echo "$URL" | grep -qE "^https?://" || URL="https://$URL"

        TIMEOUT=5


        if check_cmd_installed curl; then  # ? [�߰�] curl ���� �ÿ��� ����

            STATUS_CODE=$(curl --write-out "%{http_code}" --silent --output /dev/null --max-time $TIMEOUT "$URL")

            if [ "$STATUS_CODE" -eq 200 ]; then

                echo "[O] $URL (curl)" >> $FILENAME 2>&1

                echo "[O] $URL (curl)"

            else

                echo "[X] $URL - Status: $STATUS_CODE" >> $FILENAME 2>&1

                echo "[X] $URL - Status: $STATUS_CODE"

            fi

        else

            echo "[SKIP] $URL - curl not installed" >> $FILENAME 2>&1  # ? [�߰�]

            echo "[SKIP] $URL - curl not installed"

        fi

    }


    check_url2() {

        if [ -z "$1" ]; then

            return 1

        fi


        URL=$1

        echo "$URL" | grep -qE "^https?://" || URL="https://$URL"

        TIMEOUT=5


        if check_cmd_installed wget; then  # ? [�߰�] wget ���� �ÿ��� ����

            wget --spider --timeout=$TIMEOUT --tries=1 --no-check-certificate "$URL" > /dev/null 2>&1

            if [ $? -eq 0 ]; then

                echo "[O] $URL (wget)" >> $FILENAME 2>&1

                echo "[O] $URL (wget)"

            else

                echo "[X] $URL (wget)" >> $FILENAME 2>&1

                echo "[X] $URL (wget)"

            fi

        else

            echo "[SKIP] $URL - wget not installed" >> $FILENAME 2>&1  # ? [�߰�]

            echo "[SKIP] $URL - wget not installed"

        fi

    }


    #. ���� �� ���ͳ� üũ

    # check_url() {

    #     if [ -z "$1" ]; then

    #         return 1

    #     fi

    #     URL=$1

    #     echo "$URL" | grep -qE "^https?://"

    #     if [ $? -ne 0 ]; then

    #         URL="https://$URL"

    #     fi

    #     TIMEOUT=5

    #     STATUS_CODE=$(curl --write-out "%{http_code}" --silent --output /dev/null --max-time $TIMEOUT $URL)

    #     if [ "$STATUS_CODE" -eq 200 ]; then

    #         echo "[O] $URL" >> $FILENAME 2>&1

    #     else

    #         echo "[X] $URL - Status: $STATUS_CODE" >> $FILENAME 2>&1

    #     fi

    # }


    # check_url2() {

    #     if [ -z "$1" ]; then

    #         return 1

    #     fi

    #     URL=$1

    #     echo "$URL" | grep -qE "^https?://"

    #     if [ $? -ne 0 ]; then

    #         URL="https://$URL"

    #     fi

    #     TIMEOUT=5

    #     wget --spider --timeout=$TIMEOUT $URL > /dev/null 2>&1

    #     if [ $? -eq 0 ]; then

    #         echo "[O] $URL" >> $FILENAME 2>&1

    #     else

    #         echo "[X] $URL" >> $FILENAME 2>&1

    #     fi

    # }


    check_url "www.naver.com"

    check_url "www.google.com"

    check_url "www.daum.net"

    check_url "www.youtube.com"

    check_url "www.auction.co.kr"

    check_url "gall.dcinside.com"

    check_url "only.webhard.co.kr"

    check_url "www.yesfile.com"

    check_url "www.hangame.com"

    check_url "www.netmarble.net"


    check_url2 "www.naver.com"

    check_url2 "www.google.com"

    check_url2 "www.daum.net"

    check_url2 "www.youtube.com"

    check_url2 "www.auction.co.kr"

    check_url2 "gall.dcinside.com"

    check_url2 "only.webhard.co.kr"

    check_url2 "www.yesfile.com"

    check_url2 "www.hangame.com"

    check_url2 "www.netmarble.net"


}


if [ "${VS_START_CHECK}" = "y" ]; then

    echo

    echo

    echo "Configuration Check START!"

    echo

    VS_RESULT_FILE_PRINT

    SELECT_RUN_CMD

else

    echo "Script error. Please restart"

fi


echo
echo
echo   "ALL COMPLETE!"
echo
echo
echo   "SYSTEM Result File Location = $(pwd)"
echo   "SYSTEM Result File Name     = $FILENAME"
echo
echo
echo   "Thank you for your cooperation."
echo   "Press any key to exit. . ."
echo 
echo -n

