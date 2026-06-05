#!/bin/sh

LANG=C
export LANG
VER_info=20250203

# 스크립트 root권한 확인
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    echo "This script must be run as root" 1>&2
    echo "This script must be run as root" 1>&2
    echo "This script must be run as root" 1>&2
    echo "This script must be run as root" 1>&2
    echo "This script must be run as root" 1>&2
    echo "This script must be run as root" 1>&2
    echo "This script must be run as root" 1>&2
    echo "This script must be run as root" 1>&2
    exit 1
fi

#UNIX 계열 확인
AIX_CHECK_00=0
HP_CHECK_00=0
SOLARIS_CHECK_00=0
Linux_CHECK_00=0
SUSE_CHECK_00=0

if [ -f "value.sh" ]; then
    OS_CHECK_VALUE=$(cat ./value.sh | grep -i "OS_INFO=" | grep -v "#" | sed 's/OS_INFO=//g')
    case "$OS_CHECK_VALUE" in
        "Linux")
            Linux_CHECK_00=1
            ;;
        "Solaris")
            SOLARIS_CHECK_00=1
            ;;
        "AIX")
            AIX_CHECK_00=1
            ;;
        "HP-UX")
            HP_CHECK_00=1
            ;;
        "SUSE")
            SUSE_CHECK_00=1
            ;;
        *)
            echo "value.sh requires a value input." 1>&2
            echo "value.sh requires a value input." 1>&2
            echo "value.sh requires a value input." 1>&2
            echo "value.sh requires a value input." 1>&2
            echo "value.sh requires a value input." 1>&2
            echo "value.sh requires a value input." 1>&2
            echo "value.sh requires a value input." 1>&2
            echo "value.sh requires a value input." 1>&2
            echo "value.sh requires a value input." 1>&2
            exit 1
            ;;
    esac
else
    if command -v uname >/dev/null 2>&1; then
        if uname -a | egrep "solaris|SunOS" >/dev/null; then
            SOLARIS_CHECK_00=1
        elif uname -a | egrep "AIX" >/dev/null; then
            AIX_CHECK_00=1
        elif uname -a | egrep "HP-UX" >/dev/null; then
            HP_CHECK_00=1
        elif uname -a | egrep "suse" >/dev/null; then
            SUSE_CHECK_00=1
        else
            Linux_CHECK_00=1
        fi
    else
        echo "value.sh requires a value input." 1>&2
        echo "value.sh requires a value input." 1>&2
        echo "value.sh requires a value input." 1>&2
        echo "value.sh requires a value input." 1>&2
        echo "value.sh requires a value input." 1>&2
        echo "value.sh requires a value input." 1>&2
        echo "value.sh requires a value input." 1>&2
        echo "value.sh requires a value input." 1>&2
        echo "value.sh requires a value input." 1>&2
        exit 1
    fi
fi

OS_CHECK_VALUE=""
if [ $SOLARIS_CHECK_00 -eq 1 ]; then
    OS_CHECK_VALUE="Solaris"
elif [ $AIX_CHECK_00 -eq 1 ]; then
    OS_CHECK_VALUE="AIX"
elif [ $HP_CHECK_00 -eq 1 ]; then
    OS_CHECK_VALUE="HP-UX"
elif [ $SUSE_CHECK_00 -eq 1 ]; then
    OS_CHECK_VALUE="SUSE"
else
    OS_CHECK_VALUE="Linux"
fi


HOST_IP=""
# 파일명 IP 주소 생성
# HP-UX hostname 이슈로 인한 주석처리
# if [ $HP_CHECK_00 -eq 0 ]; then
#     if hostname -I >/dev/null 2>&1; then
#         HOST_IP=$(hostname -I 2>/dev/null | grep -v "Usage"| awk '{print $1}')
#         echo $(hostname -I 2>/dev/null | grep -v "Usage" | awk '{print $1}' | wc -l )
#     fi
# fi
if [ "$HOST_IP" = "" ]; then
    if command -v ip >/dev/null 2>&1; then
        HOST_IP=$(ip addr show 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n 1 )
    fi
fi

if [ "$HOST_IP" = "" ]; then
    if command -v ifconfig >/dev/null 2>&1; then
        HOST_IP=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1 )
    fi
fi

if [ "$HOST_IP" = "" ]; then
    if command -v ifconfig >/dev/null 2>&1; then
        HOST_IP=$(ifconfig -a 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
    fi
fi

if [ "$HOST_IP" = "" ]; then
    if command -v ifconfig >/dev/null 2>&1; then
        HOST_IP=$(ifconfig lan0 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
    fi
fi

if [ "$HOST_IP" = "" ]; then
    if command -v ifconfig >/dev/null 2>&1; then
        HOST_IP="notfindhostip"
    fi
fi

clear

#진단디렉터리변수명
CREATE_FILE_DIR="SECURITY_INSPECTION_TEMP"
#주요통신기반시설
CREATE_FILE_INFRA=$CREATE_FILE_DIR/"_+${OS_CHECK_VALUE}+$(hostname)+${HOST_IP}+I".hangrp
#전자금융기반시설
CREATE_FILE_FINANCE=$CREATE_FILE_DIR/"_+${OS_CHECK_VALUE}+$(hostname)+${HOST_IP}+F".hangrp

# 먼저 생성된 파일 삭제
if [ -d "$CREATE_FILE_DIR" ]; then
    rm -rf "SECURITY_INSPECTION_TEMP"
fi

# 임시디렉토리 생성
mkdir SECURITY_INSPECTION_TEMP
mkdir "${CREATE_FILE_DIR}/FILE_DETAIL"
mkdir "${CREATE_FILE_DIR}/COMMAND_DETAIL"
mkdir "${CREATE_FILE_DIR}/VULNERABILITY"
mkdir "${CREATE_FILE_DIR}/VULNERABILITY_REF"
mkdir "${CREATE_FILE_DIR}/WEBWAS_CHECK"
mkdir "${CREATE_FILE_DIR}/Service_check/"
mkdir "${CREATE_FILE_DIR}/SECURITY_STATUS"
mkdir -p "${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE/$USERNAME"


# grep 옵션 사용 가능여부 체크 파일
echo "dummy" >> "${CREATE_FILE_DIR}/VULNERABILITY_REF/dummy_file.hangrp" 2>&1
GREP_AB_TMP=$(cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/dummy_file.hangrp" | egrep -i -A 1 -B 1 "dummy" 2>/dev/null | wc -l)
SED_TMP=$(cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/dummy_file.hangrp" | sed -e 's/	//g' 2>/dev/null | wc -l)

#onoff확인변수
PS_CHECK_01=""
DNS_CHECK_01=0
FTP_CHECK_01=0
SMTP_CHECK_01=0
SNMP_CHECK_01=0
WEB_CHECK_01=0



####
####
echo "CHECK_PS_START"
#DNS 확인(ps)
PS_CHECK_01=$(ps -ef | grep 'named' | grep -v 'grep')
if [ -n "$PS_CHECK_01" ]; then
    DNS_CHECK_01=1

    if [ -s "/etc/named.conf" ]; then
        DNS_PATH="/etc/named.conf"
    elif [ -s "/etc/bind/named.conf.options" ]; then
        DNS_PATH="/etc/bind/named.conf.options"
    else
        DNS_PATH=$(find /etc/ -type f \( -name "named.conf" -o -name "named.conf.options" -o -name "named.conf.local" \))
    fi

    #$(find /etc/ -type f \( -name "ftpusers" -o -name "user_list" -o -name "vsftpd.ftpusers" -o -name "vsftpd.user_list" \))

    echo "[ps -ef | grep 'named' 결과]" >> "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"
    ps -ef | grep 'named' | grep -v 'grep'  >> "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"
else
    DNS_CHECK_01=0
    echo "[ps -ef | grep 'named' 결과]" >> "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"
    echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"       
fi

#ps변수초기화
PS_CHECK_01=""

#FTP(ps,port)
PS_CHECK_01=$(ps -ef | grep 'ftp' | grep -v 'grep' | grep -v '/sftp' )
if [ -n "$PS_CHECK_01" ]; then
    FTP_CHECK_01=1
    echo "[ps -ef | grep 'ftp' 결과]" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
    ps -ef | grep 'ftp' | grep -v 'grep' | grep -v '/sftp' >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"

    #파일 경로지정
    #vsftp
    if [ -s "/etc/vsftpd.conf" ]; then
        VSFTPD_PATH="/etc/vsftpd.conf"
    fi
    if [ -s "/etc/vsftpd/vsftpd.conf" ]; then
        if [ -n "$VSFTPD_PATH" ]; then
            VSFTPD_PATH="$VSFTPD_PATH /etc/vsftpd/vsftpd.conf"
        else
            VSFTPD_PATH="/etc/vsftpd/vsftpd.conf"
        fi
    fi
    if [ -n "$VSFTPD_PATH" ]; then
        VSFTPD_PATH=$(echo "$VSFTPD_PATH" | tr ' ' '\n')
    fi
    if [ -z "$VSFTPD_PATH" ]; then
        VSFTPD_PATH=$(find /etc/ -type f -name "vsftpd.conf")
    fi

    #proftp
    if [ -s "/etc/proftpd/proftpd.conf" ]; then
        PROFTPD_PATH="/etc/proftpd/proftpd.conf"
    fi
    if [ -s "/etc/proftpd.conf" ]; then
        if [ -n "$PROFTPD_PATH" ]; then
            PROFTPD_PATH="$PROFTPD_PATH /etc/proftpd.conf"
        else
            PROFTPD_PATH="/etc/proftpd.conf"
        fi
    fi
    if [ -s "/etc/proftpd.conf" ]; then
        if [ -n "$PROFTPD_PATH" ]; then
            PROFTPD_PATH="$PROFTPD_PATH /etc/proftpd.conf"
        else
            PROFTPD_PATH="/etc/proftpd.conf"
        fi
    fi
    if [ -s "/usr/local/etc/proftpd.conf" ]; then
        if [ -n "$PROFTPD_PATH" ]; then
            PROFTPD_PATH="$PROFTPD_PATH /usr/local/etc/proftpd.conf"
        else
            PROFTPD_PATH="/usr/local/etc/proftpd.conf"
        fi
    fi
    if [ -n "$PROFTPD_PATH" ]; then
        PROFTPD_PATH=$(echo "$PROFTPD_PATH" | tr ' ' '\n')
    fi
    if [ -z "$PROFTPD_PATH" ]; then
        PROFTPD_PATH=$(find /etc/ /usr/ -type f -name "proftpd.conf")
    fi

    FTPUSERS_PATH=$(find /etc/ -type f \( -name "ftpusers" -o -name "user_list" -o -name "vsftpd.ftpusers" -o -name "vsftpd.user_list" \))

    if command -v netstat >/dev/null 2>&1; then
        COMMAND_TMP_001=$(netstat -an | awk '/[.:]21 /')
        if [ -n "$COMMAND_TMP_001" ]; then
        #if netstat -an | awk '/[.:]21 /' >/dev/null 2>&1; then
            echo "[netstat -an | grep '21' 결과]" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
            netstat -an | awk '/[.:]21 /'  >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
        else
            echo "[netstat -an | grep '21' 결과]" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
            echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
        fi
        COMMAND_TMP_001=""
    else
        if command -v ss >/dev/null 2>&1; then
            COMMAND_TMP_001=$(ss -an | awk '/[.:]21 /')
            if [ -n "$COMMAND_TMP_001" ]; then
            #if ss -an | awk '/[.:]21 /' >/dev/null 2>&1; then
                echo "[ss -an | grep '21' 결과]" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
                ss -an | awk '/[.:]21 /'  >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
            else
                echo "[ss -an | grep '21' 결과]" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
                echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
            fi
            COMMAND_TMP_001=""
        fi
    fi
else
    FTP_CHECK_01=0
    echo "[ps -ef | grep 'ftp' 결과]" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"
    echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp"       
fi

#ps변수초기화
PS_CHECK_01=""

#SMTP(ps,port)
PS_CHECK_01=$(ps -ef | egrep -i 'sendmail|postfix|exim' | grep -v 'grep')
if [ -n "$PS_CHECK_01" ]; then
    SMTP_CHECK_01=1
    echo "[ps -ef | egrep -i 'sendmail|postfix|exim' 결과]" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
    ps -ef | egrep 'sendmail|postfix|exim' | grep -v 'grep'  >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"

    #파일 경로지정
    #sendmail
    if [ -s "/etc/mail/sendmail.cf" ]; then
        SENDMAIL_PATH="/etc/mail/sendmail.cf"
    elif [ -s "/etc/sendmail.cf" ]; then
        SENDMAIL_PATH="/etc/sendmail.cf"
    else
        SENDMAIL_PATH=$(find /etc/ -type f -name "sendmail.cf")
    fi
    #postfix
    if [ -s "/etc/postfix/main.cf" ]; then
        POSTFIX_PATH="/etc/postfix/main.cf"
    else
        POSTFIX_PATH=$(find /etc/ -type f -name "main.cf")
    fi
    #postuper
    if [ -s "/usr/sbin/postsuper" ]; then
        POSTFIX_POSTUPER_PATH="/usr/sbin/postsuper"
    else
        POSTFIX_POSTUPER_PATH=$(find /usr/ -type f -name "postsuper")
    fi

    #exim
    EXIM_PATH=$(find /etc/ -type f \( -name "exim4.conf.template" -o -name "exim4.conf" -o -name "exim.conf" \))

    if [ -s "/usr/sbin/exim" ]; then
        EXIM_EXECUTE_PATH="/usr/sbin/exim"
    else
        EXIM_EXECUTE_PATH=$(find /usr/ -type f -name "exim")
    fi

    if command -v netstat >/dev/null 2>&1; then
        COMMAND_TMP_001=$(netstat -an | awk '/[.:](25|587|465) /')
        if [ -n "$COMMAND_TMP_001" ]; then
        #if netstat -an | awk '/[.:](25|587|465) /' >/dev/null 2>&1; then
            echo "[netstat -an | grep '(25|587|465)' 결과]" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
            netstat -an | awk '/[.:](25|587|465) /'  >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
        else
            echo "[netstat -an | grep '(25|587|465)' 결과]" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
            echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
        fi
        COMMAND_TMP_001=""
    else
        if command -v ss >/dev/null 2>&1; then
            COMMAND_TMP_001=$(ss -an | awk '/[.:](25|587|465) /')
            if [ -n "$COMMAND_TMP_001" ]; then
            #if ss -an | awk '/[.:](25|587|465) /' >/dev/null 2>&1; then
                echo "[ss -an | egrep '(25|587|465)' 결과]" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
                ss -an | awk '/[.:](25|587|465) /'  >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
            else
                echo "[ss -an | egrep '(25|587|465)' 결과]" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
                echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
            fi
            COMMAND_TMP_001=""
        fi
    fi
else
    SMTP_CHECK_01=0
    echo "[ps -ef | egrep 'sendmail|postfix|exim' 결과]" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"
    echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp"      
fi

#ps변수초기화
PS_CHECK_01=""

#SNMP(ps,port)
#참고 SNMP 는 수신대기중일시 포트가 열려있지 않는 경우 존재
PS_CHECK_01=$(ps -ef | grep -i 'snmp' | grep -v 'grep')
if [ -n "$PS_CHECK_01" ]; then
    SNMP_CHECK_01=1
    echo "[ps -ef | grep 'snmp' 결과]" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
    ps -ef | grep -i 'snmp' | grep -v 'grep'  >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"


    if [ -s "/etc/snmp/snmpd.conf" ]; then
        SNMP_PATH="/etc/snmp/snmpd.conf"
    fi
    if [ -s "/etc/snmp/conf/snmpd.conf" ]; then
        if [ -n "$SNMP_PATH" ]; then
            SNMP_PATH="$SNMP_PATH /etc/snmp/conf/snmpd.conf"
        else
            SNMP_PATH="/etc/snmp/conf/snmpd.conf"
        fi
    fi
    if [ -s "/etc/sma/snmp/snmpd.conf" ]; then
        if [ -n "$SNMP_PATH" ]; then
            SNMP_PATH="$SNMP_PATH /etc/sma/snmp/snmpd.conf"
        else
            SNMP_PATH="/etc/sma/snmp/snmpd.conf"
        fi
    fi
    if [ -s "/etc/SnmpAgent.d/snmpd.conf" ]; then
        if [ -n "$SNMP_PATH" ]; then
            SNMP_PATH="$SNMP_PATH /etc/SnmpAgent.d/snmpd.conf"
        else
            SNMP_PATH="/etc/SnmpAgent.d/snmpd.conf"
        fi
    fi
    if [ -s "/etc/snmpd.conf" ]; then
        if [ -n "$SNMP_PATH" ]; then
            SNMP_PATH="$SNMP_PATH /etc/snmpd.conf"
        else
            SNMP_PATH="/etc/snmpd.conf"
        fi
    fi
    if [ -s "/etc/snmpdv3.conf" ]; then
        if [ -n "$SNMP_PATH" ]; then
            SNMP_PATH="$SNMP_PATH /etc/snmpdv3.conf"
        else
            SNMP_PATH="/etc/snmpdv3.conf"
        fi
    fi
    if [ -s "/etc/net-snmp/snmp/snmpd.conf" ]; then
        if [ -n "$SNMP_PATH" ]; then
            SNMP_PATH="$SNMP_PATH /etc/net-snmp/snmp/snmpd.conf"
        else
            SNMP_PATH="/etc/net-snmp/snmp/snmpd.conf"
        fi
    fi
    if [ -s "/var/lib/net-snmp/snmpd.conf" ]; then
        if [ -n "$SNMP_PATH" ]; then
            SNMP_PATH="$SNMP_PATH /var/lib/net-snmp/snmpd.conf"
        else
            SNMP_PATH="/var/lib/net-snmp/snmpd.conf"
        fi
    fi

    
    if [ -n "$SNMP_PATH" ]; then
        SNMP_PATH=$(echo "$SNMP_PATH" | tr ' ' '\n')
    fi

    if [ -z "$SNMP_PATH" ]; then
        SNMP_PATH=$(find /etc/ -type f \( -name "snmpd.conf" -o -name "snmpdv3.conf" \))
    fi

    if command -v netstat >/dev/null 2>&1; then
        COMMAND_TMP_001=$(netstat -an | awk '/[.:]161 /')
        if [ -n "$COMMAND_TMP_001" ]; then
        #if netstat -an | awk '/[.:]161 /' >/dev/null 2>&1; then
            echo "[netstat -an | grep '161' 결과]" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
            netstat -an | awk '/[.:]161 /'  >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
        else
            echo "[netstat -an | grep '161' 결과]" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
            echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
        fi
        COMMAND_TMP_001=""
    else
        if command -v ss >/dev/null 2>&1; then
            COMMAND_TMP_001=$(ss -an | awk '/[.:]161 /')
            if [ -n "$COMMAND_TMP_001" ]; then
            #if ss -an | awk '/[.:]161 /' >/dev/null 2>&1; then
                echo "[ss -an | grep '161' 결과]" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
                ss -an | awk '/[.:]161 /'  >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
            else
                echo "[ss -an | grep '161' 결과]" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
                echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
            fi
            COMMAND_TMP_001=""
        fi
    fi
else
    SNMP_CHECK_01=0
    echo "[ps -ef | grep 'snmp' 결과]" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"
    echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp"      
fi

#ps변수초기화
PS_CHECK_01=""

#WEB(ps)
PS_CHECK_01=$(ps -ef | egrep -i "httpd|apache|webtob|tomcat|jeus|nginx|litespeed|lighttpd|jetty|wildfly|glassfish|websphere|weblogic|resin|tomee|jenkins|nodejs|jboss|webtier|weblogic" | grep -v 'grep')
if [ -n "$PS_CHECK_01" ]; then
    WEB_CHECK_01=1
    echo "[WEB/WAS 구동 여부 확인]" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
    ps -ef | egrep -i "httpd|apache|webtob|tomcat|jeus|nginx|litespeed|lighttpd|jetty|wildfly|glassfish|websphere|weblogic|resin|tomee|jenkins|nodejs|jboss|webtier|weblogic" | grep -v 'grep'  >> "${CREATE_FILE_DIR}/Service_check/webcheck2.hangrp"
    #APACHE
    WEBWAS_NAME="httpd|apache2"
    if ps -ef | egrep -i $WEBWAS_NAME | egrep -v -i "grep|webtob|nginx|litespeed|lighttpd|Webtier" | grep -q .; then
        echo "APACHE running" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
    fi
    #WEBTOB
    WEBWAS_NAME="webtob"
    if ps -ef | grep -i $WEBWAS_NAME | egrep -v -i "grep|nginx|litespeed|lighttpd" | grep -q .; then
        echo "WEBTOB running" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
    fi
    #TOMCAT
    WEBWAS_NAME="tomcat"
    if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
        echo "TOMCAT running" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
    fi
    #JEUS
    WEBWAS_NAME="jeus"
    if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
        echo "JEUS running" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
    fi
    #NGINX
    WEBWAS_NAME="nginx"
    if ps -ef | grep -i $WEBWAS_NAME | egrep -v -i "grep|webtob|litespeed|lighttpd" | grep -q .; then
        echo "NGINX running" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
    fi
else
    WEB_CHECK_01=0
    echo "[WEB/WAS 구동 여부 확인]" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
    echo "명령어 결과값 존재하지 않음" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
    echo "" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" 
    echo "[확인하는 web,was 서비스]" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"       
    #echo "APACHE, WEBTOB, TOMCAT, JEUS, NGINX, LITESPEED, LIGHTTPD, JETTY, WILDFLY, GLASSFISH, WEBSPHERE, WEBLOGIC, RESIN, TOMEE, JENKINS, NODEJS, JBOSS, WEBTIER, WEBLOGIC" >> "${CREATE_FILE_DIR}/Service_check/webcheck2.hangrp"
    echo "APACHE, WEBTOB, TOMCAT, JEUS, NGINX" >> "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp"
fi

echo "CHECK_PS_END"


echo "CHECK_WEB_WAS_OPERATION_START"
#WEB 서비스 종류
#APACHE
#WEBTOB
#TOMCAT
#JEUS
#NGINX
#LITESPEED
#LIGHTTPD
#JETTY
#WILDFLY
#GLASSFISH
#WEBSPHERE
#WEBLOGIC
#RESIN
#TOMEE
#JENKINS
#NODEJS(스크립트형식불가)
#jboss



WEBWAS_COPY(){
    for file in "$@"; do
        if [ -e "$file" ]; then
            filesize=$(ls -l "$file" | awk '{print $5}')
            if [ ! "$filesize" -gt 500000 ]; then
                file_name=$(echo "${file}" | tr '/' '_' | sed 's/^_//')
                #링크파일 과 일반파일의 길이가 다르기 때문에 길이를 비교하여 링크파일인지 일반파일인지 구분
                #디버깅용
                #echo "$file"
                len1=$(ls -l "$file" | wc -c)
                len2=$(ls -lLd "$file" | wc -c)
                # 파일정보가 이미 존재하는지 아닌지 확인
                if [ ! -f "${CREATE_FILE_DIR}/WEBWAS_CHECK/${file_name}.hangrp" ]; then
                    # 일반파일,링크 파일 확인
                    if [ "$len1" -eq "$len2" ]; then
                        #일반파일
                        cat ${file} > "${CREATE_FILE_DIR}/WEBWAS_CHECK/${file_name}.hangrp"
                        echo "-----" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___FILE_AUTH__CHECK.hangrp"
                        ls -al ${file} >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___FILE_AUTH__CHECK.hangrp"
                        echo "-----" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___FILE_AUTH__CHECK.hangrp"
                    else
                        cat ${file} > "${CREATE_FILE_DIR}/WEBWAS_CHECK/${file_name}.hangrp"
                        echo "-----" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___FILE_AUTH__CHECK.hangrp"
                        ls -al ${file} >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___FILE_AUTH__CHECK.hangrp"
                        ls -alLd ${file} >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___FILE_AUTH__CHECK.hangrp"
                        echo "-----" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___FILE_AUTH__CHECK.hangrp"
                    fi
                fi
            fi
        fi
    done
}






#APACHE
PS_APACHE=0
WEBWAS_NAME="httpd|apache2"
if ps -ef | egrep -i $WEBWAS_NAME | egrep -v -i "grep" | grep -q .; then
    if ps -ef | egrep -i $WEBWAS_NAME | egrep -v -i "grep|webtob|nginx|litespeed|lshttpd|lighttpd|Webtier" | grep -q .; then
        PS_APACHE=1
        APACHE_CONFIG=""
        APACHE_PATH=""
        PS_APACHE_STATUS=0

        #APACHE_CONFIG 경로
        if [ -s "/etc/httpd/conf/httpd.conf" ]; then
            APACHE_CONFIG="/etc/httpd/conf/httpd.conf"
        elif [ -s "/etc/httpd/conf.d/httpd.conf" ]; then
            APACHE_CONFIG="/etc/httpd/conf.d/httpd.conf"
        elif [ -s "/etc/httpd/httpd.conf" ]; then
            APACHE_CONFIG="/etc/httpd/httpd.conf"
        elif [ -s "/etc/apache2/apache2.conf" ]; then
            APACHE_CONFIG="/etc/apache2/apache2.conf"
        elif [ -s "/etc/apache2/httpd.conf" ]; then
            APACHE_CONFIG="/etc/apache2/httpd.conf"
        elif [ -s "/etc/apache2/conf/httpd.conf" ]; then
            APACHE_CONFIG="/etc/apache2/conf/httpd.conf"
        elif [ -s "/etc/apache2/conf.d/httpd.conf" ]; then
            APACHE_CONFIG="/etc/apache2/conf.d/httpd.conf"
        else
            echo "debug apache config find start ..."
            
            # 불필요한 디렉터리를 제외하고 검색
            APACHE_CONFIGS=$(find / -xdev \
            \( \
                \( -type d \( -name "httpd" -o -name "apache" -o -name "apache2" \) \) -o \
                \( -type f \( -name "httpd.conf" -o -name "apache2.conf" \) \) \
            \) \
            -not \( -path "/boot/*" -prune \) \
            -not \( -path "/dev/*" -prune \) \
            -not \( -path "/local/*" -prune \) \
            -not \( -path "/media/*" -prune \) \
            -not \( -path "/mnt/*" -prune \) \
            -not \( -path "/proc/*" -prune \) \
            -not \( -path "/run/*" -prune \) \
            -not \( -path "/srv/*" -prune \) \
            -not \( -path "/sys/*" -prune \) \
            -not \( -path "/tmp/*" -prune \) \
            -not \( -path "/var/*" -prune \) \
            -not \( -path "*/.snapshots/*" -prune \) \
            -not \( -path "/bin/*" -prune \) \
            -not \( -path "/lib/*" -prune \) \
            -not \( -path "/lib64/*" -prune \) \
            -not \( -path "/sbin/*" -prune \) \
            -not \( -path "/selinux/*" -prune \) \
            -not \( -path "/cdrom/*" -prune \) \
            -not \( -path "/devices/*" -prune \) \
            -not \( -path "/export/*" -prune \) \
            -not \( -path "/kernel/*" -prune \) \
            -not \( -path "/net/*" -prune \) \
            -not \( -path "/nfs4/*" -prune \) \
            -not \( -path "/platform/*" -prune \) \
            -not \( -path "/rpool/*" -prune \) \
            -not \( -path "/system/*" -prune \) \
            -not \( -path "*/.snap/*" -prune \) \
            -not \( -path "/libexec/*" -prune \) \
            -not \( -path "/rescue/*" -prune \) \
            -not \( -path "/zroot/*" -prune \) \
            -not \( -path "/lost+found/*" -prune \) \
            -not \( -path "/snap/*" -prune \) \
            -not \( -path "/nfs_mount/*" -prune \) \
            -not \( -path "/.cache/*" -prune \) \
            -not \( -path "/admin/*" -prune \) \
            -not \( -path "/audit/*" -prune \) \
            -not \( -path "/junepine1/*" -prune \) \
            -not \( -path "/lpp/*" -prune \) \
            -not \( -path "/tftpboot/*" -prune \) \
            -not \( -path "/.dt/*" -prune \) \
            -not \( -path "/.ssh/*" -prune \) \
            -not \( -path "/.sw/*" -prune \) \
            -not \( -path "/stand/*" -prune \) \
            -not \( -path "/tcb/*" -prune \) \
            -not \( -path "/tmp_mnt/*" -prune \) 2>/dev/null)

            if [ -n "$APACHE_CONFIGS" ]; then
                for WEBWAS_config in $APACHE_CONFIGS; do
                    if [ -f "$WEBWAS_config" ]; then
                        if [ "$(cat "$WEBWAS_config" | grep -i "Directory" | wc -l )" -ne 0 ]; then
                            APACHE_CONFIG="$WEBWAS_config"
                            break
                        fi
                    fi
                done
            fi
        fi


        if [ -f "$APACHE_CONFIG" ]; then
            PS_APACHE_STATUS=1
        
            #APACHE_PATH 설치경로
            if [ -d "/etc/httpd" ]; then
                APACHE_PATH="/etc/httpd"
            elif [ -d "/etc/apache2" ]; then
                APACHE_PATH="/etc/apache2"
            elif [ -d "/usr/local/apache" ]; then
                APACHE_PATH="/usr/local/apache"
            elif [ -d "/usr/local/apache2" ]; then
                APACHE_PATH="/usr/local/apache2"
            elif [ -d "/usr/local/httpd" ]; then
                APACHE_PATH="/usr/local/httpd"
            elif [ -d "/usr/local/httpd2" ]; then
                APACHE_PATH="/usr/local/httpd2"
            else
                echo "debug apache path find start ..."

                if [ -n "$APACHE_CONFIGS" ]; then
                    for APACHE_PATHS_TMP_01 in $APACHE_CONFIGS; do
                        if [ -d "$APACHE_PATHS_TMP_01" ]; then
                            if [ "$(ls -alR $APACHE_PATHS_TMP_01 | egrep -i "httpd.conf|apache2.conf" | wc -l )" -ne 0 ]; then
                                APACHE_PATH="$APACHE_PATHS_TMP_01"
                                break
                            fi
                        fi
                    done
                fi
            fi
            
            
            echo "$APACHE_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___APACHE_PATH.hangrp"
            # 솔라리스에서 sed -E 안먹혀서 주석처리함
            #cat $APACHE_CONFIG | egrep -i "<Directory|ServerRoot|DocumentRoot" | egrep -v "#|<Directory />" | sed -E 's/.*\s+\"?([^\">]+)\"?>?/\1/' >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___APACHE_PATH.hangrp"
            cat $APACHE_CONFIG | egrep -i "<Directory|ServerRoot|DocumentRoot" | egrep -v "#|<Directory />" | sed 's/.*[[:space:]]"\([^"]\+\)".*/\1/' >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___APACHE_PATH.hangrp"
            

            APACHE_DIR_PATH=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___APACHE_PATH.hangrp" | sort | uniq)
            
            # 파일 복사
            WEBWAS_COPY "$APACHE_CONFIG"

        else
            PS_APACHE_STATUS=0
        fi
    fi
fi

if [ $PS_APACHE -eq 1 ]; then
    if [ -n "$APACHE_PATH" ]; then
        GREP_R_APACHE_PATH_TMP=$(find $APACHE_PATH -type f)
    fi
fi


#WEBTOB
PS_WEBTOB=0
WEBWAS_NAME="webtob"
if ps -ef | grep -i $WEBWAS_NAME | egrep -v -i "grep|nginx|litespeed|lshttpd|lighttpd" | grep -q .; then
    PS_WEBTOB=1
    PS_WEBTOB_STATUS=0
    PS_WEBTOB_STATUS=1
    #필요한파일
    # http.m
    #WEBTOB_http.m 경로
    echo "debug webtob find start ..."
    # 불필요한 디렉터리를 제외하고 검색
    WEBTOB_HTTP_M_PATHS=$(find / -xdev -type f \
    \( -name "http*.m" \) \
    -not \( -path "/boot/*" -prune \) \
    -not \( -path "/dev/*" -prune \) \
    -not \( -path "/local/*" -prune \) \
    -not \( -path "/media/*" -prune \) \
    -not \( -path "/mnt/*" -prune \) \
    -not \( -path "/proc/*" -prune \) \
    -not \( -path "/run/*" -prune \) \
    -not \( -path "/srv/*" -prune \) \
    -not \( -path "/sys/*" -prune \) \
    -not \( -path "/tmp/*" -prune \) \
    -not \( -path "/var/*" -prune \) \
    -not \( -path "*/.snapshots/*" -prune \) \
    -not \( -path "/bin/*" -prune \) \
    -not \( -path "/lib/*" -prune \) \
    -not \( -path "/lib64/*" -prune \) \
    -not \( -path "/sbin/*" -prune \) \
    -not \( -path "/selinux/*" -prune \) \
    -not \( -path "/cdrom/*" -prune \) \
    -not \( -path "/devices/*" -prune \) \
    -not \( -path "/export/*" -prune \) \
    -not \( -path "/kernel/*" -prune \) \
    -not \( -path "/net/*" -prune \) \
    -not \( -path "/nfs4/*" -prune \) \
    -not \( -path "/platform/*" -prune \) \
    -not \( -path "/rpool/*" -prune \) \
    -not \( -path "/system/*" -prune \) \
    -not \( -path "*/.snap/*" -prune \) \
    -not \( -path "/libexec/*" -prune \) \
    -not \( -path "/rescue/*" -prune \) \
    -not \( -path "/zroot/*" -prune \) \
    -not \( -path "/lost+found/*" -prune \) \
    -not \( -path "/snap/*" -prune \) \
    -not \( -path "/nfs_mount/*" -prune \) \
    -not \( -path "/.cache/*" -prune \) \
    -not \( -path "/admin/*" -prune \) \
    -not \( -path "/audit/*" -prune \) \
    -not \( -path "/junepine1/*" -prune \) \
    -not \( -path "/lpp/*" -prune \) \
    -not \( -path "/tftpboot/*" -prune \) \
    -not \( -path "/.dt/*" -prune \) \
    -not \( -path "/.ssh/*" -prune \) \
    -not \( -path "/.sw/*" -prune \) \
    -not \( -path "/stand/*" -prune \) \
    -not \( -path "/tcb/*" -prune \) \
    -not \( -path "/tmp_mnt/*" -prune \) 2>/dev/null)

    if [ -n "$WEBTOB_HTTP_M_PATHS" ]; then
        for WEBTOB_HTTP_M_PATH in $WEBTOB_HTTP_M_PATHS; do
            if [ -f "$WEBTOB_HTTP_M_PATH" ]; then
                if [ "$(cat "$WEBTOB_HTTP_M_PATH" | grep -i "webtob" | wc -l )" -ne 0 ]; then
                    echo "$WEBTOB_HTTP_M_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___WEBTOB_HTTP_M_PATH.hangrp"
                fi
            fi
        done
        WEBTOB_HTTP_M_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___WEBTOB_HTTP_M_PATH.hangrp" | sort | uniq)

        #WEBTOB 설치 경로
        for WEBTOB_INFO_DIRS in $WEBTOB_HTTP_M_PATHS; do
            WEBTOB_INFO_DIR=$(dirname "$(dirname "$WEBTOB_INFO_DIRS")")
            if [ -d "$WEBTOB_INFO_DIR" ]; then
                echo "$WEBTOB_INFO_DIR" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___WEBTOB_INFO_DIR.hangrp"
            fi
        done
        WEBTOB_INFO_DIRS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___WEBTOB_INFO_DIR.hangrp" | sort | uniq)

        #파일복사
        for WEBTOB_HTTP_M_PATH in $WEBTOB_HTTP_M_PATHS; do
            if [ -f "$WEBTOB_HTTP_M_PATH" ]; then
                WEBWAS_COPY "$WEBTOB_HTTP_M_PATH"
            fi
        done
    fi

    # 경로못찾을시
    if [ -z "$WEBTOB_HTTP_M_PATHS" ]; then
        echo "NOT_FIND_WEBTOB_HTTP_M_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___WEBTOB_HTTP_M_PATH.hangrp"
        WEBTOB_HTTP_M_PATHS="${CREATE_FILE_DIR}/WEBWAS_CHECK/___WEBTOB_HTTP_M_PATH.hangrp"
    fi
    if [ -z "$WEBTOB_INFO_DIRS" ]; then
        echo "NOT_FIND_WEBTOB_INFO_DIR" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___WEBTOB_INFO_DIR.hangrp"
        WEBTOB_INFO_DIRS="${CREATE_FILE_DIR}/WEBWAS_CHECK"
    fi


fi


#TOMCAT
PS_TOMCAT=0
WEBWAS_NAME="tomcat"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_TOMCAT=1

    PS_TOMCAT_STATUS=0
    PS_TOMCAT_STATUS=1

    #TOMCAT_관련 경로 catalina.jar
    echo "debug tomcat find start ..."
    # 불필요한 디렉터리를 제외하고 검색
    TOMCAT_INFO_PATHS=$(find / -xdev \
    \( \
        \( -type d \( -name "tomcat" -o -name "tomcat7" -o -name "tomcat8" -o -name "tomcat9" -o -name "tomcat10" \) \) -o \
        \( -type f \( -name "web.xml" -o -name "context.xml" -o -name "tomcat-users.xml" -o -name "server.xml" -o -name "catalina.jar" \) \) \
    \) \
    -not \( -path "/boot/*" -prune \) \
    -not \( -path "/dev/*" -prune \) \
    -not \( -path "/local/*" -prune \) \
    -not \( -path "/media/*" -prune \) \
    -not \( -path "/mnt/*" -prune \) \
    -not \( -path "/proc/*" -prune \) \
    -not \( -path "/run/*" -prune \) \
    -not \( -path "/srv/*" -prune \) \
    -not \( -path "/sys/*" -prune \) \
    -not \( -path "/tmp/*" -prune \) \
    -not \( -path "/var/*" -prune \) \
    -not \( -path "*/.snapshots/*" -prune \) \
    -not \( -path "/bin/*" -prune \) \
    -not \( -path "/lib/*" -prune \) \
    -not \( -path "/lib64/*" -prune \) \
    -not \( -path "/sbin/*" -prune \) \
    -not \( -path "/selinux/*" -prune \) \
    -not \( -path "/cdrom/*" -prune \) \
    -not \( -path "/devices/*" -prune \) \
    -not \( -path "/export/*" -prune \) \
    -not \( -path "/kernel/*" -prune \) \
    -not \( -path "/net/*" -prune \) \
    -not \( -path "/nfs4/*" -prune \) \
    -not \( -path "/platform/*" -prune \) \
    -not \( -path "/rpool/*" -prune \) \
    -not \( -path "/system/*" -prune \) \
    -not \( -path "*/.snap/*" -prune \) \
    -not \( -path "/libexec/*" -prune \) \
    -not \( -path "/rescue/*" -prune \) \
    -not \( -path "/zroot/*" -prune \) \
    -not \( -path "/lost+found/*" -prune \) \
    -not \( -path "/snap/*" -prune \) \
    -not \( -path "/nfs_mount/*" -prune \) \
    -not \( -path "/.cache/*" -prune \) \
    -not \( -path "/admin/*" -prune \) \
    -not \( -path "/audit/*" -prune \) \
    -not \( -path "/junepine1/*" -prune \) \
    -not \( -path "/lpp/*" -prune \) \
    -not \( -path "/tftpboot/*" -prune \) \
    -not \( -path "/.dt/*" -prune \) \
    -not \( -path "/.ssh/*" -prune \) \
    -not \( -path "/.sw/*" -prune \) \
    -not \( -path "/stand/*" -prune \) \
    -not \( -path "/tcb/*" -prune \) \
    -not \( -path "/tmp_mnt/*" -prune \) 2>/dev/null)

    TOMCAT_INFO_PATHS=$(echo "$TOMCAT_INFO_PATHS" | egrep -v "jeus|wildfly|glassfish|weblogic|websphere|resin|tomee|jenkins|nodejs|jboss|weblogic")
    #TOMCAT_SERVER_XML_PATH 경로추출
    TOMCAT_PATHS=$(echo "$TOMCAT_INFO_PATHS" | grep -i "/tomcat[0-9]*$" | sort | uniq)

    #TOMCAT_SERVER_XML_PATH 경로추출
    TOMCAT_SERVER_XML_PATHS=$(echo "$TOMCAT_INFO_PATHS" | grep -i "server.xml" | sort | uniq)
    for TOMCAT_SERVER_XML_PATH in $TOMCAT_SERVER_XML_PATHS; do
            if [ "$(cat "$TOMCAT_SERVER_XML_PATH" | grep -i "tomcat" | wc -l )" -ne 0 ]; then
                echo "$TOMCAT_SERVER_XML_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___TOMCAT_SERVER_XML_PATH.hangrp"
            fi
    done
    TOMCAT_SERVER_XML_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___TOMCAT_SERVER_XML_PATH.hangrp" | sort | uniq)

    #TOMCAT_WEB_XML_PATH 경로추출
    TOMCAT_WEB_XML_PATHS=$(echo "$TOMCAT_INFO_PATHS" | grep -i "web.xml" | sort | uniq)
    for TOMCAT_WEB_XML_PATH in $TOMCAT_WEB_XML_PATHS; do
            if [ "$(cat "$TOMCAT_WEB_XML_PATH" | grep -i "tomcat" | wc -l )" -ne 0 ]; then
                echo "$TOMCAT_WEB_XML_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___TOMCAT_WEB_XML_PATH.hangrp"
            fi
    done
    TOMCAT_WEB_XML_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___TOMCAT_WEB_XML_PATH.hangrp" | sort | uniq)


    #TOMCAT_CONTEXT_XML_PATH 경로추출
    TOMCAT_CONTEXT_XML_PATHS=$(echo "$TOMCAT_INFO_PATHS" | grep -i "context.xml" | sort | uniq)
    for TOMCAT_CONTEXT_XML_PATH in $TOMCAT_CONTEXT_XML_PATHS; do
            if [ "$(cat "$TOMCAT_CONTEXT_XML_PATH" | egrep -v "TomEE|Jetty" | wc -l )" -ne 0 ]; then
            echo "$TOMCAT_CONTEXT_XML_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___TOMCAT_CONTEXT_XML_PATH.hangrp"
            fi
    done
    TOMCAT_CONTEXT_XML_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___TOMCAT_CONTEXT_XML_PATH.hangrp" | sort | uniq)


    #TOMCAT_USERS_XML_PATH 경로추출
    TOMCAT_USERS_XML_PATHS=$(echo "$TOMCAT_INFO_PATHS" | grep -i "tomcat-users.xml" | sort | uniq)
    for TOMCAT_USERS_XML_PATH in $TOMCAT_USERS_XML_PATHS; do
            if [ "$(cat "$TOMCAT_USERS_XML_PATH" | grep -i "tomcat-users" | wc -l )" -ne 0 ]; then
            echo "$TOMCAT_USERS_XML_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___TOMCAT_USERS_XML_PATH.hangrp"
            fi
    done
    TOMCAT_USERS_XML_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___TOMCAT_USERS_XML_PATH.hangrp" | sort | uniq)

    #TOMCAT_catlina.jar 경로추출
    TOMCAT_CATLINA_JAR_PATHS=$(echo "$TOMCAT_INFO_PATHS" | grep -i "catalina.jar" | sort | uniq)

    #TOMCAT_SERVER_CONTEXT_XML_PATHS
    #U-41,SRV-046 에서 사용 변수
    TOMCAT_SERVER_CONTEXT_XML_PATHS="${TOMCAT_SERVER_XML_PATHS}
    ${TOMCAT_CONTEXT_XML_PATHS}"


    # 파일복사(server.xml,web.xml,context.xml,tomcat-users.xml)
    TOMCAT_DIR_INFO_01=$(echo $TOMCAT_INFO_PATHS | egrep -i "server.xml|web.xml|context.xml|tomcat-users.xml")
    for TOMCAT_DIR_INFO_02 in $TOMCAT_DIR_INFO_01; do
        if [ -f "$TOMCAT_DIR_INFO_02" ] ; then
        WEBWAS_COPY "$TOMCAT_DIR_INFO_02"
        fi
    done

fi



#JEUS
PS_JEUS=0
WEBWAS_NAME="jeus"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_JEUS=1
    PS_JEUS_STATUS=0
    PS_JEUS_STATUS=1
    
    #JEUS_설치 경로 JEUS_INFO_PATHS
        echo "debug jeus find start ..."
        # 불필요한 디렉터리를 제외하고 검색
        JEUS_INFO_PATHS=$(find / -xdev -type f \
        \( -name "jeusadmin" \) \
        -not \( -path "/boot/*" -prune \) \
        -not \( -path "/dev/*" -prune \) \
        -not \( -path "/local/*" -prune \) \
        -not \( -path "/media/*" -prune \) \
        -not \( -path "/mnt/*" -prune \) \
        -not \( -path "/proc/*" -prune \) \
        -not \( -path "/run/*" -prune \) \
        -not \( -path "/srv/*" -prune \) \
        -not \( -path "/sys/*" -prune \) \
        -not \( -path "/tmp/*" -prune \) \
        -not \( -path "/var/*" -prune \) \
        -not \( -path "*/.snapshots/*" -prune \) \
        -not \( -path "/bin/*" -prune \) \
        -not \( -path "/lib/*" -prune \) \
        -not \( -path "/lib64/*" -prune \) \
        -not \( -path "/sbin/*" -prune \) \
        -not \( -path "/selinux/*" -prune \) \
        -not \( -path "/cdrom/*" -prune \) \
        -not \( -path "/devices/*" -prune \) \
        -not \( -path "/export/*" -prune \) \
        -not \( -path "/kernel/*" -prune \) \
        -not \( -path "/net/*" -prune \) \
        -not \( -path "/nfs4/*" -prune \) \
        -not \( -path "/platform/*" -prune \) \
        -not \( -path "/rpool/*" -prune \) \
        -not \( -path "/system/*" -prune \) \
        -not \( -path "*/.snap/*" -prune \) \
        -not \( -path "/libexec/*" -prune \) \
        -not \( -path "/rescue/*" -prune \) \
        -not \( -path "/zroot/*" -prune \) \
        -not \( -path "/lost+found/*" -prune \) \
        -not \( -path "/snap/*" -prune \) \
        -not \( -path "/nfs_mount/*" -prune \) \
        -not \( -path "/.cache/*" -prune \) \
        -not \( -path "/admin/*" -prune \) \
        -not \( -path "/audit/*" -prune \) \
        -not \( -path "/junepine1/*" -prune \) \
        -not \( -path "/lpp/*" -prune \) \
        -not \( -path "/tftpboot/*" -prune \) \
        -not \( -path "/.dt/*" -prune \) \
        -not \( -path "/.ssh/*" -prune \) \
        -not \( -path "/.sw/*" -prune \) \
        -not \( -path "/stand/*" -prune \) \
        -not \( -path "/tcb/*" -prune \) \
        -not \( -path "/tmp_mnt/*" -prune \) 2>/dev/null)

        if [ -n "$JEUS_INFO_PATHS" ]; then
            for JEUS_INFO_PATH in $JEUS_INFO_PATHS; do
                JEUS_INFO_PATH_TMP_01=$(dirname "$(dirname "$JEUS_INFO_PATH")")
                echo "$JEUS_INFO_PATH_TMP_01" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___JEUS_INFO_PATH_01.hangrp"
            done
            JEUS_INFO_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___JEUS_INFO_PATH_01.hangrp" | sort | uniq)
            for JEUS_INFO_PATH in $JEUS_INFO_PATHS; do
                if [ -d "$JEUS_INFO_PATH/bin" ] && [ -d "$JEUS_INFO_PATH/derby" ] && [ -d "$JEUS_INFO_PATH/license" ]; then
                    echo "$JEUS_INFO_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___JEUS_INFO_PATH_02.hangrp"
                fi
            done
            JEUS_INFO_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___JEUS_INFO_PATH_02.hangrp" | sort | uniq)

        #JEUS_ACCOUNTS_XML_PATH
            echo "debug jeus PATHS find start ..."
            for JEUS_INFO_PATH in $JEUS_INFO_PATHS; do
                JEUS_ACCOUNTS_PATH_TMP_01=$(find "$JEUS_INFO_PATH" -type f \( -name "accounts.xml" \)) 
                echo "$JEUS_ACCOUNTS_PATH_TMP_01" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___JEUS_ACCOUNTS_PATH.hangrp"
            done
            JEUS_ACCOUNTS_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___JEUS_ACCOUNTS_PATH.hangrp" | sort | uniq)
        #JEUS_DOMAIN_XML_PATH 
            echo "debug jeus XML_PATHS find start ..."
            for JEUS_INFO_PATH in $JEUS_INFO_PATHS; do
                JEUS_DOMAIN_XML_PATH_TMP_01=$(find "$JEUS_INFO_PATH" -type f \( -name "domain.xml" \)) 
                echo "$JEUS_DOMAIN_XML_PATH_TMP_01" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___JEUS_DOMAIN_XML_PATH.hangrp"
            done
            JEUS_DOMAIN_XML_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___JEUS_DOMAIN_XML_PATH.hangrp" | sort | uniq)
        fi
fi



#NGINX
PS_NGINX=0
WEBWAS_NAME="nginx"
if ps -ef | grep -i $WEBWAS_NAME | egrep -v -i "grep|apache2|httpd|tomcat|jeus|webtob|litespeed|lshttpd|lighttpd" | grep -q .; then
    PS_NGINX=1
    PS_NGINX_STATUS=0
    PS_NGINX_STATUS=1
    #NGINX_config 경로
        echo "debug nginx find start ..."
        # 불필요한 디렉터리를 제외하고 검색
        NGINX_CONFIG_PATHS=$(find / -xdev -type f \
        \( -name "nginx.conf" \) \
        -not \( -path "/boot/*" -prune \) \
        -not \( -path "/dev/*" -prune \) \
        -not \( -path "/local/*" -prune \) \
        -not \( -path "/media/*" -prune \) \
        -not \( -path "/mnt/*" -prune \) \
        -not \( -path "/proc/*" -prune \) \
        -not \( -path "/run/*" -prune \) \
        -not \( -path "/srv/*" -prune \) \
        -not \( -path "/sys/*" -prune \) \
        -not \( -path "/tmp/*" -prune \) \
        -not \( -path "/var/*" -prune \) \
        -not \( -path "*/.snapshots/*" -prune \) \
        -not \( -path "/bin/*" -prune \) \
        -not \( -path "/lib/*" -prune \) \
        -not \( -path "/lib64/*" -prune \) \
        -not \( -path "/sbin/*" -prune \) \
        -not \( -path "/selinux/*" -prune \) \
        -not \( -path "/cdrom/*" -prune \) \
        -not \( -path "/devices/*" -prune \) \
        -not \( -path "/export/*" -prune \) \
        -not \( -path "/kernel/*" -prune \) \
        -not \( -path "/net/*" -prune \) \
        -not \( -path "/nfs4/*" -prune \) \
        -not \( -path "/platform/*" -prune \) \
        -not \( -path "/rpool/*" -prune \) \
        -not \( -path "/system/*" -prune \) \
        -not \( -path "*/.snap/*" -prune \) \
        -not \( -path "/libexec/*" -prune \) \
        -not \( -path "/rescue/*" -prune \) \
        -not \( -path "/zroot/*" -prune \) \
        -not \( -path "/lost+found/*" -prune \) \
        -not \( -path "/snap/*" -prune \) \
        -not \( -path "/nfs_mount/*" -prune \) \
        -not \( -path "/.cache/*" -prune \) \
        -not \( -path "/admin/*" -prune \) \
        -not \( -path "/audit/*" -prune \) \
        -not \( -path "/junepine1/*" -prune \) \
        -not \( -path "/lpp/*" -prune \) \
        -not \( -path "/tftpboot/*" -prune \) \
        -not \( -path "/.dt/*" -prune \) \
        -not \( -path "/.ssh/*" -prune \) \
        -not \( -path "/.sw/*" -prune \) \
        -not \( -path "/stand/*" -prune \) \
        -not \( -path "/tcb/*" -prune \) \
        -not \( -path "/tmp_mnt/*" -prune \) 2>/dev/null)

        if [ -n "$NGINX_CONFIG_PATHS" ]; then
            for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                if [ -f "$NGINX_CONFIG_PATH" ]; then
                    if [ "$(cat "$NGINX_CONFIG_PATH" | grep -i "user" | wc -l )" -ne 0 ]; then
                        echo "$NGINX_CONFIG_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___NGINX_CONFIG_PATH.hangrp"
                    fi
                fi
            done
            NGINX_CONFIG_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___NGINX_CONFIG_PATH.hangrp" | sort | uniq)

            # NGINX 설치 경로
            for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                NGINX_HOME_PATH=$(dirname "$NGINX_CONFIG_PATH")
                if [ -d "$NGINX_HOME_PATH" ]; then
                    echo "$NGINX_HOME_PATH" >> "${CREATE_FILE_DIR}/WEBWAS_CHECK/___NGINX_HOME_PATH.hangrp"
                fi
            done
            NGINX_HOME_PATHS=$(cat "${CREATE_FILE_DIR}/WEBWAS_CHECK/___NGINX_HOME_PATH.hangrp" | sort | uniq)

            # nginx.conf 파일 복사
            for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                if [ -f "$NGINX_CONFIG_PATH" ]; then
                    WEBWAS_COPY "$NGINX_CONFIG_PATH"
                fi
            done

            # 확장자 .conf 파일 복사
            NGINX_ALL_CONF_PATHS=$(find $NGINX_HOME_PATHS -type f -name "*.conf")
            for NGINX_ALL_CONF_PATH in $NGINX_ALL_CONF_PATHS; do
                if [ -f "$NGINX_ALL_CONF_PATH" ]; then
                    WEBWAS_COPY "$NGINX_ALL_CONF_PATH"
                fi
            done
        fi
fi

#LITESPEED
PS_LITESPEED=0
WEBWAS_NAME="lshttpd"
if ps -ef | grep -i $WEBWAS_NAME | egrep -v -i "grep|apache2|tomcat|jeus|webtob|litespeed|lighttpd" | grep -q .; then
    PS_LITESPEED=1
else
    PS_LITESPEED=0
fi

#LIGHTTPD
PS_LIGHTTPD=0
WEBWAS_NAME="lighttpd"
if ps -ef | grep -i $WEBWAS_NAME | egrep -v -i "grep|webtob|nginx|lshttpd|litespeed" | grep -q .; then
    PS_LIGHTTPD=1
else
    PS_LIGHTTPD=0
fi

#JETTY
PS_JETTY=0
WEBWAS_NAME="jetty"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_JETTY=1
else
    PS_JETTY=0
fi

#WILDFLY
PS_WILDFLY=0
WEBWAS_NAME="wildfly"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_WILDFLY=1
else
    PS_WILDFLY=0
fi

#GLASSFISH
PS_GLASSFISH=0
WEBWAS_NAME="glassfish"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_GLASSFISH=1
else
    PS_GLASSFISH=0
fi

#WEBSPHERE
PS_WEBSPHERE=0
WEBWAS_NAME="websphere"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_WEBSPHERE=1
else
    PS_WEBSPHERE=0
fi

#WEBLOGIC
PS_WEBLOGIC=0
WEBWAS_NAME="weblogic"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_WEBLOGIC=1
else
    PS_WEBLOGIC=0
fi

#RESIN
PS_RESIN=0
WEBWAS_NAME="resin"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_RESIN=1
else
    PS_RESIN=0
fi

#TOMEE
PS_TOMEE=0
WEBWAS_NAME="tomee"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_TOMEE=1
else
    PS_TOMEE=0
fi

#JENKINS
PS_JENKINS=0
WEBWAS_NAME="jenkins"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_JENKINS=1
else
    PS_JENKINS=0
fi

#NODEJS
PS_NODEJS=0
WEBWAS_NAME="nodejs"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_NODEJS=1
else
    PS_NODEJS=0
fi

#jboss
PS_JBOSS=0
WEBWAS_NAME="jboss"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_JBOSS=1
else
    PS_JBOSS=0
fi


#Webtier
PS_WEBTIER=0
WEBWAS_NAME="webtier"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_WEBTIER=1
else
    PS_WEBTIER=0
fi

#WebLogic
PS_WEBLOGIC=0
WEBWAS_NAME="weblogic"
if ps -ef | grep -i $WEBWAS_NAME | grep -v -i "grep" | grep -q .; then
    PS_WEBLOGIC=1
else
    PS_WEBLOGIC=0
fi
echo "CHECK_WEB_WAS_OPERATION_COMPLETE"




#주요통신기반시설
echo "##############################################################################" >> $CREATE_FILE_INFRA 2>&1
echo " 		Copyright (C) 2024. hangrp.com. All rights reserved." >> $CREATE_FILE_INFRA 2>&1
echo " 		Version: $VER_info" >> $CREATE_FILE_INFRA 2>&1
echo "##############################################################################" >> $CREATE_FILE_INFRA 2>&1
echo "[ Startup account ]">> $CREATE_FILE_INFRA 2>&1
echo "`id 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
echo "" >> $CREATE_FILE_INFRA 2>&1

echo "[ startup shell ]" >> $CREATE_FILE_INFRA 2>&1
echo "`echo $SHELL`" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1

if [ -f "/etc/os-release" ]; then
    echo "[ version(/etc/os-release) ]"  >> $CREATE_FILE_INFRA 2>&1
    echo "`cat /etc/os-release| grep -i VERSION 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if [ -f "/etc/os-release" ]; then
    echo "[ version(/etc/os-release) ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`cat /etc/os-release 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1

fi

if [ -f "/proc/version" ]; then
    echo "[ version(/proc/version) ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`cat /proc/version 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if command -v uname >/dev/null 2>&1; then
    echo "[ version(uname -a) ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`uname -a 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if command -v lsb_release >/dev/null 2>&1; then
    echo "[ version(lsb_release -a) ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`lsb_release -a 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if command -v ifconfig >/dev/null 2>&1; then
    echo "[ ip(ifconfig) ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`ifconfig -a 2>/dev/null | awk '/inet / {print $2}' | cut -d '/' -f 1 `" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if command -v ip >/dev/null 2>&1; then
    echo "[ ip(ip addr) ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`ip addr | awk '/inet / {print $2}' | cut -d '/' -f 1 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

#netstat -in
if command -v netstat >/dev/null 2>&1; then
    echo "[ netstat -in ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`netstat -in 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi
echo "INSTANCE-ID CHECK..."
echo ">> If it will take more than 3 minutes, please tell the consultant...."
# 인스턴스 ID 확인

if command -v curl >/dev/null 2>&1; then
    # AWS
    AWS_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 30")
    INTENS_ID_STR_AWS="`curl -H "X-aws-ec2-metadata-token: $AWS_TOKEN" -s http://169.254.169.254/latest/dynamic/instance-identity/document 2>/dev/null`"
    INTENS_IP_STR_AWS="`curl -H "X-aws-ec2-metadata-token: $AWS_TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null`"
    AWS_TOKEN=""
    # AWS 빈값 조건문
    if [ "$(echo "$INTENS_ID_STR_AWS" | grep -i "<html" | wc -l)" -eq 1 ]; then
        INTENS_ID_STR_AWS=""
    fi
    if [ "$(echo "$INTENS_IP_STR_AWS" | grep -i "<html" | wc -l)" -eq 1 ]; then
        INTENS_IP_STR_AWS=""
    fi

    # GCP
    INTENS_ID_STR_GCP="`curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/id 2>/dev/null`"
    INTENS_EXTERNAL_IP_GCP=$(curl -H "Metadata-Flavor: Google" -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip" 2>/dev/null) 
    INTENS_INTERNAL_IP_GCP=$(curl -H "Metadata-Flavor: Google" -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" 2>/dev/null)
    #GCP 빈값 조건문
    if [ "$(echo "$INTENS_ID_STR_GCP" | grep -i "<html" | wc -l)" -eq 1 ]; then
        INTENS_ID_STR_GCP=""
    fi
    if [ "$(echo "$INTENS_EXTERNAL_IP_GCP" | grep -i "<html" | wc -l)" -eq 1 ]; then
        INTENS_EXTERNAL_IP_GCP=""
    fi
    if [ "$(echo "$INTENS_INTERNAL_IP_GCP" | grep -i "<html" | wc -l)" -eq 1 ]; then
        INTENS_INTERNAL_IP_GCP=""
    fi


    # AZURE
    INTENS_ID_STR_AZURE="`curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/vmId?api-version=2021-02-01&format=text" 2>/dev/null`"
    INTENS_IP_STR_AZURE="`curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2021-02-01&format=text" 2>/dev/null`"
    #AZURE 빈값 조건문
    if [ "$(echo "$INTENS_ID_STR_AZURE" | grep -i "<html" | wc -l)" -eq 1 ]; then
        INTENS_ID_STR_AZURE=""
    fi
    if [ "$(echo "$INTENS_IP_STR_AZURE" | grep -i "<html" | wc -l)" -eq 1 ]; then
        INTENS_IP_STR_AZURE=""
    fi

else
    INTENS_ID_STR_AWS=""
    INTENS_IP_STR_AWS=""
    INTENS_ID_STR_GCP=""
    INTENS_EXTERNAL_IP_GCP=""
    INTENS_INTERNAL_IP_GCP=""
    INTENS_ID_STR_AZURE=""
    INTENS_IP_STR_AZURE=""
fi



if [ -n "$INTENS_ID_STR_AWS" ] || [ -n "$INTENS_IP_STR_AWS" ]; then
    echo "[AWS 인스턴스 ID]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_ID_STR_AWS" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "[AWS 외부 IP 확인]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_IP_STR_AWS" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if [ -n "$INTENS_ID_STR_GCP" ] || [ -n "$INTENS_EXTERNAL_IP_GCP" ] || [ -n "$INTENS_INTERNAL_IP_GCP" ]; then
    echo "[GCP 인스턴스 ID]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_ID_STR_GCP" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "[GCP 외부 IP 확인]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_EXTERNAL_IP_GCP" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "[GCP 내부 IP 확인]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_INTERNAL_IP_GCP" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if [ -n "$INTENS_ID_STR_AZURE" ] || [ -n "$INTENS_IP_STR_AZURE" ]; then
    echo "[AZURE 인스턴스 ID]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_ID_STR_AZURE" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "[AZURE 외부 IP 확인]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_IP_STR_AZURE" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

echo "[ script execution date and time ]" >> $CREATE_FILE_INFRA 2>&1
echo "$(date "+%Y-%m-%d %T")" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "##############################################################################" >> $CREATE_FILE_INFRA 2>&1

#전자금융기반시설
echo "##############################################################################" >> $CREATE_FILE_FINANCE 2>&1
echo " 		Copyright (C) 2024. hangrp.com. All rights reserved." >> $CREATE_FILE_FINANCE 2>&1
echo " 		Version: $VER_info" >> $CREATE_FILE_FINANCE 2>&1
echo "##############################################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "[ Startup account ]">> $CREATE_FILE_FINANCE 2>&1
echo "`id 2>/dev/null`" >> $CREATE_FILE_FINANCE 2>/dev/null
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[ startup shell ]" >> $CREATE_FILE_FINANCE 2>&1
echo "`echo $SHELL`" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

if [ -f "/etc/os-release" ]; then
    echo "[ version(/etc/os-release) ]"  >> $CREATE_FILE_FINANCE 2>&1
    echo "`cat /etc/os-release| grep -i VERSION 2>/dev/null`" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if [ -f "/etc/os-release" ]; then
    echo "[ version(/etc/os-release) ]" >> $CREATE_FILE_FINANCE 2>&1
    echo "`cat /etc/os-release 2>/dev/null`" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if [ -f "/proc/version" ]; then
    echo "[ version(/proc/version) ]" >> $CREATE_FILE_FINANCE 2>&1
    echo "`cat /proc/version 2>/dev/null`" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if command -v uname >/dev/null 2>&1; then
    echo "[ version(uname -a) ]" >> $CREATE_FILE_FINANCE 2>&1
    echo "`uname -a 2>/dev/null`" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if command -v lsb_release >/dev/null 2>&1; then
    echo "[ version(lsb_release) ]" >> $CREATE_FILE_FINANCE 2>&1
    echo "`lsb_release -a 2>/dev/null`" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if command -v ifconfig >/dev/null 2>&1; then
    echo "[ ip(ifconfig) ]" >> $CREATE_FILE_FINANCE 2>&1
    echo "`ifconfig -a 2>/dev/null | awk '/inet / {print $2}' | cut -d '/' -f 1 `" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if command -v ip >/dev/null 2>&1; then
    echo "[ ip(ip addr) ]" >> $CREATE_FILE_FINANCE 2>&1
    echo "`ip addr | awk '/inet / {print $2}' | cut -d '/' -f 1 2>/dev/null`" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi


if command -v netstat >/dev/null 2>&1; then
    echo "[ netstat -in ]" >> $CREATE_FILE_FINANCE 2>&1
    echo "`netstat -in 2>/dev/null`" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if [ -n "$INTENS_ID_STR_AWS" ] || [ -n "$INTENS_IP_STR_AWS" ]; then
    echo "[AWS 인스턴스 ID]" >> $CREATE_FILE_FINANCE 2>&1
    echo "$INTENS_ID_STR_AWS" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "[AWS 외부 IP 확인]" >> $CREATE_FILE_FINANCE 2>&1
    echo "$INTENS_IP_STR_AWS" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if [ -n "$INTENS_ID_STR_GCP" ] || [ -n "$INTENS_EXTERNAL_IP_GCP" ] || [ -n "$INTENS_INTERNAL_IP_GCP" ]; then
    echo "[GCP 인스턴스 ID]" >> $CREATE_FILE_FINANCE 2>&1
    echo "$INTENS_ID_STR_GCP" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "[GCP 외부 IP 확인]" >> $CREATE_FILE_FINANCE 2>&1
    echo "$INTENS_EXTERNAL_IP_GCP" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "[GCP 내부 IP 확인]" >> $CREATE_FILE_FINANCE 2>&1
    echo "$INTENS_INTERNAL_IP_GCP" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

if [ -n "$INTENS_ID_STR_AZURE" ] || [ -n "$INTENS_IP_STR_AZURE" ]; then
    echo "[AZURE 인스턴스 ID]" >> $CREATE_FILE_FINANCE 2>&1
    echo "$INTENS_ID_STR_AZURE" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "[AZURE 외부 IP 확인]" >> $CREATE_FILE_FINANCE 2>&1
    echo "$INTENS_IP_STR_AZURE" >> $CREATE_FILE_FINANCE 2>/dev/null
    echo "" >> $CREATE_FILE_FINANCE 2>&1
fi

echo "[ script execution date and time ]" >> $CREATE_FILE_FINANCE 2>&1
echo "$(date "+%Y-%m-%d %T")" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "##############################################################################" >> $CREATE_FILE_FINANCE 2>&1


# 권한 확인 사용법
# if perm_000 '/tmp/han/test.sh' ; then
#     ls -l '/tmp/han/test.sh'
#     echo "False"
# else
#     ls -l '/tmp/han/test.sh'
#     echo "Ture"
# fi

perm_000() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    
    # owner(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c2)" = "r" ] || [ "$(echo "$PERMS" | cut -c3)" = "w" ] || [ "$(echo "$PERMS" | cut -c4)" = "x" ]; then
        return 1
    fi

    # group(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c5)" = "r" ] || [ "$(echo "$PERMS" | cut -c6)" = "w" ] || [ "$(echo "$PERMS" | cut -c7)" = "x" ]; then
        return 1
    fi

    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c8)" = "r" ] || [ "$(echo "$PERMS" | cut -c9)" = "w" ] || [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}


perm_400() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    
    # owner(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c3)" = "w" ] || [ "$(echo "$PERMS" | cut -c4)" = "x" ]; then
        return 1
    fi

    # group(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c5)" = "r" ] || [ "$(echo "$PERMS" | cut -c6)" = "w" ] || [ "$(echo "$PERMS" | cut -c7)" = "x" ]; then
        return 1
    fi

    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c8)" = "r" ] || [ "$(echo "$PERMS" | cut -c9)" = "w" ] || [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}

perm_600() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    
    # owner(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c4)" = "x" ]; then
        return 1
    fi

    # group(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c5)" = "r" ] || [ "$(echo "$PERMS" | cut -c6)" = "w" ] || [ "$(echo "$PERMS" | cut -c7)" = "x" ]; then
        return 1
    fi

    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c8)" = "r" ] || [ "$(echo "$PERMS" | cut -c9)" = "w" ] || [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}



perm_640() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    
    # owner(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c4)" = "x" ]; then
        return 1
    fi

    # group(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c6)" = "w" ] || [ "$(echo "$PERMS" | cut -c7)" = "x" ]; then
        return 1
    fi

    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c8)" = "r" ] || [ "$(echo "$PERMS" | cut -c9)" = "w" ] || [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}


perm_644() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    
    # owner(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c4)" = "x" ]; then
        return 1
    fi

    # group(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c6)" = "w" ] || [ "$(echo "$PERMS" | cut -c7)" = "x" ]; then
        return 1
    fi

    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c9)" = "w" ] || [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}

perm_750() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    

    # group(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c6)" = "w" ]; then
        return 1
    fi

    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c8)" = "r" ] || [ "$(echo "$PERMS" | cut -c9)" = "w" ] || [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}

perm_744() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    
    # group(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c6)" = "w" ] || [ "$(echo "$PERMS" | cut -c7)" = "x" ]; then
        return 1
    fi

    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c9)" = "w" ] || [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}

perm_766() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    
    # group(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c7)" = "x" ]; then
        return 1
    fi

    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}



perm_770() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c8)" = "r" ] || [ "$(echo "$PERMS" | cut -c9)" = "w" ] || [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}


perm_775() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c9)" = "w" ]; then
        return 1
    fi
    return 0
}


perm_776() {
    PERMS=$(ls -ldL "$1" | awk '{print $1}')
    # other(r:4, w:2, x:1)
    if [ "$(echo "$PERMS" | cut -c10)" = "x" ]; then
        return 1
    fi

    return 0
}

#grep -A -B 옵션 안될때 사용
# 사용법 : grep_AB_shell "ikeuser|smmsp" "/etc/passwd" "3" "3"
grep_AB_shell() {
    patterns="$1"
    file="$2"
    lines_before="$3"
    lines_after="$4"
    output_file="${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp"

    # 파일 초기화
    printf "" > "$output_file"

    # | 를 공백으로 변경
    read_patterns=$(echo $patterns | sed 's/|/ /g')

    # 각 패턴 처리
    for p in $read_patterns; do
        result_found=false

        # 패턴별 grep 실행
        egrep -i -n "$p" "$file" | cut -f1 -d: | while read lineno; do
            if [ "$result_found" = false ]; then
                echo "=> grep -i \"$p\" \"$file\"" >> "$output_file"
                result_found=true
            fi

            start=$((lineno - lines_before))
            end=$((lineno + lines_after))
            [ $start -lt 1 ] && start=1
            sed -n "${start},${end}p" "$file" >> "$output_file"
        done

        if [ "$result_found" = true ]; then
            echo "-----" >> "$output_file"
        fi
    done
}

#함수 사용 예시(솔라리스시 사용)
# SOLARIS_CHECK_SERVICES "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis" "NIS"
SOLARIS_CHECK_SERVICES() {
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        SOLARIS_SERVICES_INFO=$1
        SOLARIS_SERVICES_STRING=$2
        output_file="${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp"

        if command -v inetadm >/dev/null 2>&1; then
            echo "" > $output_file 2>&1
            if [ "$(inetadm | egrep -i "$SOLARIS_SERVICES_INFO" | wc -l)" -gt 0 ]; then
                echo "[inetadm 명령어 확인 (inetadm | egrep -i \"$SOLARIS_SERVICES_INFO\")]" >> $output_file 2>&1
                inetadm | egrep -i "$SOLARIS_SERVICES_INFO" >> $output_file 2>&1
            else
                if command -v svcs >/dev/null 2>&1; then
                    echo "[inetadm 명령어 확인 (inetadm | egrep -i \"$SOLARIS_SERVICES_INFO\")]" >> $output_file 2>&1
                    echo "-$SOLARIS_SERVICES_STRING 서비스가 존재하지 않음" >> $output_file 2>&1
                    echo "" >> $output_file 2>&1
                    echo "[svcs 명령어 확인 (svcs -a | egrep -i \"$SOLARIS_SERVICES_INFO\")]" >> $output_file 2>&1
                    if [ "$(svcs -a | egrep -i "$SOLARIS_SERVICES_INFO" | wc -l)" -gt 0 ]; then
                        svcs -a | egrep -i "$SOLARIS_SERVICES_INFO" >> $output_file 2>&1
                    else
                        echo "-$SOLARIS_SERVICES_STRING 서비스가 존재하지 않음" >> $output_file 2>&1
                    fi
                fi
            fi
        else
            if command -v svcs >/dev/null 2>&1; then
                echo "[svcs 명령어 확인 (svcs -a | egrep -i \"$SOLARIS_SERVICES_INFO\")]" >> $output_file 2>&1
                if [ "$(svcs -a | egrep -i "$SOLARIS_SERVICES_INFO" | wc -l)" -gt 0 ]; then
                    svcs -a | egrep -i "$SOLARIS_SERVICES_INFO" >> $output_file 2>&1
                else
                    echo "-$SOLARIS_SERVICES_STRING 서비스가 존재하지 않음" >> $output_file 2>&1
                fi
            fi
        fi
    fi
}



# 파일복사함수 사용법 아래 주석 참조
# 사용법 : FILE_COPY "/etc/named.conf" "/etc/bind/named.conf"
FILE_COPY(){
    for file in "$@"; do
        if [ -e "$file" ]; then
            filesize=$(ls -l "$file" | awk '{print $5}')
            if [ ! "$filesize" -gt 500000 ]; then
                file_name=$(echo "${file}" | tr '/' '_' | sed 's/^_//')
                
                #링크파일 과 일반파일의 길이가 다르기 때문에 길이를 비교하여 링크파일인지 일반파일인지 구분
                len1=$(ls -l "$file" | wc -c)
                len2=$(ls -lLd "$file" | wc -c)
                # 파일정보가 이미 존재하는지 아닌지 확인
                if [ ! -f "${CREATE_FILE_DIR}/FILE_DETAIL/${file_name}.hangrp" ]; then
                    # 일반파일,링크 파일 확인
                    if [ "$len1" -eq "$len2" ]; then
                        #일반파일
                        cat ${file} > "${CREATE_FILE_DIR}/FILE_DETAIL/${file_name}.hangrp"
                        echo "-----" >> "${CREATE_FILE_DIR}/FILE_DETAIL/___FILE_AUTH__CHECK.hangrp"
                        ls -al ${file} >> "${CREATE_FILE_DIR}/FILE_DETAIL/___FILE_AUTH__CHECK.hangrp"
                        echo "-----" >> "${CREATE_FILE_DIR}/FILE_DETAIL/___FILE_AUTH__CHECK.hangrp"
                    else
                        cat ${file} > "${CREATE_FILE_DIR}/FILE_DETAIL/${file_name}.hangrp"
                        echo "-----" >> "${CREATE_FILE_DIR}/FILE_DETAIL/___FILE_AUTH__CHECK.hangrp"
                        ls -al ${file} >> "${CREATE_FILE_DIR}/FILE_DETAIL/___FILE_AUTH__CHECK.hangrp"
                        ls -alLd ${file} >> "${CREATE_FILE_DIR}/FILE_DETAIL/___FILE_AUTH__CHECK.hangrp"
                        echo "-----" >> "${CREATE_FILE_DIR}/FILE_DETAIL/___FILE_AUTH__CHECK.hangrp"

                    fi
                fi
            fi
        fi
    done
}

# /etc/xinetd.d/ 가 존재할 경우
if [ -d "/etc/xinetd.d/" ]; then
    XINETD_PATH_01=$(find /etc/xinetd.d/ -type f)
        for XINETD_PATH_02 in $XINETD_PATH_01; do
            FILE_COPY "$XINETD_PATH_02"
        done
fi
#VSFTPD_PATH 변수에 내용이 존재할 경우
if [ -n "$VSFTPD_PATH" ]; then
    for VSFTPD_PATH_01 in $VSFTPD_PATH; do
        FILE_COPY "$VSFTPD_PATH_01"
    done
fi
#PROFTPD_PATH
if [ -n "$PROFTPD_PATH" ]; then
    for PROFTPD_PATH_01 in $PROFTPD_PATH; do
        FILE_COPY "$PROFTPD_PATH_01"
    done
fi
#FTPUSERS_PATH
if [ -n "$FTPUSERS_PATH" ]; then
    for FTPUSERS_PATH_TMP_01 in $FTPUSERS_PATH; do
        FILE_COPY "$FTPUSERS_PATH_TMP_01"
    done
fi
#SENDMAIL_PATH
if [ -n "$SENDMAIL_PATH" ]; then
    for SENDMAIL_PATH_01 in $SENDMAIL_PATH; do
        FILE_COPY "$SENDMAIL_PATH_01"
    done
fi
#POSTFIX_PATH
if [ -n "$POSTFIX_PATH" ]; then
    for POSTFIX_PATH_01 in $POSTFIX_PATH; do
        FILE_COPY "$POSTFIX_PATH_01"
    done
fi
#POSTFIX_POSTUPER_PATH
if [ -n "$POSTFIX_POSTUPER_PATH" ]; then
    for POSTFIX_POSTUPER_PATH_01 in $POSTFIX_POSTUPER_PATH; do
        FILE_COPY "$POSTFIX_POSTUPER_PATH_01"
    done
fi
#EXIM_PATH
if [ -n "$EXIM_PATH" ]; then
    for EXIM_PATH_TMP_01 in $EXIM_PATH; do
        FILE_COPY "$EXIM_PATH_TMP_01"
    done
fi
#EXIM_EXECUTE_PATH
if [ -n "$EXIM_EXECUTE_PATH" ]; then
    for EXIM_EXECUTE_PATH_01 in $EXIM_EXECUTE_PATH; do
        FILE_COPY "$EXIM_EXECUTE_PATH_01"
    done
fi
#DNS_PATH
if [ -n "$DNS_PATH" ]; then
    for DNS_PATH_01 in $DNS_PATH; do
        FILE_COPY "$DNS_PATH_01"
    done
fi
#SNMP_PATH
if [ -n "$SNMP_PATH" ]; then
    for SNMP_PATH_01 in $SNMP_PATH; do
    FILE_COPY "$SNMP_PATH_01"
    done
fi



#SUID SGID file find 실행(root(/)에서 실행시킬 목적이면 주석 아래세번째 변수,echo 주석 제거)
FIND_SUIDSGID=""
CHECK_SUID_SGID_FILE="${CREATE_FILE_DIR}/$(hostname)+${HOST_IP}+SUID_SGID_FILE.hangrp"
# echo "FIND_SUIDSGID_START"
# FIND_SUIDSGID=$(find / -xdev -type f \( -perm -04000 -o -perm -02000 \) -exec ls -alLd {} \; 2>/dev/null)
# echo "FIND_SUIDSGID_END"


#world writable file find 실행
CHECK_WORLD_WRITABLE_FILES="${CREATE_FILE_DIR}/$(hostname)+${HOST_IP}+WORLD_WRITABLE_FILES.hangrp"

#High hidden file find 실행(root(/)에서 실행시킬 목적이면 주석 아래세번째 변수,echo 주석 제거)
CHECK_HIIDEN_FILE="${CREATE_FILE_DIR}/$(hostname)+${HOST_IP}+HIIDEN_FILE.hangrp"
FIND_HIIDEN_FILE=""
# echo "FIND_HIIDEN_FILE_START"
# FIND_HIDDEN_FILE=$(find / -xdev \( -type f -o -type d \) -name ".*" -exec ls -alLd {} \; 2>/dev/null)
# echo "FIND_HIIDEN_FILE_END"

#No user nogroup file find 실행
CHECK_NOUSER_NOGROUP_FILE="${CREATE_FILE_DIR}/$(hostname)+${HOST_IP}+NOUSER_NOGROUP_FILE.hangrp"

#패치 관련 정보(U-42,SRV-118)
CHECK_LATEST_PATCHES_FILE="${CREATE_FILE_DIR}/$(hostname)+${HOST_IP}+LATEST_PATCHES_FILE.hangrp"

#SSH_CONFIG_PATH
if [ -s "/etc/ssh/sshd_config" ]; then
    SSH_CONFIG_PATH="/etc/ssh/sshd_config"
elif [ -s "/etc/sshd_config" ]; then
    SSH_CONFIG_PATH="/etc/sshd_config"
elif [ -s "/usr/local/etc/sshd_config" ]; then
    SSH_CONFIG_PATH="/usr/local/etc/sshd_config"
elif [ -s "/usr/local/sshd/etc/sshd_config" ]; then
    SSH_CONFIG_PATH="/usr/local/sshd/etc/sshd_config"
elif [ -s "/usr/local/ssh/etc/sshd_config" ]; then
    SSH_CONFIG_PATH="/usr/local/ssh/etc/sshd_config"
elif [ -s "/etc/opt/ssh/sshd_config" ]; then
    SSH_CONFIG_PATH="/etc/opt/ssh/sshd_config"
elif [ -s "/opt/ssh/etc/sshd_config" ]; then
    SSH_CONFIG_PATH="/opt/ssh/etc/sshd_config"
else
    SSH_CONFIG_PATH=$(find /etc /usr -type f -name sshd_config 2>/dev/null | head -n 1)
fi
#SSH_CONFIG_PATH
if [ -n "$SSH_CONFIG_PATH" ]; then
    FILE_COPY "$SSH_CONFIG_PATH"
fi

#"/etc/passwdqc.conf" 파일 위치
if [ -s "/etc/passwdqc.conf" ]; then
    PASSWDQC_CONF_PATH="/etc/passwdqc.conf"
elif [ -s "/etc/security/passwdqc.conf" ]; then
    PASSWDQC_CONF_PATH="/etc/security/passwdqc.conf"
elif [ -s "/usr/local/etc/passwdqc.conf" ]; then
    PASSWDQC_CONF_PATH="/usr/local/etc/passwdqc.conf"
elif [ -s "/usr/local/etc/passwdqc.conf" ]; then
    PASSWDQC_CONF_PATH="/usr/local/etc/passwdqc.conf"
elif [ -s "/usr/local/lib/security/passwdqc.conf" ]; then
    PASSWDQC_CONF_PATH="/usr/local/lib/security/passwdqc.conf"
elif [ -s "/usr/lib/security/passwdqc.conf" ]; then
    PASSWDQC_CONF_PATH="/usr/lib/security/passwdqc.conf"
fi
#PASSWDQC_CONF_PATH
if [ -n "$PASSWDQC_CONF_PATH" ]; then
    FILE_COPY "$PASSWDQC_CONF_PATH"
fi


COMMAND_COPY(){
    echo "COMMAND_COPY_PROGRESS_START"

    man sshd_config 2>/dev/null >> "${CREATE_FILE_DIR}/COMMAND_DETAIL/man_sshd_config.hangrp" 
    man pam_securetty 2>/dev/null >> "${CREATE_FILE_DIR}/COMMAND_DETAIL/man_pam_securetty.hangrp" 
    netstat -an 2>/dev/null >> "${CREATE_FILE_DIR}/COMMAND_DETAIL/netstat-an.hangrp" 
    ss -an 2>/dev/null >> "${CREATE_FILE_DIR}/COMMAND_DETAIL/ss-an.hangrp" 
    echo $PATH 2>/dev/null >> "${CREATE_FILE_DIR}/COMMAND_DETAIL/PATH.hangrp" 
    ps -ef 2>/dev/null >> "${CREATE_FILE_DIR}/COMMAND_DETAIL/ps-ef.hangrp" 
    if command -v systemctl >/dev/null 2>&1; then
        systemctl list-units --type service | col -b | egrep -i ".service" >> "${CREATE_FILE_DIR}/COMMAND_DETAIL/systemctl_list-unit-files.hangrp" 2>/dev/null
        mkdir -p "${CREATE_FILE_DIR}/COMMAND_DETAIL/systemctl"
        SYSTEMCTL_SERVICES=$(systemctl list-units --type service | col -b | awk '{print $1}' | egrep -i ".service")
        for SYSTEMCTL_SERVICE in $SYSTEMCTL_SERVICES; do
            systemctl status $SYSTEMCTL_SERVICE >> "${CREATE_FILE_DIR}/COMMAND_DETAIL/systemctl/${SYSTEMCTL_SERVICE}.hangrp" 2>/dev/null
        done
    fi


    echo "COMMAND_COPY_PROGRESS_COMPLETE"
}



#비밀번호 사용 여부 확인
if [ $SOLARIS_CHECK_00 -eq 1 ]; then
#solaris 쓸 경우
PASSWORDAUTHENTICATION_DEFAULT=$(man sshd_config | col -b | /usr/xpg4/bin/awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*PasswordAuthentication[[:space:]]*$/{flag=1; next} flag {if (/^[[:space:]]*$/) flag=0; else {gsub(/[[:space:]]+/, " ", $0); printf "%s", $0}}' | /usr/xpg4/bin/awk 'BEGIN{IGNORECASE=1} /defa|ault/{print substr($0, match(tolower($0), /defa|ault/))}') 2>/dev/null
else
#solaris 아닌 경우
PASSWORDAUTHENTICATION_DEFAULT=$(man sshd_config | col -b | awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*PasswordAuthentication[[:space:]]*$/{flag=1; next} flag {if (/^[[:space:]]*$/) flag=0; else {gsub(/[[:space:]]+/, " ", $0); printf "%s", $0}}' | awk 'BEGIN{IGNORECASE=1} /defa|ault/{print substr($0, match(tolower($0), /defa|ault/))}') 2>/dev/null
fi
if [ -z "$PASSWORDAUTHENTICATION_DEFAULT" ]; then
    PASSWORDAUTHENTICATION_DEFAULT="./COMMAND_DETAIL/man_sshd_config.hangrp 내용 확인 필요"
fi



if [ $SOLARIS_CHECK_00 -eq 1 ]; then
#solaris 쓸 경우
PUBKEYAUTHENTICATION_DEFAULT=$(man sshd_config | col -b | /usr/xpg4/bin/awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*PubkeyAuthentication[[:space:]]*$/{flag=1; next} flag {if (/^[[:space:]]*$/) flag=0; else {gsub(/[[:space:]]+/, " ", $0); printf "%s", $0}}' | /usr/xpg4/bin/awk 'BEGIN{IGNORECASE=1} /defa|ault/{print substr($0, match(tolower($0), /defa|ault/))}') 2>/dev/null
else
PUBKEYAUTHENTICATION_DEFAULT=$(man sshd_config | col -b | awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*PubkeyAuthentication[[:space:]]*$/{flag=1; next} flag {if (/^[[:space:]]*$/) flag=0; else {gsub(/[[:space:]]+/, " ", $0); printf "%s", $0}}' | awk 'BEGIN{IGNORECASE=1} /defa|ault/{print substr($0, match(tolower($0), /defa|ault/))}') 2>/dev/null
fi
if [ -z "$PUBKEYAUTHENTICATION_DEFAULT" ]; then
    PUBKEYAUTHENTICATION_DEFAULT="./COMMAND_DETAIL/man_sshd_config.hangrp 내용 확인 필요"
fi




if [ $SOLARIS_CHECK_00 -eq 1 ]; then
#solaris 쓸 경우
PERMITROOTLOGIN_DEFAULT=$(man sshd_config | col -b | /usr/xpg4/bin/awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*PermitRootLogin[[:space:]]*$/{flag=1; next} flag {if (/^[[:space:]]*$/) flag=0; else {gsub(/[[:space:]]+/, " ", $0); printf "%s", $0}}' | /usr/xpg4/bin/awk 'BEGIN{IGNORECASE=1} /defa|ault/{print substr($0, match(tolower($0), /defa|ault/))}') 2>/dev/null
else
PERMITROOTLOGIN_DEFAULT=$(man sshd_config | col -b | awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*PermitRootLogin[[:space:]]*$/{flag=1; next} flag {if (/^[[:space:]]*$/) flag=0; else {gsub(/[[:space:]]+/, " ", $0); printf "%s", $0}}' | awk 'BEGIN{IGNORECASE=1} /defa|ault/{print substr($0, match(tolower($0), /defa|ault/))}') 2>/dev/null
fi


if [ -z "$PERMITROOTLOGIN_DEFAULT" ]; then
    PERMITROOTLOGIN_DEFAULT="./COMMAND_DETAIL/man_sshd_config.hangrp 내용 확인 필요"
fi


if [ "$(cat "$SSH_CONFIG_PATH" | grep -i "^PasswordAuthentication" | grep -v '#')" ]; then
    PASSWORDAUTHENTICATION_DEFAULT=$(cat "$SSH_CONFIG_PATH" | grep -i "^PasswordAuthentication" | grep -v '#')
    else
    PASSWORDAUTHENTICATION_DEFAULT="PasswordAuthentication 설정값 없음($PASSWORDAUTHENTICATION_DEFAULT)"
fi

if [ "$(cat "$SSH_CONFIG_PATH" | grep -i "^PubkeyAuthentication" | grep -v '#')" ]; then
    PUBKEYAUTHENTICATION_DEFAULT=$(cat "$SSH_CONFIG_PATH" | grep -i "^PubkeyAuthentication" | grep -v '#')
    else
    PUBKEYAUTHENTICATION_DEFAULT="PubkeyAuthentication 설정값 없음($PUBKEYAUTHENTICATION_DEFAULT)"
fi

#비밀번호 사용계정 확인
USER_PASSWORD_USE="${CREATE_FILE_DIR}/VULNERABILITY_REF/USER_PASSWORD_USE.hangrp"
if [ -f "/etc/shadow" ]; then
    grep -v '*LOCK*' /etc/shadow | awk -F: '$2 !~ /^(NP|\*LK\*|!\*|!|\*)/ {print $1}' >/dev/null >> $USER_PASSWORD_USE 2>&1
else
    # awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$7}' /etc/passwd    >> $USER_PASSWORD_USE 2>&1

    awk -F':' '
        $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
            print $1":"$7
        }
    ' /etc/passwd >> "$USER_PASSWORD_USE" 2>&1

fi


#사용자 환경설정 파일 생성
USER_ENVIROMENT_FILE(){
    echo "USER_ENVIRONMENT_FILE_PROGRESS_START"

    mkdir -p "${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE"

    GLOBAL_PROFILE_FILES="/etc/profile /etc/.profile /etc/bashrc /etc/csh.cshrc /etc/csh.login /etc/csh.logout /etc/zshrc /etc/zprofile /etc/zlogin /etc/zlogout /etc/zshenv /etc/ksh.kshrc /etc/ksh.login /etc/ksh.logout /etc/kshrc"

    for GLOBAL_PROFILE_FILE in $GLOBAL_PROFILE_FILES; do
        if [ -f "$GLOBAL_PROFILE_FILE" ]; then
            cat ${GLOBAL_PROFILE_FILE} > "${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE/$(basename ${GLOBAL_PROFILE_FILE}).hangrp"
        fi
    done

    # ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$6}' /etc/passwd)

    ACCOUNTS=$(awk -F':' '
        $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
            print $1":"$6
        }
    ' /etc/passwd)

    for ACCOUNT_INFO in $ACCOUNTS; do
        

        # Define a list of profile files
        PROFILE_FILES=".bashrc .bash_profile .bash_login .profile .bash_logout .kshrc .zshrc .zprofile .zshenv .zlogin .zlogout .cshrc .tcshrc .login .logout .cshdirs .shrc .ashrc .dashrc .yashrc .fishrc .environment .env"

        for PROFILE_FILE in $PROFILE_FILES; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            HOME_DIR=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            FULL_PATH="$HOME_DIR/$PROFILE_FILE"
            if [ -f "$FULL_PATH" ]; then
                mkdir -p "${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE/$USERNAME"
                cat "$FULL_PATH" > "${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE/${USERNAME}/_${PROFILE_FILE}"
            fi
        done
    done

    echo "USER_ENVIRONMENT_FILE_PROGRESS_COMPLETE"
}


#U-01,SRV-026
ACCOUNT_REMOTE_ACCESS_RESTRICTION(){
    echo "COMMAND_COPY_PROGRESS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-01_SRV-026.hangrp"
    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    #1 사용 2미사용
    #텔넷사용여부
    TELNET_CHECK_01=0
    #텔넷 root접속가능여부
    TELNET_CHECK_02=0
    #sshd사용여부
    SSHD_CHECK_01=0
    #내용
    TELNET_CHECK_02=""

    #TLENT 포트 여부 확인
    if command -v netstat >/dev/null 2>&1; then
        COMMAND_TMP_001=$(netstat -an | awk '/[.:]23 /')
        if [ -n "$COMMAND_TMP_001" ]; then
        #if netstat -an | awk '/[.:]23 /' >/dev/null 2>&1; then
            #사용
            TELNET_CHECK_01=1
            TELNET_CHECK_02=$(netstat -an | awk '/[.:]23 /')
        else
            #미사용
            TELNET_CHECK_01=0
        fi
        COMMAND_TMP_001=""
    else
        if command -v ss >/dev/null 2>&1; then
            COMMAND_TMP_001=$(ss -an | awk '/[.:]23 /')
            if [ -n "$COMMAND_TMP_001" ]; then
            #if ss -an | awk '/[.:]23 /' >/dev/null 2>&1; then
                #사용
                TELNET_CHECK_01=1
                TELNET_CHECK_02=$(ss -an | awk '/[.:]23 /')
            else
                #미사용
                TELNET_CHECK_01=0
            fi
            COMMAND_TMP_001=""
        fi
    fi


    #SSHD 포트 여부 확인
    if command -v netstat >/dev/null 2>&1; then
        COMMAND_TMP_001=$(netstat -an | awk '/[.:]22 /')
        if [ -n "$COMMAND_TMP_001" ]; then
        #if netstat -an | awk '/[.:]22 /' >/dev/null 2>&1; then
            #사용
            SSHD_PORT="22"
            SSHD_CHECK_01=1
        else
            #미사용(수정해야함)
            SSHD_CHECK_01=1
            if [ -f "$SSH_CONFIG_PATH" ]; then
                SSHD_PORT=$(cat $SSH_CONFIG_PATH | egrep -i '^port ' | grep -v '#')
                SSHD_PORT=$(echo $SSHD_PORT | awk '{print $2}')
            fi
        fi
        COMMAND_TMP_001=""
    else
        if command -v ss >/dev/null 2>&1; then
            COMMAND_TMP_001=$(ss -an | awk '/[.:]22 /')
            if [ -n "$COMMAND_TMP_001" ]; then
            #if ss -an | awk '/[.:]22 /' >/dev/null 2>&1; then
                #사용
                SSHD_PORT="22"
                SSHD_CHECK_01=1
            else
                #미사용(수정해야함)
                SSHD_CHECK_01=1
                if [ -f "$SSH_CONFIG_PATH" ]; then
                    SSHD_PORT=$(cat $SSH_CONFIG_PATH | egrep -i '^port ' | grep -v '#')
                    SSHD_PORT=$(echo $SSHD_PORT | awk '{print $2}')
                fi
            fi
            COMMAND_TMP_001=""
        fi
    fi

    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/securetty" "/etc/pam.d/login"

        # telnet 사용시
        if [ "$TELNET_CHECK_01" = 1 ]; then
            if [ "$(cat /etc/securetty 2>/dev/null | grep -i "pts" | grep -v '#' | wc -l )" -eq 0 ]; then
                if [ "$(cat /etc/pam.d/login | grep "pam_securetty.so" | grep -v "#" | wc -l)" -eq 0 ]; then
                    #접속가능
                    TELNET_CHECK_02=1
                else
                    #접속불가능
                    TELNET_CHECK_02=0
                fi
            else
                #접속가능
                TELNET_CHECK_02=1
            fi
        fi


        echo "[서비스 상태 확인]"   >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "-Telnet: 활성화(23포트LISTEN)" >> $OUTPUT_FILE 2>&1
            if [ "$SSHD_PORT" = "22" ]; then
                echo "-SSH: 활성화(22포트LISTEN)" >> $OUTPUT_FILE 2>&1
                else
                echo "-SSH: $SSHD_PORT 로 포트 변경" >> $OUTPUT_FILE 2>&1
            fi
            else
            echo "-Telnet: 비활성화" >> $OUTPUT_FILE 2>&1
            if [ "$SSHD_PORT" = "22" ]; then
                echo "-SSH: 활성화(22포트LISTEN)" >> $OUTPUT_FILE 2>&1
                else
                echo "-SSH: $SSHD_PORT 로 포트 변경" >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        #텔넷 사용할 경우
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "[telnet root원격접속확인]" >> $OUTPUT_FILE 2>&1
            if [ "$TELNET_CHECK_02" = 1 ]; then
                echo "-telnet root 원격접속가능" >> $OUTPUT_FILE 2>&1
                else
                echo "-telnet root 원격접속 불가능" >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1


        # ssh 사용할 경우
        if [ -f "$SSH_CONFIG_PATH" ] ; then
            echo "[PermitRootLogin 설정값 확인('${SSH_CONFIG_PATH}')]" >> $OUTPUT_FILE 2>&1
                if [ "$(cat "$SSH_CONFIG_PATH" | grep "PermitRootLogin" | grep -v "#")" = "" ] ; then
                    echo "-설정값 미존재 default값 : $PERMITROOTLOGIN_DEFAULT" >> $OUTPUT_FILE 2>&1
                else
                    cat $SSH_CONFIG_PATH | grep "PermitRootLogin" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    # #U-01,SRV-026 양취판단
                    if [ "$(cat $SSH_CONFIG_PATH | grep "PermitRootLogin" | grep -v "#" | awk '{print $2}' | awk '{print $1}'| tail -n 1)" = "no" ]; then
                        SECURITY_STATUS="Y"
                    fi
                fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        echo "----------" >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "#Telnet LISTEN확인#" >> $OUTPUT_FILE 2>&1
            if command -v netstat >/dev/null 2>&1; then
                netstat -an | awk '/[.:]23 /' >> $OUTPUT_FILE 2>&1
            else
                ss -an | awk '/[.:]23 /' >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1
        fi

        if [ "$TELNET_CHECK_01" = 1 ]; then
            if [ "$(cat /etc/securetty 2>/dev/null | grep -i "pts" | grep -v '#' | wc -l )" -eq 0 ]; then
                if [ "$(cat /etc/pam.d/login 2>/dev/null | grep -i "pam_securetty.so" | grep -v "#" | wc -l)" -eq 0 ]; then
                    if [ "$(cat /etc/pam.d/login 2>/dev/null | grep -i "pam_securetty.so" | wc -l)" -eq 0 ]; then
                        echo "#telnet /etc/pam.d/login확인#" >> $OUTPUT_FILE 2>&1
                        cat /etc/pam.d/login 2>/dev/null | grep -i "pam_securetty.so" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "#telnet /etc/securetty확인#" >> $OUTPUT_FILE 2>&1
                        cat /etc/securetty 2>/dev/null | grep -i "pts" | grep -v '#' >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        else
                        echo "#telnet /etc/pam.d/login확인#" >> $OUTPUT_FILE 2>&1
                        cat /etc/pam.d/login 2>/dev/null | grep -i "pam_securetty.so" | grep -v "#" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "#telnet /etc/securetty확인#" >> $OUTPUT_FILE 2>&1
                        cat /etc/securetty 2>/dev/null | grep -i "pts" | grep -v '#' >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            else
                    echo "#telnet /etc/securetty확인#" >> $OUTPUT_FILE 2>&1
                    cat /etc/securetty 2>/dev/null | grep -i "pts" | grep -v '#' >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
            fi
        fi
        # /etc/passwd 에서 root 쉘 접속 여부 확인
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[root 쉘 접속 가능 여부 확인(/etc/passwd)]" >> $OUTPUT_FILE 2>&1
        cat /etc/passwd | grep -i "^root" | grep -v "#" >> $OUTPUT_FILE 2>&1

    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/default/login"

        # telnet 사용시
        if [ "$TELNET_CHECK_01" = 1 ]; then
            if [ "$(cat /etc/default/login | grep -i "CONSOLE=" | grep -v '#'| wc -l )" -eq 0 ]; then
                #접속가능
                TELNET_CHECK_02=1

            else
                if [ "$(cat /etc/default/login | grep -i "/dev/console" | grep -v "#" | wc -l)" -eq 0 ]; then
                    #접속불가능
                    TELNET_CHECK_02=0
                else
                    #접속가능
                    TELNET_CHECK_02=1
                fi
            fi
        fi


        echo "[서비스 상태 확인]"   >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "-Telnet: 활성화(23포트LISTEN)" >> $OUTPUT_FILE 2>&1
            else
            echo "-Telnet: 비활성화" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        #텔넷 사용할 경우
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "[telnet root원격접속확인]" >> $OUTPUT_FILE 2>&1
            if [ "$TELNET_CHECK_02" = 1 ]; then
                echo "-telnet root 원격접속가능" >> $OUTPUT_FILE 2>&1
                else
                echo "-telnet root 원격접속 불가능" >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1


        # ssh 사용할 경우
        if [ -f "$SSH_CONFIG_PATH" ] ; then
            echo "[PermitRootLogin 설정값 확인('${SSH_CONFIG_PATH}')]" >> $OUTPUT_FILE 2>&1
                if [ "$(cat "$SSH_CONFIG_PATH" | grep "PermitRootLogin" | grep -v "#")" = "" ] ; then
                    echo "-설정값 미존재 default값 : $PERMITROOTLOGIN_DEFAULT" >> $OUTPUT_FILE 2>&1
                else
                    cat $SSH_CONFIG_PATH | grep "PermitRootLogin" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    # #U-01,SRV-026 양취판단
                    if [ "$(cat $SSH_CONFIG_PATH | grep "PermitRootLogin" | grep -v "#" | awk '{print $2}' | awk '{print $1}'| tail -n 1)" = "no" ]; then
                        SECURITY_STATUS="Y"
                    fi
                fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        echo "----------" >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "#Telnet LISTEN확인#" >> $OUTPUT_FILE 2>&1
            if command -v netstat >/dev/null 2>&1; then
                netstat -an | awk '/[.:]23 /' >> $OUTPUT_FILE 2>&1
            else
                ss -an | awk '/[.:]23 /' >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1
        fi

        if [ "$TELNET_CHECK_01" = 1 ]; then
            if [ "$(cat /etc/default/login | grep -i "CONSOLE=" | grep -v '#'| wc -l )" -gt 0 ]; then
                if [ "$(cat /etc/default/login | grep -i "/dev/console" | grep -v "#" | wc -l)" -gt 0 ]; then
                    echo "[ /etc/default/login 확인]" >> $OUTPUT_FILE 2>&1
                    cat /etc/default/login | grep -i "CONSOLE=" | grep -v '#' >> $OUTPUT_FILE 2>&1
                else
                    echo "[ /etc/default/login 확인 (/dev/console 로 설정 되어 있지 않음)]" >> $OUTPUT_FILE 2>&1
                    at /etc/default/login | grep -i "CONSOLE=" | grep -v '#' >> $OUTPUT_FILE 2>&1
                fi
            else
                echo "[ /etc/default/login 확인]" >> $OUTPUT_FILE 2>&1
                echo "CONSOLE 설정값 미존재" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/security/user"

        echo "[서비스 상태 확인]"   >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "-Telnet: 활성화(23포트LISTEN)" >> $OUTPUT_FILE 2>&1
            else
            echo "-Telnet: 비활성화" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        # rlogin 사용할 경우
        # default 확인
        echo "[rlogin default 값 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1
        files="/etc/security/user"
        keyword1="default:"
        keyword2="rlogin"
        end_marker=":"
        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
        if [ $SED_TMP -gt 0 ]; then
            RLOGIN_DEFAULT=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            RLOGIN_DEFAULT=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$RLOGIN_DEFAULT" ]; then
            echo "$RLOGIN_DEFAULT" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 rlogin이 존재하지 않음" 
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        echo "[rlogin root 값 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1
        files="/etc/security/user"
        keyword1="root:"
        keyword2="rlogin"
        end_marker=":"
        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
        if [ $SED_TMP -gt 0 ]; then
            RLOGIN_ROOT=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            RLOGIN_ROOT=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$RLOGIN_ROOT" ]; then
            echo "$RLOGIN_ROOT" >> $OUTPUT_FILE 2>&1
        else
            if [ -n "$RLOGIN_DEFAULT" ]; then
                echo "root 에 rlogin이 존재하지 않음(default : $RLOGIN_DEFAULT))" >> $OUTPUT_FILE 2>&1
            else
                echo "root,default 에 rlogin이 존재하지 않음" 
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        # ssh 사용할 경우
        if [ -f "$SSH_CONFIG_PATH" ] ; then
            echo "[PermitRootLogin 설정값 확인('${SSH_CONFIG_PATH}')]" >> $OUTPUT_FILE 2>&1
                if [ "$(cat "$SSH_CONFIG_PATH" | grep "PermitRootLogin" | grep -v "#")" = "" ] ; then
                    echo "-설정값 미존재 default값 : $PERMITROOTLOGIN_DEFAULT" >> $OUTPUT_FILE 2>&1
                else
                    cat $SSH_CONFIG_PATH | grep "PermitRootLogin" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    
                fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        echo "----------" >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "#Telnet LISTEN확인#" >> $OUTPUT_FILE 2>&1
            if command -v netstat >/dev/null 2>&1; then
                netstat -an | awk '/[.:]23 /' >> $OUTPUT_FILE 2>&1
            else
                ss -an | awk '/[.:]23 /' >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1
        fi

    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/securetty" "/etc/pam.d/login"

        # telnet 사용시
        if [ "$TELNET_CHECK_01" = 1 ]; then
            if [ "$(cat /etc/securetty 2>/dev/null | grep -i "console" | grep -v '#' | wc -l )" -gt 0 ]; then
                #접속불가능
                TELNET_CHECK_02=0
            else
                #접속가능
                TELNET_CHECK_02=1
            fi
        fi


        echo "[서비스 상태 확인]"   >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "-Telnet: 활성화(23포트LISTEN)" >> $OUTPUT_FILE 2>&1
            else
            echo "-Telnet: 비활성화" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        #텔넷 사용할 경우
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "[telnet root원격접속확인]" >> $OUTPUT_FILE 2>&1
            if [ "$TELNET_CHECK_02" = 1 ]; then
                echo "-telnet root 원격접속가능" >> $OUTPUT_FILE 2>&1
                else
                echo "-telnet root 원격접속 불가능" >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1


        # ssh 사용할 경우
        if [ -f "$SSH_CONFIG_PATH" ] ; then
            echo "[PermitRootLogin 설정값 확인('${SSH_CONFIG_PATH}')]" >> $OUTPUT_FILE 2>&1
            if [ "$(cat "$SSH_CONFIG_PATH" | grep "PermitRootLogin" | grep -v "#")" = "" ] ; then
                echo "-설정값 미존재 default값 : $PERMITROOTLOGIN_DEFAULT" >> $OUTPUT_FILE 2>&1
            else
                cat $SSH_CONFIG_PATH | grep "PermitRootLogin" | grep -v "#" >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        echo "----------" >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            echo "#Telnet LISTEN확인#" >> $OUTPUT_FILE 2>&1
            if command -v netstat >/dev/null 2>&1; then
                netstat -an | awk '/[.:]23 /' >> $OUTPUT_FILE 2>&1
            else
                ss -an | awk '/[.:]23 /' >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1
        fi

        if [ "$TELNET_CHECK_01" = 1 ]; then
            if [ "$(cat /etc/securetty 2>/dev/null | grep -i "console" | grep -v '#' | wc -l )" -eq 0 ]; then
                if [ "$(cat /etc/pam.d/login 2>/dev/null | grep -i "pam_securetty.so" | grep -v "#" | wc -l)" -eq 0 ]; then
                    if [ "$(cat /etc/pam.d/login 2>/dev/null | grep -i "pam_securetty.so" | wc -l)" -eq 0 ]; then
                        echo "#telnet /etc/pam.d/login확인#" >> $OUTPUT_FILE 2>&1
                        cat /etc/pam.d/login 2>/dev/null | grep -i "pam_securetty.so" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "#telnet /etc/securetty확인#" >> $OUTPUT_FILE 2>&1
                        cat /etc/securetty 2>/dev/null | grep -i "pts" | grep -v '#' >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        echo "#telnet /etc/pam.d/login확인#" >> $OUTPUT_FILE 2>&1
                        cat /etc/pam.d/login 2>/dev/null | grep -i "pam_securetty.so" | grep -v "#" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "#telnet /etc/securetty확인#" >> $OUTPUT_FILE 2>&1
                        cat /etc/securetty 2>/dev/null | grep -i "pts" | grep -v '#' >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            else
                echo "#telnet /etc/securetty확인#" >> $OUTPUT_FILE 2>&1
                cat /etc/securetty 2>/dev/null | grep -i "console" | grep -v '#' >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "[참고]"   >> $OUTPUT_FILE 2>&1
    echo "- PermitRootLogin 의 옵션 -"   >> $OUTPUT_FILE 2>&1
    echo " yes: root 사용자가 SSH를 통해 시스템에 로그인할 수 있음"   >> $OUTPUT_FILE 2>&1
    echo " no: root 사용자가 SSH를 통해 시스템에 로그인할 수 없음"   >> $OUTPUT_FILE 2>&1
    echo " prohibit-password: root 사용자가 패스워드 인증 이 아닌 키 인증 등 다른 방법을 사용하여 접속 할 수 있음"   >> $OUTPUT_FILE 2>&1
    echo " without-password: prohibit-password와 같음 (이전 버전의 SSH에서 사용됨)"   >> $OUTPUT_FILE 2>&1
    echo " forced-commands-only: root 사용자가 인증된 명령어 실행을 위해서만 SSH를 통해 로그인할 수 있음"   >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE 2>&1
    echo "COMMAND_COPY_PROGRESS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-01" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-026" 2>&1
}

#U-02,SRV-069,SRV-075
PASSWORD_COMPLEXITY_CONFIGURATION() {
    echo "PASSWORD_COMPLEXITY_CONFIGURATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-02_SRV-069_SRV-075.hangrp"
    # 복잡도 존재 하지 않을 경우 파일
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-02_SRV-069_SRV-075_REF01.hangrp"
    # 복잡도 존재 할 경우 파일
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-02_SRV-069_SRV-075_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1


    echo "[비밀번호사용여부,키사용여부 확인]"   >> $OUTPUT_FILE 2>&1
    echo "$PASSWORDAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo "$PUBKEYAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo ""   >> $OUTPUT_FILE 2>&1


    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/pam.d/system-auth" "/etc/security/pwquality.conf" "/etc/pam.d/password-auth" "/etc/pam.d/common-password" "/etc/pam.d/common-auth" "/etc/login.defs" "/etc/security/faillock.conf"

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        CHECK_FILES="/etc/pam.d/system-auth /etc/security/pwquality.conf /etc/pam.d/password-auth /etc/pam.d/common-password /etc/pam.d/common-auth"
        for CHECK_FILE in $CHECK_FILES; do
            if [ -f "$CHECK_FILE" ]; then
                COMPLEXITY=$(egrep -i 'lcredit|ucredit|dcredit|ocredit|minlen' $CHECK_FILE 2>/dev/null)
                if [ -z "$COMPLEXITY" ]; then
                    echo "[패스워드 복잡도 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE2"
                    echo "lcredit, ucredit, dcredit, ocredit, minlen 내용이 존재하지 않습니다." >> "$OUTPUT_FILE2"
                    echo "" >> "$OUTPUT_FILE2"
                else
                    echo "[패스워드 복잡도 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE3"
                    echo "$COMPLEXITY" >> "$OUTPUT_FILE3"
                    echo "" >> "$OUTPUT_FILE3"

                fi
            fi
        done

        #PASSWDQC_CONF_PATH 파일이 존재할 경우
        if [ -f "$PASSWDQC_CONF_PATH" ]; then
            echo "[패스워드 복잡도 확인 ($PASSWDQC_CONF_PATH)]" >> "$OUTPUT_FILE3"
            cat $PASSWDQC_CONF_PATH | egrep -i 'min=|enforce=' >> "$OUTPUT_FILE3"
            echo "" >> "$OUTPUT_FILE3"
        fi


        if [ -f "$OUTPUT_FILE3" ]; then
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
        fi
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/default/passwd"

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        CHECK_FILES="/etc/default/passwd"
        for CHECK_FILE in $CHECK_FILES; do
            if [ -f "$CHECK_FILE" ]; then
                COMPLEXITY=$(egrep -i 'MAXWEEKS=|MINALPHA=|MINDIGIT=|MINLOWER=|MINNONALPHA=|MINSPECIAL=|MINUPPER=|PASSLENGTH=' $CHECK_FILE 2>/dev/null)
                if [ -z "$COMPLEXITY" ]; then
                    echo "[패스워드 복잡도 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE2"
                    echo "MAXWEEKS, MINALPHA, MINDIGIT, MINLOWER, MINNONALPHA, MINSPECIAL, MINUPPER, PASSLENGTH 내용이 존재하지 않습니다." >> "$OUTPUT_FILE2"
                    echo "" >> "$OUTPUT_FILE2"
                else
                    echo "[패스워드 복잡도 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE3"
                    echo "$COMPLEXITY" >> "$OUTPUT_FILE3"
                    echo "" >> "$OUTPUT_FILE3"
                fi
            fi
        done

        if [ -f "$OUTPUT_FILE3" ]; then
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
        fi
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        #쉘접속이 가능한 계정
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)        

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)

        echo "[비밀번호 복잡도 default 값 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1

        files="/etc/security/user"
        keyword1="default:"
        keyword2="minlen"
        end_marker=":"
        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )

        if [ $SED_TMP -gt 0 ]; then
            minlenDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            minlenDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$minlenDEFAULT_INFO" ]; then
            echo "$minlenDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (패스워드 최소 길이)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        keyword2="minalpha"
        if [ $SED_TMP -gt 0 ]; then
            minalphaDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            minalphaDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$minalphaDEFAULT_INFO" ]; then
            echo "$minalphaDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (비밀번호에 포함될 최소 알파벳 수)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        keyword2="minupperalpha"
        if [ $SED_TMP -gt 0 ]; then
            minupperalphaDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            minupperalphaDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$minupperalphaDEFAULT_INFO" ]; then
            echo "$minupperalphaDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (대문자 최소 갯수)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        keyword2="minloweralpha"
        if [ $SED_TMP -gt 0 ]; then
            minloweralphaDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            minloweralphaDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$minloweralphaDEFAULT_INFO" ]; then
            echo "$minloweralphaDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (소문자 최소 갯수)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        keyword2="minspecialchar"
        if [ $SED_TMP -gt 0 ]; then
            minspecialcharDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            minspecialcharDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$minspecialcharDEFAULT_INFO" ]; then
            echo "$minspecialcharDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (특수 문자 최소 갯수)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        keyword2="mindigit"
        if [ $SED_TMP -gt 0 ]; then
            mindigitDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            mindigitDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$mindigitDEFAULT_INFO" ]; then
            echo "$mindigitDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (숫자 갯수)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        keyword2="minother"
        if [ $SED_TMP -gt 0 ]; then
            minotherDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            minotherDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$minotherDEFAULT_INFO" ]; then
            echo "$minotherDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (알파벳이 아닌 문자 최소 갯수)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        keyword2="maxage"
        if [ $SED_TMP -gt 0 ]; then
            maxageDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            maxageDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$maxageDEFAULT_INFO" ]; then
            echo "$maxageDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (비밀번호 최대 사용 기간)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi

        echo "" >> $OUTPUT_FILE 2>&1
        echo "[비밀번호 복잡도 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)

            files="/etc/security/user"
            keyword1="$USERNAME:"
            keyword2="minlen"
            end_marker=":"
            section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
            echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
            if [ $SED_TMP -gt 0 ]; then
                minlenACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                minlenACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$minlenACCOUNT_INFO" ]; then
                echo "$minlenACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
            else
                if [ -n "$minlenDEFAULT_INFO" ]; then
                    echo "$keyword2 (패스워드 최소 길이)가 존재하지 않음(default : $minlenDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME,default 에 $keyword2 (패스워드 최소 길이)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            keyword2="minalpha"
            if [ $SED_TMP -gt 0 ]; then
                minalphaACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                minalphaACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$minalphaACCOUNT_INFO" ]; then
                echo "$minalphaACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
            else
                if [ -n "$minalphaDEFAULT_INFO" ]; then
                    echo "$keyword2 (비밀번호에 포함될 최소 알파벳 수)가 존재하지 않음(default : $minalphaDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME,default 에 $keyword2 (비밀번호에 포함될 최소 알파벳 수)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            keyword2="minupperalpha"
            if [ $SED_TMP -gt 0 ]; then
                minupperalphaACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                minupperalphaACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$minupperalphaACCOUNT_INFO" ]; then
                echo "$minupperalphaACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
            else
                if [ -n "$minupperalphaDEFAULT_INFO" ]; then
                    echo "$keyword2 (대문자 최소 갯수)가 존재하지 않음(default : $minupperalphaDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME,default 에 $keyword2 (대문자 최소 갯수)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            keyword2="minloweralpha"
            if [ $SED_TMP -gt 0 ]; then
                minloweralphaACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                minloweralphaACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$minloweralphaACCOUNT_INFO" ]; then
                echo "$minloweralphaACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
            else
                if [ -n "$minloweralphaDEFAULT_INFO" ]; then
                    echo "$keyword2 (소문자 최소 갯수)가 존재하지 않음(default : $minloweralphaDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME,default 에 $keyword2 (소문자 최소 갯수)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            keyword2="minspecialchar"
            if [ $SED_TMP -gt 0 ]; then
                minspecialcharACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                minspecialcharACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$minspecialcharACCOUNT_INFO" ]; then
                echo "$minspecialcharACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
            else
                if [ -n "$minspecialcharDEFAULT_INFO" ]; then
                    echo "$keyword2 (특수 문자 최소 갯수)가 존재하지 않음(default : $minspecialcharDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME,default 에 $keyword2 (특수 문자 최소 갯수)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            keyword2="mindigit"
            if [ $SED_TMP -gt 0 ]; then
                mindigitACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                mindigitACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$mindigitACCOUNT_INFO" ]; then
                echo "$mindigitACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
            else
                if [ -n "$mindigitDEFAULT_INFO" ]; then
                    echo "$keyword2 (숫자 갯수)가 존재하지 않음(default : $mindigitDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME,default 에 $keyword2 (숫자 갯수)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            keyword2="minother"
            if [ $SED_TMP -gt 0 ]; then
                minotherACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                minotherACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$minotherACCOUNT_INFO" ]; then
                echo "$minotherACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
            else
                if [ -n "$minotherDEFAULT_INFO" ]; then
                    echo "$keyword2 (알파벳이 아닌 문자 최소 갯수)가 존재하지 않음(default : $minotherDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME,default 에 $keyword2 (알파벳이 아닌 문자 최소 갯수)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            keyword2="maxage"
            if [ $SED_TMP -gt 0 ]; then
                maxageACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                maxageACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$maxageACCOUNT_INFO" ]; then
                echo "$maxageACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
            else
                if [ -n "$maxageDEFAULT_INFO" ]; then
                    echo "$keyword2 (비밀번호 최대 사용 기간)가 존재하지 않음(default : $maxageDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME,default 에 $keyword2 (비밀번호 최대 사용 기간)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            echo "" >> $OUTPUT_FILE 2>&1
        done
            
    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/default/security"

        if [ -f "/etc/default/security" ]; then
            echo "[비밀번호 복잡도 확인(/etc/default/security)]" >> $OUTPUT_FILE 2>&1
            if [ $(cat /etc/default/security | egrep -i "PASSWORD_MAXDAYS" | grep -v "#" | wc -l) -eq 0 ]; then
                echo "PASSWORD_MAXDAYS(비밀번호 최대 사용 기간) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "PASSWORD_MAXDAYS(비밀번호 최대 사용 기간) : $(cat /etc/default/security | grep -i "PASSWORD_MAXDAYS" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi

            if [ $(cat /etc/default/security | egrep -i "MIN_PASSWORD_LENGTH" | grep -v "#" | wc -l) -eq 0 ]; then
                echo "MIN_PASSWORD_LENGTH(비밀번호 최소 길이) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "MIN_PASSWORD_LENGTH(비밀번호 최소 길이) : $(cat /etc/default/security | grep -i "MIN_PASSWORD_LENGTH" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi

            if [ $(cat /etc/default/security | egrep -i "PASSWORD_MIN_UPPER_CASE_CHARS" | egrep -v "#" | wc -l) -eq 0 ]; then
                echo "PASSWORD_MIN_UPPER_CASE_CHARS(대문자 최소 갯수) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "PASSWORD_MIN_UPPER_CASE_CHARS(대문자 최소 갯수) : $(cat /etc/default/security | egrep -i "PASSWORD_MIN_UPPER_CASE_CHARS" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi

            if [ $(cat /etc/default/security | egrep -i "PASSWORD_MIN_LOWER_CASE_CHARS" | egrep -v "#" | wc -l) -eq 0 ]; then
                echo "PASSWORD_MIN_LOWER_CASE_CHARS(소문자 최소 갯수) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "PASSWORD_MIN_LOWER_CASE_CHARS(소문자 최소 갯수) : $(cat /etc/default/security | egrep -i "PASSWORD_MIN_LOWER_CASE_CHARS" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi

            if [ $(cat /etc/default/security | egrep -i "PASSWORD_MIN_DIGIT_CHARS" | egrep -v "#" | wc -l) -eq 0 ]; then
                echo "PASSWORD_MIN_DIGIT_CHARS(숫자 최소 갯수) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "PASSWORD_MIN_DIGIT_CHARS(숫자 최소 갯수) : $(cat /etc/default/security | egrep -i "PASSWORD_MIN_DIGIT_CHARS" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi

            if [ $(cat /etc/default/security | egrep -i "PASSWORD_MIN_SPECIAL_CHARS" | egrep -v "#" | wc -l) -eq 0 ]; then
                echo "PASSWORD_MIN_SPECIAL_CHARS(특수 문자 최소 갯수) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "PASSWORD_MIN_SPECIAL_CHARS(특수 문자 최소 갯수) : $(cat /etc/default/security | egrep -i "PASSWORD_MIN_SPECIAL_CHARS" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "[비밀번호 복잡도 확인(/etc/default/security)]" >> $OUTPUT_FILE 2>&1
            echo "/etc/default/security 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "[참고]"   >> $OUTPUT_FILE 2>&1
    echo "PasswordAuthentication- yes: 비밀번호 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "PubkeyAuthentication- yes: 공개키 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PASSWORD_COMPLEXITY_CONFIGURATION_COMPLETE"

    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-02" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-069" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-075" 2>&1
}

#U-03,SRV-127
ACCOUNT_LOCKOUT_THRESHOLD_CONFIGURATION() {
    echo "ACCOUNT_LOCKOUT_THRESHOLD_CONFIGURATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-03_SRV-127.hangrp"
    # 계정 잠금 임계값 존재 하지 않을 경우 파일
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-03_SRV-127_REF01.hangrp"
    # 계정 잠금 임계값 존재 할 경우 파일
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-03_SRV-127_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    # 임계값 구분할때 변수로 사용
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    echo "[비밀번호사용여부,키사용여부 확인]"   >> $OUTPUT_FILE 2>&1
    echo "$PASSWORDAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo "$PUBKEYAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo ""   >> $OUTPUT_FILE 2>&1


    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        CHECK_FILES="/etc/pam.d/system-auth /etc/security/pwquality.conf /etc/pam.d/password-auth /etc/pam.d/common-password /etc/pam.d/common-auth /etc/security/faillock.conf"
        for CHECK_FILE in $CHECK_FILES; do
            if [ -f "$CHECK_FILE" ]; then
                COMPLEXITY=$(egrep -i 'deny=|unlock_time=|deny =|unlock_time =' $CHECK_FILE 2>/dev/null)
                if [ -z "$COMPLEXITY" ]; then
                    echo "[임계값 제한 설정 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE2"
                    echo "임계값 제한 설정이 존재하지 않습니다." >> "$OUTPUT_FILE2"
                    echo "" >> "$OUTPUT_FILE2"
                else
                    echo "[임계값 제한 설정 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE3"
                    echo "$COMPLEXITY" >> "$OUTPUT_FILE3"
                    #U-02,SRV-069,SRV-075 양취판단
                    SECURITY_TMP01=$(echo "$COMPLEXITY" |grep -v "#" |awk -F'=' '{print $2}' | awk '{print $1}' | tail -n 1)
                    if [ -n "$SECURITY_TMP01" ] && [ "$SECURITY_TMP01" -eq "$SECURITY_TMP01" ] 2>&1; then
                        if [ "$SECURITY_TMP01" -le 5 ]; then
                            SECURITY_STATUS="Y"
                        fi
                    fi
                    echo "" >> "$OUTPUT_FILE3"
                fi
            fi
        done

        if [ -f "$OUTPUT_FILE3" ]; then
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
        fi
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        CHECK_FILES="/etc/default/login"
        for CHECK_FILE in $CHECK_FILES; do
            if [ -f "$CHECK_FILE" ]; then
                COMPLEXITY=$(egrep -i 'RETRIES=' $CHECK_FILE 2>/dev/null)
                if [ -z "$COMPLEXITY" ]; then
                    echo "[임계값 제한 설정 확인(RETRIES) ($CHECK_FILE)]" >> "$OUTPUT_FILE2"
                    echo "임계값 제한 설정(RETRIES)이 존재하지 않습니다." >> "$OUTPUT_FILE2"
                    echo "" >> "$OUTPUT_FILE2"
                else
                    echo "[임계값 제한 설정 확인(RETRIES) ($CHECK_FILE)]" >> "$OUTPUT_FILE3"
                    echo "$COMPLEXITY" >> "$OUTPUT_FILE3"
                    echo "" >> "$OUTPUT_FILE3"
                fi
            fi
        done


        CHECK_FILES="/etc/security/policy.conf"
        for CHECK_FILE in $CHECK_FILES; do
            if [ -f "$CHECK_FILE" ]; then
                COMPLEXITY=$(egrep -i 'LOCK_AFTER_RETRIES=' $CHECK_FILE 2>/dev/null)
                if [ -z "$COMPLEXITY" ]; then
                    echo "[임계값 제한 설정 확인(LOCK_AFTER_RETRIES) ($CHECK_FILE)]" >> "$OUTPUT_FILE2"
                    echo "임계값 제한 설정(LOCK_AFTER_RETRIES)이 존재하지 않습니다." >> "$OUTPUT_FILE2"
                    echo "" >> "$OUTPUT_FILE2"
                else
                    echo "[임계값 제한 설정 확인(LOCK_AFTER_RETRIES) ($CHECK_FILE)]" >> "$OUTPUT_FILE3"
                    echo "$COMPLEXITY" >> "$OUTPUT_FILE3"
                    echo "" >> "$OUTPUT_FILE3"
                fi
            fi
        done


        if [ -f "$OUTPUT_FILE3" ]; then
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
        fi
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        #쉘접속이 가능한 계정
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)

        echo "[잠금임계값 default 값 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1

        files="/etc/security/user"
        keyword1="default:"
        keyword2="loginretries"
        end_marker=":"
        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
        if [ $SED_TMP -gt 0 ]; then
            loginretriesDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            loginretriesDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$loginretriesDEFAULT_INFO" ]; then
            echo "$loginretriesDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (로그인 재시도 횟수)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        if command -v lsuser >/dev/null 2>&1; then
            echo "[잠금임계값(loginretries) 확인(#lsuser -a loginretries <계정명>)]" >> $OUTPUT_FILE 2>&1
        else
            echo "[잠금임계값(loginretries) 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1
        fi
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            #찾을 문자열
            if command -v lsuser >/dev/null 2>&1; then
                if [ $SED_TMP -gt 0 ]; then
                    loginretriesACCOUNT_INFO=$(lsuser -a loginretries "$USERNAME" | sed -e 's/	//g')
                else
                    loginretriesACCOUNT_INFO=$(lsuser -a loginretries "$USERNAME" | sed -e 's/\s//g')
                fi
                if [ -n "$loginretriesACCOUNT_INFO" ]; then
                    echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
                    echo "$loginretriesACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    if [ -n "$loginretriesDEFAULT_INFO" ]; then
                        echo "$keyword2 (로그인 재시도 횟수)가 존재하지 않음(default : $loginretriesDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "$USERNAME,default 에 $keyword2 (로그인 재시도 횟수)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            else
                files="/etc/security/user"
                keyword1="$USERNAME:"
                keyword2="loginretries"
                end_marker=":"
                section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
                echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
                if [ $SED_TMP -gt 0 ]; then
                    loginretriesACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
                else
                    loginretriesACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
                fi
                if [ -n "$loginretriesACCOUNT_INFO" ]; then
                    echo "$loginretriesACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
                else
                    if [ -n "$loginretriesDEFAULT_INFO" ]; then
                        echo "$keyword2 (로그인 재시도 횟수)가 존재하지 않음(default : $loginretriesDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "$USERNAME,default 에 $keyword2 (로그인 재시도 횟수)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            echo "" >> $OUTPUT_FILE 2>&1
            fi
        done
    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/tcb/files/auth/system/default" "/etc/default/security"
        
        if [ -f "/tcb/files/auth/system/default" ]; then
            echo "[잠금임계값 확인(/tcb/files/auth/system/default)]" >> $OUTPUT_FILE 2>&1
            if [ $(cat /tcb/files/auth/system/default | egrep -i "u_maxtries" | grep -v "#" | wc -l) -eq 0 ]; then
                echo "u_maxtries(로그인 재시도 횟수) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "u_maxtries(로그인 재시도 횟수) : $(cat /tcb/files/auth/system/default | grep -i "u_maxtries" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "[잠금임계값 확인(/tcb/files/auth/system/default)]" >> $OUTPUT_FILE 2>&1
            echo "/tcb/files/auth/system/default 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

        if [ -f "/etc/default/security" ]; then
            echo "[잠금임계값 확인(/etc/default/security)]" >> $OUTPUT_FILE 2>&1
            if [ $(cat /etc/default/security | egrep -i "MAXTRIES" | grep -v "#" | wc -l) -eq 0 ]; then
                echo "MAXTRIES(로그인 재시도 횟수) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "MAXTRIES(로그인 재시도 횟수) : $(cat /etc/default/security | grep -i "MAXTRIES" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "[잠금임계값 확인(/etc/default/security)]" >> $OUTPUT_FILE 2>&1
            echo "/etc/default/security 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi


        if [ -d /var/adm/userdb ]; then
            echo "[잠금임계값 확인(/var/adm/userdb/*)]" >> $OUTPUT_FILE 2>&1
            for FILE in $(find /var/adm/userdb -type f); do
                if [ $(cat /var/adm/userdb/$FILE | egrep -i "MAXTRIES" | grep -v "#" | wc -l) -eq 0 ]; then
                    echo "MAXTRIES(로그인 재시도 횟수) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
                else
                    echo "MAXTRIES(로그인 재시도 횟수) : $(cat /var/adm/userdb/$FILE | grep -i "MAXTRIES" | grep -v "#")" >> $OUTPUT_FILE 2>&1
                fi
            done
        else
            echo "[잠금임계값 확인(/var/adm/userdb/*)]" >> $OUTPUT_FILE 2>&1
            echo "/var/adm/userdb 디렉터리가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "[참고]"   >> $OUTPUT_FILE 2>&1
    echo "PasswordAuthentication- yes: 비밀번호 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "PubkeyAuthentication- yes: 공개키 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE 2>&1
    echo "ACCOUNT_LOCKOUT_THRESHOLD_CONFIGURATION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-03" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-127" 2>&1
}

#U-04,SRV-070
USER_PASSWORD_ENCRYPT() {
    echo "USER_PASSWORD_ENCRYPT_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-04_SRV-070.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-04_SRV-070_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-04_SRV-070_REF02.hangrp"
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-04_SRV-070_REF03.hangrp"
    #암호화 unkonwn 계정
    OUTPUT_FILE5="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-04_SRV-070_REF04.hangrp"
    #사용자 저장
    OUTPUT_FILE6="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-04_SRV-070_REF05.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    echo "[비밀번호사용여부,키사용여부 확인]"   >> $OUTPUT_FILE 2>&1
    echo "$PASSWORDAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo "$PUBKEYAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo ""   >> $OUTPUT_FILE 2>&1


    ###############################
    #REDHAT 계열, Solaris 계열
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/shadow" "/etc/security/policy.conf"

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        # linux 파일
        if [ -f "/etc/login.defs" ]; then
            if [ "$(cat /etc/login.defs | grep -i "ENCRYPT_METHOD" | wc -l)" -gt 0 ]; then
                echo "[ENCRYPT_METHOD 설정값 확인(/etc/login.defs)]" >> $OUTPUT_FILE 2>&1
                cat /etc/login.defs | grep -i "ENCRYPT_METHOD" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        fi

        # solaris 파일
        if [ -f "/etc/security/policy.conf" ]; then
            if [ "$(cat /etc/security/policy.conf | grep -i "CRYPT_DEFAULT" | grep -v "algorithm" | wc -l)" -gt 0 ]; then
                echo "[ENCRYPT_METHOD 설정값 확인(/etc/security/policy.conf)]" >> $OUTPUT_FILE 2>&1
                cat /etc/security/policy.conf  | grep -i "CRYPT_DEFAULT=" | grep -v "algorithm" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "---------------" >> $OUTPUT_FILE 2>&1
                echo "[참고]" >> $OUTPUT_FILE 2>&1
                echo "1 : crypt_bsdmd5.so.1" >> $OUTPUT_FILE 2>&1
                echo "2a : crypt_bsdbf.so.1" >> $OUTPUT_FILE 2>&1
                echo "md5 : crypt_bsdbf.so.1" >> $OUTPUT_FILE 2>&1
                echo "5 : crypt_sha256.so.1" >> $OUTPUT_FILE 2>&1
                echo "6 : crypt_sha512.so.1" >> $OUTPUT_FILE 2>&1
                echo "---------------" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        fi

        ETC_SHADOW_MAIN=$(awk -F':' '{ print $1":"$2}' /etc/shadow)
        # /etc/shadow 파일을 읽어서 각 사용자의 암호화된 비밀번호 정보를 가져옵니다.
        for ETC_SHADOW_MAIN_INFO in $ETC_SHADOW_MAIN; do
            USER=$(echo "$ETC_SHADOW_MAIN_INFO" | cut -d':' -f1)
            PASS=$(echo "$ETC_SHADOW_MAIN_INFO" | cut -d':' -f2)

            # 패스워드가 있는 경우만 처리합니다. 
            if [ "$PASS" != "*" ] && [ "$PASS" != "!" ] && [ "$PASS" != "!!" ] && [ "$PASS" != "LOCK" ] && [ "$PASS" != "*LK*" ] && [ "$PASS" != "NP" ]; then
                # 암호화 방식을 가져옵니다.
                id=$(echo $PASS | cut -d"$" -f2)

                # 암호화 방식을 확인하고 출력합니다.
                case "$id" in
                    "1")
                        echo "User: $USER, Password Encryption: MD5" >> $OUTPUT_FILE2
                        ;;
                    "2a" | "2y" | "2b")
                        echo "User: $USER, Password Encryption: Blowfish" >> $OUTPUT_FILE2
                        ;;
                    "5")
                        echo "User: $USER, Password Encryption: SHA-256" >> $OUTPUT_FILE2
                        ;;
                    "6")
                        echo "User: $USER, Password Encryption: SHA-512" >> $OUTPUT_FILE2
                        ;;
                    "y")
                        echo "User: $USER, Password Encryption: yescrypt" >> $OUTPUT_FILE2
                        ;;
                    "*LK*")
                        echo "User: $USER, Password Encryption: PASSWORD LOCK" >> $OUTPUT_FILE2
                        ;;
                    "NP")
                        echo "User: $USER, Password Encryption: PASSWORD NOT SET" >> $OUTPUT_FILE2
                        ;;
                    "")
                        echo "User: $USER, Password Encryption: PASSWORD NOT SET" >> $OUTPUT_FILE2
                        ;;
                    *)
                        echo "User: $USER, Password Encryption: Unknown" >> $OUTPUT_FILE2
                        cat /etc/shadow | grep "^$USER:" >> $OUTPUT_FILE5
                        ;;
                esac
                cat /etc/shadow | grep "^$USER:" >> $OUTPUT_FILE6
            fi
        done




        #비밀번호 미사용 계정의 내용 제거1
        if [ -f "$OUTPUT_FILE2" ]; then
        sed 's/$/,/' "$USER_PASSWORD_USE" > $OUTPUT_FILE3 2>&1
        egrep -f "$OUTPUT_FILE3" "$OUTPUT_FILE2" > $OUTPUT_FILE4 2>&1
        cat $OUTPUT_FILE4 > $OUTPUT_FILE2 2>&1
        fi
        #비밀번호 미사용 계정의 내용 제거2
        if [ -f "$OUTPUT_FILE5" ]; then
        sed 's/$/:/' "$USER_PASSWORD_USE" > $OUTPUT_FILE3 2>&1
        egrep -f "$OUTPUT_FILE3" "$OUTPUT_FILE5" > $OUTPUT_FILE4 2>&1
        cat $OUTPUT_FILE4 > $OUTPUT_FILE5 2>&1
        fi

        if [ -f "$OUTPUT_FILE2" ]; then
            echo "[각 사용자 암호화 확인]"  >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE5" ]; then
                echo "[암호화 unkown 계정 /etc/shadow 내용]"  >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE5 >> $OUTPUT_FILE 2>&1
                echo ""   >> $OUTPUT_FILE 2>&1
            fi
        fi

        if [ -f "$OUTPUT_FILE6" ]; then
            echo "[cat /etc/shadow(로그인불가계정, 별도인증방식사용 제외)]"  >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE6 >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
            echo "[참고(2번째 필드)]"   >> $OUTPUT_FILE 2>&1
            echo "1 : MD5(MD5는 충돌 공격에 대한 취약성으로 인해 암호화 손상 가능하여 부적합)"   >> $OUTPUT_FILE 2>&1
            echo "2a, 2y, 2b : 2a 의 경우 취약점을 가지고 있으며 2y,2b 는 수정하였음"   >> $OUTPUT_FILE 2>&1
            echo "5 : SHA-256"   >> $OUTPUT_FILE 2>&1
            echo "6 : SHA-512"   >> $OUTPUT_FILE 2>&1
            echo "y : yescrypt"   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
            else
            echo "파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

        echo ""   >> $OUTPUT_FILE 2>&1

    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/security/login.cfg" "/etc/security/passwd"
        
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)        

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)

        echo "[비밀번호 알고리즘 확인 (# cat /etc/security/login.cfg | grep -i \"pwd_algorithm =\" )]" >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/security/login.cfg" ]; then
            if [ "$(cat /etc/security/login.cfg | egrep -i "pwd_algorithm =|pwd_algorithm=" | grep -v '#' | wc -l)" -gt 0 ] ; then
                cat /etc/security/login.cfg | egrep -i "pwd_algorithm =|pwd_algorithm=" | grep -v '#' >> $OUTPUT_FILE 2>&1
            else
                echo "pwd_algorithm 설정값 미존재" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "/etc/security/login.cfg 파일 미존재" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        echo "[계정별 비밀번호 알고리즘 확인 (# cat /etc/security/passwd)]" >> $OUTPUT_FILE 2>&1
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            files="/etc/security/passwd"
            keyword1="$USERNAME:"
            keyword2="password"
            end_marker=":"
            section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
            
            #비밀번호가 존재하는 계정(password = * 가 아닌 계정)만 확인
            if [ "$(echo "$section" | grep -i "password =" | grep -v "password = \*" | wc -l)" -gt 0 ] ; then
                echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]"  >> $OUTPUT_FILE 2>&1
                if [ $SED_TMP -gt 0 ]; then
                    passwordACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
                else
                    passwordACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
                fi
                if [ -n "$passwordACCOUNT_INFO" ]; then
                    echo "$passwordACCOUNT_INFO"  >> $OUTPUT_FILE 2>&1
                fi
                echo ""  >> $OUTPUT_FILE 2>&1
            fi
        done

    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/shadow"

        #/etc/shadow 존재할 경우
        if [ -f "/etc/shadow" ]; then

            ETC_SHADOW_MAIN=$(awk -F':' '{ print $1":"$2}' /etc/shadow)
            # /etc/shadow 파일을 읽어서 각 사용자의 암호화된 비밀번호 정보를 가져옵니다.
            for ETC_SHADOW_MAIN_INFO in $ETC_SHADOW_MAIN; do
                USER=$(echo "$ETC_SHADOW_MAIN_INFO" | cut -d':' -f1)
                PASS=$(echo "$ETC_SHADOW_MAIN_INFO" | cut -d':' -f2)

                # 패스워드가 있는 경우만 처리합니다. 
                if [ "$PASS" != "*" ] && [ "$PASS" != "!" ] && [ "$PASS" != "!!" ] && [ "$PASS" != "LOCK" ] && [ "$PASS" != "*LK*" ] && [ "$PASS" != "NP" ]; then
                    # 암호화 방식을 가져옵니다.
                    id=$(echo $PASS | cut -d"$" -f2)

                    # 암호화 방식을 확인하고 출력합니다.
                    case "$id" in
                        "1")
                            echo "User: $USER, Password Encryption: MD5" >> $OUTPUT_FILE2
                            ;;
                        "2a" | "2y" | "2b")
                            echo "User: $USER, Password Encryption: Blowfish" >> $OUTPUT_FILE2
                            ;;
                        "5")
                            echo "User: $USER, Password Encryption: SHA-256" >> $OUTPUT_FILE2
                            ;;
                        "6")
                            echo "User: $USER, Password Encryption: SHA-512" >> $OUTPUT_FILE2
                            ;;
                        "y")
                            echo "User: $USER, Password Encryption: yescrypt" >> $OUTPUT_FILE2
                            ;;
                        "*LK*")
                            echo "User: $USER, Password Encryption: PASSWORD LOCK" >> $OUTPUT_FILE2
                            ;;
                        "NP")
                            echo "User: $USER, Password Encryption: PASSWORD NOT SET" >> $OUTPUT_FILE2
                            ;;
                        "")
                            echo "User: $USER, Password Encryption: PASSWORD NOT SET" >> $OUTPUT_FILE2
                            ;;
                        *)
                            echo "User: $USER, Password Encryption: Unknown" >> $OUTPUT_FILE2
                            cat /etc/shadow | grep "^$USER:" >> $OUTPUT_FILE5
                            ;;
                    esac
                    cat /etc/shadow | grep "^$USER:" >> $OUTPUT_FILE6
                fi
            done




            #비밀번호 미사용 계정의 내용 제거1
            if [ -f "$OUTPUT_FILE2" ]; then
            sed 's/$/,/' "$USER_PASSWORD_USE" > $OUTPUT_FILE3 2>&1
            egrep -f "$OUTPUT_FILE3" "$OUTPUT_FILE2" > $OUTPUT_FILE4 2>&1
            cat $OUTPUT_FILE4 > $OUTPUT_FILE2 2>&1
            fi
            #비밀번호 미사용 계정의 내용 제거2
            if [ -f "$OUTPUT_FILE5" ]; then
            sed 's/$/:/' "$USER_PASSWORD_USE" > $OUTPUT_FILE3 2>&1
            egrep -f "$OUTPUT_FILE3" "$OUTPUT_FILE5" > $OUTPUT_FILE4 2>&1
            cat $OUTPUT_FILE4 > $OUTPUT_FILE5 2>&1
            fi

            if [ -f "$OUTPUT_FILE2" ]; then
                echo "[각 사용자 암호화 확인]"  >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
                echo ""   >> $OUTPUT_FILE 2>&1
                if [ -f "$OUTPUT_FILE5" ]; then
                    echo "[암호화 unkown 계정 /etc/shadow 내용]"  >> $OUTPUT_FILE 2>&1
                    cat $OUTPUT_FILE5 >> $OUTPUT_FILE 2>&1
                    echo ""   >> $OUTPUT_FILE 2>&1
                fi
            fi

            if [ -f "$OUTPUT_FILE6" ]; then
                echo "[cat /etc/shadow(로그인불가계정, 별도인증방식사용 제외)]"  >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE6 >> $OUTPUT_FILE 2>&1
                echo ""   >> $OUTPUT_FILE 2>&1
                echo "[참고(2번째 필드)]"   >> $OUTPUT_FILE 2>&1
                echo "1 : MD5(MD5는 충돌 공격에 대한 취약성으로 인해 암호화 손상 가능하여 부적합)"   >> $OUTPUT_FILE 2>&1
                echo "2a, 2y, 2b : 2a 의 경우 취약점을 가지고 있으며 2y,2b 는 수정하였음"   >> $OUTPUT_FILE 2>&1
                echo "5 : SHA-256"   >> $OUTPUT_FILE 2>&1
                echo "6 : SHA-512"   >> $OUTPUT_FILE 2>&1
                echo "y : yescrypt"   >> $OUTPUT_FILE 2>&1
                echo ""   >> $OUTPUT_FILE 2>&1
                else
                echo "파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi

        else
            echo "[비밀번호 알고리즘 확인 (# cat /etc/shadow)]" >> $OUTPUT_FILE 2>&1
            echo "/etc/shadow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1

            echo "[비밀번호 알고리즘 확인 (# cat /etc/default/securty)]" >> $OUTPUT_FILE 2>&1
            if [ -f "/etc/default/security" ]; then
                if [ "$(cat /etc/default/security | egrep -i "PASSWORD_HASH" | grep -v "#" | wc -l)" -gt 0 ] ; then
                    cat /etc/default/security | egrep -i "PASSWORD_HASH" | grep -v "#" >> $OUTPUT_FILE 2>&1
                fi
                if [ "$(cat /etc/default/security | egrep -i "CRYPT_DEFAULT" | wc -l)" -gt 0 ] ; then
                    cat /etc/default/security | egrep -i "CRYPT_DEFAULT" >> $OUTPUT_FILE 2>&1
                fi
                if [ "$(cat /etc/default/security | egrep -i "CRYPT_ALGORITHMS_DEPRECATE" | wc -l)" -gt 0 ] ; then
                    cat /etc/default/security | egrep -i "CRYPT_ALGORITHMS_DEPRECATE" >> $OUTPUT_FILE 2>&1
                fi
            else
                echo "/etc/default/security 파일 미존재" >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1
            if [ -d /tcb/files/auth ]; then
                echo "[비밀번호 알고리즘 확인 (# cat /tcb/files/auth/[a-z]/*)]" >> $OUTPUT_FILE 2>&1
                for FILE in $(find /tcb/files/auth/ -path "/tcb/files/auth/[a-zA-Z]/*" -type f 2>/dev/null); do
                    if [ "$(cat $FILE | egrep -i "u_pwd" | wc -l)" -gt 0 ] ; then
                        echo "[파일명 : $FILE]" >> $OUTPUT_FILE 2>&1
                        cat $FILE | egrep -i "u_name" >> $OUTPUT_FILE 2>&1
                        cat $FILE | egrep -i "u_pwd" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                done
            else
                echo "/tcb/files/auth 디렉터리 미존재" >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1
            if [ -f "/etc/passwd" ]; then
                echo "[# cat /etc/passwd (두번째 필드 x 여부 확인)]" >> $OUTPUT_FILE 2>&1
                cat /etc/passwd | egrep -i "u_pwd" >> $OUTPUT_FILE 2>&1
            else
                echo "/etc/passwd 파일 미존재" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "[참고]"   >> $OUTPUT_FILE 2>&1
    echo "PasswordAuthentication- yes: 비밀번호 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "PubkeyAuthentication- yes: 공개키 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE 2>&1
    echo "USER_PASSWORD_ENCRYPT_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-04" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-070" 2>&1
}

#U-44
PROHIBIT_UID_OTHER_THAN_ROOT_TO_BE_0() {
    echo "PROHIBIT_UID_OTHER_THAN_ROOT_TO_BE_0_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-44.hangrp"

    SECURITY_STATUS="CHECK"
    # 구분할때 변수로 사용
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "[UID가 0인 사용자 목록]" >> $OUTPUT_FILE 2>&1
        COMMAND_TMP_001=$(awk -F: '$3 == 0 { print $0 }' "/etc/passwd")
        if [ -n "$COMMAND_TMP_001" ]; then
        #if awk -F: '$3 == 0 { print $0 }' "/etc/passwd" >/dev/null; then
            awk -F: '$3 == 0 { print $0 }' "/etc/passwd" >> $OUTPUT_FILE 2>&1
            #U-44 양취판단
            SECURITY_TMP01=$(awk -F: '$3 == 0 { print $0 }' "/etc/passwd" | wc -l)
            if [ $SECURITY_TMP01 -eq 1 ]; then
                SECURITY_STATUS="Y"
            fi
        else
            echo "UID가 0인 사용자가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            SECURITY_STATUS="CHECK"
        fi
        COMMAND_TMP_001=""
        echo ""   >> $OUTPUT_FILE 2>&1
        echo "[/etc/passwd 내용]" >> $OUTPUT_FILE 2>&1
        cat /etc/passwd >> $OUTPUT_FILE 2>&1
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PROHIBIT_UID_OTHER_THAN_ROOT_TO_BE_0_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-44" 2>&1
}

#U-45,SRV-131
RESTRICT_SU_COMMAND_TO_SPECIFIC_GROUPS_INSUFFICIENT() {
    echo "RESTRICT_SU_COMMAND_TO_SPECIFIC_GROUPS_INSUFFICIENT_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-45_SRV-131.hangrp"
    #소유주 확인
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-45_SRV-131_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    
    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        FILE_COPY "/usr/bin/su" "/bin/su" "/usr/local/bin/su" "/etc/pam.d/su" "/etc/sudoers" "/etc/group"
        su_files="/usr/bin/su /bin/su /usr/local/bin/su"

        echo "[su 파일 권한 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/usr/bin/su" ] || [ -f "/bin/su" ] || [ -f "/usr/local/bin/su" ]; then
            for su_file in $su_files; do
                if [ -f "$su_file" ]; then
                    ls -alL $su_file >> $OUTPUT_FILE 2>&1
                fi
            done
        else
            echo "su 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo ""   >> $OUTPUT_FILE 2>&1

        echo "[/etc/pam.d/su 확인(1)]"   >> $OUTPUT_FILE 2>&1
        if [ "$(cat /etc/pam.d/su | grep -i "pam_wheel.so" | grep -v '#' | wc -l)" -eq 0 ] ; then
            if [ "$(cat /etc/pam.d/su | grep -i "pam_wheel.so" | wc -l)" -eq 0 ] ; then
                echo "pam_wheel.so 설정값 미존재" >> $OUTPUT_FILE 2>&1
            else
                cat /etc/pam.d/su | grep -i "pam_wheel.so"  >> $OUTPUT_FILE 2>&1
            fi
        else
            cat /etc/pam.d/su | grep -i "pam_wheel.so" | grep -v '#'  >> $OUTPUT_FILE 2>&1
        fi
        echo ""   >> $OUTPUT_FILE 2>&1

        echo "[/etc/sudoers 확인(2)]"   >> $OUTPUT_FILE 2>&1
        if [ "$(cat /etc/sudoers | grep -v "#" | grep -i "ALL" | wc -l)" -eq 0 ] ; then
            if [ "$(cat /etc/sudoers | grep -i "ALL" | wc -l)" -eq 0 ] ; then
                echo "/etc/sudoers 설정값 미존재" >> $OUTPUT_FILE 2>&1
            else
                cat /etc/sudoers | grep -i "ALL"  >> $OUTPUT_FILE 2>&1
            fi
        else
            cat /etc/sudoers | grep -v "#" | grep -i "ALL" >> $OUTPUT_FILE 2>&1
        fi
        echo ""   >> $OUTPUT_FILE 2>&1

        if [ -f "/etc/group" ]; then
            if [ -f "/usr/bin/su" ] || [ -f "/bin/su" ] || [ -f "/usr/local/bin/su" ]; then
                echo "[/etc/group 내용 확인(su파일 그룹 기준)]"   >> $OUTPUT_FILE 2>&1
                for su_file in $su_files; do
                    if [ -f "$su_file" ]; then
                        COMMAND_TMP_001=$(cat /etc/group | grep -i "^$(ls -alL $su_file | awk '{print $4}'):")
                        if [ -n "$COMMAND_TMP_001" ]; then
                        #if [ "$(cat /etc/group | grep -i "$(ls -alL $su_file | awk '{print $4}')" | wc -l)" -gt 0 ] ; then
                            cat /etc/group | grep -i "^$(ls -alL $su_file | awk '{print $4}'):" >> $OUTPUT_FILE2 2>&1
                            cat /etc/group | grep -i "wheel" >> $OUTPUT_FILE2 2>&1
                        fi
                        COMMAND_TMP_001=""
                    fi
                done
                cat $OUTPUT_FILE2 | sort | uniq >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "[/etc/group 내용 확인]"   >> $OUTPUT_FILE 2>&1
            echo " /etc/group 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

        echo ""   >> $OUTPUT_FILE 2>&1
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/usr/bin/su" "/bin/su" "/usr/local/bin/su" "/etc/group" "/etc/group" "/etc/pam.conf"
        su_files="/usr/bin/su /bin/su /usr/local/bin/su"

        echo "[su 파일 권한 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/usr/bin/su" ] || [ -f "/bin/su" ] || [ -f "/usr/local/bin/su" ]; then
            for su_file in $su_files; do
                if [ -f "$su_file" ]; then
                    ls -alL $su_file >> $OUTPUT_FILE 2>&1
                fi
            done
        else
            echo "su 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo ""   >> $OUTPUT_FILE 2>&1

        if [ -f "/etc/pam.d/su" ]; then
            echo "[/etc/pam.d/su 확인]"   >> $OUTPUT_FILE 2>&1
            if [ "$(cat /etc/pam.d/su | grep -i "pam_wheel.so" | grep -v '#' | wc -l)" -eq 0 ] ; then
                if [ "$(cat /etc/pam.d/su | grep -i "pam_wheel.so" | wc -l)" -eq 0 ] ; then
                    echo "pam_wheel.so 설정값 미존재" >> $OUTPUT_FILE 2>&1
                else
                    cat /etc/pam.d/su | grep -i "pam_wheel.so"  >> $OUTPUT_FILE 2>&1
                fi
            else
                cat /etc/pam.d/su | grep -i "pam_wheel.so" | grep -v '#' >> $OUTPUT_FILE 2>&1
            fi
        fi
        
        if [ -f "/etc/group" ]; then
            if [ -f "/usr/bin/su" ] || [ -f "/bin/su" ] || [ -f "/usr/local/bin/su" ]; then
                echo "[/etc/group 내용 확인(su파일 그룹 기준)]"   >> $OUTPUT_FILE 2>&1
                for su_file in $su_files; do
                    if [ -f "$su_file" ]; then
                        COMMAND_TMP_001=$(cat /etc/group | grep -i "^$(ls -alL $su_file | awk '{print $4}'):")
                        if [ -n "$COMMAND_TMP_001" ]; then
                        #if [ "$(cat /etc/group | grep -i "$(ls -alL $su_file | awk '{print $4}')" | wc -l)" -gt 0 ] ; then
                            cat /etc/group | grep -i "^$(ls -alL $su_file | awk '{print $4}'):" >> $OUTPUT_FILE2 2>&1
                        fi
                        COMMAND_TMP_001=""
                    fi
                done
                cat $OUTPUT_FILE2 | sort | uniq >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "[/etc/group 내용 확인]"   >> $OUTPUT_FILE 2>&1
            echo " /etc/group 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

        echo ""   >> $OUTPUT_FILE 2>&1
        echo "[/etc/pam.conf 내용 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/pam.conf" ]; then
            if [ "$(cat /etc/pam.conf | egrep -i "su auth|su account|su session" | grep -v '#' | wc -l)" -gt 0 ] ; then
                cat /etc/pam.conf | egrep -i "su auth|su account|su session" | grep -v '#' >> $OUTPUT_FILE 2>&1
            else
                echo "su 설정값 미존재" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo " /etc/pam.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        FILE_COPY "/usr/bin/su" "/bin/su" "/usr/local/bin/su" "/etc/group" "/etc/group" "/etc/pam.conf" "/etc/security/user"
        su_files="/usr/bin/su /bin/su /usr/local/bin/su"

        echo "[su 파일 권한 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/usr/bin/su" ] || [ -f "/bin/su" ] || [ -f "/usr/local/bin/su" ]; then
            for su_file in $su_files; do
                if [ -f "$su_file" ]; then
                    ls -alL $su_file >> $OUTPUT_FILE 2>&1
                fi
            done
        else
            echo "su 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo ""   >> $OUTPUT_FILE 2>&1

        if [ -f "/etc/pam.d/su" ]; then
            echo "[/etc/pam.d/su 확인]"   >> $OUTPUT_FILE 2>&1
            if [ "$(cat /etc/pam.d/su | grep -i "pam_wheel.so" | grep -v '#' | wc -l)" -eq 0 ] ; then
                if [ "$(cat /etc/pam.d/su | grep -i "pam_wheel.so" | wc -l)" -eq 0 ] ; then
                    echo "pam_wheel.so 설정값 미존재" >> $OUTPUT_FILE 2>&1
                else
                    cat /etc/pam.d/su | grep -i "pam_wheel.so"  >> $OUTPUT_FILE 2>&1
                fi
            else
                cat /etc/pam.d/su | grep -i "pam_wheel.so" | grep -v '#' >> $OUTPUT_FILE 2>&1
            fi
        fi
        
        if [ -f "/etc/group" ]; then
            if [ -f "/usr/bin/su" ] || [ -f "/bin/su" ] || [ -f "/usr/local/bin/su" ]; then
                echo "[/etc/group 내용 확인(su파일 그룹 기준)]"   >> $OUTPUT_FILE 2>&1
                for su_file in $su_files; do
                    if [ -f "$su_file" ]; then
                        COMMAND_TMP_001=$(cat /etc/group | grep -i "^$(ls -alL $su_file | awk '{print $4}'):")
                        if [ -n "$COMMAND_TMP_001" ]; then
                        #if [ "$(cat /etc/group | grep -i "$(ls -alL $su_file | awk '{print $4}')" | wc -l)" -gt 0 ] ; then
                            cat /etc/group | grep -i "^$(ls -alL $su_file | awk '{print $4}'):" >> $OUTPUT_FILE2 2>&1
                        fi
                        COMMAND_TMP_001=""
                    fi
                done
                cat $OUTPUT_FILE2 | sort | uniq >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "[/etc/group 내용 확인]"   >> $OUTPUT_FILE 2>&1
            echo " /etc/group 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

        echo ""   >> $OUTPUT_FILE 2>&1
        echo "[/etc/security/user 에서 sugroups 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/security/user" ]; then
            if [ "$(cat /etc/security/user | egrep -i "sugroups =|sugroups=" | wc -l)" -gt 0 ] ; then
                cat /etc/security/user | egrep -i "sugroups =|sugroups=" >> $OUTPUT_FILE 2>&1
            else
                echo "sugroups 설정값 미존재" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo " /etc/security/user 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/usr/bin/su" "/bin/su" "/usr/local/bin/su" "/etc/group" "/etc/group" "/etc/pam.conf" "/etc/security/user"
        su_files="/usr/bin/su /bin/su /usr/local/bin/su"

        echo "[su 파일 권한 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/usr/bin/su" ] || [ -f "/bin/su" ] || [ -f "/usr/local/bin/su" ]; then
            for su_file in $su_files; do
                if [ -f "$su_file" ]; then
                    ls -alL $su_file >> $OUTPUT_FILE 2>&1
                fi
            done
        else
            echo "su 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo ""   >> $OUTPUT_FILE 2>&1

        if [ -f "/etc/pam.d/su" ]; then
            echo "[/etc/pam.d/su 확인]"   >> $OUTPUT_FILE 2>&1
            if [ "$(cat /etc/pam.d/su | grep -i "pam_wheel.so" | grep -v '#' | wc -l)" -eq 0 ] ; then
                if [ "$(cat /etc/pam.d/su | grep -i "pam_wheel.so" | wc -l)" -eq 0 ] ; then
                    echo "pam_wheel.so 설정값 미존재" >> $OUTPUT_FILE 2>&1
                else
                    cat /etc/pam.d/su | grep -i "pam_wheel.so"  >> $OUTPUT_FILE 2>&1
                fi
            else
                cat /etc/pam.d/su | grep -i "pam_wheel.so" | grep -v '#' >> $OUTPUT_FILE 2>&1
            fi
        fi
        
        if [ -f "/etc/group" ]; then
            if [ -f "/usr/bin/su" ] || [ -f "/bin/su" ] || [ -f "/usr/local/bin/su" ]; then
                echo "[/etc/group 내용 확인(su파일 그룹 기준)]"   >> $OUTPUT_FILE 2>&1
                for su_file in $su_files; do
                    if [ -f "$su_file" ]; then
                        COMMAND_TMP_001=$(cat /etc/group | grep -i "^$(ls -alL $su_file | awk '{print $4}'):")
                        if [ -n "$COMMAND_TMP_001" ]; then
                        #if [ "$(cat /etc/group | grep -i "$(ls -alL $su_file | awk '{print $4}')" | wc -l)" -gt 0 ] ; then
                            cat /etc/group | grep -i "^$(ls -alL $su_file | awk '{print $4}'):" >> $OUTPUT_FILE2 2>&1
                        fi
                        COMMAND_TMP_001=""
                    fi
                done
                cat $OUTPUT_FILE2 | sort | uniq >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "[/etc/group 내용 확인]"   >> $OUTPUT_FILE 2>&1
            echo " /etc/group 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

        echo ""   >> $OUTPUT_FILE 2>&1
        echo "[/etc/default/security 에서 SU_ROOT_GROUP 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/default/security" ]; then
            if [ "$(cat /etc/default/security | egrep -i "SU_ROOT_GROUP" | wc -l)" -gt 0 ] ; then
                cat /etc/default/security | egrep -i "SU_ROOT_GROUP" >> $OUTPUT_FILE 2>&1
            else
                echo "SU_ROOT_GROUP 설정값 미존재" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo " /etc/default/security 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_SU_COMMAND_TO_SPECIFIC_GROUPS_INSUFFICIENT_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-45" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-131" 2>&1
}

#U-46
SET_PASSWORD_MINIMUM_LENGTH() {
    echo "SET_PASSWORD_MINIMUM_LENGTH_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-46.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-46_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-46_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    # 구분할때 변수로 사용(minlen)
    SECURITY_TMP01=""
    # 구분할때 변수로 사용(PASS_MIN_LEN)
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1


    echo "[비밀번호사용여부,키사용여부 확인]"   >> $OUTPUT_FILE 2>&1
    echo "$PASSWORDAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo "$PUBKEYAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo ""   >> $OUTPUT_FILE 2>&1


    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/pam.d/system-auth" "/etc/security/pwquality.conf" "/etc/pam.d/password-auth" "/etc/pam.d/common-password" "/etc/pam.d/common-auth" "/etc/login.defs"

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        CHECK_FILES="/etc/pam.d/system-auth /etc/security/pwquality.conf /etc/pam.d/password-auth /etc/pam.d/common-password /etc/pam.d/common-auth /etc/login.defs"
        for CHECK_FILE in $CHECK_FILES; do
            if [ -f "$CHECK_FILE" ]; then
                COMPLEXITY=$(egrep -i 'PASS_MIN_LEN|minlen' $CHECK_FILE 2>/dev/null)
                if [ -z "$COMPLEXITY" ]; then
                    echo "[최소 길이 설정 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE2"
                    echo "최소 길이 설정이 존재하지 않습니다." >> "$OUTPUT_FILE2"
                    echo "" >> "$OUTPUT_FILE2"
                else
                    echo "[최소 길이 설정 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE3"
                    echo "$COMPLEXITY" >> "$OUTPUT_FILE3"
                    #U-46 양취판단
                    SECURITY_TMP01=$(echo "$COMPLEXITY" | grep -v "#" | awk '{print $3}' | awk '{print $1}' | tail -n 1)
                    SECURITY_TMP02=$(echo "$COMPLEXITY" | grep -v "#" | awk '{print $2}' | awk '{print $1}' | tail -n 1)
                    if [ -n "$SECURITY_TMP01" ] && [ "$SECURITY_TMP01" -eq "$SECURITY_TMP01" ] 2>&1; then
                        if [ "$SECURITY_TMP01" -ge 8 ]; then
                            SECURITY_STATUS="Y"
                        fi
                    fi
                    if [ -n "$SECURITY_TMP02" ] && [ "$SECURITY_TMP02" -eq "$SECURITY_TMP02" ] 2>&1; then
                        if [ "$SECURITY_TMP02" -ge 8 ]; then
                            SECURITY_STATUS="Y"
                        fi
                    fi

                    echo "" >> "$OUTPUT_FILE3"
                fi
            fi
        done

        #PASSWDQC_CONF_PATH 파일이 존재할 경우
        if [ -f "$PASSWDQC_CONF_PATH" ]; then
            echo "[패스워드 복잡도 확인 ($PASSWDQC_CONF_PATH)]" >> "$OUTPUT_FILE3"
            cat $PASSWDQC_CONF_PATH | egrep -i 'min=|enforce=' >> "$OUTPUT_FILE3"
            echo "" >> "$OUTPUT_FILE3"
        fi

        if [ -f "$OUTPUT_FILE3" ]; then
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
        fi

    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then      

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        CHECK_FILES="/etc/default/passwd"
        for CHECK_FILE in $CHECK_FILES; do
            if [ -f "$CHECK_FILE" ]; then
                COMPLEXITY=$(egrep -i 'PASSLENGTH=' $CHECK_FILE 2>/dev/null)
                if [ -z "$COMPLEXITY" ]; then
                    echo "[패스워드 최소길이 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE2"
                    echo "PASSLENGTH 내용이 존재하지 않습니다." >> "$OUTPUT_FILE2"
                    echo "" >> "$OUTPUT_FILE2"
                else
                    echo "[패스워드 최소길이 확인 ($CHECK_FILE)]" >> "$OUTPUT_FILE3"
                    echo "$COMPLEXITY" >> "$OUTPUT_FILE3"
                    echo "" >> "$OUTPUT_FILE3"
                fi
            fi
        done

        if [ -f "$OUTPUT_FILE3" ]; then
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
        fi
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)        

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)

        echo "[패스워드 최소길이(minlen) default 값 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1

        files="/etc/security/user"
        keyword1="default:"
        keyword2="minlen"
        end_marker=":"
        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
        if [ $SED_TMP -gt 0 ]; then
            minlenDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            minlenDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$minlenDEFAULT_INFO" ]; then
            echo "$minlenDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (패스워드 최소 길이)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        if command -v lsuser >/dev/null 2>&1; then
            echo "[패스워드 최소길이(minlen) 확인(#lsuser -a minlen <계정명>)]" >> $OUTPUT_FILE 2>&1
        else
            echo "[패스워드 최소길이(minlen) 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1
        fi
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            #찾을 문자열
            if command -v lsuser >/dev/null 2>&1; then
                if [ $SED_TMP -gt 0 ]; then
                    minlenACCOUNT_INFO=$(lsuser -a minlen $USERNAME | sed -e 's/	//g')
                else
                    minlenACCOUNT_INFO=$(lsuser -a minlen $USERNAME | sed -e 's/\s//g')
                fi
                if [ -n "$minlenACCOUNT_INFO" ]; then
                    echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
                    echo "$minlenACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    if [ -n "$minlenDEFAULT_INFO" ]; then
                        echo "$keyword2 (패스워드 최소 길이)가 존재하지 않음(default : $minlenDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "$USERNAME,default 에 $keyword2 (패스워드 최소 길이)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            else
                files="/etc/security/user"
                keyword1="$USERNAME:"
                keyword2="minlen"
                end_marker=":"
                section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
                echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
                if [ $SED_TMP -gt 0 ]; then
                    minlenACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
                else
                    minlenACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
                fi
                if [ -n "$minlenACCOUNT_INFO" ]; then
                    echo "$minlenACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
                else
                    if [ -n "$minlenDEFAULT_INFO" ]; then
                        echo "$keyword2 (패스워드 최소 길이)가 존재하지 않음(default : $minlenDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "$USERNAME,default 에 $keyword2 (패스워드 최소 길이)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    fi
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi



        done
    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        echo "[비밀번호 최소 길이 확인(MIN_PASSWORD_LENGTH) (# cat /etc/default/security)]" >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/default/security" ]; then
            if [ $(cat /etc/default/security | egrep -i "MIN_PASSWORD_LENGTH" | grep -v "#" | wc -l) -eq 0 ]; then
                echo "MIN_PASSWORD_LENGTH(비밀번호 최소 길이) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "MIN_PASSWORD_LENGTH(비밀번호 최소 길이) : $(cat /etc/default/security | grep -i "MIN_PASSWORD_LENGTH" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "/etc/default/security 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "[참고]"   >> $OUTPUT_FILE 2>&1
    echo "PasswordAuthentication- yes: 비밀번호 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "PubkeyAuthentication- yes: 공개키 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_PASSWORD_MINIMUM_LENGTH_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-46" 2>&1
}


#U-47
SET_MAXIMUM_PASSWORD_USAGE_PERIOD() {
    echo "SET_MAXIMUM_PASSWORD_USAGE_PERIOD_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-47.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-47_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-47_REF02.hangrp"
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-47_REF03.hangrp"
    OUTPUT_FILE5="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-47_REF04.hangrp"
    OUTPUT_FILE6="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-47_REF05.hangrp"

    SECURITY_STATUS="CHECK"
    #/etc/login.defs 변수로 사용
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    
    echo "[비밀번호사용여부,키사용여부 확인]"   >> $OUTPUT_FILE 2>&1
    echo "$PASSWORDAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo "$PUBKEYAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo ""   >> $OUTPUT_FILE 2>&1



    ###############################
    #REDHAT 계열, Solaris 계열
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/login.defs" "/etc/passwd "

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi    
        

        # linux 파일
        if [ -f "/etc/login.defs" ]; then
            echo "[/etc/login.defs(PASS_MAX_DAYS)내용]"   >> $OUTPUT_FILE 2>&1
            cat "/etc/login.defs" | grep -i "PASS_MAX_DAYS"    >> $OUTPUT_FILE 2>&1
            SECURITY_TMP01=$(cat /etc/login.defs | grep -v "#" |grep -i "PASS_MAX_DAYS" | awk '{print $2}' | awk '{print $1}' | tail -n 1)
            #U-47 양취판단
            # 숫자인지 확인
            if [ -n "$SECURITY_TMP01" ] && [ "$SECURITY_TMP01" -eq "$SECURITY_TMP01" ] 2>&1; then
                if [ "$SECURITY_TMP01" -gt 90 ] || [ "$SECURITY_TMP01" -eq 0 ]; then
                    SECURITY_STATUS="N"
                fi
            fi

            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        # solaris 파일
        if [ -f "/etc/default/passwd" ]; then
            echo "[/etc/default/passwd(MAXWEEKS)내용]"   >> $OUTPUT_FILE 2>&1
            cat "/etc/default/passwd" | grep -i "MAXWEEKS="    >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        cat /etc/shadow | awk -F: '{ print $1":"$2":"$5 }' > $OUTPUT_FILE2 2>&1
        
        for Chk02 in `cat /etc/passwd | egrep -v "nologin|false|shutdown|sync|halt|:$|/$" | awk -F: '{ print $1 }'`
        do
            if [ "$(grep "^$Chk02:" "$OUTPUT_FILE2" | egrep -v ':(NP|\*LK\*|!|\*):' | wc -l)" -ne 0 ]
                then            
                    if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: 'length($3) > 0' | wc -l)" -ne 0  ]
                        then
                        if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -le 90 ] && [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -ne 0 ]
                            then
                            cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최대 사용기간 : "$3 "(양호)"}'>> "$OUTPUT_FILE3"
                            else
                            if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -eq 0 ]
                                then
                                cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최대 사용기간 : "$3 "(취약/무제한기간)"}'>> "$OUTPUT_FILE4"
                                #U-47 양취판단
                                SECURITY_STATUS="N"
                            fi
                            if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -gt 90 ]
                                then
                                cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최대 사용기간 : "$3 "(취약/90일 초과)"}'>> "$OUTPUT_FILE4"
                                #U-47 양취판단
                                SECURITY_STATUS="N"
                            fi
                        fi
                    else
                        cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최대 사용기간 존재하지 않음(취약/무제한기간)"}'>> "$OUTPUT_FILE4"
                        #U-47 양취판단
                        SECURITY_STATUS="N"
                    fi
            fi
        done


        #비밀번호 미사용 계정의 내용 제거
        if [ -f "$OUTPUT_FILE3" ]; then
            sed 's/$/계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
            egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE3" > $OUTPUT_FILE6 2>&1
            cat $OUTPUT_FILE6 > $OUTPUT_FILE3 2>&1
        fi
        
        if [ -f "$OUTPUT_FILE4" ]; then
            sed 's/$/계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
            egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE4" > $OUTPUT_FILE6 2>&1
            cat $OUTPUT_FILE6 > $OUTPUT_FILE4 2>&1
        fi




        if [ -s $OUTPUT_FILE4 ]; then
            echo " "  >> $OUTPUT_FILE3 2>&1
            echo "[/etc/shadow의 취약한 패스워드 최대 사용기간]"   >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
            echo "[접속가능한 전계정]"   >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
        else
            if [ -f "$OUTPUT_FILE3" ]; then
                echo "[/etc/shadow의 패스워드 최대 사용기간]"   >> $OUTPUT_FILE 2>&1
                cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
                echo "[/etc/shadow 수동 확인(전 계정 비밀번호 미사용)]"   >> $OUTPUT_FILE 2>&1
                cat /etc/shadow >> $OUTPUT_FILE 2>&1
            fi
        fi

        
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)        

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)

        echo "[패스워드 최대사용기간(maxage) default 값 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1

        files="/etc/security/user"
        keyword1="default:"
        keyword2="maxage"
        end_marker=":"
        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
        if [ $SED_TMP -gt 0 ]; then
            maxageDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            maxageDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$maxageDEFAULT_INFO" ]; then
            echo "$maxageDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (패스워드 최대 사용기간)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        if command -v lsuser >/dev/null 2>&1; then
            echo "[패스워드 최대사용기간(maxage) 확인(#lsuser -a maxage <계정명>)]" >> $OUTPUT_FILE 2>&1
        else
            echo "[패스워드 최대사용기간(maxage) 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1
        fi
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            #찾을 문자열
            if command -v lsuser >/dev/null 2>&1; then
                if [ $SED_TMP -gt 0 ]; then
                    maxageACCOUNT_INFO=$(lsuser -a maxage $USERNAME | sed -e 's/	//g')
                else
                    maxageACCOUNT_INFO=$(lsuser -a maxage $USERNAME | sed -e 's/\s//g')
                fi
                if [ -n "$maxageACCOUNT_INFO" ]; then
                    echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
                    echo "$maxageACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    if [ -n "$maxageDEFAULT_INFO" ]; then
                        echo "$keyword2 (패스워드 최대 사용기간)가 존재하지 않음(default : $maxageDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "$USERNAME,default 에 $keyword2 (패스워드 최대 사용기간)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            else
                files="/etc/security/user"
                keyword1="$USERNAME:"
                keyword2="maxage"
                end_marker=":"
                section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
                echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
                if [ $SED_TMP -gt 0 ]; then
                    maxageACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
                else
                    maxageACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
                fi
                if [ -n "$maxageACCOUNT_INFO" ]; then
                    echo "$maxageACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
                else
                    if [ -n "$maxageDEFAULT_INFO" ]; then
                        echo "$keyword2 (패스워드 최대 사용기간)가 존재하지 않음(default : $maxageDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "$USERNAME,default 에 $keyword2 (패스워드 최대 사용기간)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    fi
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        done


    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/shadow"

        echo "[비밀번호 최대 사용기간 확인(PASSWORD_MAXDAYS) (# cat /etc/default/security)]" >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/default/security" ]; then
            if [ $(cat /etc/default/security | egrep -i "PASSWORD_MAXDAYS" | grep -v "#" | wc -l) -eq 0 ]; then
                echo "PASSWORD_MAXDAYS(비밀번호 최대 사용기간) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "PASSWORD_MAXDAYS(비밀번호 최대 사용기간) : $(cat /etc/default/security | grep -i "PASSWORD_MAXDAYS" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "/etc/default/security 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi


        if [ -f "/etc/shadow" ]; then
            cat /etc/shadow | awk -F: '{ print $1":"$2":"$5 }' > $OUTPUT_FILE2 2>&1
            
            for Chk02 in `cat /etc/passwd | egrep -v "nologin|false|shutdown|sync|halt|:$|/$" | awk -F: '{ print $1 }'`
            do
                if [ "$(grep "^$Chk02:" "$OUTPUT_FILE2" | egrep -v ':(NP|\*LK\*|!|\*):' | wc -l)" -ne 0 ]
                    then            
                        if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: 'length($3) > 0' | wc -l)" -ne 0  ]
                            then
                            if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -le 90 ] && [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -ne 0 ]
                                then
                                cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최대 사용기간 : "$3 "(양호)"}'>> "$OUTPUT_FILE3"
                                else
                                if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -eq 0 ]
                                    then
                                    cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최대 사용기간 : "$3 "(취약/무제한기간)"}'>> "$OUTPUT_FILE4"
                                fi
                                if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -gt 90 ]
                                    then
                                    cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최대 사용기간 : "$3 "(취약/90일 초과)"}'>> "$OUTPUT_FILE4"
                                fi
                            fi
                        else
                            cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최대 사용기간 존재하지 않음(취약/무제한기간)"}'>> "$OUTPUT_FILE4"
                        fi
                fi
            done


            #비밀번호 미사용 계정의 내용 제거
            if [ -f "$OUTPUT_FILE3" ]; then
                sed 's/$/계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
                egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE3" > $OUTPUT_FILE6 2>&1
                cat $OUTPUT_FILE6 > $OUTPUT_FILE3 2>&1
            fi
            
            if [ -f "$OUTPUT_FILE4" ]; then
                sed 's/$/계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
                egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE4" > $OUTPUT_FILE6 2>&1
                cat $OUTPUT_FILE6 > $OUTPUT_FILE4 2>&1
            fi




            if [ -s $OUTPUT_FILE4 ]; then
                echo " "  >> $OUTPUT_FILE3 2>&1
                echo "[/etc/shadow의 취약한 패스워드 최대 사용기간]"   >> $OUTPUT_FILE 2>&1
                cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
                echo ""   >> $OUTPUT_FILE 2>&1
                echo "[접속가능한 전계정]"   >> $OUTPUT_FILE 2>&1
                cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
                cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
                if [ -f "$OUTPUT_FILE3" ]; then
                    echo "[/etc/shadow의 패스워드 최대 사용기간]"   >> $OUTPUT_FILE 2>&1
                    cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
                else
                    echo "[/etc/shadow 수동 확인(전 계정 비밀번호 미사용)]"   >> $OUTPUT_FILE 2>&1
                    cat /etc/shadow >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi

    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "[참고]"   >> $OUTPUT_FILE 2>&1
    echo "PasswordAuthentication- yes: 비밀번호 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "PubkeyAuthentication- yes: 공개키 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_MAXIMUM_PASSWORD_USAGE_PERIOD_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-47" 2>&1
}

#U-48
SET_MINIMUM_PASSWORD_USAGE_PERIOD() {
    echo "SET_MINIMUM_PASSWORD_USAGE_PERIOD_START"

    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-48.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-48_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-48_REF02.hangrp"
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-48_REF03.hangrp"
    OUTPUT_FILE5="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-48_REF04.hangrp"
    OUTPUT_FILE6="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-48_REF05.hangrp"

    SECURITY_STATUS="CHECK"
    #/etc/login.defs 변수로 사용
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    echo "[비밀번호사용여부,키사용여부 확인]"   >> $OUTPUT_FILE 2>&1
    echo "$PASSWORDAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo "$PUBKEYAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo ""   >> $OUTPUT_FILE 2>&1


    ###############################
    #REDHAT 계열, Solaris 계열
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ]; then

        if [ ! -s $USER_PASSWORD_USE ]; then
            echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
            echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        # linux 파일
        if [ -f "/etc/login.defs" ]; then
            echo "[/etc/login.defs(PASS_MIN_DAYS)내용]"   >> $OUTPUT_FILE 2>&1
            cat "/etc/login.defs" | grep -i "PASS_MIN_DAYS"    >> $OUTPUT_FILE 2>&1
            SECURITY_TMP01=$(cat /etc/login.defs | grep -v "#" |grep -i "PASS_MIN_DAYS" | awk '{print $2}' | awk '{print $1}' | tail -n 1)
            #U-48 양취판단
            if [ -n "$SECURITY_TMP01" ] && [ "$SECURITY_TMP01" -eq "$SECURITY_TMP01" ] 2>&1; then
                if [ "$SECURITY_TMP01" -eq 0 ]; then
                    SECURITY_STATUS="N"
                fi
            fi
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        # solaris 파일
        if [ -f "/etc/default/passwd" ]; then
            echo "[/etc/default/passwd(MINWEEKS)내용]"   >> $OUTPUT_FILE 2>&1
            cat "/etc/default/passwd" | grep -i "MINWEEKS="    >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi

        cat /etc/shadow | awk -F: '{ print $1":"$2":"$4 }' > $OUTPUT_FILE2 2>&1
        for Chk02 in `cat /etc/passwd | egrep -v "nologin|false|shutdown|sync|halt|:$|/$" | awk -F: '{ print $1 }'`
        do
            if [ "$(cat "$OUTPUT_FILE2" | grep "^$Chk02:" | egrep -v ':(NP|\*LK\*|!|\*):' | wc -l)" -ne 0 ]
            then
                if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: 'length($3) > 0' | wc -l)" -ne 0  ]
                then
                    if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -ge 1 ]
                    then
                        cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최소 사용기간 : "$3 "(양호)"}'>> "$OUTPUT_FILE3"
                    else
                        if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -eq 0 ]
                        then
                            cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최소 사용기간 : "$3 "(취약/기간없음)"}'>> "$OUTPUT_FILE4"
                            #U-48 양취판단
                            SECURITY_STATUS="N"
                        fi
                    fi
                else
                #U-48 양취판단
                SECURITY_STATUS="N"
                cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최소 사용기간 존재하지 않음(취약)"}'>> "$OUTPUT_FILE4"
                fi
            fi
        done


        #비밀번호 미사용 계정의 내용 제거
        if [ -f "$OUTPUT_FILE3" ]; then
            sed 's/$/계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
            egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE3" > $OUTPUT_FILE6 2>&1
            cat $OUTPUT_FILE6 > $OUTPUT_FILE3 2>&1
        fi


        if [ -f "$OUTPUT_FILE4" ]; then
            sed 's/$/계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
            egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE4" > $OUTPUT_FILE6 2>&1
            cat $OUTPUT_FILE6 > $OUTPUT_FILE4 2>&1
        fi




        if [ -s $OUTPUT_FILE4 ]; then
            echo " "  >> $OUTPUT_FILE3 2>&1
            echo "[/etc/shadow의 취약한 패스워드 최소 사용기간]"   >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
            echo "[접속가능한 전계정]"   >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
        else
            if [ -f "$OUTPUT_FILE3" ]; then
                echo "[/etc/shadow의 패스워드 최소 사용기간]"   >> $OUTPUT_FILE 2>&1
                cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
                echo "[/etc/shadow 수동 확인(전 계정 비밀번호 미사용)]"   >> $OUTPUT_FILE 2>&1
                cat /etc/shadow >> $OUTPUT_FILE 2>&1
            fi
        fi
        
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)        

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)

        echo "[패스워드 최소사용기간(minage) default 값 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1

        files="/etc/security/user"
        keyword1="default:"
        keyword2="minage"
        end_marker=":"
        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
        if [ $SED_TMP -gt 0 ]; then
            minageDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            minageDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        if [ -n "$minageDEFAULT_INFO" ]; then
            echo "$minageDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "default 에 $keyword2 (패스워드 최소 사용기간)가 존재하지 않음(default : 0)" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        if command -v lsuser >/dev/null 2>&1; then
            echo "[패스워드 최소사용기간(minage) 확인(#lsuser -a minage <계정명>)]" >> $OUTPUT_FILE 2>&1
        else
            echo "[패스워드 최소사용기간(minage) 확인(#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1
        fi

        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            #찾을 문자열
            if command -v lsuser >/dev/null 2>&1; then
                if [ $SED_TMP -gt 0 ]; then
                    minageACCOUNT_INFO=$(lsuser -a minage $USERNAME | sed -e 's/	//g')
                else
                    minageACCOUNT_INFO=$(lsuser -a minage $USERNAME | sed -e 's/\s//g')
                fi
                if [ -n "$minageACCOUNT_INFO" ]; then
                    echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
                    echo "$minageACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    if [ -n "$minageDEFAULT_INFO" ]; then
                        echo "$keyword2 (패스워드 최소 사용기간)가 존재하지 않음(default : $minageDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "$USERNAME,default 에 $keyword2 (패스워드 최소 사용기간)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            else
                files="/etc/security/user"
                keyword1="$USERNAME:"
                keyword2="minage"
                end_marker=":"
                section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
                echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1
                if [ $SED_TMP -gt 0 ]; then
                    minageACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
                else
                    minageACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
                fi
                if [ -n "$minageACCOUNT_INFO" ]; then
                    echo "$minageACCOUNT_INFO" >> $OUTPUT_FILE 2>&1
                else
                    if [ -n "$minageDEFAULT_INFO" ]; then
                        echo "$keyword2 (패스워드 최소 사용기간)가 존재하지 않음(default : $minageDEFAULT_INFO)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "$USERNAME,default 에 $keyword2 (패스워드 최소 사용기간)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    fi
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        done
    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        #최소 사용기간
        echo "[비밀번호 최소 사용기간 확인(PASSWORD_MINDAYS) (# cat /etc/default/security)]" >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/default/security" ]; then
            if [ $(cat /etc/default/security | egrep -i "PASSWORD_MINDAYS" | grep -v "#" | wc -l) -eq 0 ]; then
                echo "PASSWORD_MINDAYS(비밀번호 최소 사용기간) : 존재하지 않음" >> $OUTPUT_FILE 2>&1
            else
                echo "PASSWORD_MINDAYS(비밀번호 최소 사용기간) : $(cat /etc/default/security | grep -i "PASSWORD_MINDAYS" | grep -v "#")" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "/etc/default/security 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

        if [ -f "/etc/shadow" ]; then
            cat /etc/shadow | awk -F: '{ print $1":"$2":"$4 }' > $OUTPUT_FILE2 2>&1
            for Chk02 in `cat /etc/passwd | egrep -v "nologin|false|shutdown|sync|halt|:$|/$" | awk -F: '{ print $1 }'`
            do
                if [ "$(cat "$OUTPUT_FILE2" | grep "^$Chk02:" | egrep -v ':(NP|\*LK\*|!|\*):' | wc -l)" -ne 0 ]
                then
                    if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: 'length($3) > 0' | wc -l)" -ne 0  ]
                    then
                        if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -ge 1 ]
                        then
                            cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최소 사용기간 : "$3 "(양호)"}'>> "$OUTPUT_FILE3"
                        else
                            if [ "$(cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }')" -eq 0 ]
                            then
                                cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최소 사용기간 : "$3 "(취약/기간없음)"}'>> "$OUTPUT_FILE4"
                            fi
                        fi
                    else
                    cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $1"계정 > 패스워드 최소 사용기간 존재하지 않음(취약)"}'>> "$OUTPUT_FILE4"
                    fi
                fi
            done


            #비밀번호 미사용 계정의 내용 제거
            if [ -f "$OUTPUT_FILE3" ]; then
                sed 's/$/계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
                egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE3" > $OUTPUT_FILE6 2>&1
                cat $OUTPUT_FILE6 > $OUTPUT_FILE3 2>&1
            fi

            if [ -f "$OUTPUT_FILE4" ]; then
                sed 's/$/계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
                egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE4" > $OUTPUT_FILE6 2>&1
                cat $OUTPUT_FILE6 > $OUTPUT_FILE4 2>&1
            fi

            if [ -s $OUTPUT_FILE4 ]; then
                echo " "  >> $OUTPUT_FILE3 2>&1
                echo "[/etc/shadow의 취약한 패스워드 최소 사용기간]"   >> $OUTPUT_FILE 2>&1
                cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
                echo ""   >> $OUTPUT_FILE 2>&1
                echo "[접속가능한 전계정]"   >> $OUTPUT_FILE 2>&1
                cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
                cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
            else
                if [ -f "$OUTPUT_FILE3" ]; then
                    echo "[/etc/shadow의 패스워드 최소 사용기간]"   >> $OUTPUT_FILE 2>&1
                    cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
                else
                    echo "[/etc/shadow 수동 확인(전 계정 비밀번호 미사용)]"   >> $OUTPUT_FILE 2>&1
                    cat /etc/shadow >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "[참고]"   >> $OUTPUT_FILE 2>&1
    echo "PasswordAuthentication- yes: 비밀번호 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "PubkeyAuthentication- yes: 공개키 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_MINIMUM_PASSWORD_USAGE_PERIOD_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-48" 2>&1
}

#U-49,SRV-074
REMOVE_UNUSED_ACCOUNTS() {
    echo "REMOVE_UNUSED_ACCOUNTS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-49_SRV-074.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-49_SRV-074_REF01.hangrp"
    #양호
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-49_SRV-074_REF02.hangrp"
    #취약
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-49_SRV-074_REF03.hangrp"
    OUTPUT_FILE5="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-49_SRV-074_REF04.hangrp"
    OUTPUT_FILE6="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-49_SRV-074_REF05.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    echo "[비밀번호사용여부,키사용여부 확인]"   >> $OUTPUT_FILE 2>&1
    echo "$PASSWORDAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo "$PUBKEYAUTHENTICATION_DEFAULT"   >> $OUTPUT_FILE 2>&1
    echo ""   >> $OUTPUT_FILE 2>&1


    ###############################
    #REDHAT 계열, Solaris 계열, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/shadow" 

        if [ ! -s $USER_PASSWORD_USE ]; then
            if [ -f "/etc/shadow" ]; then
                echo "[비밀번호 사용하는 계정 확인]" >> $OUTPUT_FILE 2>&1
                echo "-비밀번호가 존재하는 계정이 없습니다."   >> $OUTPUT_FILE 2>&1
                echo ""   >> $OUTPUT_FILE 2>&1
            else
                echo "[# cat /etc/passwd ]" >> $OUTPUT_FILE 2>&1
                cat /etc/passwd >> $OUTPUT_FILE 2>&1
                echo ""   >> $OUTPUT_FILE 2>&1

                #마지막접속일
                for Chk02 in `cat /etc/passwd | egrep -v "root|nologin|shutdown|sync|halt|false|:$|/$" | awk -F: '{ print $1 }'`
                do
                    if command -v lastlog >/dev/null 2>&1; then
                        LASTLOG_TMP=$(lastlog | grep -i "^$Chk02 ")
                        if [ -n "$LASTLOG_TMP" ]; then
                            echo "$Chk02 계정 마지막접속일:$LASTLOG_TMP" >> "$OUTPUT_FILE3" 2>&1
                        else
                            echo "$Chk02 계정 마지막접속일:접속기록없음" >> "$OUTPUT_FILE3" 2>&1
                        fi
                        LASTLOG_TMP=""
                    elif command -v last >/dev/null 2>&1; then
                        LASTLOG_TMP=$(last | grep -i "^$Chk02 " | head -1)
                        if [ -n "$LASTLOG_TMP" ]; then
                            echo "$Chk02 계정 마지막접속일:$LASTLOG_TMP" >> "$OUTPUT_FILE3" 2>&1
                        else
                            echo "$Chk02 계정 마지막접속일:접속기록없음" >> "$OUTPUT_FILE3" 2>&1
                        fi
                        LASTLOG_TMP=""
                    fi
                done

            fi
        fi

        if [ -f "/etc/shadow" ]; then
            #패스워드 사용기간
            cat /etc/shadow | awk -F: '{ print $1":"$2":"$3 }' > "$OUTPUT_FILE2"
            for Chk02 in `cat /etc/passwd | egrep -v "root|nologin|false|shutdown|sync|halt|:$|/$" | awk -F: '{ print $1 }'`
            do
                if [ "$(cat "$OUTPUT_FILE2"|grep ^$Chk02":" | egrep -v ':(NP|\*LK\*|!|\*):' | wc -l)" -ne 0 ]
                then
                    ID_TIME=`cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }'`
                    TODAY_TIME=$((`date +%s`/86400))
                    TIME_CHECK=$((TODAY_TIME-ID_TIME))
                    if [ $TIME_CHECK -le 90 ]
                    then
                        echo "$Chk02 계정 패스워드 사용기간:$TIME_CHECK 일(양호/기준:90일)" >> "$OUTPUT_FILE3" 2>&1
                    else
                        echo "$Chk02 계정 패스워드 사용기간:$TIME_CHECK 일(취약/기준:90일)" >> "$OUTPUT_FILE4" 2>&1
                        #U-49,SRV-074 양취판단
                        SECURITY_STATUS="N"
                    fi
                fi
            done

            if [ -s $OUTPUT_FILE4 ]; then
            sed 's/$/ 계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
            egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE4" > $OUTPUT_FILE6 2>&1
            cat $OUTPUT_FILE6 > $OUTPUT_FILE4 2>&1
            fi


            #마지막접속일
            cat /etc/shadow | awk -F: '{ print $1":"$2":"$3 }' > "$OUTPUT_FILE2"
            for Chk02 in `cat /etc/passwd | egrep -v "root|nologin|false|shutdown|sync|halt|:$|/$" | awk -F: '{ print $1 }'`
            do
                if [ "$(cat "$OUTPUT_FILE2" | grep "^$Chk02:" | egrep -v ':(NP|\*LK\*|!|\*):' | wc -l)" -ne 0 ]
                then
                    ID_TIME=`cat "$OUTPUT_FILE2" | grep ^$Chk02":" | awk -F: '{ print $3 }'`
                    TODAY_TIME=$((`date +%s`/86400))
                    TIME_CHECK=$((TODAY_TIME-ID_TIME))
                    if command -v lastlog >/dev/null 2>&1; then
                        LASTLOG_TMP=$(lastlog | grep -i "^$Chk02 ")
                        if [ -n "$LASTLOG_TMP" ]; then
                            echo "$Chk02 계정 마지막접속일:$LASTLOG_TMP" >> "$OUTPUT_FILE3" 2>&1
                        else
                            echo "$Chk02 계정 마지막접속일:접속기록없음" >> "$OUTPUT_FILE3" 2>&1
                        fi
                        LASTLOG_TMP=""
                    elif command -v last >/dev/null 2>&1; then
                        LASTLOG_TMP=$(last | grep -i "^$Chk02 " | head -1)
                        if [ -n "$LASTLOG_TMP" ]; then
                            echo "$Chk02 계정 마지막접속일:$LASTLOG_TMP" >> "$OUTPUT_FILE3" 2>&1
                        else
                            echo "$Chk02 계정 마지막접속일:접속기록없음" >> "$OUTPUT_FILE3" 2>&1
                        fi
                        LASTLOG_TMP=""
                    fi
                fi
            done

            if [ -s $OUTPUT_FILE3 ]; then
            #비밀번호 미사용 계정의 내용 제거
            sed 's/$/ 계정/' "$USER_PASSWORD_USE" > $OUTPUT_FILE5 2>&1
            egrep -f "$OUTPUT_FILE5" "$OUTPUT_FILE3" > $OUTPUT_FILE6 2>&1
            cat $OUTPUT_FILE6 > $OUTPUT_FILE3 2>&1
            fi


            if [ -s $OUTPUT_FILE4 ]; then
                echo " "  >> $OUTPUT_FILE3 2>&1
                if [ -f "$OUTPUT_FILE4" ]; then
                    echo "[/etc/shadow의 취약한 패스워드 사용기간(쉘접속사용계정만확인)]"   >> $OUTPUT_FILE 2>&1
                    cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
                    echo ""   >> $OUTPUT_FILE 2>&1
                fi
                echo "[접속가능한 전계정]"   >> $OUTPUT_FILE 2>&1
                if [ -f "$OUTPUT_FILE4" ]; then
                    cat "$OUTPUT_FILE4" >> "$OUTPUT_FILE" 2>&1
                    if [ -f "$OUTPUT_FILE3" ]; then
                        cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE"
                    fi
                    else
                    if [ -f "$OUTPUT_FILE3" ]; then
                        cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE"
                    fi
                fi
                else
                    if [ -f "$OUTPUT_FILE3" ]; then
                        echo "[/etc/shadow의 패스워드 사용기간]"   >> $OUTPUT_FILE 2>&1
                        cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE"
                    fi
            fi
            echo ""   >> $OUTPUT_FILE 2>&1
            echo "---------------" >> $OUTPUT_FILE 2>&1
            echo "[참고]"   >> $OUTPUT_FILE 2>&1
            echo "root 및 직접 접속을 하지 않고 su(switch user)로 접속하는 경우 마지막 접속일 뜨지 않음"   >> $OUTPUT_FILE 2>&1
        fi

    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/security/user" "/etc/security/lastlog" "/etc/security/passwd"
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)        

        #패스워드 사용기간
        if command -v pwdadm >/dev/null 2>&1; then
            echo "[패스워드 사용기간(lastupdate) 확인 (#pwdadm -q <계정명>)]" >> $OUTPUT_FILE 2>&1
        else
            echo "[패스워드 사용기간(lastupdate) 확인 (#cat /etc/security/user)]" >> $OUTPUT_FILE 2>&1
        fi
        if command -v lsuser >/dev/null 2>&1; then
            echo "[마지막 접속일(time_last_login) 확인 (#lsuser -a time_last_login <계정명>)]" >> $OUTPUT_FILE 2>&1
        else
            echo "[마지막 접속일(time_last_login) 확인 (#cat /etc/security/lastlog)]" >> $OUTPUT_FILE 2>&1
        fi

        echo "" >> $OUTPUT_FILE 2>&1
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            #날자 계산
            TODAY_TIME=$((`date +%s`/86400))

            echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]" >> $OUTPUT_FILE 2>&1

            #패스워드 사용기간
            if command -v pwdadm >/dev/null 2>&1; then
                # 날자 추출
                lastupdateACCOUNT_INFO=$(pwdadm -q $USERNAME | egrep -i "lastupdate" | sed 's/[^0-9]*//g')
                if [ -n "$lastupdateACCOUNT_INFO" ]; then
                    ID_TIME=$(($lastupdateACCOUNT_INFO/86400))
                    TIME_CHECK=$((TODAY_TIME-ID_TIME))
                fi
                
                if [ -n "$lastupdateACCOUNT_INFO" ]; then
                    echo "계정 패스워드 사용기간: $TIME_CHECK 일" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME 계정, 패스워드 사용기간(lastupdate) 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            else
                files="/etc/security/passwd"
                keyword1="$USERNAME:"
                keyword2="lastupdate"
                end_marker=":"
                section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
                lastupdateACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed 's/[^0-9]*//g')
                if [ -n "$lastupdateACCOUNT_INFO" ]; then
                    ID_TIME=$(($lastupdateACCOUNT_INFO/86400))
                    TIME_CHECK=$((TODAY_TIME-ID_TIME))
                fi
                if [ -n "$lastupdateACCOUNT_INFO" ]; then
                    echo "계정 패스워드 사용기간: $TIME_CHECK 일" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME 계정, 패스워드 사용기간(lastupdate) 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi

            #미접속일
            if command -v lsuser >/dev/null 2>&1; then
                time_last_login=$(lsuser -a time_last_login $USERNAME | sed 's/[^0-9]*//g')
                if [ -n "$time_last_login" ]; then
                    ID_TIME=$(($time_last_login/86400))
                    TIME_CHECK=$((TODAY_TIME-ID_TIME))
                fi

                if [ -n "$time_last_login" ]; then
                    echo "계정 미접속일: $TIME_CHECK 일" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME 계정, 미접속일(time_last_login) 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            else
                files="/etc/security/lastlog"
                keyword1="$USERNAME:"
                keyword2="time_last_login"
                end_marker=":"
                section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
                time_last_login=$(echo "$section" | egrep -i "$keyword2" | sed 's/[^0-9]*//g')
                if [ -z "$time_last_login" ]; then
                    ID_TIME=$(($time_last_login/86400))
                    TIME_CHECK=$((TODAY_TIME-ID_TIME))
                fi


                if [ -n "$time_last_login" ]; then
                    echo "계정 미접속일: $TIME_CHECK 일" >> $OUTPUT_FILE 2>&1
                else
                    echo "$USERNAME 계정, 미접속일(time_last_login) 존재하지 않음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            echo "" >> $OUTPUT_FILE 2>&1
        done


        
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "[참고]"   >> $OUTPUT_FILE 2>&1
    echo "PasswordAuthentication- yes: 비밀번호 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "PubkeyAuthentication- yes: 공개키 인증 활성화, no 비활성화"   >> $OUTPUT_FILE 2>&1
    echo "---------------" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE 2>&1
    echo "REMOVE_UNUSED_ACCOUNTS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-49" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-074" 2>&1
}

#U-50,SRV-073
UNNECESSARY_USERS_IN_ADMIN_GROUP() {
    echo "UNNECESSARY_USERS_IN_ADMIN_GROUP_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-50_SRV-073.hangrp"

    SECURITY_STATUS="CHECK"
    # 구분할때 변수로 사용
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/group" 

        echo "[관리자 그룹 계정 현황(GID:0)]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/group" ]; then
            if [ "$(awk -F: '$3 == "0" {print}' /etc/group | wc -l )" -gt 0 ]; then
                awk -F: '$3 == "0" {print}' /etc/group >> $OUTPUT_FILE 2>&1
                #U-50,SRV-073 양취판단
                SECURITY_TMP01=$(awk -F: '$3 == "0" {print}' /etc/group)
                if [ "$(echo "$SECURITY_TMP01" | grep -i "," | wc -l )" -eq 0 ]; then
                    SECURITY_STATUS="Y"
                fi
            else
                cat /etc/group >> $OUTPUT_FILE 2>&1
            fi
            
        else
            echo " /etc/group 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/group" 

        ACCOUNTS=$(awk -F':' '{ print $1 }' /etc/passwd)

        echo "[GID:0 인 /etc/group 현황]"   >> $OUTPUT_FILE 2>&1
        if [ -f "/etc/group" ]; then
            if [ "$(awk -F: '$3 == "0" {print}' /etc/group | wc -l )" -gt 0 ]; then
                awk -F: '$3 == "0" {print}' /etc/group >> $OUTPUT_FILE 2>&1
            else
                cat /etc/group >> $OUTPUT_FILE 2>&1
            fi
            
        else
            echo " /etc/group 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        
        echo "[/etc/security/user 의 admgroups 확인]" >> $OUTPUT_FILE 2>&1
        files="/etc/security/user"
        keyword1="default:"
        keyword2="admgroups"
        end_marker=":"
        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )         

        if [ $SED_TMP -gt 0 ]; then
            admgroupsDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
        else
            admgroupsDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
        fi
        
        if [ -n "$admgroupsDEFAULT_INFO" ]; then
            echo "[default 의 admgroups 확인]"  >> $OUTPUT_FILE 2>&1
            echo "$admgroupsDEFAULT_INFO" >> $OUTPUT_FILE 2>&1
        else
            echo "[default 의 admgroups 확인]"  >> $OUTPUT_FILE 2>&1
            echo "default 에 $keyword2 (관리자 그룹)가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        for ACCOUNT_INFO in $ACCOUNTS; do
            keyword1="$USERNAME:"
            section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )  
            if [ $SED_TMP -gt 0 ]; then
                passwordACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
            else
                passwordACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
            fi
            if [ -n "$passwordACCOUNT_INFO" ]; then
                echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]"  >> $OUTPUT_FILE 2>&1
                echo "$passwordACCOUNT_INFO"  >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        done
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[/etc/group 내용 확인]" >> $OUTPUT_FILE 2>&1
        cat /etc/group >> $OUTPUT_FILE 2>&1
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "UNNECESSARY_USERS_IN_ADMIN_GROUP_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-50" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-073" 2>&1
}

#U-51,SRV-164
PROHIBIT_NONEXISTENT_ACCOUNTS_FOR_GID() {
    echo "PROHIBIT_NONEXISTENT_ACCOUNTS_FOR_GID_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-51_SRV-164.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-51_SRV-164_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-51_SRV-164_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/group" "/etc/passwd" 


        ETC_GROUP_MAIN=$(awk -F':' '{ print $1":"$3":"$4}' /etc/group)
        for ETC_GROUP_MAIN_INFO in $ETC_GROUP_MAIN; do
            GROUP=$(echo "$ETC_GROUP_MAIN_INFO" | cut -d':' -f1)
            GID=$(echo "$ETC_GROUP_MAIN_INFO" | cut -d':' -f2)
            MEMBERS=$(echo "$ETC_GROUP_MAIN_INFO" | cut -d':' -f3)

            #The group contains a user that does not exist in /etc/passwd
            if [ ! -z "$MEMBERS" ]; then
                members_arr=$(echo "$MEMBERS" | tr ',' '\n')
                for MEMBER in $members_arr; do
                    if ! grep -q "^${MEMBER}:" /etc/passwd; then
                        echo "그룹:$GROUP,그룹gid:$GID,존재하지않는계정명:$MEMBER" >> "$OUTPUT_FILE2"
                        echo "-`cat /etc/group | grep -i "$MEMBER"`-" >> "$OUTPUT_FILE2"
                        break
                    fi
                done
            fi

        
        done


        for ETC_GROUP_MAIN_INFO in $ETC_GROUP_MAIN; do
            GROUP=$(echo "$ETC_GROUP_MAIN_INFO" | cut -d':' -f1)
            GID=$(echo "$ETC_GROUP_MAIN_INFO" | cut -d':' -f2)
            MEMBERS=$(echo "$ETC_GROUP_MAIN_INFO" | cut -d':' -f3)

            if ! grep -q "^${GROUP}:" /etc/passwd && [ -z "$MEMBERS" ]; then
                echo "$GROUP (GID: $GID)" >> "$OUTPUT_FILE3" 2>&1
            fi
        done




        echo "[group의 미존재 계정 확인(/etc/group)]"   >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE2" ]; then
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
            #U-51,SRV-164 양취판단
            SECURITY_STATUS="N"
        else
            echo "-group의 미존재 계정이 존재하지 않음"   >> $OUTPUT_FILE 2>&1
            #U-51,SRV-164 양취판단
            SECURITY_STATUS="Y"
        fi
        echo ""   >> $OUTPUT_FILE 2>&1  

        echo "[passwd에 존재하지 않는 group 확인(/etc/group)]"   >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE3" ]; then
            cat "$OUTPUT_FILE3" >> "$OUTPUT_FILE" 2>&1
        else
            echo "-passwd에 존재하지 않는 group 존재하지 않음"   >> $OUTPUT_FILE 2>&1
        fi
        echo ""   >> $OUTPUT_FILE 2>&1  
        echo "[#/etc/group]"   >> $OUTPUT_FILE 2>&1
        cat /etc/group >> $OUTPUT_FILE 2>&1
        echo ""   >> $OUTPUT_FILE 2>&1
        echo "[#/etc/passwd]"   >> $OUTPUT_FILE 2>&1
        cat /etc/passwd >> $OUTPUT_FILE 2>&1
     
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PROHIBIT_NONEXISTENT_ACCOUNTS_FOR_GID_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-51" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-164" 2>&1
}

#U-52,SRV-142
PROHIBIT_DUPLICATE_UID() {
    echo "PROHIBIT_DUPLICATE_UID_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-52_SRV-142.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-52_SRV-142_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-52_SRV-142_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/passwd"

        # 각 UID별로 사용자 수를 세고, 중복된 UID만 추출
        uids=$(awk -F: '{print $3}' /etc/passwd | sort | uniq -d)

        for uid in $uids; do
            # 중복된 UID에 대한 사용자 정보를 추출
            result=$(awk -F: -v uid="$uid" '$3 == uid {print "계정명: " $1 " / UID: " $3}' /etc/passwd)
            echo "$result" >> "$OUTPUT_FILE2"
        done


        echo "[중복된 UID 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE2" ]; then
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
            #U-52,SRV-142 양취판단
            SECURITY_STATUS="N"
        else
            echo "-중복된 UID 가 존재하지 않음"   >> $OUTPUT_FILE 2>&1
            #U-52,SRV-142 양취판단
            SECURITY_STATUS="Y"
        fi
        echo ""   >> $OUTPUT_FILE 2>&1  
        echo "[#/etc/passwd]"   >> $OUTPUT_FILE 2>&1
        if [ $(cat /etc/passwd | sort -k 3 -n -t ":" 2>/dev/null | wc -l) -gt 0 ]; then
            cat /etc/passwd | sort -k 3 -n -t ":" 2>/dev/null >> $OUTPUT_FILE 2>&1
        else
            cat /etc/passwd   >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PROHIBIT_DUPLICATE_UID_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-52" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-142" 2>&1
}

#U-53,SRV-165
USER_SHELL_CHECK() {
    echo "USER_SHELL_CHECK_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-53_SRV-165.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-53_SRV-165_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        ChkID_00="^daemon: ^bin: ^sys: ^adm: ^listen: ^nobody: ^nobody4: ^noaccess: ^diag: ^operator: ^games: ^gopher:"

        for CHKID_01 in $ChkID_00
        do
            if [ "$(cat /etc/passwd | grep $CHKID_01 | grep -v "admin"| wc -l)" -gt 0 ] ; then
                if [ "$(cat /etc/passwd | grep $CHKID_01 | grep -v "admin" | awk -F/ '{print $NF}' | egrep -v 'nologin|false|shutdown|sync|halt|:$|/$'| wc -l)" -ne 0 ] ; then
                    cat /etc/passwd | grep $CHKID_01 | grep -v "admin" >> $OUTPUT_FILE2
                fi
            fi
        done  

        echo "[일반적으로 로그인이 필요하지 않은 계정 확인]"   >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE2" ]; then
            cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
            #U-53,SRV-165 양취판단
            SECURITY_STATUS="N"
        else
            cat /etc/passwd | egrep "^daemon|^bin|^sys|^adm|^listen|^nobody|^nobody4|^noaccess|^diag|^operator|^games|^gopher" |grep -v "admin"   >> $OUTPUT_FILE 2>&1
            #U-53,SRV-165 양취판단
            SECURITY_STATUS="Y"
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[# 쉘접속 가능 계정 확인(id,uid,shell정보)]"   >> $OUTPUT_FILE 2>&1
        # awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$7}' /etc/passwd >> $OUTPUT_FILE 2>&1
        awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$3":"$7
            }
        ' /etc/passwd >> "$OUTPUT_FILE" 2>&1

    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "USER_SHELL_CHECK_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-53" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-165" 2>&1
}

#U-54,SRV-028
SESSION_TIMEOUT_CONFIGURATION() {
    echo "SESSION_TIMEOUT_CONFIGURATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-54_SRV-028.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-54_SRV-028_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-54_SRV-028_REF02.hangrp"
    #계정별 확인
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-54_SRV-028_REF03.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    echo "[#echo \$TMOUT]"   >> $OUTPUT_FILE 2>&1
    if [ -n "$TMOUT" ]; then
        echo $TMOUT >> $OUTPUT_FILE 2>&1
        else
        echo "-결과값 없음" >> $OUTPUT_FILE 2>&1
    fi
    echo ""   >> $OUTPUT_FILE 2>&1

    # linux
    if [ -f /etc/profile ]; then
        echo "[세션타임아웃 설정값 확인(/etc/profile)]"   >> $OUTPUT_FILE 2>&1
        if [ "$(cat /etc/profile | egrep -i "TMOUT|TIMEOUT" | grep -v "#" | wc -l)" -eq 0 ]; then
            echo "TMOUT 설정값 미존재" >> $OUTPUT_FILE 2>&1
        else
            cat /etc/profile | egrep -i "TMOUT|TIMEOUT" | grep -v "#" >> $OUTPUT_FILE 2>&1
        fi
    else
        if [ -f /etc/.profile ]; then
            if [ "$(cat /etc/.profile | egrep -i "TMOUT|TIMEOUT" | grep -v "#" | wc -l)" -eq 0 ]; then
                echo "TMOUT 설정값 미존재" >> $OUTPUT_FILE 2>&1
            else
                cat /etc/.profile | egrep -i "TMOUT|TIMEOUT" | grep -v "#" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi

    # solaris 
    echo ""   >> $OUTPUT_FILE 2>&1
    if [ -f /etc/default/login ]; then
        echo "[세션타임아웃 설정값 확인(/etc/default/login)]"   >> $OUTPUT_FILE 2>&1
        if [ "$(cat /etc/default/login | egrep -i "TMOUT|TIMEOUT" | grep -v "#" | wc -l)" -gt 0 ]; then
            cat /etc/default/login | egrep -i "TMOUT|TIMEOUT" | grep -v "#" >> $OUTPUT_FILE 2>&1
        else
            if [ "$(cat /etc/default/login | egrep -i "TMOUT|TIMEOUT" | wc -l)" -gt 0 ]; then
                cat /etc/default/login | egrep -i "TMOUT|TIMEOUT" >> $OUTPUT_FILE 2>&1
                echo "(세션 타임아웃 값에 주석 처리 되어 있음)" >> $OUTPUT_FILE 2>&1
            else
                echo "세션타임아웃 설정값 미존재" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    echo ""   >> $OUTPUT_FILE 2>&1

    # aix
    echo ""   >> $OUTPUT_FILE 2>&1
    if [ -f /etc/security/.profile ]; then
        echo "[세션타임아웃 설정값 확인(/etc/security/.profile)]"   >> $OUTPUT_FILE 2>&1
        if [ "$(cat /etc/security/.profile | egrep -i "TMOUT|TIMEOUT" | grep -v "#" | wc -l)" -gt 0 ]; then
            cat /etc/security/.profile | egrep -i "TMOUT|TIMEOUT" | grep -v "#" >> $OUTPUT_FILE 2>&1
        else
            if [ "$(cat /etc/security/.profile | egrep -i "TMOUT|TIMEOUT" | wc -l)" -gt 0 ]; then
                cat /etc/security/.profile | egrep -i "TMOUT|TIMEOUT" >> $OUTPUT_FILE 2>&1
                echo "(세션 타임아웃 값에 주석 처리 되어 있음)" >> $OUTPUT_FILE 2>&1
            else
                echo "세션타임아웃 설정값 미존재" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/profile" "/etc/.profile" "/etc/default/login" "/etc/security/.profile"

        #계정별 확인(시작)
        GLOBAL_FILES="/etc/profile /etc/.profile /etc/login.defs /etc/bashrc /etc/csh.cshrc /etc/csh.login /etc/csh.logout /etc/zshrc /etc/zprofile /etc/zlogin /etc/zlogout /etc/zshenv /etc/ksh.kshrc /etc/ksh.login /etc/ksh.logout /etc/kshrc /etc/default/login"
        
        for GLOBAL_FILE in $GLOBAL_FILES; do
            if grep -i -q "^TMOUT" "$GLOBAL_FILE" 2>/dev/null; then
                echo "GLOBAL, ${GLOBAL_FILE}: $(grep -i "^TMOUT" "$GLOBAL_FILE")" >> $OUTPUT_FILE4
            fi
            if grep -i -q "^TIMEOUT" "$GLOBAL_FILE" 2>/dev/null; then
                echo "GLOBAL, ${GLOBAL_FILE}: $(grep -i "^TIMEOUT" "$GLOBAL_FILE")" >> $OUTPUT_FILE4
            fi
            if grep -i -q "^autologout" "$GLOBAL_FILE" 2>/dev/null; then
                echo "GLOBAL, ${GLOBAL_FILE}: $(grep -i "^autologout" "$GLOBAL_FILE")" >> $OUTPUT_FILE4
            fi
        done

        # ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$6}' /etc/passwd)

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$6
            }
        ' /etc/passwd)

        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo $ACCOUNT_INFO | cut -d: -f1)
            HOME_DIR=$(echo $ACCOUNT_INFO | cut -d: -f6)

            ENV_FILES="${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE/${USERNAME}/_.*"

            for ENV_FILE in $ENV_FILES; do
                RELATIVE_FILE=$(echo $ENV_FILE | sed "s|${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE/${USERNAME}/_||")
                if grep -i -q "^TMOUT" "$ENV_FILE" 2>/dev/null; then
                    echo "${USERNAME}, ${RELATIVE_FILE}: $(grep -i "^TMOUT" "$ENV_FILE")" >> $OUTPUT_FILE4
                fi
                if grep -i -q "^TIMEOUT" "$ENV_FILE" 2>/dev/null; then
                    echo "${USERNAME}, ${RELATIVE_FILE}: $(grep -i "^TIMEOUT" "$ENV_FILE")" >> $OUTPUT_FILE4
                fi
                if grep -i -q "^autologout" "$ENV_FILE" 2>/dev/null; then
                    echo "${USERNAME}, ${RELATIVE_FILE}: $(grep -i "^autologout" "$ENV_FILE")" >> $OUTPUT_FILE4
                fi
            done
        done
        
        if [ -f "$OUTPUT_FILE4" ]; then
            echo "[전역/계정별 세션타임아웃 확인]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE4 >> $OUTPUT_FILE 2>&1
            echo ""   >> $OUTPUT_FILE 2>&1
        fi
        #계정별 확인(종료)


        if [ -f "$SSH_CONFIG_PATH" ]; then
            if [ "$(cat $SSH_CONFIG_PATH | egrep -i "ClientAliveInterval|ClientAliveCountMax|TCPKeepAlive" | grep -v "#" |  wc -l)" -gt 0 ]; then
                echo "[$SSH_CONFIG_PATH 내용 확인]"   >> $OUTPUT_FILE 2>&1
                cat $SSH_CONFIG_PATH | egrep -i "ClientAliveInterval|ClientAliveCountMax|TCPKeepAlive" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
            echo "---------------" >> $OUTPUT_FILE 2>&1
            echo "[참고 환경변수 우선순위]" >> $OUTPUT_FILE 2>&1
            echo "1. 사용자 로그인 쉘 환경 설정 파일(.bashrc, .zshrc 등):" >> $OUTPUT_FILE 2>&1
            echo "2. 사용자 홈 디렉토리의 전역 환경 설정 파일(.profile, .bash_profile 등)" >> $OUTPUT_FILE 2>&1
            echo "3. 쉘의 전역 환경 설정 파일(/etc/bash.bashrc, /etc/zsh/zshrc 등)" >> $OUTPUT_FILE 2>&1
            echo "4. 시스템 전역 환경 설정 파일(/etc/profile 등):" >> $OUTPUT_FILE 2>&1
            echo "---------------" >> $OUTPUT_FILE 2>&1
        fi
        
    fi 
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SESSION_TIMEOUT_CONFIGURATION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-54" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-028" 2>&1
}



#U-05,SRV-121
ROOT_HOME_PATH_PERMISSIONS_AND_PATH_CONFIGURATION() {
echo "ROOT_HOME_PATH_PERMISSIONS_AND_PATH_CONFIGURATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-05_SRV-121.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-05_SRV-121_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-05_SRV-121_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ]; then
        ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && $7 != "/sbin/nologin" && $7 != "/usr/sbin/nologin" && $7 != "/bin/false" && $7 != "") print $1":"$7}' /etc/passwd)

        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo $ACCOUNT_INFO | cut -d: -f1)
            USER_SHELL=$(echo $ACCOUNT_INFO | cut -d: -f2)

            case "$USER_SHELL" in
                */bash*)
                    PROFILE_FILES=".bashrc .bash_profile .bash_login .profile .bash_logout .environment .env"
                    ;;
                */ksh*)
                    PROFILE_FILES=".kshrc .profile .environment .env"
                    ;;
                */zsh*)
                    PROFILE_FILES=".zshrc .zprofile .zshenv .zlogin .zlogout .environment .env"
                    ;;
                */csh*)
                    PROFILE_FILES=".cshrc .login .logout .cshdirs .environment .env"
                    ;;
                */tcsh*)
                    PROFILE_FILES=".tcshrc .login .logout .cshdirs .environment .env"
                    ;;
                */sh|*/ash|*/dash|*/yash)
                    PROFILE_FILES=".profile .shrc .ashrc .dashrc .yashrc .environment .env"
                    ;;
            esac



            for PROFILE_FILE in $PROFILE_FILES; do
                if [ -f "${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE/${USERNAME}/_${PROFILE_FILE}" ]; then
                    PATH_VALUE=$(egrep 'PATH=' "${CREATE_FILE_DIR}/USER_ENVIROMENT_FILE/${USERNAME}/_${PROFILE_FILE}" | grep -v "#" | cut -d '=' -f2)
                    if [ ! -z "$PATH_VALUE" ]; then
                        #전체PATH
                        echo "(USER:${USERNAME})(File:${PROFILE_FILE})" >> $OUTPUT_FILE2
                        echo "${PATH_VALUE}" >> $OUTPUT_FILE2
                        echo "" >> $OUTPUT_FILE2 2>&1
                        
                        case "$PATH_VALUE" in
                            *".:"*|*"::"*)
                                #취약한PATH
                                echo "(USER:${USERNAME})(File:${PROFILE_FILE})" >> $OUTPUT_FILE3
                                echo "${PATH_VALUE}" >> $OUTPUT_FILE3
                                echo "" >> $OUTPUT_FILE3 2>&1
                                ;;
                        esac
                    fi
                fi
            done
        done
        
        echo "" >> $OUTPUT_FILE 2>&1
        
        case ":$PATH" in
            *".:"*|*"::"*)
                echo "[echo \$PATH(취약)]" >> "$OUTPUT_FILE" 2>&1
                echo "($PATH)" >> "$OUTPUT_FILE" 2>&1
                ;;
            *)
                echo "[echo \$PATH(\".\", \"::\" 존재하지 않음)]" >> "$OUTPUT_FILE" 2>&1
                echo "($PATH)" >> "$OUTPUT_FILE" 2>&1
                ;;
        esac

        echo "" >> $OUTPUT_FILE 2>&1

        if [ -f /etc/default/login ]; then
            echo "[/etc/default/login 에서 PATH 확인]"   >> $OUTPUT_FILE 2>&1
            if [ "$(cat /etc/default/login | grep -i "PATH=" | grep -v "#" | wc -l)" -gt 0 ]; then
                cat /etc/default/login | grep -i "PATH=" | grep -v "#" >> $OUTPUT_FILE 2>&1
            else
                if [ "$(cat /etc/default/login | grep -i "PATH=" | grep -v "#" | wc -l)" -gt 0 ]; then
                    cat /etc/default/login | grep -i "PATH=" | grep -v "#" >> $OUTPUT_FILE 2>&1
                else
                    echo "-PATH 설정값 미존재" >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 PATH 확인]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-05,SRV-121 양취판단
            SECURITY_STATUS="N"
        else
            #U-05,SRV-121 양취판단
            SECURITY_STATUS="Y"
        fi

        if [ -f "$OUTPUT_FILE2" ] ; then
            echo "[전체 PATH 확인]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        fi
    fi 
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "ROOT_HOME_PATH_PERMISSIONS_AND_PATH_CONFIGURATION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-05" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-121" 2>&1
}

#U-06,SRV-095
SET_FILE_AND_DIRECTORY_OWNERSHIP() {
echo "SET_FILE_AND_DIRECTORY_OWNERSHIP_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-06_SRV-095.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-06_SRV-095_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    echo ">> If it will take more than 20 minutes, please tell the consultant...." >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        # 소유자 및 그룹이 존재하지 않는 파일 검색
        # not 구문 solaris 에서 동작하지 않아 주석처리
        #find / -xdev \( -nouser -o -nogroup \) -not -path "*docker*" -exec ls -alLd {} \; >> $OUTPUT_FILE2 2>/dev/null
        find / -xdev \( -nouser -o -nogroup \) -exec ls -alLd {} \; 2>/dev/null | egrep -v "docker|/cache/codedeploy" >> $OUTPUT_FILE2 2>/dev/null
        cat "$OUTPUT_FILE2" >> $CHECK_NOUSER_NOGROUP_FILE 2>&1
        COUNT=0
        COUNT=$(cat "$OUTPUT_FILE2" | wc -l)
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[#find / -xdev \( -nouser -o -nogroup \) -exec ls -alLd {} \;]"   >> $OUTPUT_FILE 2>&1
        if [ -s $OUTPUT_FILE2 ]; then
            if [ $COUNT -gt 100 ]
                then
                echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                echo "(엑셀 셀 입력 제한으로 인하여 스크립트 결과값 참조./SECURITY_INSPECTION_TEMP/$(hostname)+${HOST_IP}+NOUSER_NOGROUP_FILE.hangrp)" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 | head -n 100 >> $OUTPUT_FILE 2>&1
                else
                echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                cat "$OUTPUT_FILE2" >> "$OUTPUT_FILE" 2>&1
            fi
        else
            echo "-소유자 및 그룹이 존재하지 않는 파일이 존재하지 않음"   >> $OUTPUT_FILE 2>&1
            echo "-소유자 및 그룹이 존재하지 않는 파일이 존재하지 않음"   >> $CHECK_NOUSER_NOGROUP_FILE 2>&1
            #U-06,SRV-095
            SECURITY_STATUS="Y"
        fi
    fi 
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_FILE_AND_DIRECTORY_OWNERSHIP_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-06" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-095" 2>&1
}

#U-07
SET_ETC_PASSWD_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_ETC_PASSWD_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-07.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-07_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "[/etc/passwd의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/passwd ]; then
            if perm_644 '/etc/passwd'
            then
                printf "%s" "$(ls -al /etc/passwd)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
                #U-07 양취판단
                SECURITY_STATUS="Y"
            else
                printf "%s" "$(ls -al /etc/passwd)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한 취약/권장:644이하)" >> "$OUTPUT_FILE" 2>&1
                #U-07 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/passwd" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/passwd)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/passwd >> "$OUTPUT_FILE" 2>&1
                fi
            fi
            echo "" >> $OUTPUT_FILE 2>&1
        else
            echo "-/etc/passwd 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_ETC_PASSWD_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-07" 2>&1
}

#U-08
SET_ETC_SHADOW_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_ETC_SHADOW_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-08.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-08_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/shadow"
        echo "[/etc/shadow의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/shadow ]; then
            if perm_400 '/etc/shadow'
            then
                printf "%s" "$(ls -al /etc/shadow)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
                #U-08 양취판단
                SECURITY_STATUS="Y"
            else
                printf "%s" "$(ls -al /etc/shadow)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 취약/권장:400이하)" >> "$OUTPUT_FILE" 2>&1
                #U-08 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/shadow" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/shadow)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/shadow >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/shadow 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/security/passwd"
        echo "[/etc/security/passwd 의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/security/passwd ]; then
            if perm_600 '/etc/security/passwd'
            then
                printf "%s" "$(ls -al /etc/security/passwd)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
                #U-08 양취판단
                SECURITY_STATUS="Y"
            else
                printf "%s" "$(ls -al /etc/security/passwd)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 취약/권장:600이하)" >> "$OUTPUT_FILE" 2>&1
                #U-08 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/security/passwd" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/security/passwd)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/security/passwd >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/security/passwd 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/shadow"
        echo "[/etc/shadow의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/shadow ]; then
            if perm_400 '/etc/shadow'
            then
                printf "%s" "$(ls -al /etc/shadow)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
            else
                printf "%s" "$(ls -al /etc/shadow)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 취약/권장:400이하)" >> "$OUTPUT_FILE" 2>&1
                #U-08 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/shadow" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/shadow)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/shadow >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/shadow 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        echo "[/tcb/files/auth/ 디렉터리의 파일들 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -d /tcb/files/auth ]; then
            if perm_400 '/tcb/files/auth'
            then
                printf "%s" "$(ls -al /tcb/files/auth)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
            else
                printf "%s" "$(ls -al /tcb/files/auth)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 취약/권장:400이하)" >> "$OUTPUT_FILE" 2>&1
                #U-08 양취판단
                SECURITY_STATUS="N"
            fi
            if [ -L "/tcb/files/auth" ]; then
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[링크디렉터리 원본 권한 확인(#ls -alL /tcb/files/auth)]" >> $OUTPUT_FILE 2>&1
                ls -alL /tcb/files/auth >> "$OUTPUT_FILE" 2>&1
            fi
        else
            echo "-/tcb/files/auth 디렉터리가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_ETC_SHADOW_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-08" 2>&1
}

#U-09
SET_ETC_HOSTS_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_ETC_HOSTS_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-09.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-09_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/hosts"
        echo "[/etc/hosts의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/hosts ]; then
            if perm_600 '/etc/hosts'
            then
                printf "%s" "$(ls -al /etc/hosts)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
                #U-09 양취판단
                SECURITY_STATUS="Y"
            else
                printf "%s" "$(ls -al /etc/hosts)" >> "$OUTPUT_FILE" 2>&1
                echo " (권한 취약/권장:600이하)" >> $OUTPUT_FILE 2>&1
                #U-09 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/hosts" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/hosts)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/hosts >> "$OUTPUT_FILE" 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                if [ "$(cat /etc/hosts | grep -v "#" | wc -l)" -eq 0 ] 
                    then
                    echo "[#cat /etc/hosts 내용]" >> $OUTPUT_FILE 2>&1
                    echo "-hosts 파일에 내용이 존재하지 않음" >> $OUTPUT_FILE 2>&1
                    else
                    echo "[#cat /etc/hosts 내용]" >> $OUTPUT_FILE 2>&1
                    cat /etc/hosts | grep -v "#" >> $OUTPUT_FILE 2>&1
                fi
            fi
        else
            echo "-/etc/hosts 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_ETC_HOSTS_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-09" 2>&1
}

#U-10
SET_ETC_XINETD_CONF_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_ETC_XINETD_CONF_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-10.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-10_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/xinetd.conf" "/etc/inetd.conf"
        echo "[/etc/xinetd.conf의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/xinetd.conf ]; then
            if perm_600 '/etc/xinetd.conf'
            then
                printf "%s" "$(ls -al /etc/xinetd.conf)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
            else
                printf "%s" "$(ls -al /etc/xinetd.conf)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한 취약/권장:600이하)" >> "$OUTPUT_FILE" 2>&1
                #U-10 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/xinetd.conf" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/xinetd.conf)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/xinetd.conf >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/xinetd.conf 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[/etc/xinetd.d/의 파일들의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -d /etc/xinetd.d ]; then
            XINETD_FILE_TMPS=$(find /etc/xinetd.d -type f -name "*")
            for XINETD_FILE_TMP in $XINETD_FILE_TMPS; do
                if perm_600 "$XINETD_FILE_TMP"
                then
                    printf "%s" "$(ls -al "$XINETD_FILE_TMP")" >> "$OUTPUT_FILE" 2>&1
                    echo " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
                else
                    printf "%s" "$(ls -al "$XINETD_FILE_TMP")" >> "$OUTPUT_FILE" 2>&1
                    echo " (권한 취약/권장:600이하)" >> "$OUTPUT_FILE" 2>&1
                    #U-10 양취판단
                    SECURITY_STATUS="N"
                    if [ -L "$XINETD_FILE_TMP" ]; then
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "[링크파일 원본 권한 확인(#ls -alL <파일명>)]" >> $OUTPUT_FILE 2>&1
                        ls -alL "$XINETD_FILE_TMP" >> "$OUTPUT_FILE" 2>&1
                    fi
                fi
            done
        else
            echo "-/etc/xinetd.d/ 디렉토리가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[/etc/inetd.conf의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/inetd.conf ]; then
            if perm_600 '/etc/inetd.conf'
            then
                printf "%s" "$(ls -al /etc/inetd.conf)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
            else
                printf "%s" "$(ls -al /etc/inetd.conf)" >> $OUTPUT_FILE 2>&1
                printf "%s" " (권한 취약/권장:600이하)" >> "$OUTPUT_FILE" 2>&1
                #U-10 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/inetd.conf" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/inetd.conf)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/inetd.conf >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/inetd.conf 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi

    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_ETC_XINETD_CONF_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-10" 2>&1
}

#U-11
SET_ETC_SYSLOG_CONF_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_ETC_SYSLOG_CONF_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-11.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-11_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/syslog.conf" "/etc/rsyslog.conf" "/etc/syslog-ng.conf"
        echo "[/etc/syslog.conf의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/syslog.conf ]; then
            if perm_640 '/etc/syslog.conf'
            then
                printf "%s" "$(ls -al /etc/syslog.conf)" >> "$OUTPUT_FILE" 2>&1
                echo " (권한 양호)" >> $OUTPUT_FILE 2>&1
            else
                printf "%s" "$(ls -al /etc/syslog.conf)" >> "$OUTPUT_FILE" 2>&1
                echo " (권한 취약/권장:640이하)" >> $OUTPUT_FILE 2>&1
                #U-11 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/syslog.conf" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/syslog.conf)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/syslog.conf >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/syslog.conf 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[/etc/rsyslog.conf의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/rsyslog.conf ]; then
            if perm_640 '/etc/rsyslog.conf'
            then
                printf "%s" "$(ls -al /etc/rsyslog.conf)" >> "$OUTPUT_FILE" 2>&1
                echo " (권한 양호)" >> $OUTPUT_FILE 2>&1
            else
                printf "%s" "$(ls -al /etc/rsyslog.conf)" >> "$OUTPUT_FILE" 2>&1
                echo " (권한 취약/권장:640이하)" >> $OUTPUT_FILE 2>&1
                #U-11 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/rsyslog.conf" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/rsyslog.conf)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/rsyslog.conf >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/rsyslog.conf 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_ETC_SYSLOG_CONF_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-11" 2>&1
}

#U-12
SET_ETC_SERVICES_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_ETC_SERVICES_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-12.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-12_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/services"
        echo "[/etc/services의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/services ]; then
            if perm_644 '/etc/services'
            then
                printf "%s" "$(ls -al /etc/services)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한 양호)" >> "$OUTPUT_FILE" 2>&1
                #U-12 양취판단
                SECURITY_STATUS="Y"
            else
                printf "%s" "$(ls -al /etc/services)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한 취약/권장:644이하)" >> "$OUTPUT_FILE" 2>&1
                #U-12 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/services" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/services)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/services >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/services 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_ETC_SERVICES_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-12" 2>&1
}

#U-55
SET_HOSTS_LPD_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_HOSTS_LPD_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-55.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-55_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/hosts.lpd"
        echo "[/etc/hosts.lpd의 권한]"   >> $OUTPUT_FILE 2>&1
        if [ -f /etc/hosts.lpd ]; then
            if perm_600 '/etc/hosts.lpd'
            then
                printf "%s" "$(ls -al /etc/hosts.lpd)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한양호)" >> "$OUTPUT_FILE" 2>&1
                #U-55 양취판단
                SECURITY_STATUS="Y"
            else
                printf "%s" "$(ls -al /etc/hosts.lpd)" >> "$OUTPUT_FILE" 2>&1
                printf "%s" " (권한 취약/권장:600이하)" >> "$OUTPUT_FILE" 2>&1
                #U-55 양취판단
                SECURITY_STATUS="N"
                if [ -L "/etc/hosts.lpd" ]; then
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/hosts.lpd)]" >> $OUTPUT_FILE 2>&1
                    ls -alL /etc/hosts.lpd >> "$OUTPUT_FILE" 2>&1
                fi
            fi
        else
            echo "-/etc/hosts.lpd 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_HOSTS_LPD_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-55" 2>&1
}

#SRV-084
SET_INSUFFICIENT_PERMISSIONS_FOR_SYSTEM_CRITICAL_FILES() {
echo "SET_INSUFFICIENT_PERMISSIONS_FOR_SYSTEM_CRITICAL_FILES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-084.hangrp"
    #권한 양호
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-084_REF01.hangrp"
    #권한 취약
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-084_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/shadow" "/etc/hosts" "/etc/xinetd.conf" "/etc/inetd.conf" "/etc/syslog.conf" "/etc/rsyslog.conf" "/etc/services" "/etc/hosts.lpd"

        if [ -f /etc/passwd ]; then
            if perm_644 '/etc/passwd'
            then
                echo "[/etc/passwd의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/passwd >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/passwd의 권한(권장권한:644)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/passwd >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/passwd" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/passwd)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/passwd >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        else
            echo "[/etc/passwd의 권한]"   >> $OUTPUT_FILE2 2>&1
            echo "-/etc/passwd 파일이 존재하지 않음" >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi

        # linux, solaris
        if [ -f /etc/shadow ]; then
            if perm_600 '/etc/shadow'
            then
                echo "[/etc/shadow의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/shadow >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1

            else
                echo "[/etc/shadow의 권한(권장권한:600)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/shadow >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/shadow" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/shadow)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/shadow >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        fi

        # AIX
        if [ -f /etc/security/passwd ]; then
            if perm_600 '/etc/security/passwd'
            then
                echo "[/etc/security/passwd의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/security/passwd >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/security/passwd의 권한(권장권한:600)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/security/passwd >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/security/passwd" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/security/passwd)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/security/passwd >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        fi



        if [ -f /etc/hosts ]; then
            if perm_644 '/etc/hosts'
            then
                echo "[/etc/hosts의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/hosts >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/hosts의 권한(권장권한:644)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/hosts >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/hosts" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/hosts)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/hosts >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        else
            echo "[/etc/hosts의 권한]"   >> $OUTPUT_FILE2 2>&1
            echo "-/etc/hosts 파일이 존재하지 않음" >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi



        if [ -f /etc/xinetd.conf ]; then
            if perm_600 '/etc/xinetd.conf'
            then
                echo "[/etc/xinetd.conf의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/xinetd.conf >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/xinetd.conf의 권한(권장권한:600)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/xinetd.conf >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/xinetd.conf" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/xinetd.conf)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/xinetd.conf >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        else
            echo "[/etc/xinetd.conf의 권한]"   >> $OUTPUT_FILE2 2>&1
            echo "-/etc/xinetd.conf 파일이 존재하지 않음" >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi



        if [ -f /etc/inetd.conf ]; then
            if perm_600 '/etc/inetd.conf'
            then
                echo "[/etc/inetd.conf의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/inetd.conf >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/inetd.conf의 권한(권장권한:600)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/inetd.conf >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/inetd.conf" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/inetd.conf)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/inetd.conf >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        else
            echo "[/etc/inetd.conf의 권한]"   >> $OUTPUT_FILE2 2>&1
            echo "-/etc/inetd.conf 파일이 존재하지 않음" >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi



        if [ -f /etc/syslog.conf ]; then
            if perm_644 '/etc/syslog.conf'
            then
                echo "[/etc/syslog.conf의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/syslog.conf >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/syslog.conf의 권한(권장권한:644)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/syslog.conf >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/syslog.conf" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/syslog.conf)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/syslog.conf >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        else
            echo "[/etc/syslog.conf의 권한]"   >> $OUTPUT_FILE2 2>&1
            echo "-/etc/syslog.conf 파일이 존재하지 않음" >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi


        if [ -f /etc/rsyslog.conf ]; then
            if perm_644 '/etc/rsyslog.conf'
            then
                echo "[/etc/rsyslog.conf의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/rsyslog.conf >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/rsyslog.conf의 권한(권장권한:644)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/rsyslog.conf >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/rsyslog.conf" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/rsyslog.conf)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/rsyslog.conf >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        else
            echo "[/etc/rsyslog.conf의 권한]"   >> $OUTPUT_FILE2 2>&1
            echo "-/etc/rsyslog.conf 파일이 존재하지 않음" >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi


        if [ -f /etc/services ]; then
            if perm_644 '/etc/services'
            then
                echo "[/etc/services의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/services >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/services의 권한(권장권한:644)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/services >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/services" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/services)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/services >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        else
            echo "[/etc/services의 권한]"   >> $OUTPUT_FILE2 2>&1
            echo "-/etc/services 파일이 존재하지 않음" >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi



        if [ -f /etc/hosts.lpd ]; then
            if perm_640 '/etc/hosts.lpd'
            then
                echo "[/etc/hosts.lpd의 권한]"   >> $OUTPUT_FILE2 2>&1
                ls -al /etc/hosts.lpd >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                echo "[/etc/hosts.lpd의 권한(권장권한:640)]"   >> $OUTPUT_FILE3 2>&1
                ls -al /etc/hosts.lpd >> $OUTPUT_FILE3 2>&1
                if [ -L "/etc/hosts.lpd" ]; then
                    echo "" >> $OUTPUT_FILE3 2>&1
                    echo "[링크파일 원본 권한 확인(#ls -alL /etc/hosts.lpd)]" >> $OUTPUT_FILE3 2>&1
                    ls -alL /etc/hosts.lpd >> "$OUTPUT_FILE3" 2>&1
                fi
            fi
        else
            echo "[/etc/hosts.lpd의 권한]"   >> $OUTPUT_FILE2 2>&1
            echo "-/etc/hosts.lpd 파일이 존재하지 않음" >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi


        if [ -d /tcb/files/auth ]; then
            #echo "[/tcb/files/auth/[a-z]/* 디렉토리내의 파일들의 권한]"   >> $OUTPUT_FILE2 2>&1
            for FILE in $(find /tcb/files/auth/ -path "/tcb/files/auth/[a-zA-Z]/*" -type f 2>/dev/null); do
                if perm_644 $FILE
                then
                    ls -al $FILE >> $OUTPUT_FILE2 2>&1
                else
                    echo "[ $FILE 의 권한(권장권한:644) ]"   >> $OUTPUT_FILE3 2>&1
                    ls -al $FILE >> $OUTPUT_FILE3 2>&1
                    if [ -L $FILE ]; then
                        echo "[링크파일 원본 권한 확인( #ls -alL $FILE )]" >> $OUTPUT_FILE3 2>&1
                        ls -alL $FILE >> "$OUTPUT_FILE3" 2>&1
                    fi
                fi
            done
        fi


        if [ -f "$OUTPUT_FILE3" ]; then 
            echo "[권한 취약 파일]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            #SRV-084 양취판단
            SECURITY_STATUS="N"
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[그 외 파일 권한]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2   >> $OUTPUT_FILE 2>&1
        else
            cat $OUTPUT_FILE2   >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_INSUFFICIENT_PERMISSIONS_FOR_SYSTEM_CRITICAL_FILES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-084" 2>&1
}

#U-13,SRV-091
CHECK_SUID_SGID_STICKY_BIT_SETTINGS_IN_FILES() {
echo "CHECK_SUID_SGID_STICKY_BIT_SETTINGS_IN_FILES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-13_SRV-091.hangrp"
    #suid,sgid 설정 없음
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-13_SRV-091_REF01.hangrp"
    #suid,sgid 취약
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-13_SRV-091_REF02.hangrp"
    #설명
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-13_SRV-091_REF03.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        # root(/) 에서 find 명령어 또는 주요SUID 파일 검색
        if [ -z "$FIND_SUIDSGID" ]; then            
                #FILES="/sbin/dump /sbin/restore /sbin/unix_chkpwd /usr/bin/at /usr/bin/lpq /usr/bin/lpq-lpd /usr/bin/lpr /usr/bin/lpr-lpd /usr/bin/lprm /usr/bin/lprm-lpd /usr/bin/newgrp /usr/sbin/lpc /usr/sbin/lpc-lpd /usr/sbin/traceroute"
                FILES="/usr/sbin/traceroute /usr/sbin/sysdef /usr/sbin/swremove /usr/sbin/swreg /usr/sbin/swpackage /usr/sbin/swmodify /usr/sbin/swinstall /usr/sbin/swconfig /usr/sbin/swacl /usr/sbin/sparcv9/sysdef /usr/sbin/sparcv9/prtconf /usr/sbin/sparcv7/sysdef /usr/sbin/sparcv7/prtconf /usr/sbin/prtconf /usr/sbin/mount /usr/sbin/lpsched /usr/sbin/lpmove /usr/sbin/lpc-lpd /usr/sbin/lpc /usr/sbin/lchangelv /usr/sbin/landiag /usr/sbin/lanadmin /usr/sbin/arp /usr/platform/sun4u/sbin/prtdiag /usr/openwin/bin/xlock /usr/openwin/bin/kcms_configure /usr/openwin/bin/kcms_calibrate /usr/openwin/bin/ff.core /usr/lib/lp/bin/netpr /usr/lib/fs/ufs/ufsrestore /usr/lib/fs/ufs/ufsdump /usr/dt/bin/sdtcm_convert /usr/dt/bin/dtterm /usr/dt/bin/dtprintinfo /usr/dt/bin/dtappgather /usr/dt/bin/dtaction /usr/contrib/bin/traceroute /usr/bin/yppasswd /usr/bin/X11/xlock /usr/bin/rdist /usr/bin/nispasswd /usr/bin/newgrp /usr/bin/mediainit /usr/bin/lpset /usr/bin/lprm-lpd /usr/bin/lprm /usr/bin/lpr-lpd /usr/bin/lpr /usr/bin/lpq-lpd /usr/bin/lpq /usr/bin/lpalt /usr/bin/atrm /usr/bin/atq /usr/bin/at /usr/bin/admintool /sbin/unix_chkpwd /sbin/restore /sbin/dump /opt/video/lbin/camServer /opt/perf/bin/gpm /opt/perf/bin/glance"
                #참고 작성 및 SUOD,SGID 권한 확인
                for check_file in $FILES
                do
                    if [ -f "$check_file" ]
                        then
                        if [ -g $check_file ] || [ -u $check_file ]
                            then
                                ls -alL $check_file >> $OUTPUT_FILE3 2>&1
                                case $check_file in
                                "/usr/sbin/traceroute")
                                    echo "/usr/sbin/traceroute : 네트워크 경로 추적 및 진단 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/sysdef")
                                    echo "/usr/sbin/sysdef : 시스템 하드웨어 및 소프트웨어 정보 표시 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/swremove")
                                    echo "/usr/sbin/swremove : HP-UX 시스템용 소프트웨어 제거 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/swreg")
                                    echo "/usr/sbin/swreg : HP-UX 소프트웨어 등록 및 관리 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/swpackage")
                                    echo "/usr/sbin/swpackage : HP-UX 소프트웨어 패키징 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/swmodify")
                                    echo "/usr/sbin/swmodify : HP-UX 소프트웨어 패키지 수정 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/swinstall")
                                    echo "/usr/sbin/swinstall : HP-UX 소프트웨어 설치 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/swconfig")
                                    echo "/usr/sbin/swconfig : HP-UX 소프트웨어 구성 관리 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/swacl")
                                    echo "/usr/sbin/swacl : HP-UX 소프트웨어 접근 제어 관리 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/sparcv9/sysdef")
                                    echo "/usr/sbin/sparcv9/sysdef : SPARC V9 시스템 정의 정보 출력 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/sparcv9/prtconf")
                                    echo "/usr/sbin/sparcv9/prtconf : SPARC V9 하드웨어 구성 정보 출력 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/sparcv7/sysdef")
                                    echo "/usr/sbin/sparcv7/sysdef : SPARC V7 시스템 정의 정보 출력 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/sparcv7/prtconf")
                                    echo "/usr/sbin/sparcv7/prtconf : SPARC V7 하드웨어 구성 정보 출력 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/prtconf")
                                    echo "/usr/sbin/prtconf : 시스템 하드웨어 및 소프트웨어 구성 정보 출력 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/mount")
                                    echo "/usr/sbin/mount : 파일 시스템 마운트 관리 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/lpsched")
                                    echo "/usr/sbin/lpsched : 프린트 스케줄러 관리 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/lpmove")
                                    echo "/usr/sbin/lpmove : 프린터 큐 작업 이동 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/lpc-lpd")
                                    echo "/usr/sbin/lpc-lpd : LPD 프린트 시스템 관리 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/lpc")
                                    echo "/usr/sbin/lpc : 프린트 시스템 관리 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/lchangelv")
                                    echo "/usr/sbin/lchangelv : 논리 볼륨 관리 및 수정 도구 (HP-UX)" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/landiag")
                                    echo "/usr/sbin/landiag : LAN 진단 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/lanadmin")
                                    echo "/usr/sbin/lanadmin : 로컬 영역 네트워크 관리 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/sbin/arp")
                                    echo "/usr/sbin/arp : ARP 테이블 관리 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/platform/sun4u/sbin/prtdiag")
                                    echo "/usr/platform/sun4u/sbin/prtdiag : Sun4U 플랫폼 진단 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/openwin/bin/xlock")
                                    echo "/usr/openwin/bin/xlock : X 윈도우 시스템 화면 잠금 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/openwin/bin/kcms_configure")
                                    echo "/usr/openwin/bin/kcms_configure : OpenWindows의 KCMS 프로파일 구성 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/openwin/bin/kcms_calibrate")
                                    echo "/usr/openwin/bin/kcms_calibrate : OpenWindows의 KCMS 캘리브레이션 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/openwin/bin/ff.core")
                                    echo "/usr/openwin/bin/ff.core : OpenWindows 폰트 파일 관리 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/lib/lp/bin/netpr")
                                    echo "/usr/lib/lp/bin/netpr : 네트워크 프린터 관리 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/lib/fs/ufs/ufsrestore")
                                    echo "/usr/lib/fs/ufs/ufsrestore : UFS 백업 파일 복원 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/lib/fs/ufs/ufsdump")
                                    echo "/usr/lib/fs/ufs/ufsdump : UNIX 파일 시스템 백업 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/dt/bin/sdtcm_convert")
                                    echo "/usr/dt/bin/sdtcm_convert : CDE 달력 파일 변환 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/dt/bin/dtterm")
                                    echo "/usr/dt/bin/dtterm : CDE 터미널 에뮬레이터" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/dt/bin/dtprintinfo")
                                    echo "/usr/dt/bin/dtprintinfo : CDE 프린터 설정 정보 조회 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/dt/bin/dtappgather")
                                    echo "/usr/dt/bin/dtappgather : CDE 애플리케이션 정보 수집 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/dt/bin/dtaction")
                                    echo "/usr/dt/bin/dtaction : CDE 사용자 정의 액션 실행 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/contrib/bin/traceroute")
                                    echo "/usr/contrib/bin/traceroute : 네트워크 경로 추적 및 진단 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/yppasswd")
                                    echo "/usr/bin/yppasswd : 구버전 NIS 비밀번호 변경 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/X11/xlock")
                                    echo "/usr/bin/X11/xlock : X11 윈도우 시스템 화면 잠금 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/rdist")
                                    echo "/usr/bin/rdist : 원격 파일 및 디렉토리 복사 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/nispasswd")
                                    echo "/usr/bin/nispasswd : NIS 비밀번호 변경 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/newgrp")
                                    echo "/usr/bin/newgrp : 사용자 그룹 ID 변경 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/mediainit")
                                    echo "/usr/bin/mediainit : 미디어 초기화 및 관리 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/lpset")
                                    echo "/usr/bin/lpset : 프린터 및 프린터 클래스 설정 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/lprm-lpd")
                                    echo "/usr/bin/lprm-lpd : LPD 프린트 작업 제거 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/lprm")
                                    echo "/usr/bin/lprm : 프린트 큐 작업 제거 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/lpr-lpd")
                                    echo "/usr/bin/lpr-lpd : LPD 프린트 시스템 파일 프린팅 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/lpr")
                                    echo "/usr/bin/lpr : 프린터 큐에 파일 추가 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/lpq-lpd")
                                    echo "/usr/bin/lpq-lpd : LPD 프린트 대기열 조회 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/lpq")
                                    echo "/usr/bin/lpq : 프린트 대기열 조회 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/lpalt")
                                    echo "/usr/bin/lpalt : 프린터 설정 변경 유틸리티" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/atrm")
                                    echo "/usr/bin/atrm : 'at' 작업 제거 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/atq")
                                    echo "/usr/bin/atq : 예약된 'at' 작업 조회 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/at")
                                    echo "/usr/bin/at : 시간 기반 작업 스케줄러" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/usr/bin/admintool")
                                    echo "/usr/bin/admintool : 시스템 관리 및 설정 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/sbin/unix_chkpwd")
                                    echo "/sbin/unix_chkpwd : 유닉스 패스워드 검증 도구" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/sbin/restore")
                                    echo "/sbin/restore : 백업 데이터 복원 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/sbin/dump")
                                    echo "/sbin/dump : 파일 시스템 덤프 및 백업 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/opt/video/lbin/camServer")
                                    echo "/opt/video/lbin/camServer : 비디오 카메라 서버 관리 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/opt/perf/bin/gpm")
                                    echo "/opt/perf/bin/gpm : HP-UX 그래픽 성능 모니터" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                "/opt/perf/bin/glance")
                                    echo "/opt/perf/bin/glance : HP-UX 성능 모니터링 프로그램" >> $OUTPUT_FILE4 2>&1
                                    ;;
                                esac
                            else
                                ls -alL $check_file >> $OUTPUT_FILE2 2>&1
                        fi
                    fi
                done

                if [ -f "$OUTPUT_FILE3" ] 
                    then
                    echo "[일반적으로 불필요하게 설정된 SUID,SGID 파일]"   >> $OUTPUT_FILE 2>&1
                    cat $OUTPUT_FILE3 >> $CHECK_SUID_SGID_FILE 2>&1
                    COUNT=0
                    COUNT=`cat $OUTPUT_FILE3 | wc -l`

                    if [ $COUNT -gt 100 ]
                    then
                        echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                        echo "(엑셀 셀 입력 제한으로 인하여 스크립트 결과값 참조./SECURITY_INSPECTION_TEMP/$(hostname)+${HOST_IP}+SUID_SGID_FILE.hangrp)" >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE3 | head -n 100 >> $OUTPUT_FILE 2>&1
                    else
                        echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
                    fi
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[SUID,SGID 설정된 파일 설명]"   >> $OUTPUT_FILE 2>&1
                    cat $OUTPUT_FILE4 >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    if [ -f "$OUTPUT_FILE2" ] 
                        then
                        echo "[그 외 파일]"   >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE2   >> $OUTPUT_FILE 2>&1
                    fi
                else
                    echo "[SUID,SGID 파일 확인]"   >> $OUTPUT_FILE 2>&1
                    if [ -f "$OUTPUT_FILE2" ] 
                        then
                        cat $OUTPUT_FILE2   >> $OUTPUT_FILE 2>&1
                        else
                        #U-13,SRV-091 양취판단
                        SECURITY_STATUS="Y"
                        echo "-불필요하게 설정된 SUID,SGID 파일 존재하지 않음"   >> $CHECK_SUID_SGID_FILE 2>&1
                        echo "-불필요하게 설정된 SUID,SGID 파일 존재하지 않음"   >> $OUTPUT_FILE 2>&1
                    fi
                fi
            
            # root(/) 로 검색했을 경우
        else
                #######
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[SUID,SGID 설정된 파일(find / -user root -type f \( -perm -04000 -o -perm -02000 \) -xdev -exec ls -alLd {} \;)]"   >> $OUTPUT_FILE 2>&1
                echo "$FIND_SUIDSGID" >> $OUTPUT_FILE3 2>&1
                if [ -f "$OUTPUT_FILE3" ] 
                then
                    cat $OUTPUT_FILE3 >> $CHECK_SUID_SGID_FILE 2>&1
                    COUNT=0
                    COUNT=`cat $OUTPUT_FILE3 | wc -l`

                    if [ $COUNT -gt 100 ]
                    then
                        echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                        echo "(엑셀 셀 입력 제한으로 인하여 스크립트 결과값 참조 ./SECURITY_INSPECTION_TEMP/$(hostname)+${HOST_IP}+SUID_SGID_FILE.hangrp)" >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE3 | head -n 100 >> $OUTPUT_FILE 2>&1
                    else
                        echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
                    fi
                else
                    #U-13,SRV-091 양취판단
                    SECURITY_STATUS="Y"
                    echo "-SUID,SGID 설정된 파일 존재하지 않음"   >> $OUTPUT_FILE 2>&1
                    echo "-SUID,SGID 설정된 파일 존재하지 않음"   >> $CHECK_SUID_SGID_FILE 2>&1
                fi
                ########
            

            
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHECK_SUID_SGID_STICKY_BIT_SETTINGS_IN_FILES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-13" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-091" 2>&1
}

#U-14
SET_OWNERSHIP_AND_PERMISSIONS_FOR_USER_SYSTEM_STARTUP_AND_ENVIRONMENT_FILES() {
echo "SET_OWNERSHIP_AND_PERMISSIONS_FOR_USER_SYSTEM_STARTUP_AND_ENVIRONMENT_FILES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-14.hangrp"
    #gloabal profile 파일
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-14_REF01.hangrp"
    #계정 profile 파일
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-14_REF02.hangrp"
    #취약한 계정 profile 파일
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-14_REF03.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        GLOBAL_PROFILE_FILES="/etc/profile /etc/.profile /etc/login.defs /etc/bashrc /etc/csh.cshrc /etc/csh.login /etc/csh.logout /etc/zshrc /etc/zprofile /etc/zlogin /etc/zlogout /etc/zshenv /etc/ksh.kshrc /etc/ksh.login /etc/ksh.logout /etc/kshrc /etc/default/login"


        #gloabal profile 권한 확인
        for GLOBAL_PROFILE_FILE in $GLOBAL_PROFILE_FILES; do
            if [ -f "$GLOBAL_PROFILE_FILE" ]; then
                if perm_775 $GLOBAL_PROFILE_FILE
                then
                    echo "(global) `ls -al $GLOBAL_PROFILE_FILE`" >> $OUTPUT_FILE2 2>&1
                else
                    echo "(global) `ls -al $GLOBAL_PROFILE_FILE`" >> $OUTPUT_FILE4 2>&1
                fi
            fi
        done

        #계정 profile 파일
        # ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$6}' /etc/passwd)

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$6
            }
        ' /etc/passwd)

        for ACCOUNT_INFO in $ACCOUNTS; do

            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            HOME_DIR=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)

            PROFILE_FILES=".bashrc .bash_profile .bash_login .profile .bash_logout .kshrc .zshrc .zprofile .zshenv .zlogin .zlogout .cshrc .tcshrc .login .logout .cshdirs .shrc .ashrc .dashrc .yashrc .fishrc .environment .env"

            for PROFILE_FILE in $PROFILE_FILES; do
                FULL_PATH="$HOME_DIR/$PROFILE_FILE"
                if [ -f "$FULL_PATH" ]; then
                    if perm_775 $FULL_PATH
                    then
                        echo "($USERNAME) `ls -al $FULL_PATH`" >> $OUTPUT_FILE3 2>&1
                    else
                        echo "($USERNAME) `ls -al $FULL_PATH`" >> $OUTPUT_FILE4 2>&1
                    fi
                fi
            done
        done
        
        if [ -f "$OUTPUT_FILE4" ] ; then
            echo "[profile 취약한 권한 파일]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE4 >> $OUTPUT_FILE 2>&1
            #U-14 양취판단
            SECURITY_STATUS="N"
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[profile 양호한 파일]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2  >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE3" ] ; then
                cat $OUTPUT_FILE3   >> $OUTPUT_FILE 2>&1
            fi
        else
            #U-14 양취판단
            SECURITY_STATUS="Y"
            echo "[profile 파일 권한 확인]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2  >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE3" ] ; then
                cat $OUTPUT_FILE3   >> $OUTPUT_FILE 2>&1
            else
                echo "-계정 profile 파일 존재하지 않음"   >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_OWNERSHIP_AND_PERMISSIONS_FOR_USER_SYSTEM_STARTUP_AND_ENVIRONMENT_FILES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-14" 2>&1
}

#SRV-096
INSUFFICIENT_OWNERSHIP_OR_PERMISSIONS_FOR_USER_ENVIRONMENT_FILES() {
echo "INSUFFICIENT_OWNERSHIP_OR_PERMISSIONS_FOR_USER_ENVIRONMENT_FILES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-096.hangrp"
    #gloabal profile 파일
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-096_REF01.hangrp"
    #계정 profile 파일
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-096_REF02.hangrp"
    #취약한 계정 profile 파일
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-096_REF03.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        # GLOBAL_PROFILE_FILES="/etc/profile /etc/.profile /etc/login.defs /etc/bashrc /etc/csh.cshrc /etc/csh.login /etc/csh.logout /etc/zshrc /etc/zprofile /etc/zlogin /etc/zlogout /etc/zshenv /etc/ksh.kshrc /etc/ksh.login /etc/ksh.logout /etc/kshrc /etc/default/login"

        # #글로벌 권한 양호체크
        # function SRV-096_global_good_perm {
        # local STAT X
        # STAT=$(stat -c '%a' "$1")
        # X=${STAT:2:1}
        # ((X & 2)) && return 1
        # return 0
        # }

        # #gloabal profile 권한 확인
        # for GLOBAL_PROFILE_FILE in $GLOBAL_PROFILE_FILES; do
        #     if [ -f "$GLOBAL_PROFILE_FILE" ]; then
        #         if SRV-096_global_good_perm $GLOBAL_PROFILE_FILE 
        #             then
        #                 echo "(global) `ls -al $GLOBAL_PROFILE_FILE`" >> $OUTPUT_FILE2 2>&1
        #             else
        #                 echo "(global) `ls -al $GLOBAL_PROFILE_FILE`" >> $OUTPUT_FILE4 2>&1
        #         fi
        #     fi
        # done

        #계정 profile 파일
        # ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$6}' /etc/passwd)

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$6
            }
        ' /etc/passwd)

        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            HOME_DIR=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)

            PROFILE_FILES=".bashrc .bash_profile .bash_login .profile .bash_logout .kshrc .zshrc .zprofile .zshenv .zlogin .zlogout .cshrc .tcshrc .login .logout .cshdirs .shrc .ashrc .dashrc .yashrc .fishrc .environment .env"

            for PROFILE_FILE in $PROFILE_FILES; do
                FULL_PATH="$HOME_DIR/$PROFILE_FILE"
                if [ -f "$FULL_PATH" ]; then
                    if perm_770 $FULL_PATH
                    then
                        echo "($USERNAME) `ls -al $FULL_PATH`" >> $OUTPUT_FILE3 2>&1
                    else
                        echo "($USERNAME) `ls -al $FULL_PATH`" >> $OUTPUT_FILE4 2>&1
                    fi
                fi
            done
        done
        echo "" >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE4" ] ; then
            echo "[profile 취약한 권한 파일]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE4 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #SRV-096 양취판단
            SECURITY_STATUS="N"
            if [ -f "$OUTPUT_FILE3" ] ; then
                echo "[profile 양호한 파일]"   >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE3   >> $OUTPUT_FILE 2>&1
            fi
        else
            #SRV-096 양취판단
            SECURITY_STATUS="Y"
            echo "[profile 파일 권한 확인]"   >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE3" ] ; then
                cat $OUTPUT_FILE3   >> $OUTPUT_FILE 2>&1
            else
                echo "-계정 profile 파일 존재하지 않음"   >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "INSUFFICIENT_OWNERSHIP_OR_PERMISSIONS_FOR_USER_ENVIRONMENT_FILES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-096" 2>&1
}

#U-15,SRV-093
CHECK__WORLD_WRITABLE_FILES() {
echo "CHECK__WORLD_WRITABLE_FILES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-15_SRV-093.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-15_SRV-093_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        HOMEDIRS=`egrep -v 'nologin|false' /etc/passwd | awk -F":" '{print $6}'`
        HOMEDIRS=$(echo "$HOMEDIRS" | sort | uniq | egrep -v "^/$|^/proc$|^/sys$|^/dev$|^/run$|^/tmp$|^/var$|^/etc$|^/tmp$|^/bin$|^/sbin$")
        for HOMEDIR_TMP in $HOMEDIRS; do
            if [ -d $HOMEDIR_TMP ]; then
                HOMEDIR="$HOMEDIR $HOMEDIR_TMP"
            fi
        done
        find $HOMEDIR -perm -2 -type f -exec ls -alLd {} \; 2>/dev/null >> $OUTPUT_FILE2 2>&1

        echo "[world writable 파일(# find \$HOMEDIR -perm -2 -type f -exec ls -alLd {} \;)]"   >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE2" ] 
        then
            cat $OUTPUT_FILE2 >> $CHECK_WORLD_WRITABLE_FILES 2>&1
            COUNT=0
            COUNT=`cat $OUTPUT_FILE2 | wc -l`

            if [ $COUNT -gt 100 ]
            then
                echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                echo "(엑셀 셀 입력 제한으로 인하여 스크립트 결과값 참조./SECURITY_INSPECTION_TEMP/$(hostname)+${HOST_IP}+WORLD_WRITABLE_FILES.hangrp )" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 | head -n 100 >> $OUTPUT_FILE 2>&1
            else
                echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            fi


        else
            #U-15,SRV-093 양취판단
            SECURITY_STATUS="Y"
            echo "-world writable 파일 존재하지 않음"   >> $OUTPUT_FILE 2>&1
            echo "-world writable 파일 존재하지 않음"   >> $CHECK_WORLD_WRITABLE_FILES 2>&1
        fi


        # 이전에 사용하던 방식
        #
        # SEARCH_DIR="/"
        # MAX_COUNT=100
        # count=0
        # find $SEARCH_DIR \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /tmp -o -path /var/tmp \) -prune -o -type f -perm -0002 ! -perm -1000 -ls | while IFS= read -r line; do
        #     ((count++))
        #     echo "Checking file #${count}..."   
        #     echo $line >> $OUTPUT_FILE2
        #     if (( count >= MAX_COUNT )); then
        #         break
        #     fi
        # done
        # echo "" >> $OUTPUT_FILE 2>&1
        # if [ -f "$OUTPUT_FILE2" ] 
        # then
        #     echo "[world writable 파일]"   >> $OUTPUT_FILE 2>&1
        #     cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        # else
        #     echo "-world writable 파일 존재하지 않음"   >> $OUTPUT_FILE 2>&1
        # fi
    fi

    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHECK__WORLD_WRITABLE_FILES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-15" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-093" 2>&1
}

#U-16,SRV-144
CHECK_NONEXISTENT_DEVICE_FILES_IN_DEV() {
echo "CHECK_NONEXISTENT_DEVICE_FILES_IN_DEV_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-16_SRV-144.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-16_SRV-144_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-16_SRV-144_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        find /dev -type f -exec ls -l {} \; >> $OUTPUT_FILE2 2>&1
        if [ -s $OUTPUT_FILE2 ] 
            then
            egrep -v 'mqueue|shm|udev|termination-log' $OUTPUT_FILE2 >> $OUTPUT_FILE3 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        if [ -s $OUTPUT_FILE3 ] 
            then
            echo "[#find /dev -type f -exec ls -l {} \;]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            else
            echo "[#find /dev -type f -exec ls -l {} \;]"   >> $OUTPUT_FILE 2>&1
            echo "-존재하지 않는 디바이스 파일 존재하지 않음"   >> $OUTPUT_FILE 2>&1
            #U-16,SRV-144 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHECK_NONEXISTENT_DEVICE_FILES_IN_DEV_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-16" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-144" 2>&1
}

#U-17,SRV-025
PROHIBIT_USE_OF_HOME__rhosts_AND_hosts_equiv() {
echo "PROHIBIT_USE_OF_HOME__rhosts_AND_hosts_equiv_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-17_SRV-025.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-17_SRV-025_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/hosts.equiv"

        RCOMMAND_CHECK=0
        if command -v netstat >/dev/null; then
            if [ "$(netstat -an | awk '/[.:](512|513|514) /' | wc -l)" -ge 1 ] ; then
                RCOMMAND_CHECK=1
                # "rsh, rlogin, rexec 서비스가 활성화 되어 있습니다."
            fi
        else
            if command -v ss >/dev/null; then
                if [ "$(ss -an | awk '/[.:](512|513|514) /' | wc -l)" -ge 1 ] ; then
                    RCOMMAND_CHECK=1
                    # "rsh, rlogin, rexec 서비스가 활성화 되어 있습니다."
                fi
            fi
        fi

        echo "[‘r’command 서비스 여부]" >> $OUTPUT_FILE 2>&1
        if [ $RCOMMAND_CHECK -eq 1 ] ; then
            if command -v netstat >/dev/null; then
                if [ "$(netstat -an | awk '/[.:](512|513|514) /' | wc -l)" -ge 1 ] ; then
                    netstat -an | awk '/[.:](512|513|514) /' >> $OUTPUT_FILE 2>&1
                fi
            else
                if command -v ss >/dev/null; then
                    if [ "$(ss -an | awk '/[.:](512|513|514) /' | wc -l)" -ge 1 ] ; then
                        ss -an | awk '/[.:](512|513|514) /' >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi
            echo "" >> $OUTPUT_FILE 2>&1
        else
            echo "‘r’command 서비스가 비활성화 되어 있습니다.(512,513,514 포트 활성화 되어 있지 않음)" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-17,SRV-025 양취판단
            SECURITY_STATUS="Y"
        fi



        if [ $RCOMMAND_CHECK -eq 1 ] ; then
            echo "[hosts.equiv 파일]" >> $OUTPUT_FILE 2>&1
            if [ -f /etc/hosts.equiv ]; then
                if [ "$(cat /etc/hosts.equiv | grep -v '^#' | grep -v '^$' | wc -l)" -eq 0 ]; then
                    ls -al /etc/hosts.equiv >> $OUTPUT_FILE 2>&1
                    echo "-hosts.equiv 파일이 존재하지만 설정값이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                else
                    ls -al /etc/hosts.equiv >> $OUTPUT_FILE 2>&1
                    cat /etc/hosts.equiv >> $OUTPUT_FILE 2>&1
                fi
            else
                echo "-hosts.equiv 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1

            
            # ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$6}' /etc/passwd)

            ACCOUNTS=$(awk -F':' '
                $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                    print $1":"$6
                }
            ' /etc/passwd)

            for ACCOUNT_INFO in $ACCOUNTS; do
                USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
                HOME_DIR=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
                FULL_PATH="$HOME_DIR/.rhosts"
                if [ -f "$FULL_PATH" ]; then
                    echo "[$USERNAME 의 .rhosts 파일]" >> $OUTPUT_FILE 2>&1
                    echo "($USERNAME) `ls -al $FULL_PATH`" >> $OUTPUT_FILE 2>&1
                    cat $FULL_PATH >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            done
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PROHIBIT_USE_OF_HOME__rhosts_AND_hosts_equiv_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-17" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-025" 2>&1
}
#U-18,SRV-027
RESTRICT_ACCESS_BY_IP_AND_PORT() {
echo "RESTRICT_ACCESS_BY_IP_AND_PORT_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-18_SRV-027.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-18_SRV-027_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/hosts.allow" "/etc/hosts.deny" "/etc/ipf/ipf.conf" "/var/adm/inetd.sec"

        #solaris
        if command -v inetadm >/dev/null 2>&1; then
            echo "[inetadm -p | egrep -i \"tcp_wrappers\"]" >> $OUTPUT_FILE 2>&1
            inetadm -p | egrep -i "tcp_wrappers" >> $OUTPUT_FILE 2>&1
            echo "(true: 실행, false : 정지)" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi


        #HP-UX
        if [ -f /var/adm/inetd.sec ]; then
            echo "[#cat /var/adm/inetd.sec]" >> $OUTPUT_FILE 2>&1
            cat /var/adm/inetd.sec | grep -v "#" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi

        #sshd_config 파일에서 AllowUsers, DenyUsers, AllowGroups, DenyGroups 설정 확인
        if [ -f "$SSH_CONFIG_PATH" ]; then
            if [ "$(egrep -i 'AllowUsers|DenyUsers|AllowGroups|DenyGroups' $SSH_CONFIG_PATH | grep -v '#' | wc -l)" -ne 0 ]; then
                echo "[#cat $SSH_CONFIG_PATH | egrep -i \"AllowUsers|DenyUsers|AllowGroups|DenyGroups\"]" >> $OUTPUT_FILE 2>&1
                cat $SSH_CONFIG_PATH | egrep -i "AllowUsers|DenyUsers|AllowGroups|DenyGroups" | grep -v "#" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        fi

        echo "[hosts.allow 파일]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/hosts.allow ] ; then
            if [ "$(cat /etc/hosts.allow | grep -v '^#' | grep -v '^$' | wc -l)" -eq 0 ]; then
                echo "[#ls -al /etc/hosts.allow]" >> $OUTPUT_FILE 2>&1
                ls -al /etc/hosts.allow >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[#cat /etc/hosts.allow]" >> $OUTPUT_FILE 2>&1
                echo "-hosts.allow 파일이 존재하지만 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                echo "[#ls -al /etc/hosts.allow]" >> $OUTPUT_FILE 2>&1
                ls -al /etc/hosts.allow >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[#cat /etc/hosts.allow]" >> $OUTPUT_FILE 2>&1
                cat /etc/hosts.allow >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-hosts.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[hosts.deny 파일]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/hosts.deny ] ; then
            if [ "$(cat /etc/hosts.deny | grep -v '^#' | grep -v '^$' | wc -l)" -eq 0 ]; then
                echo "[#ls -al /etc/hosts.deny]" >> $OUTPUT_FILE 2>&1
                ls -al /etc/hosts.deny >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[#cat /etc/hosts.deny]" >> $OUTPUT_FILE 2>&1
                echo "-hosts.deny 파일이 존재하지만 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                echo "[#ls -al /etc/hosts.deny]" >> $OUTPUT_FILE 2>&1
                ls -al /etc/hosts.deny >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[#cat /etc/hosts.deny]" >> $OUTPUT_FILE 2>&1
                cat /etc/hosts.deny >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-hosts.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi

        if command -v firewall-cmd >/dev/null 2>&1; then
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[firewall-cmd --state]" >> $OUTPUT_FILE 2>&1
            firewall-cmd --state >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[firewall-cmd --list-all]" >> $OUTPUT_FILE 2>&1
            firewall-cmd --list-all >> $OUTPUT_FILE 2>&1
        fi

        echo "" >> $OUTPUT_FILE 2>&1
        if command -v iptables >/dev/null 2>&1; then
            echo "[iptables -S | grep \"-P\" 기본 정책 확인]" >> $OUTPUT_FILE 2>&1
            iptables -S | grep "\-P" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[iptables -L 확인]" >> $OUTPUT_FILE 2>&1
            iptables -L >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi
        # solaris
        if [ -f /etc/ipf/ipf.conf ] ; then
            echo "[# cat /etc/ipf/ipf.conf]" >> $OUTPUT_FILE 2>&1
            cat /etc/ipf/ipf.conf >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_ACCESS_BY_IP_AND_PORT_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-18" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-027" 2>&1
}

#U-56,SRV-122
MANAGE_UMASK_CONFIGURATION() {
echo "MANAGE_UMASK_CONFIGURATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-56_SRV-122.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-56_SRV-122_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/bashrc" "/etc/csh.cshrc" "/etc/csh.login" "/etc/csh.logout" "/etc/zshrc" "/etc/zprofile" "/etc/zlogin" "/etc/zlogout" "/etc/zshenv" "/etc/ksh.kshrc" "/etc/ksh.login" "/etc/ksh.logout" "/etc/kshrc" "/etc/default/security"
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)        

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)

        GLOBAL_FILES="/etc/profile /etc/.profile /etc/bashrc /etc/csh.cshrc /etc/csh.login /etc/csh.logout /etc/zshrc /etc/zprofile /etc/zlogin /etc/zlogout /etc/zshenv /etc/ksh.kshrc /etc/ksh.login /etc/ksh.logout /etc/kshrc /etc/login.defs /etc/default/login /etc/security/user /etc/default/security"

        for GLOBAL_FILE in $GLOBAL_FILES; do
            if [ -f "$GLOBAL_FILE" ]; then
                if [ "$GLOBAL_FILE" = "/etc/login.defs" ] || [ "$GLOBAL_FILE" = "/etc/security/user" ] || [ "$GLOBAL_FILE" = "/etc/default/login" ] || [ "$GLOBAL_FILE" = "/etc/default/security" ]; then
                    #linux
                    if [ "$GLOBAL_FILE" = "/etc/login.defs" ]; then
                        if [ "$(cat "$GLOBAL_FILE" | grep -v "#" | grep -i "umask" | wc -l)" -ne 0 ]; then
                            echo "[#$GLOBAL_FILE]" >> $OUTPUT_FILE2 2>&1
                            cat $GLOBAL_FILE | grep -v "#" | grep -i "umask" >> $OUTPUT_FILE2 2>&1
                            echo "" >> $OUTPUT_FILE2 2>&1
                        fi
                    fi

                    # AIX
                    if [ "$GLOBAL_FILE" = "/etc/security/user" ]; then
                        echo "[#$GLOBAL_FILE]" >> $OUTPUT_FILE2 2>&1
                        files="/etc/security/user"
                        keyword1="default:"
                        keyword2="umask"
                        end_marker=":"
                        section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
                        if [ $SED_TMP -gt 0 ]; then
                            umaskDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
                        else
                            umaskDEFAULT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
                        fi
                        if [ -n "$umaskDEFAULT_INFO" ]; then
                            echo "[$keyword1] : $umaskDEFAULT_INFO" >> $OUTPUT_FILE2 2>&1
                        fi

                        echo "" >> $OUTPUT_FILE2 2>&1

                        if command -v lsuser >/dev/null 2>&1; then
                            echo "[계정별 UMASK 확인 (#lsuser -a umask <계정명>)]" >> $OUTPUT_FILE2 2>&1
                        else
                            echo "[계정별 UMASK 확인 (#cat /etc/security/user)]" >> $OUTPUT_FILE2 2>&1
                        fi

                        for ACCOUNT_INFO in $ACCOUNTS; do
                            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
                            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)



                            if command -v lsuser >/dev/null 2>&1; then
                                if [ $SED_TMP -gt 0 ]; then
                                    umaskACCOUNT_INFO=$(lsuser -a umask $USERNAME | sed -e 's/	//g')
                                else
                                    umaskACCOUNT_INFO=$(lsuser -a umask $USERNAME | sed -e 's/\s//g')
                                fi
                                if [ -n "$umaskACCOUNT_INFO" ]; then
                                    echo "[$USERNAME] : $umaskACCOUNT_INFO" >> $OUTPUT_FILE2 2>&1
                                fi
                            else
                                keyword1="$USERNAME:"
                                section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
                                if [ $SED_TMP -gt 0 ]; then
                                    umaskACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
                                else
                                    umaskACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
                                fi
                                if [ -n "$umaskACCOUNT_INFO" ]; then
                                    echo "[$keyword1] : $umaskACCOUNT_INFO" >> $OUTPUT_FILE2 2>&1
                                fi
                            fi
                        done
                    fi
                
                    #solaris
                    if [ "$GLOBAL_FILE" = "/etc/default/login" ]; then
                        if [ "$(cat "$GLOBAL_FILE" | grep -v "#" | grep -i "UMASK" | wc -l)" -ne 0 ]; then
                            echo "[#$GLOBAL_FILE]" >> $OUTPUT_FILE2 2>&1
                            cat $GLOBAL_FILE | grep -v "#" | grep -i "UMASK" >> $OUTPUT_FILE2 2>&1
                            echo "" >> $OUTPUT_FILE2 2>&1
                        fi
                    fi

                    #HP-UX
                    if [ "$GLOBAL_FILE" = "/etc/default/security" ]; then
                        if [ "$(cat "$GLOBAL_FILE" | grep -v "#" | grep -i "UMASK" | wc -l)" -ne 0 ]; then
                            echo "[#$GLOBAL_FILE]" >> $OUTPUT_FILE2 2>&1
                            cat $GLOBAL_FILE | grep -v "#" | grep -i "UMASK" >> $OUTPUT_FILE2 2>&1
                            echo "" >> $OUTPUT_FILE2 2>&1
                        fi
                    fi

                else
                    # profile 과 bashrc
                    if [ "$(cat "$GLOBAL_FILE" | grep -v "#" | grep -i "umask" | wc -l)" -ne 0 ]; then
                        echo "[#$GLOBAL_FILE]" >> $OUTPUT_FILE2 2>&1
                        if [ $GREP_AB_TMP -gt 0 ]; then                   
                            cat $GLOBAL_FILE | grep -v "#" | grep -A 1 -B 1 -i "umask"   >> $OUTPUT_FILE2 2>&1
                            echo "" >> $OUTPUT_FILE2 2>&1
                        else
                            #1:patterns, 2:file, 3:lines_before, 4:lines_after
                            grep_AB_shell "umask" "$GLOBAL_FILE" "1" "1"   >> $OUTPUT_FILE2 2>&1
                            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
                            echo "" >> $OUTPUT_FILE2 2>&1
                        fi
                    fi
                fi




            fi
        done

        # ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$6}' /etc/passwd)

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$6
            }
        ' /etc/passwd)

        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            HOME_DIR=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            PROFILE_FILES=".bashrc .bash_profile .bash_login .profile .bash_logout .kshrc .zshrc .zprofile .zshenv .zlogin .zlogout .cshrc .tcshrc .login .logout .cshdirs .shrc .ashrc .dashrc .yashrc .fishrc .config/fish/config.fish .environment .env"

            for PROFILE_FILE in $PROFILE_FILES; do
                FULL_PATH="$HOME_DIR/$PROFILE_FILE"
                if [ -f "$FULL_PATH" ]; then
                    if [ "$(cat "$FULL_PATH" | grep -v "#" | grep -v "^$" | grep -i "umask" | wc -l)" -ne 0 ]; then
                        echo "[#$USERNAME 의 $PROFILE_FILE]" >> $OUTPUT_FILE2 2>&1
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            cat $FULL_PATH | grep -v "#" | grep -v "^$" | grep -A 1 -B 1 -i "umask"  >> $OUTPUT_FILE2 2>&1
                        else
                            #1:patterns, 2:file, 3:lines_before, 4:lines_after
                            grep_AB_shell "umask" "$FULL_PATH" "1" "1" >> $OUTPUT_FILE2 2>&1
                            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
                        fi
                        echo "" >> $OUTPUT_FILE2 2>&1
                    fi
                fi
            done
        done

        echo "" >> $OUTPUT_FILE 2>&1
        if command -v umask >/dev/null 2>&1; then
            echo "[umask 명령어 확인(# umask)]"   >> $OUTPUT_FILE 2>&1
            umask >> $OUTPUT_FILE 2>&1
        fi

        echo "" >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE2" ]; then 
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        fi
    fi
    echo "" >> $OUTPUT_FILE 2>&1
    echo "MANAGE_UMASK_CONFIGURATION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-56" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-122" 2>&1
}

#U-57,SRV-092
SET_HOME_DIRECTORY_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_HOME_DIRECTORY_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-57_SRV-092.hangrp"
    #other w 권한
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-57_SRV-092_REF01.hangrp"
    #소유자 다른경우
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-57_SRV-092_REF02.hangrp"
    #홈디렉터리가 존재하지 않음
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-57_SRV-092_REF03.hangrp"
    #양호한 홈디렉터리
    OUTPUT_FILE5="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-57_SRV-092_REF04.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        #쉘접속 가능한 계정
        # ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$6}' /etc/passwd)

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$6
            }
        ' /etc/passwd)

        #홈 디렉터리의 소유자와 실 사용자가 일치하지 않거나, 홈디렉터리의 others 쓰기 권한 존재 확인
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            HOME_DIR=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)

            if [ -d $HOME_DIR ]; then

                DIR_DETAILS=$(ls -alLd $HOME_DIR)
                DIR_OWNER=$(echo $DIR_DETAILS | awk '{print $3}')


                if ! perm_775 $HOME_DIR ; then
                    echo "(${USERNAME}계정), ${DIR_DETAILS}: other 에 쓰기권한 존재" >> $OUTPUT_FILE2
                fi

                if [ $DIR_OWNER != $USERNAME ] && [ $DIR_OWNER != "root" ]; then
                    echo "(${USERNAME}계정), ${DIR_DETAILS}: 소유자 미일치" >> $OUTPUT_FILE3
                fi
                
                if perm_775 $HOME_DIR ; then
                    if [ "$DIR_OWNER" = "$USERNAME" ] || [ "$DIR_OWNER" = "root" ]; then
                    echo "(${USERNAME}계정), ${DIR_DETAILS}" >> $OUTPUT_FILE5
                    fi
                fi

                if [ "$HOME_DIR" = "/" ]; then
                    echo "(${USERNAME}계정), ${HOME_DIR}: 홈디렉터리 미존재" >> $OUTPUT_FILE4
                fi
                
            else
                echo "(${USERNAME}계정), ${HOME_DIR}: 홈디렉터리 미존재" >> $OUTPUT_FILE4
            fi
        done

        echo "" >> $OUTPUT_FILE4 2>&1
        if [ -f "$OUTPUT_FILE2" ] ; then
            echo "[홈디렉터리 other 쓰기권한 존재]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-57,SRV-092 양취판단
            SECURITY_STATUS="N"
        fi

        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[홈디렉터리 소유자 미일치]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-57,SRV-092 양취판단
            SECURITY_STATUS="N"
        fi

        if [ -f "$OUTPUT_FILE5" ] ; then
            echo "[양호한 홈디렉터리]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE5 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_HOME_DIRECTORY_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-57" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-092" 2>&1
}

#U-58
MANAGE_EXISTENCE_OF_HOME_DIRECTORY_SPECIFIED() {
echo "MANAGE_EXISTENCE_OF_HOME_DIRECTORY_SPECIFIED_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-58.hangrp"
    #홈디렉터리 미존재
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-58_REF01.hangrp"
    #전체 홈디렉터리
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-58_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        #/etc/passwd 에서 home 디렉터리가 존재하지 않는 계정 확인
        # ACCOUNTS=$(awk -F':' '{ if ($2 != "!" && ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh")) print $1":"$6}' /etc/passwd)

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$6
            }
        ' /etc/passwd)

        #home 디렉터리가 / 또는 존재하지 않는 경우
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            HOME_DIR=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            if [ "$HOME_DIR" = "/" ] || [ ! -d $HOME_DIR ]; then
                echo "(${USERNAME}계정), ${HOME_DIR}: 홈디렉터리 미존재" >> $OUTPUT_FILE2
                cat /etc/passwd | egrep "^$USERNAME:" >> $OUTPUT_FILE2
            fi
                echo "(${USERNAME}계정), ${HOME_DIR}" >> $OUTPUT_FILE3
        done
        echo "" >> $OUTPUT_FILE 2>&1

        if [ -f "$OUTPUT_FILE2" ] ; then
            echo "[홈디렉터리 미존재]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-58 양취판단
            SECURITY_STATUS="N"
        fi
        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[전체 홈디렉터리]"   >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1    
    echo "MANAGE_EXISTENCE_OF_HOME_DIRECTORY_SPECIFIED_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-58" 2>&1
}

#U-59,SRV-166
SEARCH_AND_REMOVE_HIDDEN_FILES_AND_DIRECTORIES() {
echo "SEARCH_AND_REMOVE_HIDDEN_FILES_AND_DIRECTORIES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-59_SRV-166.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-59_SRV-166_REF01.hangrp"
    # 전체 숨겨진 파일과 디렉터리 리스트
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-59_SRV-166_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        if [ -z "$FIND_HIIDEN_FILE" ]; then

            
            # # 이미 알려진 숨겨진 파일과 디렉터리 리스트
            # KNOWN_HIDDEN=(
            #     # Bash 쉘 환경 설정 파일
            #     ".bashrc"
            #     # 로그인 시 실행되는 Bash 쉘 스크립트
            #     ".bash_profile"
            #     # 로그아웃 시 실행되는 Bash 쉘 스크립트
            #     ".bash_logout"
            #     # 사용자의 Bash 명령어 히스토리
            #     ".bash_history"
            #     # 사용자의 쉘 환경 설정 파일, 로그인 시 실행
            #     ".profile"
            #     # SSH 키와 구성 파일을 저장하는 디렉터리
            #     ".ssh"
            #     # Vim 에디터의 사용자 히스토리 및 세션 정보
            #     ".viminfo"
            #     # Korn Shell(Ksh) 환경 설정 파일
            #     ".kshrc"
            #     # 사용자의 캐시 데이터 저장 디렉터리
            #     ".cache"
            #     # 사용자의 로컬 애플리케이션 데이터 디렉터리
            #     ".local"
            #     # Mozilla 애플리케이션(예: Firefox) 관련 데이터 디렉터리
            #     ".mozilla"
            #     # 사용자별 애플리케이션 구성 데이터 디렉터리
            #     ".config"
            #     # X 윈도 시스템 관련 잠금 파일
            #     ".X1-lock"
            #     # Enlightenment 사운드 데몬 관련 파일
            #     ".esd-1000"
            #     # Oracle 관련 구성 파일
            #     ".oracle"
            #     # GNU Privacy Guard 암호화 키 저장소
            #     ".gnupg"
            #     # X 윈도우 시스템 권한 인증 파일
            #     ".Xauthority"
            #     # Nano 편집기의 백업 및 상태 파일
            #     ".nano"
            #     # Java 관련 사용자 설정 및 데이터
            #     ".java"
            #     # YUM 패키지 관리자의 사용자 데이터 및 설정
            #     ".yum"
            #     # less 프로그램의 검색 기록
            #     ".lesshst"
            #     # Git 버전 관리 시스템의 사용자 구성 파일
            #     ".gitconfig"
            #     # tmux 터미널 멀티플렉서 구성 파일
            #     ".tmux.conf"
            #     # GnuPG 암호화 키 관련 파일
            #     ".gpg"
            #     # 공개 키 인프라(PKI) 데이터 저장 디렉터리
            #     ".pki"
            #     # GNOME 데스크톱 환경 설정
            #     ".gnome"
            #     # D-Bus 메시지 버스 시스템 파일
            #     ".dbus"
            #     # X 윈도 세션 오류 로그
            #     ".xsession-errors"
            #     # MySQL 명령어 히스토리
            #     ".mysql_history"
            #     # Python 인터프리터 명령어 히스토리
            #     ".python_history"
            #     # Node Package Manager(NPM) 관련 파일
            #     ".npm"
            #     # Yarn 패키지 관리자 캐시 디렉터리
            #     ".yarn"
            #     # RubyGems 패키지 관리자의 사용자 설정
            #     ".gem"
            #     # RubyGems 의존성 관리 파일
            #     ".bundle"
            #     # Rust 패키지 관리자 Cargo의 사용자 데이터
            #     ".cargo"
            #     # Rust 툴체인 관리자 Rustup의 사용자 데이터
            #     ".rustup"
            #     # Go 언어 관련 사용자 설정 및 데이터
            #     ".go"
            #     # Visual Studio Code 사용자 설정 및 데이터
            #     ".vscode"
            #     # 생성된 미리보기 썸네일 파일
            #     ".thumbnails"
            #     # GConf 시스템의 사용자 설정 데이터
            #     ".gconf"
            #     # Adobe 제품 관련 사용자 설정 및 데이터
            #     ".adobe"
            #     # Macromedia(현재 Adobe) 제품 사용자 데이터
            #     ".macromedia"
            #     # Dropbox 동기화 정보
            #     ".dropbox"
            #     # Wget의 HTTPS 세션 트래킹 파일
            #     ".wget-hsts"
            #     # Subversion 버전 관리 시스템의 사용자 설정
            #     ".subversion"
            #     # Ansible 자동화 플랫폼 사용자 데이터
            #     ".ansible"
            #     # KDE 데스크톱 환경 사용자 설정
            #     ".kde"
            #     # CUPS 프린팅 시스템 사용자 설정 및 데이터
            #     ".cups"
            #     # Compiz 윈도우 관리자 구성 파일
            #     ".compiz"
            #     # GNOME 2 데스크톱 환경 설정
            #     ".gnome2"
            #     # GVFS(GNOME Virtual File System) 설정
            #     ".gvfs"
            #     # IPython 인터랙티브 쉘의 사용자 설정 및 데이터
            #     ".ipython"
            #     # Jupyter 노트북 관련 사용자 설정 및 데이터
            #     ".jupyter"
            #     # Matplotlib 그래프 라이브러리의 사용자 설정 및 데이터
            #     ".matplotlib"
            #     # Oracle Java Runtime Environment 사용 데이터
            #     ".oracle_jre_usage"
            #     # Redis 명령어 라인 인터페이스 히스토리
            #     ".rediscli_history"
            #     # Scala REPL(Read-Eval-Print Loop) 히스토리
            #     ".scala_history"
            #     # SQLite 데이터베이스 쉘 히스토리 파일
            #     ".sqlite_history"
            #     # Node.js V8 엔진 플래그 저장 파일
            #     ".v8flags"
            #     # node-gyp 구성 파일, Node.js 애드온 빌드 도구
            #     ".node-gyp"
            #     # Node.js REPL(Read-Eval-Print Loop) 히스토리
            #     ".node_repl_history"
            #     # Python 'eggs' 패키지 캐시
            #     ".python-eggs"
            #     # pylint 구성 및 데이터 디렉터리
            #     ".pylint.d"
            #     # Qutebrowser 웹 브라우저 구성 및 데이터
            #     ".qutebrowser"
            #     # 사용자가 선택한 기본 편집기 정보
            #     ".selected_editor"
            #     # 관리자 권한으로 sudo를 사용한 표시
            #     ".sudo_as_admin_successful"
            #     # Vim 스왑 파일, 편집 중인 파일의 임시 복사본
            #     ".swp"
            #     # Docker 구성 및 데이터 디렉터리
            #     ".docker"
            #     # Synaptic 패키지 관리자 구성 및 데이터
            #     ".synaptic"
            #     # systemd 사용자 세션 데이터
            #     ".systemd"
            #     # Vim 편집기 구성 파일
            #     ".vim"
            #     # 이전 X 윈도 세션 오류 로그
            #     ".xsession-errors.old"
            #     # Zsh 컴플리션 덤프 파일
            #     ".zcompdump"
            #     # Zenmap 네트워크 스캐너 사용자 설정 및 데이터
            #     ".zenmap"
            #     # Zsh 쉘 명령어 히스토리
            #     ".zsh_history"
            #     # Zsh 쉘 구성 파일
            #     ".zshrc"
            #     # Git 버전 관리 시스템 메타데이터
            #     ".git"
            #     # Mercurial(Hg) 버전 관리 시스템 메타데이터
            #     ".hg"
            #     # Subversion(SVN) 버전 관리 시스템 메타데이터
            #     ".svn"
            #     # HFS 및 HFS+ 볼륨의 파일 시스템 데이터
            #     ".vol"
            #     # AppleDouble 포맷 파일, 리소스 포크 및 파일 메타데이터
            #     ".AppleDouble"
            #     # AppleDB 파일, macOS 시스템의 다양한 데이터베이스 파일
            #     ".AppleDB"
            #     # 네트워크 휴지통 폴더, 네트워크 볼륨의 삭제된 파일 저장
            #     ".NetworkTrashFolder"
            #     # AppleShare 파일 서버 정보
            #     ".apdisk"
            #     # Time Machine 백업에서 제외되는 항목을 표시
            #     ".com.apple.timemachine.donotpresent"
            #     # 볼륨 아이콘 파일, macOS에서 사용되는 아이콘
            #     ".VolumeIcon.icns"
            #     # iPhoto 앨범 설정 및 환경 설정
            #     ".iPhotoAlbumPrefs"
            #     # udev 장치 관리자 관련 데이터
            #     "/dev/.udev"
            #     # 초기 RAM 파일 시스템(initramfs) 관련 데이터
            #     "/dev/.initramfs"
            #     # 마운트 포인트 정보 및 관리
            #     "/dev/.mount"
            #     # systemd 장치 관리 및 초기화 데이터
            #     "/dev/.systemd"
            #     # 부팅 관련 HMAC 보안 검증 데이터
            #     "/boot/.vmlinuz.hmac"
            #     # 리눅스 부트로더의 커널 이미지 파일
            #     "/boot/.vmlinuz"
            #     # GNU 빌드 ID 노트, 실행 파일의 고유 식별자
            #     ".note.gnu.build-id"
            #     # 초기화 텍스트, 실행 파일의 시작 부분
            #     ".init.text"
            #     # 텍스트 세그먼트, 실행 파일의 코드 부분
            #     ".text"
            #     # 읽기 전용 데이터 세그먼트
            #     ".rodata"
            #     # 문자열 테이블, 실행 파일의 문자열 데이터
            #     ".strtab"
            #     # 심볼 테이블, 실행 파일의 심볼 정보
            #     ".symtab"
            #     # GNU 링크 작업 관련 파일
            #     ".gnu.linkonce.this_module"
            #     # C Shell(csh) 환경 설정 파일
            #     ".cshrc"
            #     # Tcsh 쉘 환경 설정 파일
            #     ".tcshrc"
            #     # X 윈도 시스템 인증 파일(임시)
            #     ".xauth1nf0Qv"
            #     # X 윈도 시스템 인증 파일(임시)
            #     ".xauthfmwPxy"
            #     # X 윈도 시스템 인증 권한 파일
            #     ".ICEauthority"
            #     # 프로그램 실행 상태 관련 메타데이터
            #     ".meta.isrunning"
            #     # 변경사항 관련 메타데이터
            #     ".changed"
            #     # esd(Enlightenment Sound Daemon) 인증 파일
            #     ".esd_auth"
            #     # 데이터베이스 환경 잠금 파일
            #     ".dbenv.lock"
            #     # RPM 패키지 관리자 잠금 파일
            #     ".rpm.lock"
            #     # 유닉스 소켓 관련 테스트 파일
            #     ".Test-unix"
            #     # X11 유닉스 소켓 관련 파일
            #     ".X11-unix"
            #     # XIM 유닉스 소켓 관련 파일
            #     ".XIM-unix"
            #     # 글꼴 관련 유닉스 소켓 파일
            #     ".font-unix"
            #     # 종속성 관련 텍스트 파일
            #     ".dependencies.txt"
            #     # ICE 유닉스 소켓 관련 파일
            #     ".ICE-unix"
            #     # X 윈도 시스템 잠금 파일
            #     ".X0-lock"
            #     # esd 사운드 데몬 관련 파일
            #     ".esd-0"
            #     # 고유 식별자(UUID) 관련 파일
            #     ".uuid"
            #     # 패스워드 잠금 관련 파일
            #     ".pwd.lock"
            #     # 일시적인 플레이스홀더 파일
            #     ".placeholder"
            #     # 메타데이터 관련 파일
            #     ".metadata"
            #     # 부모 잠금 관련 파일
            #     ".parentlock"
            #     # 메타데이터 버전 2 관련 파일
            #     ".metadata-v2"
            #     # PulseAudio 사운드 서버 관련 파일
            #     ".pulse"
            #     # 시퀀스 넘버
            #     ".SEQ"
            #     # 시스템 또는 애플리케이션 업데이트 관련 파일
            #     ".updated"
            #     # Docker 컨테이너 환경을 나타내는 파일
            #     ".dockerenv"
            #     # colorls 커스텀 색상 설정 파일
            #     ".colorlsCZ1"
            #     #Kerberos V5 인증 시스템과 관련된 매뉴얼 페이지
            #     ".k5login"
            #     #Kerberos V5 인증 시스템과 관련된 매뉴얼 페이지
            #     ".k5identity.5.gz"
            #     #OpenSSL 또는 기타 암호화 라이브러리에서 사용하는 난수 생성기 시드 값 저장
            #     ".rnd"
            #     # 잠금 파일로 특정 프로세스나 서비스가 리소스를 사용 중임을 나타냄
            #     ".etab.lock"
            #     # 잠금 파일로 특정 프로세스나 서비스가 리소스를 사용 중임을 나타냄
            #     ".xtab.lock"
            # )


            #이미 알려진 파일시스템
            KNOWN_HIDDEN=".bashrc .bash_profile .bash_logout .bash_history .profile .ssh .viminfo .kshrc .cache .local .mozilla .config .X1-lock .esd-1000 .oracle .gnupg .Xauthority .nano .java .yum .lesshst .gitconfig .tmux.conf .gpg .pki .gnome .dbus .xsession-errors .mysql_history .python_history .npm .yarn .gem .bundle .cargo .rustup .go .vscode .thumbnails .gconf .adobe .macromedia .dropbox .wget-hsts .subversion .ansible .kde .cups .compiz .gnome2 .gvfs .ipython .jupyter .matplotlib .oracle_jre_usage .rediscli_history .scala_history .sqlite_history .v8flags .node-gyp .node_repl_history .python-eggs .pylint.d .qutebrowser .selected_editor .sudo_as_admin_successful .swp .docker .synaptic .systemd .vim .xsession-errors.old .zcompdump .zenmap .zsh_history .zshrc .git .hg .svn .vol .AppleDouble .AppleDB .NetworkTrashFolder .apdisk .com.apple.timemachine.donotpresent .VolumeIcon.icns .iPhotoAlbumPrefs .udev .initramfs .mount .systemd .vmlinuz.hmac .vmlinuz .note.gnu.build-id .init.text .text .rodata .strtab .symtab .gnu.linkonce.this_module .cshrc .tcshrc .xauth1nf0Qv .xauthfmwPxy .ICEauthority .meta.isrunning .changed .esd_auth .dbenv.lock .rpm.lock .Test-unix .X11-unix .XIM-unix .font-unix .dependencies.txt .ICE-unix .X0-lock .esd-0 .uuid .pwd.lock .placeholder .metadata .parentlock .metadata-v2 .pulse .SEQ .updated .dockerenv .colorlsCZ1 .k5login .k5identity.5.gz .rnd .etab.lock .xtab.lock .bash_history .sh_history .vi_history snapshot"
            # KNOWN_HIDDEN 문자열을 grep 패턴으로 변환
            EXCLUDE_PATTERN=$(echo "$KNOWN_HIDDEN" | sed 's/ /\\|/g')

            # 시스템 안정성 데이터 보호를 위하여 해당 디렉터리 제외
            # "/sys/ /proc/ /var/cache/ /dev/ /run/ /etc/ /bin/ /sbin/ /usr/bin/ /usr/sbin/ /lib/ /usr/lib/ /usr/src/ /lib64/ /usr/lib64/ /u01/ /tmp/ /var/lib/docker/"
            ALL_HIDDEN=$(find / -xdev \
                \( -path '/sys' -o -path '/proc' -o -path '/var/cache' -o -path '/dev' -o \
                -path '/run' -o -path '/etc' -o -path '/bin' -o -path '/sbin' -o \
                -path '/usr/bin' -o -path '/usr/sbin' -o -path '/lib' -o \
                -path '/usr/lib' -o -path '/usr/src' -o -path '/lib64' -o \
                -path '/usr/lib64' -o -path '/u01' -o -path '/tmp' -o \
                -path '/var/lib/docker' \) -prune -o \
                \( -name '.*' -type f -o -name '.*' -type d \) -print 2>/dev/null | egrep -v "/$|$EXCLUDE_PATTERN")


            echo "$ALL_HIDDEN" >> $OUTPUT_FILE3 2>&1

            for HIDDEN_FILE in $ALL_HIDDEN; do
                if [ -e "$HIDDEN_FILE" ] || [ -d "$HIDDEN_FILE" ]; then
                    if ! perm_744 "$HIDDEN_FILE" ; then
                        echo "$(ls -alLd "$HIDDEN_FILE" 2>/dev/null)" >> $OUTPUT_FILE2
                    fi
                fi
            done


            #/bin/bash 에서 사용하던 방식
            # while IFS= read -r HIDDEN; do
            #     ((count++))
            #     echo -ne "Checking hidden file or directory #${count}: $HIDDEN...\r"

            #     PERM=$(stat -c '%A' "$HIDDEN" 2>/dev/null)
            #     if [ $PERM =~ ..[w|x] || $PERM =~ .[w|x]. || $PERM =~ [w|x].. ]; then
            #         BASENAME=$(basename "$HIDDEN")
            #         if ! printf '%s\n' "${KNOWN_HIDDEN[@]}" | grep -q -P "^$BASENAME$"; then
            #             SKIP=false
            #             for IGNORE_DIR in "${IGNORE_DIRS[@]}"; do
            #                 if [ "$HIDDEN" == "$IGNORE_DIR"* ]; then
            #                     SKIP=true
            #                     break
            #                 fi
            #             done
            #             if $SKIP; then continue; fi

            #             UNKNOWN_HIDDEN+=("$HIDDEN")
            #             echo "$(ls -alLd "$HIDDEN" 2>/dev/null)" >> $OUTPUT_FILE2

            #             if [ ${#UNKNOWN_HIDDEN[@]} -ge 30000 ]; then
            #                 echo -e "\nMore than 30,000 unknown hidden files or directories found. Stopping the function."
            #                 break
            #             fi
            #         fi
            #     fi
            # done < <(echo "$ALL_HIDDEN")

            echo "" >> $OUTPUT_FILE 2>&1
            echo "[숨겨진 파일 및 디렉터리]" >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE2" ] 
                then
                    cat $OUTPUT_FILE2 >> $CHECK_HIIDEN_FILE 2>&1
                    COUNT=0
                    COUNT=`cat $OUTPUT_FILE2 | wc -l`

                    if [ $COUNT -gt 100 ]
                    then
                        echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                        echo "(엑셀 셀 입력 제한으로 인하여 스크립트 결과값 참조 ./SECURITY_INSPECTION_TEMP/$(hostname)+${HOST_IP}+HIIDEN_FILE.hangrp)" >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE2 | head -n 100 >> $OUTPUT_FILE 2>&1
                    else
                        echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
                    fi
                else
                echo "-불필요한 숨겨진 파일 및 디렉터리 존재하지 않음"   >> $OUTPUT_FILE 2>&1
                echo "-불필요한 숨겨진 파일 및 디렉터리 존재하지 않음"   >> $CHECK_HIIDEN_FILE 2>&1
                #U-59,SRV-166 양취판단
                SECURITY_STATUS="Y"
            fi
        
        else
                ##########
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[숨겨진 파일 및 디렉터리(find / \( -type f -o -type d \) -name ".*" -exec ls -alLd {} \;)]"   >> $OUTPUT_FILE 2>&1
                echo "$FIND_HIIDEN_FILE" >> $OUTPUT_FILE2 2>&1
                if [ -f "$OUTPUT_FILE2" ] 
                then
                    cat $OUTPUT_FILE2 >> $CHECK_HIIDEN_FILE 2>&1
                    COUNT=0
                    COUNT=`cat $OUTPUT_FILE2 | wc -l`

                    if [ $COUNT -gt 100 ]
                    then
                        echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                        echo "(엑셀 셀 입력 제한으로 인하여 스크립트 결과값 참조 ./SECURITY_INSPECTION_TEMP/$(hostname)+${HOST_IP}+HIIDEN_FILE.hangrp)" >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE2 | head -n 100 >> $OUTPUT_FILE 2>&1
                    else
                        echo "-$COUNT 개 발견되었습니다.-" >> $OUTPUT_FILE 2>&1
                        cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
                    fi
                else
                    echo "-불필요한 숨겨진 파일 및 디렉터리 존재하지 않음"   >> $OUTPUT_FILE 2>&1
                    echo "-불필요한 숨겨진 파일 및 디렉터리 존재하지 않음"   >> $CHECK_HIIDEN_FILE 2>&1
                    #U-59,SRV-166 양취판단
                    SECURITY_STATUS="Y"
                fi
                ##########
        fi


    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SEARCH_AND_REMOVE_HIDDEN_FILES_AND_DIRECTORIES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-59" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-166" 2>&1
}

#U-19
DISABLE_FINGER_SERVICE() {
echo "DISABLE_FINGER_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-19.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-19_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-19_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/inetd.conf"

        echo "[/etc/inetd.conf 파일 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -f /etc/inetd.conf ] ; then
            echo "[#cat /etc/inetd.conf | grep -i \"finger\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/inetd.conf | grep -i "finger" | grep -v "^#" | grep -v "^$" | wc -l)" -eq 0 ]; then
                echo "-finger 서비스가 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
            else
                if [ $GREP_AB_TMP -gt 0 ]; then
                    cat /etc/inetd.conf | grep -A 3 -B 5 -i "finger" | grep -v "^#" | grep -v "^$" >> $OUTPUT_FILE2 2>&1
                else
                    #1:patterns, 2:file, 3:lines_before, 4:lines_after
                    grep_AB_shell "finger" "/etc/inetd.conf" "5" "3" >> $OUTPUT_FILE2 2>&1
                    cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
                fi
            fi
        else
            echo "-/etc/inetd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi
        echo "" >> $OUTPUT_FILE2 2>&1
        echo "[/etc/xinetd.d 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -d /etc/xinetd.d ] && [ "$(ls -A /etc/xinetd.d)" ]; then
            echo "[#ls -alL /etc/xinetd.d]" >> $OUTPUT_FILE3 2>&1
            ls -alL /etc/xinetd.d >> $OUTPUT_FILE3 2>&1
            echo "" >> $OUTPUT_FILE3 2>&1
            echo "[#cat /etc/xinetd.d/* | grep -i \"finger\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/xinetd.d/* | grep -i "finger" | grep -v "^#" | grep -v "^$" | wc -l)" -eq 0 ]; then
                echo "-finger 서비스가 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
            else
                files=$(find "/etc/xinetd.d" -type f 2>/dev/null)
                keyword1="finger"
                keyword2="disable"
                end_marker="}"
                for file in $files; do
                    for keyword in $keyword1; do
                        section=$(sed -n "/$keyword/,/$end_marker/p" "$file" )
                        if [ "$(echo "$section" | grep -i "$keyword2" | wc -l)" -gt 0 ]; then
                            echo "file:$file, keyword:$keyword" >> $OUTPUT_FILE2 2>&1
                            if [ $SED_TMP -gt 0 ]; then
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/	//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            else
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/\s//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            fi
                        fi
                    done
                done
            fi
        else
            echo "-/etc/xinetd.d 디렉터리가 존재하지 않거나 디렉터리에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi

        #solaris
        SOLARIS_CHECK_SERVICES "finger" "finger"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
        fi
        # if command -v inetadm >/dev/null 2>&1; then
        #     if [ "$(inetadm | egrep -i "finger" | wc -l)" -gt 0 ]; then
        #         echo "[inetadm 명령어 확인 (inetadm | egrep -i \"finger\")]" >> $OUTPUT_FILE2 2>&1
        #         inetadm | egrep -i "finger" >> $OUTPUT_FILE2 2>&1
        #     else
        #         if command -v svcs >/dev/null 2>&1; then
        #             echo "[inetadm 명령어 확인 (inetadm | egrep -i \"finger\")]" >> $OUTPUT_FILE2 2>&1
        #             echo "-finger 서비스가 존재하지 않음." >> $OUTPUT_FILE2 2>&1
        #             echo "" >> $OUTPUT_FILE2 2>&1
        #             echo "[svcs 명령어 확인 (svcs -a | egrep -i \"finger\")]" >> $OUTPUT_FILE2 2>&1
        #             if [ "$(svcs -a | egrep -i "finger" | wc -l)" -gt 0 ]; then
        #                 svcs -a | egrep -i "finger" >> $OUTPUT_FILE2 2>&1
        #             else
        #                 echo "-finger 서비스가 존재하지 않음." >> $OUTPUT_FILE2 2>&1
        #             fi
        #         fi
        #     fi
        # else
        #     if command -v svcs >/dev/null 2>&1; then
        #         echo "[svcs 명령어 확인 (svcs -a | egrep -i \"finger\")]" >> $OUTPUT_FILE2 2>&1
        #         if [ "$(svcs -a | egrep -i "finger" | wc -l)" -gt 0 ]; then
        #             svcs -a | egrep -i "finger" >> $OUTPUT_FILE2 2>&1
        #         else
        #             echo "-finger 서비스가 존재하지 않음." >> $OUTPUT_FILE2 2>&1
        #         fi
        #     fi
        # fi
        echo "" >> $OUTPUT_FILE2 2>&1

        cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE3" ] ; then
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_FINGER_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-19" 2>&1
}

#U-21
DISABLE_R_SERVICES() {
echo "DISABLE_R_SERVICES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-21.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-21_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-21_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        RCOMMAND_CHECK=0
        if command -v netstat >/dev/null; then
            if [ "$(netstat -an | awk '/[.:](512|513|514) /' | wc -l)" -ge 1 ] ; then
                RCOMMAND_CHECK=1
                # "rsh, rlogin, rexec 서비스가 활성화 되어 있습니다."
            fi
        else
            if command -v ss >/dev/null; then
                if [ "$(ss -an | awk '/[.:](512|513|514) /' | wc -l)" -ge 1 ] ; then
                    RCOMMAND_CHECK=1
                    # "rsh, rlogin, rexec 서비스가 활성화 되어 있습니다."
                fi
            fi
        fi
        echo "" >> $OUTPUT_FILE2 2>&1

        echo "[‘r’command 서비스 여부]" >> $OUTPUT_FILE2 2>&1
        if [ $RCOMMAND_CHECK -eq 1 ] ; then
            if command -v netstat >/dev/null; then
                if [ "$(netstat -an | awk '/[.:](512|513|514) /' | wc -l)" -ge 1 ] ; then
                    netstat -an | awk '/[.:](512|513|514) /' >> $OUTPUT_FILE2 2>&1
                fi
            else
                if command -v ss >/dev/null; then
                    if [ "$(ss -an | awk '/[.:](512|513|514) /' | wc -l)" -ge 1 ] ; then
                        ss -an | awk '/[.:](512|513|514) /' >> $OUTPUT_FILE2 2>&1
                    fi
                fi
            fi
            echo "" >> $OUTPUT_FILE2 2>&1
        else
            echo "-‘r’command 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi

        echo "[/etc/inetd.conf 파일 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -f /etc/inetd.conf ] ; then
            echo "[#cat /etc/inetd.conf | egrep -i \"shell|login|exec|rsh|rlogin|rexec\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/inetd.conf | egrep -i "shell|login|exec|rsh|rlogin|rexec" | grep -v "^#" | egrep -v "grep|klogin|kshell|kexec" | wc -l)" -eq 0 ]; then
                echo "-‘r’command 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
            else
                if [ $GREP_AB_TMP -gt 0 ]; then
                    cat /etc/inetd.conf | egrep -A 3 -B 5 -i "shell|login|exec|rsh|rlogin|rexec" | grep -v "^#" | egrep -v "grep|klogin|kshell|kexec" >> $OUTPUT_FILE2 2>&1
                else
                    grep_AB_shell "shell|login|exec|rsh|rlogin|rexec" "/etc/inetd.conf" "5" "3" >> $OUTPUT_FILE2 2>&1
                    cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
                fi
            fi
        else
            echo "-/etc/inetd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi
        echo "" >> $OUTPUT_FILE2 2>&1

        echo "[/etc/xinetd.d 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -d /etc/xinetd.d ] && [ "$(ls -A /etc/xinetd.d)" ]; then
            echo "[#ls -alL /etc/xinetd.d]" >> $OUTPUT_FILE3 2>&1
            ls -alL /etc/xinetd.d >> $OUTPUT_FILE3 2>&1
            echo "" >> $OUTPUT_FILE3 2>&1
            echo "[#cat /etc/xinetd.d/* | egrep -i \"shell|login|exec|rsh|rlogin|rexec\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/xinetd.d/* | egrep -i "shell|login|exec|rsh|rlogin|rexec" | grep -v "^#" | egrep -v "grep|klogin|kshell|kexec" | wc -l)" -eq 0 ]; then
                echo "-‘r’command 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
            else
                files=$(find "/etc/xinetd.d" -type f 2>/dev/null)
                keyword1="shell login exec rsh rlogin rexec"
                keyword2="disable"
                end_marker="}"
                for file in $files; do
                    for keyword in $keyword1; do
                        section=$(sed -n "/$keyword/,/$end_marker/p" "$file" )
                        if [ "$(echo "$section" | grep -i "$keyword2" | egrep -v "grep|klogin|kshell|kexec" | wc -l)" -gt 0 ]; then
                            echo "file:$file, keyword:$keyword" >> $OUTPUT_FILE2 2>&1
                            if [ $SED_TMP -gt 0 ]; then
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/	//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            else
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/\s//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            fi
                        fi
                    done
                done
            fi
        else
            echo "-/etc/xinetd.d 디렉터리가 존재하지 않거나 디렉터리에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi


        #solaris
        SOLARIS_CHECK_SERVICES "shell|rlogin|rexec" "shell, rlogin, rexec"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
        fi
        
        # if command -v inetadm >/dev/null 2>&1; then
        #     if [ "$(inetadm | egrep -i "shell|rlogin|rexec" | wc -l)" -gt 0 ]; then
        #         echo "[inetadm 명령어 확인 (inetadm | egrep -i \"shell|rlogin|rexec\")]" >> $OUTPUT_FILE2 2>&1
        #         inetadm | egrep -i "shell|rlogin|rexec" >> $OUTPUT_FILE2 2>&1
        #     else
        #         if command -v svcs >/dev/null 2>&1; then
        #             echo "[inetadm 명령어 확인 (inetadm | egrep -i \"shell|rlogin|rexec\")]" >> $OUTPUT_FILE2 2>&1
        #             echo "-shell, rlogin, rexec 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #             echo "" >> $OUTPUT_FILE2 2>&1
        #             echo "[svcs 명령어 확인 (svcs -a | egrep -i \"shell|rlogin|rexec\")]" >> $OUTPUT_FILE2 2>&1
        #             if [ "$(svcs -a | egrep -i "shell|rlogin|rexec" | wc -l)" -gt 0 ]; then
        #                 svcs -a | egrep -i "shell|rlogin|rexec" >> $OUTPUT_FILE2 2>&1
        #             else
        #                 echo "-shell, rlogin, rexec 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #             fi
        #         fi
        #     fi
        # else
        #     if command -v svcs >/dev/null 2>&1; then
        #         echo "[svcs 명령어 확인 (svcs -a | egrep -i \"shell|rlogin|rexec\")]" >> $OUTPUT_FILE2 2>&1
        #         if [ "$(svcs -a | egrep -i "shell|rlogin|rexec" | wc -l)" -gt 0 ]; then
        #             svcs -a | egrep -i "shell|rlogin|rexec" >> $OUTPUT_FILE2 2>&1
        #         else
        #             echo "-shell, rlogin, rexec 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #         fi
        #     fi
        # fi
        echo "" >> $OUTPUT_FILE2 2>&1

        cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE3" ] ; then
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_R_SERVICES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-21" 2>&1
}

#U-23
DISABLE_VULNERABLE_SERVICES_TO_DOS_ATTACKS() {
echo "DISABLE_VULNERABLE_SERVICES_TO_DOS_ATTACKS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-23.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-23_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-23_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE2 2>&1
        echo "[/etc/inetd.conf 파일 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -f /etc/inetd.conf ] ; then
            echo "[#cat /etc/inetd.conf | egrep -i \"echo|discard|daytime|chargen\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/inetd.conf | egrep -i "echo|discard|daytime|chargen" | grep -v "^#" | wc -l)" -eq 0 ]; then
                echo "-Dos 공격에 취약한 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
            else
                if [ $GREP_AB_TMP -gt 0 ]; then
                    cat /etc/inetd.conf | egrep -A 3 -B 5 -i "echo|discard|daytime|chargen" | grep -v "^#" >> $OUTPUT_FILE2 2>&1
                else
                    #1:patterns, 2:file, 3:lines_before, 4:lines_after
                    grep_AB_shell "echo|discard|daytime|chargen" "/etc/inetd.conf" "5" "3"
                    cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
                fi
            fi
        else
            echo "-/etc/inetd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi
        echo "" >> $OUTPUT_FILE2 2>&1

        echo "[/etc/xinetd.d 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -d /etc/xinetd.d ] && [ "$(ls -A /etc/xinetd.d)" ]; then
            echo "[#ls -alL /etc/xinetd.d]" >> $OUTPUT_FILE3 2>&1
            ls -alL /etc/xinetd.d >> $OUTPUT_FILE3 2>&1
            echo "" >> $OUTPUT_FILE3 2>&1
            echo "[#cat /etc/xinetd.d/* | egrep -i \"echo|discard|daytime|chargen\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/xinetd.d/* | egrep -i "echo|discard|daytime|chargen" | grep -v "^#" | wc -l)" -eq 0 ]; then
                echo "-Dos 공격에 취약한 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
            else
                files=$(find "/etc/xinetd.d" -type f 2>/dev/null)
                keyword1="echo discard daytime chargen"
                keyword2="disable"
                end_marker="}"
                for file in $files; do
                    for keyword in $keyword1; do
                        section=$(sed -n "/$keyword/,/$end_marker/p" "$file" )
                        if [ "$(echo "$section" | grep -i "$keyword2" | wc -l)" -gt 0 ]; then
                            echo "file:$file, keyword:$keyword" >> $OUTPUT_FILE2 2>&1
                            if [ $SED_TMP -gt 0 ]; then
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/	//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            else
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/\s//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            fi
                        fi
                    done
                done
            fi
        else
            echo "-/etc/xinetd.d 디렉터리가 존재하지 않거나 디렉터리에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi

        #solaris
        SOLARIS_CHECK_SERVICES "echo|discard|daytime|chargen" "echo, discard, daytime, chargen"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
        fi
        
        # if command -v inetadm >/dev/null 2>&1; then
        #     if [ "$(inetadm | egrep -i "echo|discard|daytime|chargen" | wc -l)" -gt 0 ]; then
        #         echo "[inetadm 명령어 확인 (inetadm | egrep -i \"echo|discard|daytime|chargen\")]" >> $OUTPUT_FILE2 2>&1
        #         inetadm | egrep -i "echo|discard|daytime|chargen" >> $OUTPUT_FILE2 2>&1
        #     else
        #         if command -v svcs >/dev/null 2>&1; then
        #             echo "[inetadm 명령어 확인 (inetadm | egrep -i \"echo|discard|daytime|chargen\")]" >> $OUTPUT_FILE2 2>&1
        #             echo "-echo, discard, daytime, chargen 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #             echo "" >> $OUTPUT_FILE2 2>&1
        #             echo "[svcs 명령어 확인 (svcs -a | egrep -i \"echo|discard|daytime|chargen\")]" >> $OUTPUT_FILE2 2>&1
        #             if [ "$(svcs -a | egrep -i "echo|discard|daytime|chargen" | wc -l)" -gt 0 ]; then
        #                 svcs -a | egrep -i "echo|discard|daytime|chargen" >> $OUTPUT_FILE2 2>&1
        #             else
        #                 echo "-echo, discard, daytime, chargen 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #             fi
        #         fi
        #     fi
        # else
        #     if command -v svcs >/dev/null 2>&1; then
        #         echo "[svcs 명령어 확인 (svcs -a | egrep -i \"echo|discard|daytime|chargen\")]" >> $OUTPUT_FILE2 2>&1
        #         if [ "$(svcs -a | egrep -i "echo|discard|daytime|chargen" | wc -l)" -gt 0 ]; then
        #             svcs -a | egrep -i "echo|discard|daytime|chargen" >> $OUTPUT_FILE2 2>&1
        #         else
        #             echo "-echo, discard, daytime, chargen 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #         fi
        #     fi
        # fi
        echo "" >> $OUTPUT_FILE2 2>&1
        cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE3" ] ; then
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_VULNERABLE_SERVICES_TO_DOS_ATTACKS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-23" 2>&1
}

#U-28
CHECK_NIS_AND_NISPLUS_CONFIGURATION() {
echo "CHECK_NIS_AND_NISPLUS_CONFIGURATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-28.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-28_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[NIS, NIS+ 서비스 확인]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" | grep -v "grep" | wc -l)" -eq 0 ]; then
            echo "-NIS, NIS+ 서비스가 비활성화 되어 있습니다.(ps -ef | egrep \"ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated\" 내용 존재하지 않음)" >> $OUTPUT_FILE 2>&1
            #U-28 양취판단
            SECURITY_STATUS="Y"
        else
            ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" | grep -v "grep" >> $OUTPUT_FILE 2>&1
            # ypserv 확인
            if ps -ef | grep -i "ypserv" | grep -v "grep" > /dev/null; then
                echo "ypserv : master와 slave 서버에서 실행되며 클라이언트로부터의 ypbind 요청에 응답" >> $OUTPUT_FILE 2>&1
            fi
            # ypbind 확인
            if ps -ef | grep -i "ypbind" | grep -v "grep" > /dev/null; then
                echo "ypbind : 모든 NIS 시스템에서 실행되며 클라이언트와 서버를 바인딩하고 초기화함" >> $OUTPUT_FILE 2>&1
            fi
            # rpc.yppasswdd 확인
            if ps -ef | grep -i "rpc.yppasswdd" | grep -v "grep" > /dev/null; then
                echo "rpc.yppasswdd : 사용자들이 패스워드를 변경하기 위해 사용" >> $OUTPUT_FILE 2>&1
            fi
            # ypxfrd 확인
            if ps -ef | grep -i "ypxfrd" | grep -v "grep" > /dev/null; then
                echo "ypxfrd : NIS 마스터 서버에서만 실행되며 고속으로 NIS 맵 전송" >> $OUTPUT_FILE 2>&1
            fi
            # rpc.ypupdated 확인
            if ps -ef | grep -i "rpc.ypupdated" | grep -v "grep" > /dev/null; then
                echo "rpc.ypupdated : NIS 마스터 서버에서만 실행되며 고속으로 암호화하여 NIS맵 전송" >> $OUTPUT_FILE 2>&1
            fi
        fi

        #solaris
        SOLARIS_CHECK_SERVICES "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis" "NIS"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE 2>&1
        fi
        
        # if command -v inetadm >/dev/null 2>&1; then
        #     if [ "$(inetadm | egrep -i "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis" | wc -l)" -gt 0 ]; then
        #         echo "[inetadm 명령어 확인 (inetadm | egrep -i \"ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis\")]" >> $OUTPUT_FILE 2>&1
        #         inetadm | egrep -i "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis" >> $OUTPUT_FILE 2>&1
        #     else
        #         if command -v svcs >/dev/null 2>&1; then
        #             echo "[inetadm 명령어 확인 (inetadm | egrep -i \"ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis\")]" >> $OUTPUT_FILE 2>&1
        #             echo "-NIS 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #             echo "" >> $OUTPUT_FILE 2>&1
        #             echo "[svcs 명령어 확인 (svcs -a | egrep -i \"ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis\")]" >> $OUTPUT_FILE 2>&1
        #             if [ "$(svcs -a | egrep -i "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis" | wc -l)" -gt 0 ]; then
        #                 svcs -a | egrep -i "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis" >> $OUTPUT_FILE 2>&1
        #             else
        #                 echo "-NIS 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #             fi
        #         fi
        #     fi
        # else
        #     if command -v svcs >/dev/null 2>&1; then
        #         echo "[svcs 명령어 확인 (svcs -a | egrep -i \"ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis\")]" >> $OUTPUT_FILE 2>&1
        #         if [ "$(svcs -a | egrep -i "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis" | wc -l)" -gt 0 ]; then
        #             svcs -a | egrep -i "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|nis" >> $OUTPUT_FILE 2>&1
        #         else
        #             echo "-NIS 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #         fi
        #     fi
        # fi
        echo "" >> $OUTPUT_FILE 2>&1
fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHECK_NIS_AND_NISPLUS_CONFIGURATION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-28" 2>&1
}

#U-29
DISABLE_TFTP_AND_TALK_SERVICES() {
echo "DISABLE_TFTP_AND_TALK_SERVICES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-29.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-29_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-29_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE2 2>&1
        echo "[/etc/inetd.conf 파일 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -f /etc/inetd.conf ] ; then
            echo "[#cat /etc/inetd.conf | egrep -i \"tftp|talk|ntalk\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/inetd.conf | egrep -i "tftp|talk|ntalk" | grep -v "^#" | wc -l)" -eq 0 ]; then
                echo "-tftp, talk, ntalk 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
            else
                if [ $GREP_AB_TMP -gt 0 ]; then
                    cat /etc/inetd.conf | egrep -A 3 -B 5 -i "tftp|talk|ntalk" | grep -v "^#" >> $OUTPUT_FILE2 2>&1
                else
                    #1:patterns, 2:file, 3:lines_before, 4:lines_after
                    grep_AB_shell "tftp|talk|ntalk" "/etc/inetd.conf" "5" "3"
                    cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
                fi
            fi
        else
            echo "-/etc/inetd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi
        echo "" >> $OUTPUT_FILE2 2>&1

        echo "[/etc/xinetd.d 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -d /etc/xinetd.d ] && [ "$(ls -A /etc/xinetd.d)" ]; then
            echo "[#ls -alL /etc/xinetd.d]" >> $OUTPUT_FILE3 2>&1
            ls -alL /etc/xinetd.d >> $OUTPUT_FILE3 2>&1
            echo "" >> $OUTPUT_FILE3 2>&1
            echo "[#cat /etc/xinetd.d/* | egrep -i \"tftp|talk|ntalk\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/xinetd.d/* | egrep -i "tftp|talk|ntalk" | grep -v "^#" | wc -l)" -eq 0 ]; then
                echo "-tftp, talk, ntalk 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            else
                files=$(find "/etc/xinetd.d" -type f 2>/dev/null)
                keyword1="tftp talk ntalk"
                keyword2="disable"
                end_marker="}"
                for file in $files; do
                    for keyword in $keyword1; do
                        section=$(sed -n "/$keyword/,/$end_marker/p" "$file" )
                        if [ "$(echo "$section" | grep -i "$keyword2" | wc -l)" -gt 0 ]; then
                            echo "file:$file, keyword:$keyword" >> $OUTPUT_FILE2 2>&1
                            if [ $SED_TMP -gt 0 ]; then
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/	//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            else
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/\s//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            fi
                        fi
                    done
                done
            fi
        else
            echo "-/etc/xinetd.d 디렉터리가 존재하지 않거나 디렉터리에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi

        #solaris
        SOLARIS_CHECK_SERVICES "tftp|talk|ntalk" "tftp, talk, ntalk"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
        fi
        
        # if command -v inetadm >/dev/null 2>&1; then
        #     if [ "$(inetadm | egrep -i "tftp|talk|ntalk" | wc -l)" -gt 0 ]; then
        #         echo "[inetadm 명령어 확인 (inetadm | egrep -i \"tftp|talk|ntalk\")]" >> $OUTPUT_FILE 2>&1
        #         inetadm | egrep -i "tftp|talk|ntalk" >> $OUTPUT_FILE 2>&1
        #     else
        #         if command -v svcs >/dev/null 2>&1; then
        #             echo "[inetadm 명령어 확인 (inetadm | egrep -i \"tftp|talk|ntalk\")]" >> $OUTPUT_FILE 2>&1
        #             echo "-tftp, talk, ntalk 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #             echo "" >> $OUTPUT_FILE 2>&1
        #             echo "[svcs 명령어 확인 (svcs -a | egrep -i \"tftp|talk|ntalk\")]" >> $OUTPUT_FILE 2>&1
        #             if [ "$(svcs -a | egrep -i "tftp|talk|ntalk" | wc -l)" -gt 0 ]; then
        #                 svcs -a | egrep -i "tftp|talk|ntalk" >> $OUTPUT_FILE 2>&1
        #             else
        #                 echo "-tftp, talk, ntalk 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #             fi
        #         fi
        #     fi
        # else
        #     if command -v svcs >/dev/null 2>&1; then
        #         echo "[svcs 명령어 확인 (svcs -a | egrep -i \"tftp|talk|ntalk\")]" >> $OUTPUT_FILE 2>&1
        #         if [ "$(svcs -a | egrep -i "tftp|talk|ntalk" | wc -l)" -gt 0 ]; then
        #             svcs -a | egrep -i "tftp|talk|ntalk" >> $OUTPUT_FILE 2>&1
        #         else
        #             echo "-tftp, talk, ntalk 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #         fi
        #     fi
        # fi
        echo "" >> $OUTPUT_FILE 2>&1
        cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE3" ] ; then
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_TFTP_AND_TALK_SERVICES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-29" 2>&1
}

#SRV-035
ENABLE_VULNERABLE_SERVICES() {
echo "ENABLE_VULNERABLE_SERVICES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-035.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[1. tftp, talk, ntalk]" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/U-29_REF01.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1
        echo "-----------------------" >> $OUTPUT_FILE 2>&1
        echo "[2. finger]" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/U-19_REF01.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1
        echo "-----------------------" >> $OUTPUT_FILE 2>&1
        echo "[3. 취약한 r 계열 서비스(rexec, rlogin, rsh)]" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/U-21_REF01.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1
        echo "-----------------------" >> $OUTPUT_FILE 2>&1
        echo "[4. DoS에 취약한 서비스 (echo, discard, daytime, chargen)]" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/U-23_REF01.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1
        echo "-----------------------" >> $OUTPUT_FILE 2>&1
        echo "[5. NIS, NIS+]" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/VULNERABILITY/U-28.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1
        echo "-----------------------" >> $OUTPUT_FILE 2>&1
        if [ -d /etc/xinetd.d ] && [ "$(ls -A /etc/xinetd.d)" ]; then
            echo "[#ls -alL /etc/xinetd.d]" >> $OUTPUT_FILE3 2>&1
            ls -alL /etc/xinetd.d >> $OUTPUT_FILE3 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "ENABLE_VULNERABLE_SERVICES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-035" 2>&1
}

#U-20,SRV-013
DISABLE_ANONYMOUS_FTP() {
echo "DISABLE_ANONYMOUS_FTP_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-20_SRV-013.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-20_SRV-013_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-20_SRV-013_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp" >> $OUTPUT_FILE 2>&1

        if [ $FTP_CHECK_01 = 1 ] ; then
            echo "" >> $OUTPUT_FILE 2>&1

            #ftp 서비스에서 ANONYMOUS 활성화 확인
            echo "[#cat /etc/passwd | egrep -i '^ftp|^anonymous']" >> $OUTPUT_FILE 2>&1
            if [ "$(cat /etc/passwd | egrep -i '^ftp|^anonymous' | wc -l)" -eq 0 ]; then
                echo "-ftp,anonymous 계정이 존재하지 않습니다.." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/passwd | egrep -i '^ftp|^anonymous' >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1

            #vsftp 서비스에서 ANONYMOUS 활성화 확인
            if ps -ef | grep -i "vsftp" | grep -v "grep" > /dev/null; then
                if [ -n "$VSFTPD_PATH" ]; then
                    for file in $VSFTPD_PATH; do
                        if egrep -i "anonymous_enable|anonymous enable" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                egrep -i -A 1 -B 1 "anonymous_enable|anonymous enable" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "anonymous_enable|anonymous enable" "$file" "1" "1"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "vsftpd.conf 파일에서 anonymous enable  관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[vsftpd.conf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-vsftpd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
            fi

            #proftp 서비스에서 ANONYMOUS 활성화 확인
            if ps -ef | grep -i "proftp" | grep -v "grep" > /dev/null; then
                if [ -n "$PROFTPD_PATH" ]; then
                    for file in $PROFTPD_PATH; do
                        if grep -i "anonymous" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 1 -B 5 "anonymous" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "anonymous" "$file" "5" "1"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "-proftpd.conf 파일에서 anonymous 관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[proftpd.conf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-proftpd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        else
            #U-20,SRV-013 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_ANONYMOUS_FTP_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-20" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-013" 2>&1
}

#U-61,SRV-037
CHECK_FTP_SERVICE() {
echo "CHECK_FTP_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-61_SRV-037.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-61_SRV-037_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-61_SRV-037_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        if [ $FTP_CHECK_01 = 0 ] ; then
            #U-61,SRV-037 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHECK_FTP_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-61" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-037" 2>&1
}

#U-62
RESTRICT_FTP_ACCOUNT_SHELL() {
echo "RESTRICT_FTP_ACCOUNT_SHELL_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-62.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-62_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-62_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $FTP_CHECK_01 = 1 ] ; then
            #ftp 서비스에서 ANONYMOUS 활성화 확인
            echo "[#cat /etc/passwd | egrep -i '^ftp|^anonymous']" >> $OUTPUT_FILE 2>&1
            if [ "$(cat /etc/passwd | egrep -i '^ftp|^anonymous' | wc -l)" -eq 0 ]; then
                echo "-ftp,anonymous 계정이 존재하지 않습니다.." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/passwd | egrep -i '^ftp|^anonymous' >> $OUTPUT_FILE 2>&1
            fi
        else
            #U-62 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_FTP_ACCOUNT_SHELL_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-62" 2>&1
}

#U-63,SRV-161
SET_FTPUSERS_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_FTPUSERS_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-63_SRV-161.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-63_SRV-161_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-63_SRV-161_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $FTP_CHECK_01 = 1 ] ; then
            echo "" >> $OUTPUT_FILE 2>&1
            if [ -n "$FTPUSERS_PATH" ]; then
                echo "[ftpusers 파일 권한 확인]" >> $OUTPUT_FILE 2>&1
                for file in $FTPUSERS_PATH; do
                ls -alLd $file >> $OUTPUT_FILE 2>&1
                done
            else
                echo "-ftpusers 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            #U-63,SRV-161 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_FTPUSERS_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-63" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-161" 2>&1
}

#U-64,SRV-011
CONFIGURE_FTPUSERS_FILE() {
echo "CONFIGURE_FTPUSERS_FILE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-64_SRV-011.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-64_SRV-011_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-64_SRV-011_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $FTP_CHECK_01 = 1 ] ; then
            echo "" >> $OUTPUT_FILE 2>&1
            if [ -n "$FTPUSERS_PATH" ]; then
                echo "[ftpusers 파일 내용 확인]" >> $OUTPUT_FILE 2>&1
                for file in $FTPUSERS_PATH; do
                    echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                    cat $file >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                done
            else
                echo "-ftpusers 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
            # PROFTPD_PATH에서 RootLogin 확인
            if [ -n "$PROFTPD_PATH" ]; then
                for file in $PROFTPD_PATH; do
                    echo "[# cat $file | grep -i \"RootLogin\"]" >> $OUTPUT_FILE 2>&1
                    if [ "$(cat $file | grep -i "RootLogin" | wc -l)" -eq 0 ]; then
                        echo "-proftpd.conf 파일에서 RootLogin 관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    else
                        cat $file | grep -i "RootLogin" >> $OUTPUT_FILE 2>&1
                    fi
                    echo "" >> $OUTPUT_FILE 2>&1
                done
            else
                if [ -z "$FTPUSERS_PATH" ]; then
                    echo "-ftpusers 또는 proftpd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
            fi
        else
            #U-64,SRV-011 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CONFIGURE_FTPUSERS_FILE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-64" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-011" 2>&1
}

#SRV-021
INCOMPLETE_ACCESS_CONTROL_CONFIGURATION_FOR_FTP_SERVICE() {
echo "INCOMPLETE_ACCESS_CONTROL_CONFIGURATION_FOR_FTP_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-021.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-021_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-021_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp" >> $OUTPUT_FILE 2>&1

        if [ $FTP_CHECK_01 = 1 ] ; then
            echo "" >> $OUTPUT_FILE 2>&1

            #ftp 접근제어 확인
            echo "[TCP Wrapper(hosts.allow,hosts.deny) 를 통한 접근제어 확인(일반 FTP,VSFTPD)]" >> $OUTPUT_FILE 2>&1
            echo "[#cat /etc/hosts.allow]" >> $OUTPUT_FILE 2>&1
            if [ -f /etc/hosts.allow ] ; then
                if [ "$(cat /etc/hosts.allow | grep -v "#" | wc -l)" -eq 0 ]; then
                    echo "-hosts.allow 파일에 접근제어 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                else
                    cat /etc/hosts.allow | grep -v "#" >> $OUTPUT_FILE 2>&1
                fi
            else
                echo "-/etc/hosts.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[#cat /etc/hosts.deny]" >> $OUTPUT_FILE 2>&1
            if [ -f /etc/hosts.deny ] ; then
                if [ "$(cat /etc/hosts.deny | grep -v "#" | wc -l)" -eq 0 ]; then
                    echo "-hosts.deny 파일에 접근제어 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                else
                    cat /etc/hosts.deny | grep -v "#" >> $OUTPUT_FILE 2>&1
                fi
            else
                echo "-/etc/hosts.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
            echo "" >> $OUTPUT_FILE 2>&1

            #HP-UX
            if [ -f /var/adm/inetd.sec ]; then
                echo "[TCP Wrapper(/var/adm/inetd.sec) 를 통한 접근제어 확인(일반 FTP,VSFTPD)]" >> $OUTPUT_FILE 2>&1
                echo "[#cat /var/adm/inetd.sec]" >> $OUTPUT_FILE 2>&1
                cat /var/adm/inetd.sec | grep -v "#" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #aix
            if [ $AIX_CHECK_00 -eq 1 ]; then
                if [ -f /etc/ftpaccess.ctl ]; then
                    echo "[#cat /etc/ftpaccess.ctl]" >> $OUTPUT_FILE 2>&1
                    cat /etc/ftpaccess.ctl >> $OUTPUT_FILE 2>&1
                else
                    echo "-/etc/ftpaccess.ctl 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
            fi

            #proftp 서비스
            if ps -ef | grep -i "proftp" | grep -v "grep" > /dev/null; then
                if [ -n "$PROFTPD_PATH" ]; then
                    for file in $PROFTPD_PATH; do
                        if grep -i "Allow from" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 1 -B 1 "Allow from" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "Allow from" "$file" "1" "1"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-proftpd.conf 파일에서 Allow from 관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[proftpd.conf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-proftpd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        else
            #SRV-021 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "INCOMPLETE_ACCESS_CONTROL_CONFIGURATION_FOR_FTP_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-021" 2>&1
}

#SRV-171
EXPOSURE_OF_FTP_SERVICE_INFORMATION() {
echo "EXPOSURE_OF_FTP_SERVICE_INFORMATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-171.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-171_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-171_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/ftpcheck.hangrp" >> $OUTPUT_FILE 2>&1

        if [ $FTP_CHECK_01 = 1 ] ; then
            FILE_COPY "/etc/ftpd/ftpaccess"
            echo "" >> $OUTPUT_FILE 2>&1

            #"[배너 확인-일반FTP는 통상적으로 배너가 존재하지 않음]"

            #aix
            if [ $AIX_CHECK_00 -eq 1 ]; then
                if [ -f /tmp/ftpd.msg ]; then
                    echo "[#cat /tmp/ftpd.msg]" >> $OUTPUT_FILE 2>&1
                    cat /tmp/ftpd.msg >> $OUTPUT_FILE 2>&1
                else
                    echo "-/tmp/ftpd.msg 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
            fi


            #solaris
            if [ $SOLARIS_CHECK_00 -eq 1 ]; then
                if [ -f /etc/ftpd/ftpaccess ]; then
                    if [ "$(cat /etc/ftpd/ftpaccess | egrep -i "greeting" | grep -v "#" | wc -l)" -gt 0 ]; then
                        echo "[#cat /etc/ftpd/ftpaccess | egrep -i \"greeting\"]" >> $OUTPUT_FILE 2>&1
                        cat /etc/ftpd/ftpaccess | egrep -i "greeting" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    else
                        echo "-/etc/ftpd/ftpaccess 파일에 greeting 관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi

            #vsftp
            if ps -ef | grep -i "vsftp" | grep -v "grep" > /dev/null; then
                if [ -n "$VSFTPD_PATH" ]; then
                    for file in $VSFTPD_PATH; do
                        if grep -i "banner" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 1 -B 1 "banner" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "banner" "$file" "1" "1"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "vsftpd.conf 파일에서 banner  관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[vsftpd.conf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-vsftpd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
            fi

            #proftp
            if ps -ef | grep -i "proftp" | grep -v "grep" > /dev/null; then
                if [ -n "$PROFTPD_PATH" ]; then
                    for file in $PROFTPD_PATH; do
                        #ServerIdent 구문
                        if grep -i "ServerIdent" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 1 -B 1 "ServerIdent" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "ServerIdent" "$file" "1" "1"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "-proftpd.conf 파일에서 ServerIdent 관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[proftpd.conf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-proftpd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        else
            #SRV-171 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "EXPOSURE_OF_FTP_SERVICE_INFORMATION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-171" 2>&1
}

#U-22
SET_CRON_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_CRON_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-22.hangrp"
    #양호권한
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-22_REF01.hangrp"
    #취약권한
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-22_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        echo "[cron 서비스 활성화 확인]" >> $OUTPUT_FILE 2>&1
        echo "[#ps -ef | grep cron]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | grep cron | grep -v grep | wc -l)" -ge 1 ] ; then
            ps -ef | grep cron | grep -v grep >> $OUTPUT_FILE 2>&1
        else
            echo "-cron 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ -f /etc/crontab ] ; then
            if perm_750 "/etc/crontab" ; then
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE2 2>&1
                printf "%s" "$(ls -alLd "/etc/crontab")" >> $OUTPUT_FILE2 2>&1
                echo " (권한 양호)" >> $OUTPUT_FILE2 2>&1
            else
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE3 2>&1
                printf "%s" "$(ls -alLd "/etc/crontab")" >> $OUTPUT_FILE3 2>&1
                echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
            fi
        fi

        CRONS="/etc/cron.daily/* /etc/cron.hourly/* /etc/cron.monthly/* /etc/cron.weekly/* /var/spool/cron/*"
        CROND="/etc/cron.deny /etc/cron.allow"

        for FILE in $CRONS; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        for FILE in $CROND; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done
        


        CRONTAB_USERS=$(cut -f1 -d: /etc/passwd)
        if crontab -u "root" -l >/dev/null 2>&1; then
            #crontab -u 사용가능할 경우
            for user in $CRONTAB_USERS; do
                filepaths=$(crontab -u "$user" -l 2>/dev/null | grep -v "#" | awk '{for (i=1;i<=NF;i++) if ($i ~ /^\//) printf "%s ", $i}')
                if [ -n "$filepaths" ] && [ "$filepaths" != "/" ] && [ "$filepaths" != "/*" ]; then
                    for file in $filepaths; do
                        if [ -f "$file" ]; then
                            if perm_750 $file; then 
                                    printf "(crontab -u \"$user\" -l) " >> $OUTPUT_FILE2 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE2 2>&1
                                    echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                            else
                                    printf "(crontab -u \"$user\" -l) " >> $OUTPUT_FILE3 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE3 2>&1
                                    echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                            fi
                        fi
                    done
                fi
            done
        else
            #crontab -u 사용불가능할 경우
            for user in $CRONTAB_USERS; do
                filepaths=$(crontab -l "$user" 2>/dev/null | grep -v "#" | awk '{for (i=1;i<=NF;i++) if ($i ~ /^\//) printf "%s ", $i}')
                if [ -n "$filepaths" ] && [ "$filepaths" != "/" ] && [ "$filepaths" != "/*" ]; then
                    for file in $filepaths; do
                        if [ -f "$file" ]; then
                            if perm_750 $file; then 
                                    printf "(crontab -l \"$user\") " >> $OUTPUT_FILE2 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE2 2>&1
                                    echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                            else
                                    printf "(crontab -l \"$user\") " >> $OUTPUT_FILE3 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE3 2>&1
                                    echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                            fi
                        fi
                    done
                fi
            done
        fi

        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 cron파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-22 양취판단
            SECURITY_STATUS="N"
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[양호한 권한을 가진 cron파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            fi
        else
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[cron 파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/etc/cron.allow 내용 확인
        echo "[#cat /etc/cron.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.allow ] ; then
            if [ "$(cat /etc/cron.allow | grep -v "#" | wc -l)" -eq 0 ]; then
                echo "-/etc/cron.allow 파일에 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/cron.allow >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/etc/cron.deny 내용 확인
        echo "[#cat /etc/cron.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.deny ] ; then
            if [ "$(cat /etc/cron.deny | grep -v "#" | wc -l)" -eq 0 ]; then
                echo "-/etc/cron.deny 파일에 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/cron.deny >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        echo "[cron 서비스 활성화 확인]" >> $OUTPUT_FILE 2>&1
        echo "[#ps -ef | grep cron]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | grep cron | grep -v grep | wc -l)" -ge 1 ] ; then
            ps -ef | grep cron | grep -v grep >> $OUTPUT_FILE 2>&1
        else
            echo "-cron 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ -f /etc/crontab ] ; then
            if perm_750 "/etc/crontab" ; then
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE2 2>&1
                printf "%s" "$(ls -alLd "/etc/crontab")" >> $OUTPUT_FILE2 2>&1
                echo " (권한 양호)" >> $OUTPUT_FILE2 2>&1
            else
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE3 2>&1
                printf "%s" "$(ls -alLd "/etc/crontab")" >> $OUTPUT_FILE3 2>&1
                echo " (권한취약 권장:750이하)" >> $OUTPUT_FILE3 2>&1
            fi
        fi

        CRONS="/var/spool/cron/crontabs/* /var/spool/cron/crontab/*"
        CROND="/etc/cron.d/cron.deny /etc/cron.d/cron.allow"

        for FILE in $CRONS; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        for FILE in $CROND; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done
        

        CRONTAB_USERS=$(cut -f1 -d: /etc/passwd)
        if crontab -u "root" -l >/dev/null 2>&1; then
            #crontab -u 사용가능할 경우
            for user in $CRONTAB_USERS; do
                filepaths=$(crontab -u "$user" -l 2>/dev/null | grep -v "#" | awk '{for (i=1;i<=NF;i++) if ($i ~ /^\//) printf "%s ", $i}')
                if [ -n "$filepaths" ] && [ "$filepaths" != "/" ] && [ "$filepaths" != "/*" ]; then
                    for file in $filepaths; do
                        if [ -f "$file" ]; then
                            if perm_750 $file; then 
                                    printf "(crontab -u \"$user\" -l) " >> $OUTPUT_FILE2 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE2 2>&1
                                    echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                            else
                                    printf "(crontab -u \"$user\" -l) " >> $OUTPUT_FILE3 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE3 2>&1
                                    echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                            fi
                        fi
                    done
                fi
            done
        else
            #crontab -u 사용불가능할 경우
            for user in $CRONTAB_USERS; do
                filepaths=$(crontab -l "$user" 2>/dev/null | grep -v "#" | awk '{for (i=1;i<=NF;i++) if ($i ~ /^\//) printf "%s ", $i}')
                if [ -n "$filepaths" ] && [ "$filepaths" != "/" ] && [ "$filepaths" != "/*" ]; then
                    for file in $filepaths; do
                        if [ -f "$file" ]; then
                            if perm_750 $file; then 
                                    printf "(crontab -l \"$user\") " >> $OUTPUT_FILE2 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE2 2>&1
                                    echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                            else
                                    printf "(crontab -l \"$user\") " >> $OUTPUT_FILE3 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE3 2>&1
                                    echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                            fi
                        fi
                    done
                fi
            done
        fi


        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 cron파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            #U-22 양취판단
            SECURITY_STATUS="N"
            echo "" >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[양호한 권한을 가진 cron파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            fi
        else
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[cron 파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/etc/cron.d/cron.allow 내용 확인
        echo "[#cat /etc/cron.d/cron.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.d/cron.allow ] ; then
            if [ "$(cat /etc/cron.d/cron.allow | grep -v "#" | wc -l)" -eq 0 ]; then
                echo "-/etc/cron.d/cron.allow 파일에 접근제어 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/cron.d/cron.allow >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.d/cron.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/etc/cron.d/cron.deny 내용 확인
        echo "[#cat /etc/cron.d/cron.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.d/cron.deny ] ; then
            if [ "$(cat /etc/cron.d/cron.deny | grep -v "#" | wc -l)" -eq 0 ]; then
                echo "-/etc/cron.d/cron.deny 파일에 접근제어 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/cron.d/cron.deny >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.d/cron.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #AIX, HP-UX
    if [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "[cron 서비스 활성화 확인]" >> $OUTPUT_FILE 2>&1
        echo "[#ps -ef | grep cron]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | grep cron | grep -v grep | wc -l)" -ge 1 ] ; then
            ps -ef | grep cron | grep -v grep >> $OUTPUT_FILE 2>&1
        else
            echo "-cron 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ -f /etc/crontab ] ; then
            if perm_750 "/etc/crontab" ; then
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE2 2>&1
                printf "%s" "$(ls -alLd "/etc/crontab")" >> $OUTPUT_FILE2 2>&1
                echo " (권한 양호)" >> $OUTPUT_FILE2 2>&1
            else
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE3 2>&1
                printf "%s" "$(ls -alLd "/etc/crontab")" >> $OUTPUT_FILE3 2>&1
                echo " (권한취약 권장:750이하)" >> $OUTPUT_FILE3 2>&1
            fi
        fi

        CRONS="/var/spool/cron/crontabs/* /var/spool/cron/crontab/*"
        CROND="/var/adm/cron/cron.deny /var/adm/cron/cron.allow"

        for FILE in $CRONS; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        for FILE in $CROND; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done
        

        CRONTAB_USERS=$(cut -f1 -d: /etc/passwd)
        if crontab -u "root" -l >/dev/null 2>&1; then
            #crontab -u 사용가능할 경우
            for user in $CRONTAB_USERS; do
                filepaths=$(crontab -u "$user" -l 2>/dev/null | grep -v "#" | awk '{for (i=1;i<=NF;i++) if ($i ~ /^\//) printf "%s ", $i}')
                if [ -n "$filepaths" ] && [ "$filepaths" != "/" ] && [ "$filepaths" != "/*" ]; then
                    for file in $filepaths; do
                        if [ -f "$file" ]; then
                            if perm_750 $file; then 
                                    printf "(crontab -u \"$user\" -l) " >> $OUTPUT_FILE2 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE2 2>&1
                                    echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                            else
                                    printf "(crontab -u \"$user\" -l) " >> $OUTPUT_FILE3 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE3 2>&1
                                    echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                            fi
                        fi
                    done
                fi
            done
        else
            #crontab -u 사용불가능할 경우
            for user in $CRONTAB_USERS; do
                filepaths=$(crontab -l "$user" 2>/dev/null | grep -v "#" | awk '{for (i=1;i<=NF;i++) if ($i ~ /^\//) printf "%s ", $i}')
                if [ -n "$filepaths" ] && [ "$filepaths" != "/" ] && [ "$filepaths" != "/*" ]; then
                    for file in $filepaths; do
                        if [ -f "$file" ]; then
                            if perm_750 $file; then 
                                    printf "(crontab -l \"$user\") " >> $OUTPUT_FILE2 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE2 2>&1
                                    echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                            else
                                    printf "(crontab -l \"$user\") " >> $OUTPUT_FILE3 2>&1
                                    printf "%s" "$(ls -alLd $file)" >> $OUTPUT_FILE3 2>&1
                                    echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                            fi
                        fi
                    done
                fi
            done
        fi


        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 cron파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-22 양취판단
            SECURITY_STATUS="N"
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[양호한 권한을 가진 cron파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            fi
        else
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[cron 파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/var/adm/cron/cron.allow 내용 확인
        echo "[#cat /var/adm/cron/cron.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /var/adm/cron/cron.allow ] ; then
            if [ "$(cat /var/adm/cron/cron.allow | egrep -v "#" | wc -l)" -ne 0 ] ; then
                cat /var/adm/cron/cron.allow >> $OUTPUT_FILE 2>&1
            else
                echo "-/var/adm/cron/cron.allow 파일이 존재하지만, 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/var/adm/cron/cron.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/var/adm/cron/cron.deny 내용 확인
        echo "[#cat /var/adm/cron/cron.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /var/adm/cron/cron.deny ] ; then
            if [ $(cat /var/adm/cron/cron.deny | egrep -v "#" | wc -l) -ne 0 ] ; then
                cat /var/adm/cron/cron.deny >> $OUTPUT_FILE 2>&1
            else
                echo "-/var/adm/cron/cron.deny 파일이 존재하지만, 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/var/adm/cron/cron.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_CRON_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-22" 2>&1
}

#U-65
SET_AT_FILE_OWNERSHIP_AND_PERMISSIONS() {
echo "SET_AT_FILE_OWNERSHIP_AND_PERMISSIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-65.hangrp"
    #양호권한
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-65_REF01.hangrp"
    #취약권한
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-65_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        AT_LIST="/etc/at.allow /etc/at.deny"
        for AT_LIST1 in $AT_LIST ; do
            if [ -f "$AT_LIST1" ] ; then
                if perm_640 $AT_LIST1 ; then
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            else
                echo "-$AT_LIST1 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
            fi
        done
        
        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 at파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            #U-65 양취판단
            SECURITY_STATUS="N"
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[양호한 권한을 가진 at파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        else
            echo "[at 파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        #/etc/at.allow 내용 확인
        echo "[#cat /etc/at.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/at.allow ] ; then
            if [ "$(cat /etc/at.allow | egrep -v "#|$" | wc -l)" -ne 0 ] ; then
                cat /etc/at.allow >> $OUTPUT_FILE 2>&1
            else
                echo "-/etc/at.allow 파일이 존재하지만, 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/at.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/etc/at.deny 내용 확인
        echo "[#cat /etc/at.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/at.deny ] ; then
            if [ "$(cat /etc/at.deny | egrep -v "#|$" | wc -l)" -ne 0 ] ; then
                cat /etc/at.deny >> $OUTPUT_FILE 2>&1
            else
                echo "-/etc/at.deny 파일이 존재하지만, 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/at.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        AT_LIST="/etc/cron.d/at.allow /etc/cron.d/at.deny"
        for AT_LIST1 in $AT_LIST ; do
            if [ -f "$AT_LIST1" ] ; then
                if perm_640 $AT_LIST1 ; then
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            else
                echo "-$AT_LIST1 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
            fi
        done
        
        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 at파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-65 양취판단
            SECURITY_STATUS="N"
            echo "[양호한 권한을 가진 at파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        else
            echo "[at 파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        #/etc/cron.d/at.allow 내용 확인
        echo "[#cat /etc/cron.d/at.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.d/at.allow ] ; then
            if [ "$(cat /etc/cron.d/at.allow | egrep -v "#|$" | wc -l)" -ne 0 ] ; then
                cat /etc/cron.d/at.allow >> $OUTPUT_FILE 2>&1
            else
                echo "-/etc/cron.d/at.allow 파일이 존재하지만, 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.d/at.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/etc/cron.d/at.deny 내용 확인
        echo "[#cat /etc/cron.d/at.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.d/at.deny ] ; then
            if [ "$(cat /etc/cron.d/at.deny | egrep -v "#|$" | wc -l)" -ne 0 ] ; then
                cat /etc/cron.d/at.deny >> $OUTPUT_FILE 2>&1
            else
                echo "-/etc/cron.d/at.deny 파일이 존재하지만, 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.d/at.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #AIX, HP-UX
    if [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        AT_LIST="/var/adm/cron/at.allow /var/adm/cron/at.deny"
        for AT_LIST1 in $AT_LIST ; do
            if [ -f "$AT_LIST1" ] ; then
                if perm_640 $AT_LIST1 ; then
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            else
                echo "-$AT_LIST1 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
            fi
        done
        
        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 at파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[양호한 권한을 가진 at파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        else
            echo "[at 파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        #/var/adm/cron/at.allow 내용 확인
        echo "[#cat /var/adm/cron/at.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /var/adm/cron/at.allow ] ; then
            if [ "$(cat /var/adm/cron/at.allow | egrep -v "#|$" | wc -l)" -ne 0 ] ; then
                cat /var/adm/cron/at.allow >> $OUTPUT_FILE 2>&1
            else
                echo "-/var/adm/cron/at.allow 파일이 존재하지만, 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/var/adm/cron/at.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/var/adm/cron/at.deny 내용 확인
        echo "[#cat /var/adm/cron/at.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /var/adm/cron/at.deny ] ; then
            if [ "$(cat /var/adm/cron/at.deny | egrep -v "#|$" | wc -l)" -ne 0 ] ; then
                cat /var/adm/cron/at.deny >> $OUTPUT_FILE 2>&1
            else
                echo "-/var/adm/cron/at.deny 파일이 존재하지만, 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/var/adm/cron/at.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################

    echo "" >> $OUTPUT_FILE 2>&1
    echo "SET_AT_FILE_OWNERSHIP_AND_PERMISSIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-65" 2>&1
}

#SRV-081
INCOMPLETE_PERMISSIONS_CONFIGURATION_FOR_CRONTAB_SETTINGS_FILE() {
echo "INCOMPLETE_PERMISSIONS_CONFIGURATION_FOR_CRONTAB_SETTINGS_FILE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-081.hangrp"
    #양호권한
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-081_REF01.hangrp"
    #취약권한
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-081_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        if [ -f /etc/crontab ] ; then
            if perm_750 "/etc/crontab" ; then
                echo "[ls -al /etc/crontab]" >> $OUTPUT_FILE2 2>&1
                printf "%s" "$(ls -al /etc/crontab)" >> "$OUTPUT_FILE2" 2>&1
                echo " (권한 양호)" >> $OUTPUT_FILE2 2>&1
            else
                echo "[ls -al /etc/crontab]" >> $OUTPUT_FILE3 2>&1
                printf "%s" "$(ls -al /etc/crontab)" >> "$OUTPUT_FILE3" 2>&1
                echo " (권한취약 권장:750이하)" >> $OUTPUT_FILE3 2>&1
            fi
        fi

        CRONS="/etc/cron.daily/* /etc/cron.hourly/* /etc/cron.monthly/* /etc/cron.weekly/* /var/spool/cron/*"
        CROND="/etc/cron.deny /etc/cron.allow"

        for FILE in $CRONS; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640또는750이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640또는750이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        for FILE in $CROND; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        AT_LIST="/etc/at.allow /etc/at.deny"
        for AT_LIST1 in $AT_LIST ; do
            if [ -f "$AT_LIST1" ] ; then
                if perm_640 $AT_LIST1 ; then
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            #SRV-081 양취판단
            SECURITY_STATUS="N"
            echo "" >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[양호한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            else
                echo "-양호한 권한을 가진 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            #SRV-081 양취판단
            SECURITY_STATUS="Y"
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            else
                echo "-/var/spool/cron/crontab/, /etc/at.allow, /etc/at.deny, cron.allow, cron.deny 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        if [ -f /etc/crontab ] ; then
            if perm_750 "/etc/crontab" ; then
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE2 2>&1
                printf "%s" "$(ls -al /etc/crontab)" >> "$OUTPUT_FILE2" 2>&1
                echo " (권한 양호)" >> $OUTPUT_FILE2 2>&1
            else
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE3 2>&1
                printf "%s" "$(ls -al /etc/crontab)" >> "$OUTPUT_FILE3" 2>&1
                echo " (권한취약 권장:750이하)" >> $OUTPUT_FILE3 2>&1
            fi
        fi

        CRONS="/var/spool/cron/crontabs/* /var/spool/cron/crontab/*"
        CROND="/etc/cron.d/cron.deny /etc/cron.d/cron.allow"

        for FILE in $CRONS; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640또는750이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640또는750이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        for FILE in $CROND; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        AT_LIST="/etc/cron.d/at.allow /etc/cron.d/at.deny"
        for AT_LIST1 in $AT_LIST ; do
            if [ -f "$AT_LIST1" ] ; then
                if perm_640 $AT_LIST1 ; then
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            #SRV-081 양취판단
            SECURITY_STATUS="N"
            echo "" >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[양호한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            else
                echo "-양호한 권한을 가진 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            #SRV-081 양취판단
            SECURITY_STATUS="Y"
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            else
                echo "-/var/spool/cron/crontab/, at.allow, at.deny, cron.allow, cron.deny 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    ###############################
    #AIX, HP-UX
    if [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        if [ -f /etc/crontab ] ; then
            if perm_750 "/etc/crontab" ; then
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE2 2>&1
                printf "%s" "$(ls -al /etc/crontab)" >> "$OUTPUT_FILE2" 2>&1
                echo " (권한 양호)" >> $OUTPUT_FILE2 2>&1
            else
                echo "[ls -alLd /etc/crontab]" >> $OUTPUT_FILE3 2>&1
                printf "%s" "$(ls -al /etc/crontab)" >> "$OUTPUT_FILE3" 2>&1
                echo " (권한취약 권장:750이하)" >> $OUTPUT_FILE3 2>&1
            fi
        fi

        CRONS="/var/spool/cron/crontabs/* /var/spool/cron/crontab/*"
        CROND="/var/adm/cron/cron.deny /var/adm/cron/cron.allow"

        for FILE in $CRONS; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640또는750이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640또는750이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        for FILE in $CROND; do
            if [ -f "$FILE" ]; then
                if perm_750 $FILE; then
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$FILE" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $FILE)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:소유자 root/ 권한 group 쓰기제거,other 권한제거)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        AT_LIST="/var/adm/cron/at.allow /var/adm/cron/at.deny"
        for AT_LIST1 in $AT_LIST ; do
            if [ -f "$AT_LIST1" ] ; then
                if perm_640 $AT_LIST1 ; then
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE2 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE3 2>&1
                    fi
                else
                    if [ "$(ls -al "$AT_LIST1" | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (권한취약 권장:640이하)" >> $OUTPUT_FILE3 2>&1
                    else
                        printf "%s" "$(ls -al $AT_LIST1)" >> $OUTPUT_FILE3 2>&1
                        echo " (소유자,권한취약 권장:root,640이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                fi
            fi
        done

        if [ -f "$OUTPUT_FILE3" ] ; then
            echo "[취약한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
            #SRV-081 양취판단
            SECURITY_STATUS="N"
            echo "" >> $OUTPUT_FILE 2>&1
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[양호한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            else
                echo "-양호한 권한을 가진 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            #SRV-081 양취판단
            SECURITY_STATUS="Y"
            if [ -f "$OUTPUT_FILE2" ] ; then
                echo "[파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            else
                echo "-/var/spool/cron/crontab/, at.allow, at.deny, cron.allow, cron.deny 파일이 존재하지 않음" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "INCOMPLETE_PERMISSIONS_CONFIGURATION_FOR_CRONTAB_SETTINGS_FILE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-081" 2>&1
}

#SRV-094
INCOMPLETE_PERMISSIONS_CONFIGURATION_FOR_CRONTAB_REFERENCE_FILE() {
echo "INCOMPLETE_PERMISSIONS_CONFIGURATION_FOR_CRONTAB_REFERENCE_FILE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-094.hangrp"
    #양호권한
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-094_REF01.hangrp"
    #취약권한
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-094_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        CRONTAB_USERS=$(cut -f1 -d: /etc/passwd)
        if crontab -u "root" -l >/dev/null 2>&1; then
            #crontab -u 사용가능할 경우
            for user in $CRONTAB_USERS; do
                filepaths=$(crontab -u "$user" -l 2>/dev/null | grep -v "#" | awk '{for (i=1;i<=NF;i++) if ($i ~ /^\//) printf "%s ", $i}')
                if [ -n "$filepaths" ] && [ "$filepaths" != "/" ] && [ "$filepaths" != "/*" ]; then
                    for file in $filepaths; do
                        if [ -f "$file" ]; then
                            if perm_775 $file ; then
                                printf "(계정명:%s)" "$user" >> "$OUTPUT_FILE2" 2>&1
                                ls -alLd "$file" >> $OUTPUT_FILE2 2>&1
                            else
                                printf "(계정명:%s)" "$user" >> "$OUTPUT_FILE3" 2>&1
                                ls -alLd "$file" >> $OUTPUT_FILE3 2>&1
                            fi
                        fi
                    done
                fi
            done
        else
            #crontab -u 사용불가능할 경우
            for user in $CRONTAB_USERS; do
                filepaths=$(crontab -l "$user" 2>/dev/null | grep -v "#" | awk '{for (i=1;i<=NF;i++) if ($i ~ /^\//) printf "%s ", $i}')
                if [ -n "$filepaths" ] && [ "$filepaths" != "/" ] && [ "$filepaths" != "/*" ]; then
                    for file in $filepaths; do
                        if [ -f "$file" ]; then
                            if perm_775 $file ; then
                                printf "(계정명:%s)" "$user" >> "$OUTPUT_FILE2" 2>&1
                                ls -alLd "$file" >> $OUTPUT_FILE2 2>&1
                            else
                                printf "(계정명:%s)" "$user" >> "$OUTPUT_FILE3" 2>&1
                                ls -alLd "$file" >> $OUTPUT_FILE3 2>&1
                            fi
                        fi
                    done
                fi
            done
        fi

        echo "" >> $OUTPUT_FILE 2>&1

        #crontab -u "계정명" -l 으로 참조파일 확인
        if crontab -u "root" -l >/dev/null 2>&1; then
            if [ -f "$OUTPUT_FILE3" ] ; then
                #SRV-094 양취판단
                SECURITY_STATUS="N"
                echo "[crontab 참조파일(crontab -u \"계정명\" -l)에 others 쓰기 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[crontab 참조파일(crontab -u \"계정명\" -l)에 others 쓰기 권한이 없는 파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            else
                echo "[파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
                if [ -f "$OUTPUT_FILE2" ] ; then
                    cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
                else
                    echo "-crontab 참조파일(crontab -u \"계정명\" -l) 미존재" >> $OUTPUT_FILE 2>&1
                fi
            fi
        else
            if [ -f "$OUTPUT_FILE3" ] ; then
                #SRV-094 양취판단
                SECURITY_STATUS="N"
                echo "[crontab 참조파일(crontab -l \"계정명\")에 others 쓰기 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[crontab 참조파일(crontab -l \"계정명\")에 others 쓰기 권한이 없는 파일]" >> $OUTPUT_FILE 2>&1
                cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
            else
                echo "[파일 소유자 및 권한설정 확인]" >> $OUTPUT_FILE 2>&1
                if [ -f "$OUTPUT_FILE2" ] ; then
                    cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
                else
                    echo "-crontab 참조파일(crontab -l \"계정명\") 미존재" >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "INCOMPLETE_PERMISSIONS_CONFIGURATION_FOR_CRONTAB_REFERENCE_FILE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-094" 2>&1
}

#SRV-112
UNCONFIGURED_CRON_SERVICE_LOGGING() {
echo "UNCONFIGURED_CRON_SERVICE_LOGGING_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-112.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-112_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-112_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/syslog.conf" "/etc/rsyslog.conf"
        # solaris
        if [ -f /etc/default/cron ]; then
            if [ "$(cat /etc/default/cron | grep -i "CRONLOG=" | grep -v "#")" ] ; then
                echo "[/etc/default/cron 파일 내용 확인(cat /etc/default/cron | grep -i \"CRONLOG=\")]" >> $OUTPUT_FILE 2>&1
                cat /etc/default/cron | grep -i "CRONLOG=" | grep -v "#" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            else
                if [ "$(cat /etc/default/cron | grep -i "CRONLOG=")" ] ; then
                    echo "[/etc/default/cron 파일 내용 확인(cat /etc/default/cron | grep -i \"CRONLOG=\")]" >> $OUTPUT_FILE 2>&1
                    cat /etc/default/cron | grep -i "CRONLOG=" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "[/etc/default/cron 파일 내용 확인(cat /etc/default/cron | grep -i \"CRONLOG=\")]" >> $OUTPUT_FILE 2>&1
                    echo "-/etc/default/cron 파일에 CRONLOG 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi

        echo "[/etc/syslog.conf 파일 내용 확인]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/syslog.conf ] ; then
            if [ "$(cat /etc/syslog.conf | grep -i "cron" | grep -v "#")" ] ; then
                cat /etc/syslog.conf | grep -i "cron" | grep -v "#" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            else
                cat /etc/syslog.conf  >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/syslog.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi

        echo "[/etc/rsyslog.conf 파일 내용 확인]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/rsyslog.conf ] ; then
            if [ "$(cat /etc/rsyslog.conf | grep -i "cron" | grep -v "#" | wc -l)" -ne 0 ] ; then
                cat /etc/rsyslog.conf | grep -i "cron" | grep -v "#" >> $OUTPUT_FILE 2>&1
            else
                cat /etc/rsyslog.conf  >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/rsyslog.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "UNCONFIGURED_CRON_SERVICE_LOGGING_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-112" 2>&1
}

#SRV-133
INCOMPLETE_USER_RESTRICTIONS_FOR_CRON_SERVICE() {
echo "INCOMPLETE_USER_RESTRICTIONS_FOR_CRON_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-133.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-133_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-133_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/cron.allow" "/etc/cron.deny"

        allow_exists=false
        deny_exists=false
        allow_content=false
        deny_content=false

        if [ -f /etc/cron.allow ]; then
            allow_exists=true
            if [ "$(wc -l < /etc/cron.allow)" -ge 1 ]; then
                allow_content=true
            fi
        fi

        if [ -f /etc/cron.deny ]; then
            deny_exists=true
            if [ "$(wc -l < /etc/cron.deny)" -ge 1 ]; then
                deny_content=true
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[Cron.allow, Cron.deny 파일 확인]" >> $OUTPUT_FILE 2>&1
        if [ "$allow_exists" = true ] && [ "$deny_exists" = true ]; then
            if [ "$allow_content" = true ] && [ "$deny_content" = true ]; then
                echo "Allow와 Deny 파일 모두 존재 및 내용 있음: Allow 목록 사용자만 허용, Deny 목록 사용자 제외" >> $OUTPUT_FILE 2>&1
            elif [ "$allow_content" = true ]; then
                echo "Allow 파일에 내용 있음, Deny 파일 비어 있음: Allow 목록 사용자만 허용" >> $OUTPUT_FILE 2>&1
            elif [ "$deny_content" = true ]; then
                echo "Deny 파일에 내용 있음, Allow 파일 비어 있음: Deny 목록 사용자 제외, 나머지 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Allow와 Deny 파일 모두 비어 있음: 일반 사용자 사용 불가" >> $OUTPUT_FILE 2>&1
            fi
        elif [ "$allow_exists" = true ]; then
            if [ "$allow_content" = true ]; then
                echo "Allow 파일만 존재 및 내용 있음: Allow 목록 사용자만 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Allow 파일만 존재하나 비어 있음: 일반 사용자 사용 불가" >> $OUTPUT_FILE 2>&1
            fi
        elif [ "$deny_exists" = true ]; then
            if [ "$deny_content" = true ]; then
                echo "Deny 파일만 존재 및 내용 있음: Deny 목록 사용자 제외, 나머지 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Deny 파일만 존재하나 비어 있음: 모든 사용자 허용" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "Allow와 Deny 파일 모두 없음: Root 사용자만 허용" >> $OUTPUT_FILE 2>&1
        fi


        #/etc/cron.allow 내용 확인
        echo "[#cat /etc/cron.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.allow ] ; then
            #파일 내용이 존재하지 않을 경우
            if [ "$(cat /etc/cron.allow | wc -l)" -eq 0 ] ; then
                echo "-/etc/cron.allow 파일에 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/cron.allow >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/etc/cron.deny 내용 확인
        echo "[#cat /etc/cron.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.deny ] ; then
            if [ "$(cat /etc/cron.deny | wc -l)" -eq 0 ] ; then
                echo "-/etc/cron.deny 파일에 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/cron.deny >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/cron.d/cron.allow" "/etc/cron.d/cron.deny"

        allow_exists=false
        deny_exists=false
        allow_content=false
        deny_content=false

        if [ -f /etc/cron.d/cron.allow ]; then
            allow_exists=true
            if [ "$(wc -l < /etc/cron.d/cron.allow)" -ge 1 ]; then
                allow_content=true
            fi
        fi

        if [ -f /etc/cron.d/cron.deny ]; then
            deny_exists=true
            if [ "$(wc -l < /etc/cron.d/cron.deny)" -ge 1 ]; then
                deny_content=true
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[Cron.allow, Cron.deny 파일 확인]" >> $OUTPUT_FILE 2>&1
        if [ "$allow_exists" = true ] && [ "$deny_exists" = true ]; then
            if [ "$allow_content" = true ] && [ "$deny_content" = true ]; then
                echo "Allow와 Deny 파일 모두 존재 및 내용 있음: Allow 목록 사용자만 허용, Deny 목록 사용자 제외" >> $OUTPUT_FILE 2>&1
            elif [ "$allow_content" = true ]; then
                echo "Allow 파일에 내용 있음, Deny 파일 비어 있음: Allow 목록 사용자만 허용" >> $OUTPUT_FILE 2>&1
            elif [ "$deny_content" = true ]; then
                echo "Deny 파일에 내용 있음, Allow 파일 비어 있음: Deny 목록 사용자 제외, 나머지 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Allow와 Deny 파일 모두 비어 있음: 일반 사용자 사용 불가" >> $OUTPUT_FILE 2>&1
            fi
        elif [ "$allow_exists" = true ]; then
            if [ "$allow_content" = true ]; then
                echo "Allow 파일만 존재 및 내용 있음: Allow 목록 사용자만 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Allow 파일만 존재하나 비어 있음: 일반 사용자 사용 불가" >> $OUTPUT_FILE 2>&1
            fi
        elif [ "$deny_exists" = true ]; then
            if [ "$deny_content" = true ]; then
                echo "Deny 파일만 존재 및 내용 있음: Deny 목록 사용자 제외, 나머지 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Deny 파일만 존재하나 비어 있음: 모든 사용자 허용" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "Allow와 Deny 파일 모두 없음: Root 사용자만 허용" >> $OUTPUT_FILE 2>&1
        fi


        #/etc/cron.d/cron.allow 내용 확인
        echo "[#cat /etc/cron.d/cron.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.d/cron.allow ] ; then
            #파일 내용이 존재하지 않을 경우
            if [ "$(cat /etc/cron.d/cron.allow | wc -l)" -eq 0 ] ; then
                echo "-/etc/cron.d/cron.allow 파일에 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/cron.d/cron.allow >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.d/cron.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/etc/cron.d/cron.deny 내용 확인
        echo "[#cat /etc/cron.d/cron.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /etc/cron.d/cron.deny ] ; then
            if [ "$(cat /etc/cron.d/cron.deny | wc -l)" -eq 0 ] ; then
                echo "-/etc/cron.d/cron.deny 파일에 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /etc/cron.d/cron.deny >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/etc/cron.d/cron.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    #AIX, HP-UX
    if [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/var/adm/cron/cron.allow" "/var/adm/cron/cron.deny"

        allow_exists=false
        deny_exists=false
        allow_content=false
        deny_content=false

        if [ -f /var/adm/cron/cron.allow ]; then
            allow_exists=true
            if [ "$(wc -l < /var/adm/cron/cron.allow)" -ge 1 ]; then
                allow_content=true
            fi
        fi

        if [ -f /var/adm/cron/cron.deny ]; then
            deny_exists=true
            if [ "$(wc -l < /var/adm/cron/cron.deny)" -ge 1 ]; then
                deny_content=true
            fi
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[Cron.allow, Cron.deny 파일 확인]" >> $OUTPUT_FILE 2>&1
        if [ "$allow_exists" = true ] && [ "$deny_exists" = true ]; then
            if [ "$allow_content" = true ] && [ "$deny_content" = true ]; then
                echo "Allow와 Deny 파일 모두 존재 및 내용 있음: Allow 목록 사용자만 허용, Deny 목록 사용자 제외" >> $OUTPUT_FILE 2>&1
            elif [ "$allow_content" = true ]; then
                echo "Allow 파일에 내용 있음, Deny 파일 비어 있음: Allow 목록 사용자만 허용" >> $OUTPUT_FILE 2>&1
            elif [ "$deny_content" = true ]; then
                echo "Deny 파일에 내용 있음, Allow 파일 비어 있음: Deny 목록 사용자 제외, 나머지 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Allow와 Deny 파일 모두 비어 있음: 일반 사용자 사용 불가" >> $OUTPUT_FILE 2>&1
            fi
        elif [ "$allow_exists" = true ]; then
            if [ "$allow_content" = true ]; then
                echo "Allow 파일만 존재 및 내용 있음: Allow 목록 사용자만 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Allow 파일만 존재하나 비어 있음: 일반 사용자 사용 불가" >> $OUTPUT_FILE 2>&1
            fi
        elif [ "$deny_exists" = true ]; then
            if [ "$deny_content" = true ]; then
                echo "Deny 파일만 존재 및 내용 있음: Deny 목록 사용자 제외, 나머지 허용" >> $OUTPUT_FILE 2>&1
            else
                echo "Deny 파일만 존재하나 비어 있음: 모든 사용자 허용" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "Allow와 Deny 파일 모두 없음: Root 사용자만 허용" >> $OUTPUT_FILE 2>&1
        fi


        #/var/adm/cron/cron.allow 내용 확인
        echo "[#cat /var/adm/cron/cron.allow]" >> $OUTPUT_FILE 2>&1
        if [ -f /var/adm/cron/cron.allow ] ; then
            #파일 내용이 존재하지 않을 경우
            if [ "$(cat /var/adm/cron/cron.allow | wc -l)" -eq 0 ] ; then
                echo "-/var/adm/cron/cron.allow 파일에 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /var/adm/cron/cron.allow >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/var/adm/cron/cron.allow 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #/var/adm/cron/cron.deny 내용 확인
        echo "[#cat /var/adm/cron/cron.deny]" >> $OUTPUT_FILE 2>&1
        if [ -f /var/adm/cron/cron.deny ] ; then
            if [ "$(cat /var/adm/cron/cron.deny | wc -l)" -eq 0 ] ; then
                echo "-/var/adm/cron/cron.deny 파일에 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            else
                cat /var/adm/cron/cron.deny >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "-/var/adm/cron/cron.deny 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "INCOMPLETE_USER_RESTRICTIONS_FOR_CRON_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-133" 2>&1
}

#U-24,SRV-015
DISABLE_NFS_SERVICE() {
echo "DISABLE_NFS_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-24_SRV-015.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-24_SRV-015_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-24_SRV-015_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        NFS_SERVER_CHECK_01=0
        NFS_CLIENT_CHECK_01=0
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[1) NFS Server Daemon(nfsd)확인]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l)" -gt 0 ] ; then
            NFS_SERVER_CHECK_01=1
            ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        else
            echo "-NFS Server Daemon(nfsd) 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi
        echo "[2) NFS Client Daemon(statd,lockd,biod)확인]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | egrep "statd|lockd|biod " | egrep -v "grep|emi|statdaemon|dsvclockd|kblockd" | grep -v "grep" | wc -l)" -gt 0 ] ; then
            NFS_CLIENT_CHECK_01=1
            ps -ef | egrep "statd|lockd|biod " | egrep -v "grep|emi|statdaemon|dsvclockd|kblockd" | grep -v "grep" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        else
            echo "-NFS Client Daemon(statd,lockd,biod) 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi


        #solaris
        SOLARIS_CHECK_SERVICES "nfs|statd|lockd" "nfs, statd, lockd"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE 2>&1
        fi
        # if command -v inetadm >/dev/null 2>&1; then
        #     if [ "$(inetadm | egrep -i "nfs|statd|lockd" | wc -l)" -gt 0 ]; then
        #         echo "[inetadm 명령어 확인 (inetadm | egrep -i \"nfs|statd|lockd\")]" >> $OUTPUT_FILE 2>&1
        #         inetadm | egrep -i "nfs|statd|lockd" >> $OUTPUT_FILE 2>&1
        #     else
        #         if command -v svcs >/dev/null 2>&1; then
        #             echo "[inetadm 명령어 확인 (inetadm | egrep -i \"nfs|statd|lockd\")]" >> $OUTPUT_FILE 2>&1
        #             echo "-nfs, statd, lockd 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #             echo "" >> $OUTPUT_FILE 2>&1
        #             echo "[svcs 명령어 확인 (svcs -a | egrep -i \"nfs|statd|lockd\")]" >> $OUTPUT_FILE 2>&1
        #             if [ "$(svcs -a | egrep -i "nfs|statd|lockd" | wc -l)" -gt 0 ]; then
        #                 svcs -a | egrep -i "nfs|statd|lockd" >> $OUTPUT_FILE 2>&1
        #             else
        #                 echo "-nfs, statd, lockd 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #             fi
        #         fi
        #     fi
        # else
        #     if command -v svcs >/dev/null 2>&1; then
        #         echo "[svcs 명령어 확인 (svcs -a | egrep -i \"nfs|statd|lockd\")]" >> $OUTPUT_FILE 2>&1
        #         if [ "$(svcs -a | egrep -i "nfs|statd|lockd" | wc -l)" -gt 0 ]; then
        #             svcs -a | egrep -i "nfs|statd|lockd" >> $OUTPUT_FILE 2>&1
        #         else
        #             echo "-nfs, statd, lockd 서비스가 존재하지 않음" >> $OUTPUT_FILE 2>&1
        #         fi
        #     fi
        # fi
        echo "" >> $OUTPUT_FILE 2>&1

        #NFS_SERVER_CHECK_01=1 또는 NFS_CLIENT_CHECK_01=1 경우
        if [ $NFS_SERVER_CHECK_01 -eq 1 ] || [ $NFS_CLIENT_CHECK_01 -eq 1 ] ; then
            echo "---------------" >> $OUTPUT_FILE 2>&1
            echo "[참고]" >> $OUTPUT_FILE 2>&1
            echo "nfsd : NFS 서버데몬, NFS 클라이언트의 요청을 처리" >> $OUTPUT_FILE 2>&1
            echo "biod : NFS 클라이언트 데몬, NFS 요청을 NFS 서버에 보내는 기능" >> $OUTPUT_FILE 2>&1
            echo "mountd : NFS 상에서의 파일시스템 마운트를 위한 서비스 데몬" >> $OUTPUT_FILE 2>&1
            echo "statd : Lockd 데몬과 함께 작동하여 잠금 관리자를 위한 충돌 복구기능 제공" >> $OUTPUT_FILE 2>&1
            echo "lockd : NFS 파일의 레코드 잠금 제공" >> $OUTPUT_FILE 2>&1
            echo "nfslogd : NFS v2/3을 위한 로깅 제공(NFSv4에서는 미사용)" >> $OUTPUT_FILE 2>&1
            echo "---------------" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_NFS_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-24" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-015" 2>&1
}

#U-25
ENFORCE_ACCESS_CONTROLS_FOR_NFS() {
    echo "ENFORCE_ACCESS_CONTROLS_FOR_NFS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-25.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-25_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-25_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/exports"
        NFS_SERVER_CHECK_01=0
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[1) NFS Server Daemon(nfsd)확인]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l)" -gt 0 ] ; then
            NFS_SERVER_CHECK_01=1
            ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        else
            echo "-NFS Server Daemon(nfsd) 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #U-25 양취판단
            SECURITY_STATUS="Y"
        fi

        if [ $NFS_SERVER_CHECK_01 -eq 1 ] ; then
            if [ -f /etc/exports ]; then
                if [ "$(cat /etc/exports | grep -v "#" | wc -l)" -gt 0 ]; then
                    echo "[NFS 서비스 설정파일(/etc/exports) 확인]" >> $OUTPUT_FILE 2>&1
                    cat /etc/exports >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "[NFS 서비스 설정파일(/etc/exports) 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-NFS 서비스 설정파일(/etc/exports)에 설정 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi

        if [ $NFS_SERVER_CHECK_01 -eq 1 ] ; then
            if [ -f /etc/dfs/dfstab ]; then
                echo "[NFS 서비스 설정파일(/etc/dfs/dfstab) 확인]" >> $OUTPUT_FILE 2>&1
                if [ "$(cat /etc/dfs/dfstab | grep -v "#" | wc -l)" -gt 0 ]; then
                    cat /etc/dfs/dfstab >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "[NFS 서비스 설정파일(/etc/dfs/dfstab) 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-NFS 서비스 설정파일(/etc/dfs/dfstab)에 설정 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi

        if [ $NFS_SERVER_CHECK_01 -eq 1 ] ; then
            if [ -f /etc/dfs/sharetab ]; then
                echo "[NFS 서비스 설정파일(/etc/dfs/sharetab) 확인]" >> $OUTPUT_FILE 2>&1
                if [ "$(cat /etc/dfs/sharetab | grep -v "#" | wc -l)" -gt 0 ]; then
                    cat /etc/dfs/sharetab >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "[NFS 서비스 설정파일(/etc/dfs/sharetab) 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-NFS 서비스 설정파일(/etc/dfs/sharetab)에 설정 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi

        # 진단시 불필요하여 주석처리
        # if [ $NFS_SERVER_CHECK_01 -eq 1 ] ; then
        #     if [ -f /etc/fstab ]; then
        #         echo "[NFS 서비스 설정파일(/etc/fstab) 확인]" >> $OUTPUT_FILE 2>&1
        #         if [ "$(cat /etc/fstab | grep -v "#" | wc -l)" -gt 0 ]; then
        #             cat /etc/fstab >> $OUTPUT_FILE 2>&1
        #             echo "" >> $OUTPUT_FILE 2>&1
        #         else
        #             echo "[NFS 서비스 설정파일(/etc/fstab) 확인]" >> $OUTPUT_FILE 2>&1
        #             echo "-NFS 서비스 설정파일(/etc/fstab)에 설정 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
        #             echo "" >> $OUTPUT_FILE 2>&1
        #         fi
        #     fi
        # fi


    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "ENFORCE_ACCESS_CONTROLS_FOR_NFS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-25" 2>&1
}

#U-69
RESTRICT_ACCESS_TO_NFS_CONFIGURATION_FILES() {
echo "RESTRICT_ACCESS_TO_NFS_CONFIGURATION_FILES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-69.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-69_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-69_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        NFS_SERVER_CHECK_01=0
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[1) NFS Server Daemon(nfsd)확인]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l)" -gt 0 ] ; then
            NFS_SERVER_CHECK_01=1
            ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        else
            echo "-NFS Server Daemon(nfsd) 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi

        if [ $NFS_SERVER_CHECK_01 -eq 1 ] ; then
            
            if [ -f /etc/exports ]; then
                echo "[NFS 서비스 설정파일(/etc/exports) 확인]" >> $OUTPUT_FILE 2>&1
                if perm_644 '/etc/exports' ; then
                    if [ "$(ls -al '/etc/exports' | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al '/etc/exports')" >> $OUTPUT_FILE 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE 2>&1
                    else
                        printf "%s" "$(ls -al '/etc/exports')" >> $OUTPUT_FILE 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE 2>&1
                        #U-69 양취판단
                        SECURITY_STATUS="N"
                    fi
                else
                    #U-69 양취판단
                    SECURITY_STATUS="N"
                    if [ "$(ls -al '/etc/exports' | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al '/etc/exports')" >> $OUTPUT_FILE 2>&1
                        echo " (권한취약 권장:644이하)" >> $OUTPUT_FILE 2>&1
                    else
                        printf "%s" "$(ls -al '/etc/exports')" >> $OUTPUT_FILE 2>&1
                        echo " (소유자,권한취약 권장:root,644이하)" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi

            if [ -f /etc/dfs/dfstab ]; then
                echo "[NFS 서비스 설정파일(/etc/dfs/dfstab) 확인]" >> $OUTPUT_FILE 2>&1
                if perm_644 '/etc/dfs/dfstab' ; then
                    if [ "$(ls -al '/etc/dfs/dfstab' | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al '/etc/dfs/dfstab')" >> $OUTPUT_FILE 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE 2>&1
                    else
                        printf "%s" "$(ls -al '/etc/dfs/dfstab')" >> $OUTPUT_FILE 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE 2>&1
                        #U-69 양취판단
                        SECURITY_STATUS="N"
                    fi
                else
                    #U-69 양취판단
                    SECURITY_STATUS="N"
                    if [ "$(ls -al '/etc/dfs/dfstab' | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al '/etc/dfs/dfstab')" >> $OUTPUT_FILE 2>&1
                        echo " (권한취약 권장:644이하)" >> $OUTPUT_FILE 2>&1
                    else
                        printf "%s" "$(ls -al '/etc/dfs/dfstab')" >> $OUTPUT_FILE 2>&1
                        echo " (소유자,권한취약 권장:root,644이하)" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi

        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_ACCESS_TO_NFS_CONFIGURATION_FILES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-69" 2>&1
}

#SRV-014
INCOMPLETE_NFS_ACCESS_CONTROL() {
echo "INCOMPLETE_NFS_ACCESS_CONTROL_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-014.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-014_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-014_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        NFS_SERVER_CHECK_01=0
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[1) NFS Server Daemon(nfsd)확인]" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l)" -gt 0 ] ; then
            NFS_SERVER_CHECK_01=1
            ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        else
            echo "-NFS Server Daemon(nfsd) 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #SRV-014 양취판단
            SECURITY_STATUS="Y"
        fi

        if [ $NFS_SERVER_CHECK_01 -eq 1 ] ; then
            if [ -f /etc/exports ]; then
                echo "[NFS 서비스 설정파일(/etc/exports) 확인]" >> $OUTPUT_FILE 2>&1
                echo "[#cat /etc/exports]" >> $OUTPUT_FILE 2>&1
                if [ "$(cat /etc/exports | grep -v "#")" ]; then
                    cat /etc/exports >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "-NFS 서비스 설정파일(/etc/exports)에 설정 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi

                echo "[#ls -al /etc/exports]" >> $OUTPUT_FILE 2>&1
                if perm_644 '/etc/exports' ; then
                    if [ "$(ls -al '/etc/exports' | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al '/etc/exports')" >> $OUTPUT_FILE 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        printf "%s" "$(ls -al '/etc/exports')" >> $OUTPUT_FILE 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                else
                    if [ "$(ls -al '/etc/exports' | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al '/etc/exports')" >> $OUTPUT_FILE 2>&1
                        echo " (권한취약 권장:644이하)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        printf "%s" "$(ls -al '/etc/exports')" >> $OUTPUT_FILE 2>&1
                        echo " (소유자,권한취약 권장:root,644이하)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi

            if [ -f /etc/dfs/dfstab ]; then
                echo "[NFS 서비스 설정파일(/etc/dfs/dfstab) 확인]" >> $OUTPUT_FILE 2>&1
                echo "[#cat /etc/dfs/dfstab]" >> $OUTPUT_FILE 2>&1
                if [ "$(cat /etc/dfs/dfstab | grep -v "#")" ]; then
                    cat /etc/dfs/dfstab >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "-NFS 서비스 설정파일(/etc/dfs/dfstab)에 설정 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi

                echo "[#ls -al /etc/dfs/dfstab]" >> $OUTPUT_FILE 2>&1
                if perm_644 '/etc/dfs/dfstab' ; then
                    if [ "$(ls -al '/etc/dfs/dfstab' | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al '/etc/dfs/dfstab')" >> $OUTPUT_FILE 2>&1
                        echo " (권한양호)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        printf "%s" "$(ls -al '/etc/dfs/dfstab')" >> $OUTPUT_FILE 2>&1
                        echo " (소유자취약 권장:root)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                else
                    if [ "$(ls -al '/etc/dfs/dfstab' | awk '{print $3}')" = "root" ] ; then
                        printf "%s" "$(ls -al '/etc/dfs/dfstab')" >> $OUTPUT_FILE 2>&1
                        echo " (권한취약 권장:644이하)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        printf "%s" "$(ls -al '/etc/dfs/dfstab')" >> $OUTPUT_FILE 2>&1
                        echo " (소유자,권한취약 권장:root,644이하)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "INCOMPLETE_NFS_ACCESS_CONTROL_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-014" 2>&1
}

#U-26,SRV-034
REMOVE_AUTOMOUNTD() {
echo "REMOVE_AUTOMOUNTD_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-26_SRV-034.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-26_SRV-034_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-26_SRV-034_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[ps -ef | egrep 'automountd|autofs']" >> $OUTPUT_FILE 2>&1
        if [ "$(ps -ef | egrep 'automountd|autofs'  | egrep -v "grep|statdaemon|emi" | wc -l)" -gt 0 ] ; then
            ps -ef | egrep 'automountd|autofs'  | egrep -v "grep|statdaemon|emi" >> $OUTPUT_FILE 2>&1
        else
            echo "-automountd 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
            #U-26,SRV-034 양취판단
            SECURITY_STATUS="Y"
        fi
        SOLARIS_CHECK_SERVICES "autofs" "automountd"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
        fi
        
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "REMOVE_AUTOMOUNTD_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-26" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-034" 2>&1
}

#U-27,SRV-016
CHECK_RPC_SERVICE() {
echo "CHECK_RPC_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-27_SRV-016.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-27_SRV-016_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-27_SRV-016_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE2 2>&1
        RPC_SERVICE_CHECK_01=0
        echo "[/etc/inetd.conf 파일 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -f /etc/inetd.conf ] ; then
            echo "[#cat /etc/inetd.conf | egrep -i \"rpc.cmsd|rpc.ttdbserverd|sadmind|ruserd|walld|sprayd|rstatd|rpc.nisd|rexd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/inetd.conf | egrep -i "rpc.cmsd|rpc.ttdbserverd|sadmind|ruserd|walld|sprayd|rstatd|rpc.nisd|rexd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd" | grep -v "^#" | wc -l)" -eq 0 ]; then
                echo "-불필요한 RPC 서비스가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
            else
                RPC_SERVICE_CHECK_01=1
                if [ $GREP_AB_TMP -gt 0 ]; then
                    cat /etc/inetd.conf | egrep -A 3 -B 5 -i "rpc.cmsd|rpc.ttdbserverd|sadmind|ruserd|walld|sprayd|rstatd|rpc.nisd|rexd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd" | grep -v "^#" >> $OUTPUT_FILE2 2>&1
                else
                    #1:patterns, 2:file, 3:lines_before, 4:lines_after
                    grep_AB_shell "rpc.cmsd|rpc.ttdbserverd|sadmind|ruserd|walld|sprayd|rstatd|rpc.nisd|rexd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd" "/etc/inetd.conf" "5" "3"
                    cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
                fi
            fi
        else
            echo "-/etc/inetd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi
        echo "" >> $OUTPUT_FILE2 2>&1

        echo "[/etc/xinetd.d 확인]" >> $OUTPUT_FILE2 2>&1
        if [ -d /etc/xinetd.d ] && [ "$(ls -A /etc/xinetd.d)" ]; then
            echo "[#ls -alL /etc/xinetd.d]" >> $OUTPUT_FILE3 2>&1
            ls -alL /etc/xinetd.d >> $OUTPUT_FILE3 2>&1
            echo "" >> $OUTPUT_FILE3 2>&1
            echo "[#cat /etc/xinetd.d/* | egrep -i \"rpc.cmsd|rpc.ttdbserverd|sadmind|ruserd|walld|sprayd|rstatd|rpc.nisd|rexd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd\"]" >> $OUTPUT_FILE2 2>&1
            if [ "$(cat /etc/xinetd.d/* | egrep -i "rpc.cmsd|rpc.ttdbserverd|sadmind|ruserd|walld|sprayd|rstatd|rpc.nisd|rexd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd" | grep -v "^#" | wc -l)" -eq 0 ]; then
                echo "-불필요한 RPC 서비스 가 비활성화 되어 있습니다." >> $OUTPUT_FILE2 2>&1
            else
                RPC_SERVICE_CHECK_01=1
                files=$(find "/etc/xinetd.d" -type f 2>/dev/null)
                keyword1="rpc.cmsd rpc.ttdbserverd sadmind ruserd walld sprayd rstatd rpc.nisd rexd rpc.pcnfsd rpc.statd rpc.ypupdated rpc.rquotad kcms_server cachefsd"
                keyword2="disable"
                end_marker="}"
                for file in $files; do
                    for keyword in $keyword1; do
                        section=$(sed -n "/$keyword/,/$end_marker/p" "$file" )
                        if [ "$(echo "$section" | grep -i "$keyword2" | wc -l)" -gt 0 ]; then
                            echo "file:$file, keyword:$keyword" >> $OUTPUT_FILE2 2>&1
                            if [ $SED_TMP -gt 0 ]; then
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/	//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            else
                                echo "$section" | egrep -i "id|$keyword2" | sed -e 's/\s//g' >> $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE2 2>&1
                            fi
                        fi
                    done
                done
            fi
        else
            echo "-/etc/xinetd.d 디렉터리가 존재하지 않거나 디렉터리에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi

        #solaris
        SOLARIS_CHECK_SERVICES "rpc" "RPC"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE2 2>&1
        fi
        
        # if command -v inetadm >/dev/null 2>&1; then
        #     if [ "$(inetadm | egrep -i "ttdbserver|rex|rstat|rusers|spray|wall|rquota" | wc -l)" -gt 0 ]; then
        #         echo "[inetadm 명령어 확인 (inetadm | egrep -i \"ttdbserver|rex|rstat|rusers|spray|wall|rquota\")]" >> $OUTPUT_FILE2 2>&1
        #         inetadm | egrep -i "ttdbserver|rex|rstat|rusers|spray|wall|rquota" >> $OUTPUT_FILE2 2>&1
        #     else
        #         if command -v svcs >/dev/null 2>&1; then
        #             echo "[inetadm 명령어 확인 (inetadm | egrep -i \"ttdbserver|rex|rstat|rusers|spray|wall|rquota\")]" >> $OUTPUT_FILE2 2>&1
        #             echo "-RPC 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #             echo "" >> $OUTPUT_FILE2 2>&1
        #             echo "[svcs 명령어 확인 (svcs -a | egrep -i \"ttdbserver|rex|rstat|rusers|spray|wall|rquota\")]" >> $OUTPUT_FILE2 2>&1
        #             if [ "$(svcs -a | egrep -i "ttdbserver|rex|rstat|rusers|spray|wall|rquota" | wc -l)" -gt 0 ]; then
        #                 svcs -a | egrep -i "ttdbserver|rex|rstat|rusers|spray|wall|rquota" >> $OUTPUT_FILE2 2>&1
        #             else
        #                 echo "-RPC 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #             fi
        #         fi
        #     fi
        # else
        #     if command -v svcs >/dev/null 2>&1; then
        #         echo "[svcs 명령어 확인 (svcs -a | egrep -i \"ttdbserver|rex|rstat|rusers|spray|wall|rquota\")]" >> $OUTPUT_FILE2 2>&1
        #         if [ "$(svcs -a | egrep -i "ttdbserver|rex|rstat|rusers|spray|wall|rquota" | wc -l)" -gt 0 ]; then
        #             svcs -a | egrep -i "ttdbserver|rex|rstat|rusers|spray|wall|rquota" >> $OUTPUT_FILE2 2>&1
        #         else
        #             echo "-RPC 서비스가 존재하지 않음" >> $OUTPUT_FILE2 2>&1
        #         fi
        #     fi
        # fi
        echo "" >> $OUTPUT_FILE2 2>&1

        cat $OUTPUT_FILE2 >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE3" ] ; then
            cat $OUTPUT_FILE3 >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
        #RPC_SERVICE_CHECK_01=1 인경우
        if [ $RPC_SERVICE_CHECK_01 -eq 1 ] ; then
            echo "---------------" >> $OUTPUT_FILE 2>&1
            echo "[참고]" >> $OUTPUT_FILE2 2>&1
            echo "rpc.cmsd: 네트워크 달력 관리 서비스 제공, 일정 관리 기능 지원." >> $OUTPUT_FILE2 2>&1
            echo "rpc.ttdbserverd: ToolTalk 서비스의 일부로 응용 프로그램 간 통신 및 정보 교환 관리." >> $OUTPUT_FILE2 2>&1
            echo "sadmind: Solaris 운영 체제의 Solstice AdminSuite 소프트웨어에 사용되는 관리 데몬." >> $OUTPUT_FILE2 2>&1
            echo "ruserd: 네트워크상의 다른 시스템에 로그인한 사용자 정보 제공." >> $OUTPUT_FILE2 2>&1
            echo "walld: 네트워크상의 모든 사용자에게 메시지 전송 서비스 제공." >> $OUTPUT_FILE2 2>&1
            echo "sprayd: 네트워크 성능 테스트를 위한 대량의 네트워크 트래픽 생성." >> $OUTPUT_FILE2 2>&1
            echo "rstatd: 원격 시스템의 성능 통계 제공." >> $OUTPUT_FILE2 2>&1
            echo "rpc.nisd: 중앙 집중식 사용자 및 호스트 정보 관리 및 공유." >> $OUTPUT_FILE2 2>&1
            echo "rexd: 네트워크를 통한 원격 커맨드 실행 지원." >> $OUTPUT_FILE2 2>&1
            echo "rpc.pcnfsd: NFS 클라이언트와 서버 간의 파일 공유 지원." >> $OUTPUT_FILE2 2>&1
            echo "rpc.statd: NFS 락 상태와 관련된 정보 관리 및 모니터링." >> $OUTPUT_FILE2 2>&1
            echo "rpc.ypupdated: NIS 또는 NIS+ 데이터베이스의 정보 변경 및 업데이트." >> $OUTPUT_FILE2 2>&1
            echo "rpc.rquotad: 네트워크 파일 시스템 사용자의 디스크 할당량 정보 관리." >> $OUTPUT_FILE2 2>&1
            echo "kcms_server: 색상 관리 시스템을 위한 서버로 이미지의 색상 정확도 유지." >> $OUTPUT_FILE2 2>&1
            echo "cachefsd: 캐시된 파일 시스템 관리 및 네트워크 성능 최적화." >> $OUTPUT_FILE2 2>&1
            echo "---------------" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHECK_RPC_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-27" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-016" 2>&1
}

#U-30,SRV-007
CHECK_SENDMAIL_VERSION() {
    echo "CHECK_SENDMAIL_VERSION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-30_SRV-007.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-30_SRV-007_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-30_SRV-007_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $SMTP_CHECK_01 = 1 ] ; then
            #sendmail
            if ps -ef | grep -i "sendmail" | grep -v "grep" > /dev/null; then
                echo "[sendmail_버전확인]" >> $OUTPUT_FILE 2>&1
                for file in $SENDMAIL_PATH; do
                    echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                    cat $file | grep -i "DZ" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                done
            fi

            #postfix
            if ps -ef | grep -i "postfix" | grep -v "grep" > /dev/null; then
                echo "[postfix_버전확인]" >> $OUTPUT_FILE 2>&1
                if command -v postconf >/dev/null 2>&1; then
                    postconf -d mail_version >> $OUTPUT_FILE 2>&1
                else
                    if [ -f /usr/sbin/postconf ]; then
                        /usr/sbin/postconf -d mail_version >> $OUTPUT_FILE 2>&1
                    else
                        echo "-postconf 명령어가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi

            #exim
            if ps -ef | grep -i "exim" | grep -v "grep" > /dev/null; then
                echo "[exim_버전확인]" >> $OUTPUT_FILE 2>&1
                if command -v exim >/dev/null 2>&1; then
                    exim -bV >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    if [ -f /usr/sbin/exim ]; then
                        /usr/sbin/exim -bV >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        echo "-exim 명령어가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi
        else
            #U-30,SRV-007 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHECK_SENDMAIL_VERSION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-30" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-007" 2>&1
}

#U-31,SRV-009
RESTRICT_SPAM_MAIL_RELAY() {
    echo "RESTRICT_SPAM_MAIL_RELAY_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-31_SRV-009.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-31_SRV-009_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-31_SRV-009_REF02.hangrp"
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-31_SRV-009_REF03.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $SMTP_CHECK_01 = 1 ] ; then

            #sendmail
            if ps -ef | grep -i "sendmail" | grep -v "grep" > /dev/null; then
                echo "[sendmail_버전확인]" >> $OUTPUT_FILE 2>&1
        
                for file in $SENDMAIL_PATH; do
                    if [ -f "$file" ]; then
                        cat $file | grep -i "DZ" >> $OUTPUT_FILE4 2>&1
                    fi
                done

                if [ -f "$OUTPUT_FILE4" ] ; then
                    cat $OUTPUT_FILE4 >> $OUTPUT_FILE 2>&1
                    else
                    echo "-sendmail설정파일(sendmail.cf)에서 버전 정보가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1

                if [ -n "$SENDMAIL_PATH" ]; then
                    for file in $SENDMAIL_PATH; do
                        if grep -i "Relaying denied" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 3 "Relaying denied" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "Relaying denied" "$file" "0" "3"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-Relaying denied 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[sendmail.cf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-sendmail설정파일(sendmail.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #postfix
            if ps -ef | grep -i "postfix" | grep -v "grep" > /dev/null; then
                if [ -n "$POSTFIX_PATH" ]; then
                    for file in $POSTFIX_PATH; do
                        if egrep -i "smtpd_recipient_restrictions|smtpd_relay_restrictions" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                egrep -i -A 3 "smtpd_recipient_restrictions|smtpd_relay_restrictions" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "smtpd_recipient_restrictions|smtpd_relay_restrictions" "$file" "0" "3"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-smtpd_recipient_restrictions 또는 smtpd_relay_restrictions 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[postfix설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-postfix설정파일(main.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
    
            #exim
            if ps -ef | grep -i "exim" | grep -v "grep" > /dev/null; then
                if [ -n "$EXIM_PATH" ]; then
                    for file in $EXIM_PATH; do
                        if grep -i "acl_smtp_rcpt" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            cat "$file" | grep -i "acl_smtp_rcpt" | grep -v "#" >> $OUTPUT_FILE 2>&1
                            cat "$file" | grep -i "MAIN_ACL_CHECK_RCPT" | grep -v "#" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                cat "$file" | grep -i -A 7 "acl_check_rcpt:" | grep -v "#" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "acl_check_rcpt:" "$file" "0" "7"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-acl_smtp_rcpt 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[EXIM 설정 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-exim설정파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        else
            #U-31,SRV-009 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_SPAM_MAIL_RELAY_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-31" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-009" 2>&1
}

#U-32,SRV-010
PREVENT_SENDMAIL_EXECUTION_BY_REGULAR_USERS() {
    echo "PREVENT_SENDMAIL_EXECUTION_BY_REGULAR_USERS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-32_SRV-010.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-32_SRV-010_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-32_SRV-010_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $SMTP_CHECK_01 = 1 ] ; then

            #sendmail
            if ps -ef | grep -i "sendmail" | grep -v "grep" > /dev/null; then
                if [ -n "$SENDMAIL_PATH" ]; then
                    for file in $SENDMAIL_PATH; do
                        if grep -i "PrivacyOptions" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "PrivacyOptions" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-PrivacyOptions 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[sendmail.cf 파일 권한 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-sendmail설정파일(sendmail.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi


            #postfix
            if ps -ef | grep -i "postfix" | grep -v "grep" > /dev/null; then
                if [ -n "$POSTFIX_POSTUPER_PATH" ]; then
                    echo "[postsuper 파일 권한 확인]" >> $OUTPUT_FILE 2>&1
                    for file in $POSTFIX_POSTUPER_PATH; do
                        if ls -alLd "$file" | awk '{print $1}' | grep -q ".x"; then
                            echo "[#ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                            ls -alLd "$file" >> $OUTPUT_FILE 2>&1
                            echo "-other에 실행권한이 존재" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[#ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                            ls -alLd "$file" >> $OUTPUT_FILE 2>&1 >> $OUTPUT_FILE 2>&1
                            
                        fi
                    done
                else
                    echo "[postsuper 파일 권한 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-postsuper파일(postsuper)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #exim
            if ps -ef | grep -i "exim" | grep -v "grep" > /dev/null; then
                if [ -n "$EXIM_EXECUTE_PATH" ]; then
                    echo "[EXIM 실행파일 권한 확인]" >> $OUTPUT_FILE 2>&1
                    for file in $EXIM_EXECUTE_PATH; do
                        if ls -alLd "$file" | awk '{print $1}' | grep -q ".x"; then
                            echo "[#ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                            ls -alLd "$file" >> $OUTPUT_FILE 2>&1
                            echo "-other에 실행권한이 존재" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[#ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                            ls -alLd "$file" >> $OUTPUT_FILE 2>&1 >> $OUTPUT_FILE 2>&1
                            
                        fi
                    done
                else
                    echo "[EXIM 실행파일 권한 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-EXIM 실행파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        else
            #U-32,SRV-010 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PREVENT_SENDMAIL_EXECUTION_BY_REGULAR_USERS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-32" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-010" 2>&1
}
#U-70,SRV-005
RESTRICT_EXPN_AND_VRFY_COMMANDS() {
    echo "RESTRICT_EXPN_AND_VRFY_COMMANDS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-70_SRV-005.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-70_SRV-005_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-70_SRV-005_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $SMTP_CHECK_01 = 1 ] ; then
            #sendmail
            if ps -ef | grep -i "sendmail" | grep -v "grep" > /dev/null; then
                if [ -n "$SENDMAIL_PATH" ]; then
                    for file in $SENDMAIL_PATH; do
                        if egrep -i "noexpn|novrfy|goaway" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            egrep -i "noexpn|novrfy|goaway" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            egrep -i "PrivacyOptions" "$file" >> $OUTPUT_FILE 2>&1
                            echo "-noexpn과 novrfy 또는 goaway의 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[sendmail.cf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-sendmail설정파일(sendmail.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #postfix
            if ps -ef | grep -i "postfix" | grep -v "grep" > /dev/null; then
                if [ -n "$POSTFIX_PATH" ]; then
                    for file in $POSTFIX_PATH; do
                        if grep -i "disable_vrfy_command" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 3 "disable_vrfy_command" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "disable_vrfy_command" "$file" "0" "3"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                            
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-disable_vrfy_command 설정이 존재하지 않습니다.(default : no,권장 : yes)" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[postfix설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-postfix설정파일(main.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #exim
            if ps -ef | grep -i "exim" | grep -v "grep" > /dev/null; then
                if [ -n "$EXIM_PATH" ]; then
                    for file in $EXIM_PATH; do
                        if egrep -i "acl_smtp_expn|acl_smtp_vrfy" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                egrep -i -A 2 "acl_smtp_expn|acl_smtp_vrfy" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "acl_smtp_expn|acl_smtp_vrfy" "$file" "0" "2"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-acl_smtp_expn, acl_smtp_vrfy 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            echo "(설정 존재하지 않을 시 기본 거부)" >> $OUTPUT_FILE 2>&1
                            echo "(※https://www.exim.org/exim-html-current/doc/html/spec_html/ch-access_control_lists.html)" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[EXIM 설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-exim설정파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        else
            #U-70,SRV-005 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_EXPN_AND_VRFY_COMMANDS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-70" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-005" 2>&1
}

#SRV-004
DISABLE_UNNECESSARY_SMTP_SERVICES() {
    echo "DISABLE_UNNECESSARY_SMTP_SERVICES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-004.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        if [ $SMTP_CHECK_01 = 0 ] ; then
            #SRV-004 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_UNNECESSARY_SMTP_SERVICES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-004" 2>&1
}
#SRV-006
IMPROVE_LOG_LEVEL_FOR_SMTP_SERVICE() {
    echo "IMPROVE_LOG_LEVEL_FOR_SMTP_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-006.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-006_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-006_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $SMTP_CHECK_01 = 1 ] ; then
            #sendmail
            if ps -ef | grep -i "sendmail" | grep -v "grep" > /dev/null; then
                if [ -n "$SENDMAIL_PATH" ]; then
                    for file in $SENDMAIL_PATH; do
                        if grep -i "LogLevel" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "LogLevel" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-LogLevel 설정값이 존재하지 않음(default:9)" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[sendmail.cf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-sendmail설정 파일(sendmail.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi


            #postfix
            if ps -ef | grep -i "postfix" | grep -v "grep" > /dev/null; then
                if [ -n "$POSTFIX_PATH" ]; then
                    for file in $POSTFIX_PATH; do
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        #message_size_limit
                        if grep -i "debug_peer_level" "$file" | grep -q .; then
                            grep -i "debug_peer_level" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "debug_peer_level 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[postfix설정 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-postfix설정 파일(main.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #exim
            if ps -ef | grep -i "exim" | grep -v "grep" > /dev/null; then
               if [ -n "$EXIM_PATH" ]; then
                    for file in $EXIM_PATH; do
                        if grep -i "log_level" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 2 "log_level" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "log_level" "$file" "0" "2"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                            
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-log_level 설정값이 존재하지 않음(default:5)" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[EXIM 설정 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-exim설정 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        else
            #SRV-006 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "IMPROVE_LOG_LEVEL_FOR_SMTP_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-006" 2>&1
}

#SRV-008
CONFIGURE_DOS_PREVENTION_FOR_SMTP_SERVICE() {
    echo "CONFIGURE_DOS_PREVENTION_FOR_SMTP_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-008.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-008_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-008_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $SMTP_CHECK_01 = 1 ] ; then

            #sendmail
            if ps -ef | grep -i "sendmail" | grep -v "grep" > /dev/null; then
                if [ -n "$SENDMAIL_PATH" ]; then
                    for file in $SENDMAIL_PATH; do
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        #MaxDaemonChildren
                        if grep -i "MaxDaemonChildren" "$file" | grep -q .; then
                            grep -i "MaxDaemonChildren" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "MaxDaemonChildren 설정값이 존재하지 않음" >> $OUTPUT_FILE 2>&1
                        fi
                        #ConnectionRateThrottle
                        if grep -i "ConnectionRateThrottle" "$file" | grep -q .; then
                            grep -i "ConnectionRateThrottle" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "ConnectionRateThrottle 설정값이 존재하지 않음" >> $OUTPUT_FILE 2>&1
                        fi
                        #MinFreeBlocks
                        if grep -i "MinFreeBlocks" "$file" | grep -q .; then
                            grep -i "MinFreeBlocks" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "MinFreeBlocks 설정값이 존재하지 않음" >> $OUTPUT_FILE 2>&1
                        fi
                        #MaxHeadersLength
                        if grep -i "MaxHeadersLength" "$file" | grep -q .; then
                            grep -i "MaxHeadersLength" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "MaxHeadersLength 설정값이 존재하지 않음" >> $OUTPUT_FILE 2>&1
                        fi
                        #MaxMessageSize
                        if grep -i "MaxMessageSize" "$file" | grep -q .; then
                            grep -i "MaxMessageSize" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "MaxMessageSize 설정값이 존재하지 않음" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[sendmail.cf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-sendmail설정파일(sendmail.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #postfix
            if ps -ef | grep -i "postfix" | grep -v "grep" > /dev/null; then
                if [ -n "$POSTFIX_PATH" ]; then
                    for file in $POSTFIX_PATH; do
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        #message_size_limit
                        if grep -i "message_size_limit" "$file" | grep -q .; then
                            grep -i "message_size_limit" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "message_size_limit 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                        #header_size_limit
                        if grep -i "header_size_limit" "$file" | grep -q .; then
                            grep -i "header_size_limit" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "header_size_limit 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                        #default_process_limit
                        if grep -i "default_process_limit" "$file" | grep -q .; then
                            grep -i "default_process_limit" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "default_process_limit 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                        #local_destination_concurrency_limit
                        if grep -i "local_destination_concurrency_limit" "$file" | grep -q .; then
                            grep -i "local_destination_concurrency_limit" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "local_destination_concurrency_limit 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                        #smtpd_recipient_limit
                        if grep -i "smtpd_recipient_limit" "$file" | grep -q .; then
                            grep -i "smtpd_recipient_limit" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "smtpd_recipient_limit 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[postfix설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-postfix설정파일(main.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #exim
            if ps -ef | grep -i "exim" | grep -v "grep" > /dev/null; then
               if [ -n "$EXIM_PATH" ]; then
                    for file in $EXIM_PATH; do
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        #message_size_limit
                        if grep -i "message_size_limit" "$file" | grep -q .; then
                            grep -i "message_size_limit" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "message_size_limit 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                        #header_maxsize
                        if grep -i "header_maxsize" "$file" | grep -q .; then
                            grep -i "header_maxsize" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "header_maxsize 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                        #queue_run_max
                        if grep -i "queue_run_max" "$file" | grep -q .; then
                            grep -i "queue_run_max" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "queue_run_max 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                        #recipients_max
                        if grep -i "recipients_max" "$file" | grep -q .; then
                            grep -i "recipients_max" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "recipients_max 설정값이 존재하지 않음(default 설정되어 있음)" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[EXIM 설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-exim설정파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        else
            #SRV-008 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CONFIGURE_DOS_PREVENTION_FOR_SMTP_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-008" 2>&1
}
#SRV-170
PROTECT_SENSITIVE_INFORMATION_IN_SMTP_SERVICE() {
    echo "PROTECT_SENSITIVE_INFORMATION_IN_SMTP_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-170.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-170_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-170_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/smtpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $SMTP_CHECK_01 = 1 ] ; then
            #sendmail
            if ps -ef | grep -i "sendmail" | grep -v "grep" > /dev/null; then
                if [ -n "$SENDMAIL_PATH" ]; then
                    for file in $SENDMAIL_PATH; do
                        if grep -i "SmtpGreetingMessage" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "SmtpGreetingMessage" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-SmtpGreetingMessage의 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[sendmail.cf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-sendmail설정파일(sendmail.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #postfix
            if ps -ef | grep -i "postfix" | grep -v "grep" > /dev/null; then
                if [ -n "$POSTFIX_PATH" ]; then
                    for file in $POSTFIX_PATH; do
                        if grep -i "smtpd_banner" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 3 "smtpd_banner" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "smtpd_banner" "$file" "0" "3"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                            
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-smtpd_banner 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[postfix설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-postfix설정파일(main.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #exim
            if ps -ef | grep -i "exim" | grep -v "grep" > /dev/null; then
                if [ -n "$EXIM_PATH" ]; then
                    for file in $EXIM_PATH; do
                        if grep -i "smtp_banner" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 2 "smtp_banner" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "smtp_banner" "$file" "0" "2"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                            
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-smtp_banner 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[EXIM 설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-exim설정파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        else
            #SRV-170 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PROTECT_SENSITIVE_INFORMATION_IN_SMTP_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-170" 2>&1
}
#U-33,SRV-064
APPLY_SECURITY_PATCHES_TO_DNS_VERSION() {
    echo "APPLY_SECURITY_PATCHES_TO_DNS_VERSION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-33_SRV_064.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-33_SRV_064_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-33_SRV_064_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"  >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $DNS_CHECK_01 = 1 ] ; then
            FILE_COPY "/etc/named.conf" "/etc/bind/named.conf.options" "/etc/bind/named.conf" "/etc/bind/named.conf.default-zones" "/etc/bind/named.conf.local"
            #bind
            echo "[named_버전확인]" >> $OUTPUT_FILE 2>&1
            if named -v >/dev/null 2>&1; then
                named -v  2>/dev/null >> $OUTPUT_FILE 2>&1
            else
                if [ -f /usr/sbin/named ]; then
                    if /usr/sbin/named -v >/dev/null 2>&1; then
                        /usr/sbin/named -v  2>/dev/null >> $OUTPUT_FILE 2>&1
                    else
                        #HP-UX
                        if command -v what > /dev/null; then
                            what $(which named) 2>/dev/null >> $OUTPUT_FILE 2>&1
                        fi
                    fi
                else
                    echo "-named 실행파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
            fi
        else
            #U-33,SRV-064 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "APPLY_SECURITY_PATCHES_TO_DNS_VERSION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-33" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-064" 2>&1
}
#U-34,SRV-066
CONFIGURE_DNS_ZONE_TRANSFER_SETTINGS() {
    echo "CONFIGURE_DNS_ZONE_TRANSFER_SETTINGS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-34_SRV-066.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-34_SRV-066_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-34_SRV-066_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"  >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $DNS_CHECK_01 = 1 ] ; then
                if [ -n "$DNS_PATH" ]; then
                    for file in $DNS_PATH; do
                        echo "[allow-transfer 확인]" >> $OUTPUT_FILE 2>&1
                        if grep -i "allow-transfer" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "allow-transfer" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-allow-transfer 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                        echo "[xfrnets 확인]" >> $OUTPUT_FILE 2>&1
                        if grep -i "xfrnets" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "xfrnets" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-xfrnets 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                    if [ -s /etc/named.boot ]; then
                        if grep -i "xfrnets" "/etc/named.boot" | grep -q .; then
                            echo "[# cat \"/etc/named.boot\"]" >> $OUTPUT_FILE 2>&1
                            grep -i "xfrnets" "/etc/named.boot" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat \"/etc/named.boot\"]" >> $OUTPUT_FILE 2>&1
                            echo "-xfrnets 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    fi
                else
                    echo "[bind설정파일(named.conf) 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-bind설정파일(named.conf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
        else
            #U-34,SRV-066 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CONFIGURE_DNS_ZONE_TRANSFER_SETTINGS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-34" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-066" 2>&1
}

#SRV-062
PROTECT_SENSITIVE_INFORMATION_IN_DNS_SERVICE() {
    echo "PROTECT_SENSITIVE_INFORMATION_IN_DNS_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-062.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-062_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-062_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"  >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $DNS_CHECK_01 = 1 ] ; then
                if [ -n "$DNS_PATH" ]; then
                    for file in $DNS_PATH; do
                        echo "[version 옵션 확인]" >> $OUTPUT_FILE 2>&1
                        if grep -i "version" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "version" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-version 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[bind설정파일(named.conf) 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-bind설정파일(named.conf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
        else
            #SRV-062 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PROTECT_SENSITIVE_INFORMATION_IN_DNS_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-062" 2>&1
}

#SRV-063
IMPROVE_RECURSIVE_QUERY_CONFIGURATION_FOR_DNS() {
    echo "IMPROVE_RECURSIVE_QUERY_CONFIGURATION_FOR_DNS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-063.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-063_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-063_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"  >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $DNS_CHECK_01 = 1 ] ; then
                if [ -n "$DNS_PATH" ]; then
                    for file in $DNS_PATH; do
                        echo "[recursion 옵션 확인]" >> $OUTPUT_FILE 2>&1
                        if grep -i "recursion" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "recursion" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-recursion 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[bind설정파일(named.conf) 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-bind설정파일(named.conf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
        else
            #SRV-063 양취판단
            SECURITY_STATUS="Y"            
        fi
    fi
    ##############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "IMPROVE_RECURSIVE_QUERY_CONFIGURATION_FOR_DNS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-063" 2>&1
}

#SRV-173
CONFIGURE_SECURE_DYNAMIC_UPDATES_FOR_DNS_SERVICE() {
    echo "CONFIGURE_SECURE_DYNAMIC_UPDATES_FOR_DNS_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-173.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-173_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-173_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"  >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        if [ $DNS_CHECK_01 = 1 ] ; then
                if [ -n "$DNS_PATH" ]; then
                    for file in $DNS_PATH; do
                        echo "[allow-update 확인]" >> $OUTPUT_FILE 2>&1
                        if grep -i "allow-update" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "allow-update" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-allow-update 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                        echo "[update-policy 확인]" >> $OUTPUT_FILE 2>&1
                        if grep -i "update-policy" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "update-policy" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-update-policy 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done

                else
                    echo "[bind설정파일(named.conf) 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-bind설정파일(named.conf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
        else
            #SRV-173 양취판단
            SECURITY_STATUS="Y"            
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CONFIGURE_SECURE_DYNAMIC_UPDATES_FOR_DNS_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-173" 2>&1
}

#SRV-174
DISABLE_UNNECESSARY_DNS_SERVICES() {
    echo "DISABLE_UNNECESSARY_DNS_SERVICES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-174.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-174_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-174_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/dnscheck.hangrp"  >> $OUTPUT_FILE 2>&1
        if [ $DNS_CHECK_01 = 0 ] ; then
            #SRV-174 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_UNNECESSARY_DNS_SERVICES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-174" 2>&1
}

#U-60,SRV-158
ENABLE_SSH_REMOTE_ACCESS() {
    echo "ENABLE_SSH_REMOTE_ACCESS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-60_SRV-158.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-60_SRV-158_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-60_SRV-158_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then

       #1 사용 2미사용
        #텔넷사용여부
        TELNET_CHECK_01=0
        #sshd사용여부
        SSHD_CHECK_01=0

        #TLENT 포트 여부 확인
        if command -v netstat >/dev/null 2>&1; then
            TELNET_COMMAND_TMP_001=$(netstat -an | awk '/[.:]23 /')
            if [ -n "$TELNET_COMMAND_TMP_001" ]; then
                #사용
                TELNET_CHECK_01=1
            else
                #미사용
                TELNET_CHECK_01=0
            fi
        else
            if command -v ss >/dev/null 2>&1; then
                TELNET_COMMAND_TMP_001=$(ss -an | awk '/[.:]23 /')
                if [ -n "$TELNET_COMMAND_TMP_001" ]; then
                    #사용
                    TELNET_CHECK_01=1
                else
                    #미사용
                    TELNET_CHECK_01=0
                fi
            fi
        fi

        #SSHD 포트 여부 확인
        if command -v netstat >/dev/null 2>&1; then
            SSHD_COMMAND_TMP_001=$(netstat -an | awk '/[.:]22 /')
            if [ -n "$SSHD_COMMAND_TMP_001" ]; then
                #사용
                SSHD_CHECK_01=1
            else
                #미사용
                SSHD_CHECK_01=1
            fi
        else
            if command -v ss >/dev/null 2>&1; then
                SSHD_COMMAND_TMP_001=$(ss -an | awk '/[.:]22 /')
                if [ -n "$SSHD_COMMAND_TMP_001" ]; then
                    #사용
                    SSHD_CHECK_01=1
                else
                    #미사용
                    SSHD_CHECK_01=1
                fi
            fi
        fi

        SOLARIS_CHECK_SERVICES "telnet" "telnet"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE 2>&1
        fi
        SOLARIS_CHECK_SERVICES "ssh" "SSH"
        if [ -f "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" ] ; then
            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/solaris_service_check_tmp.hangrp" >> $OUTPUT_FILE 2>&1
        fi
        
        echo "[서비스 상태 확인]"   >> $OUTPUT_FILE 2>&1
        if [ "$TELNET_CHECK_01" = 1 ]; then
            #U-60,SRV-158 양취판단
            SECURITY_STATUS="N"
            echo "-Telnet: 활성화(23포트LISTEN)" >> $OUTPUT_FILE 2>&1
            if [ -n "$TELNET_COMMAND_TMP_001" ]; then
                echo "(# netstat -an | awk '/[.:]23 /')" >> $OUTPUT_FILE 2>&1
                echo "$TELNET_COMMAND_TMP_001" >> $OUTPUT_FILE 2>&1
            fi
        else
            #U-60,SRV-158 양취판단
            SECURITY_STATUS="Y"
            echo "-Telnet: 비활성화" >> $OUTPUT_FILE 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "ENABLE_SSH_REMOTE_ACCESS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-60" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-158" 2>&1
}

#U-66,SRV-147
CHECK_SNMP_SERVICE_STATUS() {
    echo "CHECK_SNMP_SERVICE_STATUS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-66_SRV-147.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-66_SRV-147_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-66_SRV-147_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        if [ $SNMP_CHECK_01 = 0 ] ; then
            #U-66,SRV-147 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHECK_SNMP_SERVICE_STATUS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-66" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-147" 2>&1
}

#U-67
CONFIGURE_COMPLEXITY_FOR_SNMP_COMMUNITY_STRINGS() {
    echo "CONFIGURE_COMPLEXITY_FOR_SNMP_COMMUNITY_STRINGS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-67.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-67.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-67.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1
        
        if [ $SNMP_CHECK_01 = 1 ] ; then
            if [ -n "$SNMP_PATH" ]; then
                for file in $SNMP_PATH; do
                    if egrep -i "community|com2sec" "$file" | grep -v "#" | grep -q .; then
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        egrep -i "community|com2sec" "$file" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    else
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        echo "-Community 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    fi
                done
                for file in $SNMP_PATH; do
                    if egrep -i "createUser" "$file" | grep -v "#" | grep -q .; then
                        echo "[# cat $file (SNMP V3 사용 중)]" >> $OUTPUT_FILE 2>&1
                        egrep -i "createUser" "$file" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    fi
                done
            else
                echo "[SNMP 설정파일(snmpd.conf) 확인]" >> $OUTPUT_FILE 2>&1
                echo "-snmp설정파일(snmpd.conf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        else
            #U-67 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CONFIGURE_COMPLEXITY_FOR_SNMP_COMMUNITY_STRINGS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-67" 2>&1
}

#SRV-163
F_PROVIDE_LOGIN_WARNING_MESSAGE() {
    echo "F_PROVIDE_LOGIN_WARNING_MESSAGE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-163.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-163.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-163_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then

        #/etc/motd가 존재하지 않으면 /run/motd, /run/motd가 존재하지 않으면 /usr/lib/motd
        if [ -f "/etc/motd" ]; then
            MOTD_PATH="/etc/motd"
            FILE_COPY "/etc/motd"
        else
            if [ -f "/run/motd" ]; then
                MOTD_PATH="/run/motd"
                FILE_COPY "/run/motd"
            else
                MOTD_PATH="/usr/lib/motd"
                FILE_COPY "/usr/lib/motd"
            fi
        fi


        #/etc/motd.d/, /run/motd.d/, /usr/lib/motd.d/
        if [ -d "/etc/motd.d/" ] || [ -d "/run/motd.d/" ] || [ -d "/usr/lib/motd.d/" ]; then
            MOTD_PATH_01=$(find /etc/motd.d/ /run/motd.d/ /usr/lib/motd.d/ -type f)
                for MOTD_PATH_02 in $MOTD_PATH_01; do
                    FILE_COPY "$MOTD_PATH_02"
                done
        fi

        if [ -f "/etc/issue.net" ]; then
            ISSUE_1_PATH="/etc/issue.net"
        fi

        if [ -f "/etc/issue" ]; then
            ISSUE_2_PATH="/etc/issue"
        fi

        if [ -z "$ISSUE_1_PATH" ] && [ -z "$ISSUE_2_PATH" ]; then
            ISSUE_0_PATH=$(find /etc/ -type f -name "issue*")
        fi

        BANNER_PATH="$MOTD_PATH $ISSUE_0_PATH $ISSUE_1_PATH $ISSUE_2_PATH $SSH_CONFIG_PATH /usr/lib/motd.d/30-banner"

        for file in $BANNER_PATH; do
            if [ -f "$file" ]; then
                # 파일이 존재할 경우의 처리
                # 파일명이 sshd_config 인 경우
                if echo "$file" | grep -qi "sshd_config"; then
                    if grep -i "Banner" "$file" | grep -v "#" | grep -q .; then
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        grep -i "Banner" "$file" | grep -v "#" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        echo "-Banner 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                fi

                # 파일명이 motd 또는 issue 인 경우
                if echo "$file" | grep -qi "motd" || echo "$file" | grep -qi "issue"; then
                    echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                    cat "$file" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            else
                # 파일이 존재하지 않을 경우의 처리
                echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                echo "-파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        done


    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "F_PROVIDE_LOGIN_WARNING_MESSAGE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-163" 2>&1
}
#U-68
I_PROVIDE_LOGIN_WARNING_MESSAGE() {
    echo "I_PROVIDE_LOGIN_WARNING_MESSAGE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-68.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-68.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-68.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then

        #/etc/motd가 존재하지 않으면 /run/motd, /run/motd가 존재하지 않으면 /usr/lib/motd
        if [ -f "/etc/motd" ]; then
            MOTD_PATH="/etc/motd"
            FILE_COPY "/etc/motd"
        else
            if [ -f "/run/motd" ]; then
                MOTD_PATH="/run/motd"
                FILE_COPY "/run/motd"
            else
                MOTD_PATH="/usr/lib/motd"
                FILE_COPY "/usr/lib/motd"
            fi
        fi


        #/etc/motd.d/, /run/motd.d/, /usr/lib/motd.d/
        if [ -d "/etc/motd.d/" ] || [ -d "/run/motd.d/" ] || [ -d "/usr/lib/motd.d/" ]; then
            MOTD_PATH_01=$(find /etc/motd.d/ /run/motd.d/ /usr/lib/motd.d/ -type f)
                for MOTD_PATH_02 in $MOTD_PATH_01; do
                    FILE_COPY "$MOTD_PATH_02"
                done
        fi

        if [ -f "/etc/issue.net" ]; then
            ISSUE_1_PATH="/etc/issue.net"
        fi

        if [ -f "/etc/issue" ]; then
            ISSUE_2_PATH="/etc/issue"
        fi

        if [ -z "$ISSUE_1_PATH" ] && [ -z "$ISSUE_2_PATH" ]; then
            ISSUE_0_PATH=$(find /etc/ -type f -name "issue*")
        fi

        BANNER_PATH="$MOTD_PATH $ISSUE_0_PATH $ISSUE_1_PATH $ISSUE_2_PATH $SSH_CONFIG_PATH /usr/lib/motd.d/30-banner"

        for file in $BANNER_PATH; do
            if [ -f "$file" ]; then
                # 파일이 존재할 경우의 처리
                # 파일명이 sshd_config 인 경우
                if echo "$file" | grep -qi "sshd_config"; then
                    if grep -i "Banner" "$file" | grep -v "#" | grep -q .; then
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        grep -i "Banner" "$file" | grep -v "#" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        echo "-Banner 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi
                fi

                # 파일명이 motd 또는 issue 인 경우
                if echo "$file" | grep -qi "motd" || echo "$file" | grep -qi "issue"; then
                    echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                    cat "$file" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            else
                # 파일이 존재하지 않을 경우의 처리
                echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                echo "-파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        done

        if [ $FTP_CHECK_01 = 1 ] ; then
            FILE_COPY "/etc/ftpd/ftpaccess" "/etc/default/ftpd"
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[FTP 배너 확인]" >> $OUTPUT_FILE 2>&1
            #"[배너 확인-일반FTP는 통상적으로 배너가 존재하지 않음]"

            #solaris
            if [ -f /etc/ftpd/ftpaccess ]; then
                if [ "$(cat /etc/ftpd/ftpaccess | egrep -i "greeting" | grep -v "#" | wc -l)" -gt 0 ]; then
                    echo "[#cat /etc/ftpd/ftpaccess | egrep -i \"greeting\"]" >> $OUTPUT_FILE 2>&1
                    cat /etc/ftpd/ftpaccess | egrep -i "greeting" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "-/etc/ftpd/ftpaccess 파일에 greeting 관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            if [ -f /etc/default/ftpd ]; then
                if [ "$(cat /etc/default/ftpd | egrep -i "BANNER" | grep -v "#" | wc -l)" -gt 0 ]; then
                    echo "[#cat /etc/default/ftpd | egrep -i \"BANNER\"]" >> $OUTPUT_FILE 2>&1
                    cat /etc/default/ftpd | egrep -i "BANNER" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "-/etc/default/ftpd 파일에 BANNER 관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi

            #vsftp
            if ps -ef | grep -i "vsftp" | grep -v "grep" > /dev/null; then
                if [ -n "$VSFTPD_PATH" ]; then
                    for file in $VSFTPD_PATH; do
                        if grep -i "banner" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 1 -B 1 "banner" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "banner" "$file" "2" "2"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "vsftpd.conf 파일에서 banner  관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[vsftpd.conf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-vsftpd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
            fi

            #proftp
            if ps -ef | grep -i "proftp" | grep -v "grep" > /dev/null; then
                if [ -n "$PROFTPD_PATH" ]; then
                    for file in $PROFTPD_PATH; do
                        #ServerIdent 구문
                        if grep -i "ServerIdent" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 1 -B 1 "ServerIdent" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "ServerIdent" "$file" "1" "1"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "-proftpd.conf 파일에서 ServerIdent 관련 내용이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[proftpd.conf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-proftpd.conf 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi


        if [ $SMTP_CHECK_01 = 1 ] ; then
            #sendmail
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[SMTP 배너 확인]" >> $OUTPUT_FILE 2>&1
            if ps -ef | grep -i "sendmail" | grep -v "grep" > /dev/null; then
                if [ -n "$SENDMAIL_PATH" ]; then
                    for file in $SENDMAIL_PATH; do
                        if grep -i "SmtpGreetingMessage" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            grep -i "SmtpGreetingMessage" "$file" >> $OUTPUT_FILE 2>&1
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-SmtpGreetingMessage의 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[sendmail.cf 파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-sendmail설정파일(sendmail.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #postfix
            if ps -ef | grep -i "postfix" | grep -v "grep" > /dev/null; then
                if [ -n "$POSTFIX_PATH" ]; then
                    for file in $POSTFIX_PATH; do
                        if grep -i "smtpd_banner" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 3 "smtpd_banner" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "smtpd_banner" "$file" "0" "3"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-smtpd_banner 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[postfix설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-postfix설정파일(main.cf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi

            #exim
            if ps -ef | grep -i "exim" | grep -v "grep" > /dev/null; then
                if [ -n "$EXIM_PATH" ]; then
                    for file in $EXIM_PATH; do
                        if grep -i "smtp_banner" $file | grep -q .; then
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                grep -i -A 2 "smtp_banner" "$file" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "smtp_banner" "$file" "0" "2"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                            echo "-smtp_banner 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    done
                else
                    echo "[EXIM 설정파일 확인]" >> $OUTPUT_FILE 2>&1
                    echo "-exim설정파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        fi

        if [ $DNS_CHECK_01 = 1 ] ; then
            echo "[DNS 버전 조회 여부 확인]" >> $OUTPUT_FILE 2>&1
            if [ -n "$DNS_PATH" ]; then
                for file in $DNS_PATH; do
                    echo "[version 옵션 확인]" >> $OUTPUT_FILE 2>&1
                    if grep -i "version" $file | grep -q .; then
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        grep -i "version" "$file" >> $OUTPUT_FILE 2>&1
                    else
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        echo "-version 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    fi
                done
            else
                echo "[bind설정파일(named.conf) 확인]" >> $OUTPUT_FILE 2>&1
                echo "-bind설정파일(named.conf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        fi

    fi

    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "I_PROVIDE_LOGIN_WARNING_MESSAGE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-68" 2>&1
}
#U-42,SRV-118
APPLY_LATEST_SECURITY_PATCHES_AND_VENDOR_RECOMMENDATIONS() {
    echo "APPLY_LATEST_SECURITY_PATCHES_AND_VENDOR_RECOMMENDATIONS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-42_SRV-118.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        if [ -f "/etc/os-release" ]; then
            echo "o version(/etc/os-release) o"  >> $OUTPUT_FILE 2>&1
            echo "`cat /etc/os-release| grep -i VERSION 2>/dev/null`" >> $OUTPUT_FILE 2>&1
        fi

        if [ -f "/proc/version" ]; then
            echo "o version(/proc/version) o" >> $OUTPUT_FILE 2>&1
            echo "`cat /proc/version 2>/dev/null`" >> $OUTPUT_FILE 2>&1
        fi
        if command -v uname >/dev/null 2>&1; then
            echo "o version(uname -a) o" >> $OUTPUT_FILE 2>&1
            echo "`uname -a 2>/dev/null`" >> $OUTPUT_FILE 2>&1
        fi
        if command -v lsb_release >/dev/null 2>&1; then
            echo "o version(lsb_release -a) o" >> $OUTPUT_FILE 2>&1
            echo "`lsb_release -a 2>/dev/null`" >> $OUTPUT_FILE 2>&1
        fi

        echo "커널 영향받는 버전 : knvd.krcert.or.kr/detailSecNo.do?IDX=6150" >> $OUTPUT_FILE 2>&1


        echo "" >> $OUTPUT_FILE 2>&1
        echo "[패키지 파일 버전 확인]" >> $OUTPUT_FILE 2>&1
        if command -v ssh >/dev/null 2>&1; then
            echo ">oepnssh 버전확인(ssh -V)<" >> $OUTPUT_FILE 2>&1
            ssh -V >> $OUTPUT_FILE 2>&1
            echo "영향받는버전 : 4.4p1 이전버전,  8.5p1부터 9.7p1까지(이전은 포함되지 않음)" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi
        if command -v xz >/dev/null 2>&1; then
            echo ">xz 버전확인(xz --version)<" >> $OUTPUT_FILE 2>&1
            xz --version >> $OUTPUT_FILE 2>&1
            echo "영향받는버전 :  5.6.0 및 5.6.1" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi

        echo "그외 엑셀 셀 입력 제한으로 인하여 스크립트 결과값 참조./SECURITY_INSPECTION_TEMP/$(hostname)+${HOST_IP}+LATEST_PATCHES_FILE.hangrp" >> $OUTPUT_FILE 2>&1
        
        #AIX
        if command -v lslpp >/dev/null 2>&1; then
            echo "[lslpp -h]" >> $CHECK_LATEST_PATCHES_FILE 2>&1
            lslpp -h >> $CHECK_LATEST_PATCHES_FILE 2>&1
            echo "" >> $CHECK_LATEST_PATCHES_FILE 2>&1
        fi

        #Linux
        if command -v rpm >/dev/null 2>&1; then
            echo "[rpm -qa -i]" >> $CHECK_LATEST_PATCHES_FILE 2>&1
            rpm -qa -i >> $CHECK_LATEST_PATCHES_FILE 2>&1
            echo "" >> $CHECK_LATEST_PATCHES_FILE 2>&1
        fi
        #Linux
        if command -v dpkg >/dev/null 2>&1; then
            echo "[dpkg -l]" >> $CHECK_LATEST_PATCHES_FILE 2>&1
            dpkg -l | col -b >> $CHECK_LATEST_PATCHES_FILE 2>&1
            echo "" >> $CHECK_LATEST_PATCHES_FILE 2>&1
        fi
        #Solaris
        if command -v pkginfo >/dev/null 2>&1; then
            echo "[pkginfo -l]" >> $CHECK_LATEST_PATCHES_FILE 2>&1
            pkginfo -l >> $CHECK_LATEST_PATCHES_FILE 2>&1
        fi
        #HP-UX 
        if command -v swlist >/dev/null 2>&1; then
            echo "[swlist]" >> $CHECK_LATEST_PATCHES_FILE 2>&1
            swlist >> $CHECK_LATEST_PATCHES_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "APPLY_LATEST_SECURITY_PATCHES_AND_VENDOR_RECOMMENDATIONS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-42" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-118" 2>&1
}

#U-43,SRV-115
PERFORM_REGULAR_LOG_REVIEW_AND_REPORTING() {
    echo "PERFORM_REGULAR_LOG_REVIEW_AND_REPORTING_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-43_SRV-115.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "[로그 기록에 대해 정기적 검토, 분석, 보고서 작성 및 보고 등의 절차를 수행 확인 필요]" >> $OUTPUT_FILE 2>&1
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PERFORM_REGULAR_LOG_REVIEW_AND_REPORTING_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-43" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-115" 2>&1
}

#U-72,SRV-109
CONFIGURE_SYSTEM_LOGGING_PER_POLICY() {
    echo "CONFIGURE_SYSTEM_LOGGING_PER_POLICY_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-72_SRV-109.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-72_SRV-109_REF01.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        LOG_CONF_FILES="/etc/syslog.conf /etc/rsyslog.conf"

        # solaris
        if [ -f "/etc/default/su" ]; then
            if [ "$(cat /etc/default/su | grep -i "log" | grep -v "#")" ] ; then
                echo "[/etc/default/su 파일 내용 확인(cat /etc/default/su | grep -i \"log\")]" >> $OUTPUT_FILE 2>&1
                cat /etc/default/su | grep -i "log" | grep -v "#" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            else
                if [ "$(cat /etc/default/su | grep -i "log")" ] ; then
                    echo "[/etc/default/su 파일 내용 확인(cat /etc/default/su | grep -i \"log\")]" >> $OUTPUT_FILE 2>&1
                    cat /etc/default/su | grep -i "log" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "[/etc/default/su 파일 내용 확인(cat /etc/default/su | grep -i \"log\")]" >> $OUTPUT_FILE 2>&1
                    echo "-/etc/default/su 파일에 log 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        fi


        printf "로그 정책 정보:\n" >> $OUTPUT_FILE
        for conf_file in $LOG_CONF_FILES; do
            if [ -f "$conf_file" ]; then
                echo "로그 구성 파일 경로 : $conf_file" >> $OUTPUT_FILE
                echo "로그 구성 파일의 내용:" >> $OUTPUT_FILE
                cat "$conf_file" | grep -v "^\s*#" | grep "/" >> $OUTPUT_FILE
                if [ $GREP_AB_TMP -gt 0 ]; then
                    CONF_LOG_FILES=$(cat "$conf_file" | grep -v "^\s*#" | grep -oP '(?<=\s)-?/\S+' | sed 's/^-//')
                else
                    CONF_LOG_FILES=$(grep -v "^[[:space:]]*#" "$conf_file" | awk '{for (i = 1; i <= NF; i++) if ($i ~ /^\//) print $i}' | sed 's/[\/,]$//')
                fi
                for log_file in $CONF_LOG_FILES; do
                    echo $log_file >> $OUTPUT_FILE2
                done

                printf "=====================================\n" >> $OUTPUT_FILE
                break
            fi
        done


        if [ -f "$OUTPUT_FILE2" ]; then
            LOG_FILES=$(cat $OUTPUT_FILE2 | sort | uniq)
        fi
        
        for log_file in $LOG_FILES; do
            if [ -f "$log_file" ] && [ -s $log_file ]; then
                FILE_COPY "$log_file"
                
                echo "로그파일 경로: $log_file" >> $OUTPUT_FILE
                echo "로그파일의 상세정보:" >> $OUTPUT_FILE
                ls -al "$log_file" >> $OUTPUT_FILE
                echo "로그 파일의 내용:" >> $OUTPUT_FILE

                # 최신 로그만 출력, 최대 10줄
                TAIL_TMP=$(tail -n 10 "$log_file" 2>/dev/null | wc -l)
                if [ $TAIL_TMP -gt 0 ]; then
                    tail -n 10 "$log_file" >> $OUTPUT_FILE
                else
                    tail -10 "$log_file" >> $OUTPUT_FILE
                fi
                

                # 로그 파일을 새 디렉터리에 저장
                #cat "$log_file" >> "${CREATE_FILE_DIR}/log/$(basename $log_file .log).hangrp"

                printf "=====================================\n" >> $OUTPUT_FILE
            fi
        done

        # /var/log 디렉터리가 존재할 경우
        if [ -d "/var/log" ]; then
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[/var/log 디렉터리의 파일 목록]" >> $OUTPUT_FILE
            ls -al /var/log | grep -v ^d >> $OUTPUT_FILE
            echo "" >> $OUTPUT_FILE
        fi

    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CONFIGURE_SYSTEM_LOGGING_PER_POLICY_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-72" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-109" 2>&1
}

#SRV-012
PROTECT_SENSITIVE_INFORMATION_IN_NETRC_FILE() {
    echo "PROTECT_SENSITIVE_INFORMATION_IN_NETRC_FILE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-012.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-012_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-012_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        ACCOUNTS=$(awk -F':' '{print $1":"$6}' /etc/passwd)
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            HOME_DIR=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)

            NETRC_PATH="$HOME_DIR/.netrc"
            if [ -f "$NETRC_PATH" ]; then
                echo "[# cat $NETRC_PATH]" >> $OUTPUT_FILE2 2>&1
                cat "$NETRC_PATH" >> $OUTPUT_FILE2 2>&1
                echo "" >> $OUTPUT_FILE2 2>&1
            fi
        done

        echo "" >> $OUTPUT_FILE 2>&1
        echo "[.netrc 파일 확인]" >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE2" ]; then
            cat "$OUTPUT_FILE2" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        else
            echo "-.netrc 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            #SRV-163 양취판단
            SECURITY_STATUS="Y"
            echo "" >> $OUTPUT_FILE 2>&1
        fi

    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "PROTECT_SENSITIVE_INFORMATION_IN_NETRC_FILE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-012" 2>&1
}

#SRV-022
MANAGE_UNSET_PASSWORDS_AND_EMPTY_PASSWORDS_FOR_ACCOUNTS() {
    echo "MANAGE_UNSET_PASSWORDS_AND_EMPTY_PASSWORDS_FOR_ACCOUNTS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-022.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-022_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-022_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ]; then
        #/etc/shadow를 통한 계정 빈 암호 확인
        EMPTY_PASSWORD_ACCOUNTS=$(awk -F':' '($2 == "" ) { print $1 }' /etc/shadow)
        PATTERN_EMPTY_PASSWORD_ACCOUNTS=$(echo $EMPTY_PASSWORD_ACCOUNTS | tr ' ' '|')
        if [ -n "$EMPTY_PASSWORD_ACCOUNTS" ]; then
            echo "[/etc/shadow를 통한 계정 빈 암호 확인]" >> $OUTPUT_FILE 2>&1
            egrep "$PATTERN_EMPTY_PASSWORD_ACCOUNTS" /etc/shadow >> $OUTPUT_FILE 2>&1
        else
            echo "[/etc/shadow를 통한 계정 빈 암호 확인]" >> $OUTPUT_FILE 2>&1
            echo "-빈 암호를 가진 계정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            #SRV-022 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    ###############################
    #AIX
    if [ $AIX_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/security/login.cfg" "/etc/security/passwd"
        
        # ACCOUNTS=$(awk -F':' '{ if ($7 == "/bin/sh" || $7 == "/usr/bin/sh" || $7 == "/bin/bash" || $7 == "/usr/bin/bash" || $7 == "/bin/rbash" || $7 == "/usr/bin/rbash" || $7 == "/bin/dash" || $7 == "/usr/bin/dash" || $7 == "/usr/bin/ksh" || $7 == "/bin/csh" || $7 == "/bin/tcsh" || $7 == "/bin/zsh" || $7 == "/usr/bin/zsh" || $7 == "/usr/xpg4/bin/sh" || $7 == "/usr/sunos/bin/sh" || $7 == "/usr/local/bin/bash" || $7 == "/sbin/sh" || $7 == "/usr/sbin/sh" || $7 == "/sbin/bash" || $7 == "/usr/sbin/bash" || $7 == "/sbin/rbash" || $7 == "/usr/sbin/rbash" || $7 == "/sbin/dash" || $7 == "/usr/sbin/dash" || $7 == "/usr/sbin/ksh" || $7 == "/sbin/csh" || $7 == "/sbin/tcsh" || $7 == "/sbin/zsh" || $7 == "/usr/sbin/zsh") print $1":"$7}' /etc/passwd)        

        ACCOUNTS=$(awk -F':' '
            $2 != "!" && $7 != "" && $7 !~ /nologin/ && $7 !~ /false/ && $1 !~ /^(shutdown|sync|halt)$/ {
                print $1":"$7
            }
        ' /etc/passwd)


        echo "[계정별 비밀번호 알고리즘 확인 (# cat /etc/security/passwd)]" >> $OUTPUT_FILE 2>&1
        for ACCOUNT_INFO in $ACCOUNTS; do
            USERNAME=$(echo "$ACCOUNT_INFO" | cut -d':' -f1)
            SHELL_INFO=$(echo "$ACCOUNT_INFO" | cut -d':' -f2)
            files="/etc/security/passwd"
            keyword1="$USERNAME:"
            keyword2="password"
            end_marker=":"
            section=$(sed -n "/$keyword1/,/$end_marker/p" "$files" )
            
            #비밀번호가 존재하는 계정(password = * 가 아닌 계정)만 확인
            if [ "$(echo "$section" | grep -i "password =" | grep -v "password = \*" | wc -l)" -gt 0 ] ; then
                echo "[계정명 : $USERNAME (쉘: $SHELL_INFO )]"  >> $OUTPUT_FILE 2>&1
                if [ $SED_TMP -gt 0 ]; then
                    passwordACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/	//g')
                else
                    passwordACCOUNT_INFO=$(echo "$section" | egrep -i "$keyword2" | sed -e 's/\s//g')
                fi
                if [ -n "$passwordACCOUNT_INFO" ]; then
                    echo "$passwordACCOUNT_INFO"  >> $OUTPUT_FILE 2>&1
                fi
                echo ""  >> $OUTPUT_FILE 2>&1
            fi
        done

    fi
    ###############################
    ###############################
    #HP-UX
    if [ $HP_CHECK_00 -eq 1 ]; then
        #/etc/shadow를 통한 계정 빈 암호 확인
        if [ -f "/etc/shadow" ]; then
            EMPTY_PASSWORD_ACCOUNTS=$(awk -F':' '($2 == "!" ) { print $1 }' /etc/shadow)
            PATTERN_EMPTY_PASSWORD_ACCOUNTS=$(echo $EMPTY_PASSWORD_ACCOUNTS | tr ' ' '|')
            if [ -n "$EMPTY_PASSWORD_ACCOUNTS" ]; then
                echo "[/etc/shadow를 통한 계정 빈 암호 확인]" >> $OUTPUT_FILE 2>&1
                egrep "$PATTERN_EMPTY_PASSWORD_ACCOUNTS" /etc/shadow >> $OUTPUT_FILE 2>&1
            else
                echo "[/etc/shadow를 통한 계정 빈 암호 확인]" >> $OUTPUT_FILE 2>&1
                echo "-빈 암호를 가진 계정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                #SRV-022 양취판단
                SECURITY_STATUS="Y"
            fi
        else
            # /etc/passwd 확인
            if [ -f "/etc/passwd" ]; then
                echo "[/etc/passwd 확인]" >> $OUTPUT_FILE 2>&1
                cat /etc/passwd >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "MANAGE_UNSET_PASSWORDS_AND_EMPTY_PASSWORDS_FOR_ACCOUNTS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-022" 2>&1
}

#SRV-082
IMPROVE_PERMISSIONS_FOR_SYSTEM_CRITICAL_DIRECTORIES() {
    echo "IMPROVE_PERMISSIONS_FOR_SYSTEM_CRITICAL_DIRECTORIES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-082.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-082_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-082_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        DIR_CHECK="/usr /bin /sbin /etc /var"
        echo "" >> $OUTPUT_FILE 2>&1
        echo "[디렉토리 권한 확인]" >> $OUTPUT_FILE 2>&1
        for dir in $DIR_CHECK; do
            if [ -d $dir ]; then
                if perm_775 $dir ; then
                    echo "$(ls -alLd "$dir")" >> $OUTPUT_FILE 2>&1
                else
                    printf "%s" "$(ls -alLd "$dir")" >> $OUTPUT_FILE 2>&1
                    echo " (other 쓰기 존재)" >> $OUTPUT_FILE 2>&1
                fi
            else
                #SRV-082 양취판단
                SECURITY_STATUS="N"
                echo "-$dir 디렉토리가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi
        done
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "IMPROVE_PERMISSIONS_FOR_SYSTEM_CRITICAL_DIRECTORIES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-082" 2>&1
}

#SRV-083
IMPROVE_PERMISSIONS_FOR_SYSTEM_STARTUP_SCRIPTS() {
    echo "IMPROVE_PERMISSIONS_FOR_SYSTEM_STARTUP_SCRIPTS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-083.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-083_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-083_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        START_SCRIPT_PATH=$(find /etc/ -type f -name "rc.*" 2>/dev/null)
        if [ -n "$START_SCRIPT_PATH" ]; then
            for file in $START_SCRIPT_PATH; do
                if perm_775 $file ; then
                    echo "[# ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                    ls -alLd "$file" >> $OUTPUT_FILE 2>&1
                else
                    echo "[# ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                    printf "%s" "$(ls -alLd "$file")" >> "$OUTPUT_FILE" 2>&1
                    echo "(other 쓰기 존재)" >> $OUTPUT_FILE 2>&1
                    #SRV-083 양취판단
                    SECURITY_STATUS="N"
                fi
            done
        else
            echo "[시작 스크립트 파일 확인]" >> $OUTPUT_FILE 2>&1
            echo "-시작 스크립트 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            #SRV-083 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        START_SCRIPT_PATH=$(ls -al /sbin/rc* | awk '/\/rc[0-9S]$/ {print $9}' 2>/dev/null)
        if [ -n "$START_SCRIPT_PATH" ]; then
            for file in $START_SCRIPT_PATH; do
                if perm_775 $file ; then
                    echo "[# ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                    ls -alLd "$file" >> $OUTPUT_FILE 2>&1
                else
                    echo "[# ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                    printf "%s" "$(ls -alLd "$file")" >> "$OUTPUT_FILE" 2>&1
                    echo "(other 쓰기 존재)" >> $OUTPUT_FILE 2>&1
                    #SRV-083 양취판단
                    SECURITY_STATUS="N"
                fi
            done
        else
            echo "[시작 스크립트 파일 확인]" >> $OUTPUT_FILE 2>&1
            echo "-시작 스크립트 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            #SRV-083 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    ###############################
    #AIX, HP-UX
    if [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        START_SCRIPT_PATH=$(find /etc/rc*.d -type f 2>/dev/null)
        if [ -n "$START_SCRIPT_PATH" ]; then
            for file in $START_SCRIPT_PATH; do
                if perm_775 $file ; then
                    echo "[# ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                    ls -alLd "$file" >> $OUTPUT_FILE 2>&1
                else
                    echo "[# ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                    printf "%s" "$(ls -alLd "$file")" >> "$OUTPUT_FILE" 2>&1
                    echo "(other 쓰기 존재)" >> $OUTPUT_FILE 2>&1
                    #SRV-083 양취판단
                    SECURITY_STATUS="N"
                fi
            done
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[참고]" >> $OUTPUT_FILE 2>&1
            echo "일반적으로 root 사용자에 의해 실행되지만 외부에서 처리되는 경우가 있으므로 벤더사를 통하여 검토 후 조치가 필요함" >> $OUTPUT_FILE 2>&1
        else
            echo "[시작 스크립트 파일 확인]" >> $OUTPUT_FILE 2>&1
            echo "-시작 스크립트 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            #SRV-083 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "IMPROVE_PERMISSIONS_FOR_SYSTEM_STARTUP_SCRIPTS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-083" 2>&1

}

#SRV-087
IMPROVE_PERMISSIONS_FOR_C_COMPILER() {
    echo "IMPROVE_PERMISSIONS_FOR_C_COMPILER_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-087.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-087_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-087_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        C_COMPILER_PATH=$(which gcc 2>/dev/null| egrep -v "no|not"; which cc 2>/dev/null| egrep -v "no|not")
        if [ -n "$C_COMPILER_PATH" ]; then
            for file in $C_COMPILER_PATH; do
                if perm_776 $file ; then
                    echo "[# ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                    ls -alLd "$file" >> $OUTPUT_FILE 2>&1
                else
                    echo "[# ls -alLd $file]" >> $OUTPUT_FILE 2>&1
                    printf "%s" "$(ls -alLd "$file")" >> $OUTPUT_FILE 2>&1
                    echo "(other 실행 존재)" >> $OUTPUT_FILE 2>&1
                    #SRV-087 양취판단
                    SECURITY_STATUS="N"
                fi
            done
        else
            echo "[C 컴파일러 파일 확인]" >> $OUTPUT_FILE 2>&1
            echo "-C 컴파일러 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            #SRV-087 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "IMPROVE_PERMISSIONS_FOR_C_COMPILER_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-087" 2>&1
}

#SRV-108
IMPROVE_ACCESS_CONTROL_AND_MANAGEMENT_FOR_LOGS() {
    echo "IMPROVE_ACCESS_CONTROL_AND_MANAGEMENT_FOR_LOGS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-108.hangrp"
    #양호
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-108_REF01.hangrp"
    #취약
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-108_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열
    if [ $Linux_CHECK_00 -eq 1 ]; then
        #VAR_LOG_PATH=$(find /var/log/ -type f -not -name 'wtmp' -not -name 'btmp' -not -name 'lastlog')
        VAR_LOG_PATH=$(find /var/log/ -type f 2>/dev/null | egrep -v 'wtmp|btmp|lastlog')
        if [ -n "$VAR_LOG_PATH" ]; then
            for file in $VAR_LOG_PATH; do
                if perm_644 $file ; then
                    ls -alLd "$file" >> $OUTPUT_FILE2 2>&1
                else
                    printf "%s" "$(ls -alLd "$file")" >> $OUTPUT_FILE3 2>&1
                    echo "(권한취약 권장:644이하)" >> $OUTPUT_FILE3 2>&1
                fi
            done
        else
            echo "-/var/log/에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi
        echo "" >> $OUTPUT_FILE 2>&1

        if [ -f "$OUTPUT_FILE3" ]; then
            echo "[취약한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE3" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[#ls -al /var/log/]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE2" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #SRV-108 양취판단
            SECURITY_STATUS="N"
        else
            echo "[#ls -al /var/log/]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE2" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            #SRV-108 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        VAR_LOG_PATH=$(find /var/log/ -type f 2>/dev/null | egrep -v 'wtmp|btmp|lastlog')
        if [ -n "$VAR_LOG_PATH" ]; then
            for file in $VAR_LOG_PATH; do
                if perm_644 $file ; then
                    ls -alLd "$file" >> $OUTPUT_FILE2 2>&1
                else
                    printf "%s" "$(ls -alLd "$file")" >> $OUTPUT_FILE3 2>&1
                    echo "(권한취약 권장:644이하)" >> $OUTPUT_FILE3 2>&1
                fi
            done
        else
            echo "[/var/log/ 디렉터리 확인]" >> $OUTPUT_FILE2 2>&1
            echo "-/var/log/에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi
        
        VAR_LOG_PATH=$(find /var/adm/ -type f 2>/dev/null | egrep -v 'wtmp|btmp|lastlog')
        if [ -n "$VAR_LOG_PATH" ]; then
            for file in $VAR_LOG_PATH; do
                if perm_644 $file ; then
                    ls -alLd "$file" >> $OUTPUT_FILE2 2>&1
                else
                    printf "%s" "$(ls -alLd "$file")" >> $OUTPUT_FILE3 2>&1
                    echo "(권한취약 권장:644이하)" >> $OUTPUT_FILE3 2>&1
                fi
            done
        else
            echo "[/var/adm/ 디렉터리 확인]" >> $OUTPUT_FILE2 2>&1
            echo "-/var/adm/에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi

        if [ -f "$OUTPUT_FILE3" ]; then
            echo "[취약한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE3" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[#ls -al /var/log/ /var/adm/]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE2" >> $OUTPUT_FILE 2>&1
            #SRV-108 양취판단
            SECURITY_STATUS="N"
        else
            echo "[#ls -al /var/log/ /var/adm/]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE2" >> $OUTPUT_FILE 2>&1
            #SRV-108 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    ###############################
    #AIX, HP-UX
    if [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        VAR_LOG_PATH=$(find /var/adm/ -type f -name "*log*" 2>/dev/null | egrep -v 'wtmp|btmp|lastlog')
        if [ -n "$VAR_LOG_PATH" ]; then
            for file in $VAR_LOG_PATH; do
                if perm_644 $file ; then
                    ls -alLd "$file" >> $OUTPUT_FILE2 2>&1
                else
                    printf "%s" "$(ls -alLd "$file")" >> $OUTPUT_FILE3 2>&1
                    echo "(권한취약 권장:644이하)" >> $OUTPUT_FILE3 2>&1
                fi
            done
        else
            echo "[/var/adm/ 디렉터리 확인]" >> $OUTPUT_FILE2 2>&1
            echo "-/var/adm/에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
            echo "" >> $OUTPUT_FILE2 2>&1
        fi

        #AIX 해당사항
        if [ $AIX_CHECK_00 -eq 1 ]; then
            VAR_LOG_PATH=$(find /etc/security/ -type f -name "*log*" 2>/dev/null  |egrep -v 'wtmp|btmp|lastlog|login|logo|alog')
            if [ -n "$VAR_LOG_PATH" ]; then
                for file in $VAR_LOG_PATH; do
                    if perm_644 $file ; then
                        ls -alLd "$file" >> $OUTPUT_FILE2 2>&1
                    else
                        printf "%s" "$(ls -alLd "$file")" >> $OUTPUT_FILE3 2>&1
                        echo "(권한취약 권장:644이하)" >> $OUTPUT_FILE3 2>&1
                    fi
                done
            else
                echo "[/etc/security/ 디렉터리 확인]" >> $OUTPUT_FILE2 2>&1
                echo "-/etc/security/ 에 로그파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
            fi
        fi

        VAR_LOG_PATH=$(find /etc/utmp/ -type f 2>/dev/null | egrep -v 'wtmp|btmp|lastlog')
        if [ -n "$VAR_LOG_PATH" ]; then
            for file in $VAR_LOG_PATH; do
                if perm_644 $file ; then
                    ls -alLd "$file" >> $OUTPUT_FILE2 2>&1
                else
                    printf "%s" "$(ls -alLd "$file")" >> $OUTPUT_FILE3 2>&1
                    echo "(권한취약 권장:644이하)" >> $OUTPUT_FILE3 2>&1
                fi
            done
        else
            echo "[/etc/utmp/ 디렉터리 확인]" >> $OUTPUT_FILE2 2>&1
            echo "-/etc/utmp/ 에 파일이 존재하지 않습니다." >> $OUTPUT_FILE2 2>&1
        fi

        if [ -f "$OUTPUT_FILE3" ]; then
            echo "[취약한 권한을 가진 파일]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE3" >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
            echo "[#ls -al 로그디렉터리]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE2" >> $OUTPUT_FILE 2>&1
            #SRV-108 양취판단
            SECURITY_STATUS="N"
        else
            echo "[#ls -al 로그디렉터리]" >> $OUTPUT_FILE 2>&1
            cat "$OUTPUT_FILE2" >> $OUTPUT_FILE 2>&1
            #SRV-108 양취판단
            SECURITY_STATUS="Y"
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "IMPROVE_ACCESS_CONTROL_AND_MANAGEMENT_FOR_LOGS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-108" 2>&1
}
#SRV-134
ENABLE_EXECUTION_PREVENTION_FOR_STACK_REGION() {
    echo "ENABLE_EXECUTION_PREVENTION_FOR_STACK_REGION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-134.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "-SOLARIS항목 해당사항 없음" >> $OUTPUT_FILE 2>&1
        #SRV-134 양취판단
        SECURITY_STATUS="N/A"
    fi
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/system"

        # solaris 10 이하
        if [ -f "/etc/system" ]; then
            if [ "$(cat /etc/system | grep -i "noexec_user_stack" | grep -v "#")" ] ; then
                echo "[/etc/system 파일 내용 확인(cat /etc/system | grep -i \"noexec_user_stack\")]" >> $OUTPUT_FILE 2>&1
                cat /etc/system | grep -i "noexec_user_stack" | grep -v "#" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            else
                if [ "$(cat /etc/system | grep -i "noexec_user_stack")" ] ; then
                    echo "[/etc/system 파일 내용 확인(cat /etc/system | grep -i \"noexec_user_stack\")]" >> $OUTPUT_FILE 2>&1
                    cat /etc/system | grep -i "noexec_user_stack" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "[/etc/system 파일 내용 확인(cat /etc/system | grep -i \"noexec_user_stack\")]" >> $OUTPUT_FILE 2>&1
                    echo "-/etc/system 파일에 noexec_user_stack 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
        else
            # solaris 11 이상(nxstack enable 확인)
            if command -v sxadm >/dev/null 2>&1; then
                if [ "$(sxadm status | grep -i "nxstack" | grep -v "disabled")" ] ; then
                    echo "[# sxadm status | grep -i \"nxstack\"]" >> $OUTPUT_FILE 2>&1
                    sxadm status | grep -i "nxstack" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                else
                    echo "[# sxadm status | grep -i \"nxstack\"]" >> $OUTPUT_FILE 2>&1
                    sxadm status | grep -i "nxstack" >> $OUTPUT_FILE 2>&1
                    echo "-nxstack이 비활성화 되어 있습니다." >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            else
                echo "[/etc/system 파일 내용 확인(cat /etc/system | grep -i \"noexec_user_stack\")]" >> $OUTPUT_FILE 2>&1
                echo "-/etc/system 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "[# sxadm status | grep -i \"nxstack\"]" >> $OUTPUT_FILE 2>&1
                echo "-sxadm 명령어가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "ENABLE_EXECUTION_PREVENTION_FOR_STACK_REGION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-134" 2>&1
}

#SRV-135
IMPROVE_TCP_SECURITY_SETTINGS() {
    echo "IMPROVE_TCP_SECURITY_SETTINGS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-135.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "-SOLARIS항목 해당사항 없음" >> $OUTPUT_FILE 2>&1
        #SRV-135 양취판단
        SECURITY_STATUS="N/A"
    fi
    ###############################
    ###############################
    #Solaris 계열
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        FILE_COPY "/etc/default/inetinit"

        if [ -f "/etc/default/inetinit" ]; then
            if [ "$(cat /etc/default/inetinit | grep -i "tcp_strong_iss")" ] ; then
                echo "[/etc/default/inetinit 파일 내용 확인(cat /etc/default/inetinit | grep -i \"tcp_strong_iss\")]" >> $OUTPUT_FILE 2>&1
                cat /etc/default/inetinit | grep -i "tcp_strong_iss=" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            else
                echo "[/etc/default/inetinit 파일 내용 확인(cat /etc/default/inetinit | grep -i \"tcp_strong_iss\")]" >> $OUTPUT_FILE 2>&1
                echo "-/etc/default/inetinit 파일에 tcp_strong_iss 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
            fi
        else
            echo "[/etc/default/inetinit 파일 내용 확인(cat /etc/default/inetinit | grep -i \"tcp_strong_iss\")]" >> $OUTPUT_FILE 2>&1
            echo "-/etc/default/inetinit 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            echo "" >> $OUTPUT_FILE 2>&1
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "IMPROVE_TCP_SECURITY_SETTINGS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-135" 2>&1
}

#SRV-175
CONFIGURE_NTP_AND_TIME_SYNCHRONIZATION() {
    echo "CONFIGURE_NTP_AND_TIME_SYNCHRONIZATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-175.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-175_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-175_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        NTPQ_CHECK=$(ntpq -pn 2>/dev/null)
        CHRONY_CHECK=$(chronyc tracking 2>/dev/null)
        TIMEDATECTL_CHECK=$(timedatectl 2>/dev/null)
        if [ -n "$NTPQ_CHECK" ]; then
            echo "" >> $OUTPUT_FILE2 2>&1
            echo "[#ntpq -pn]" >> $OUTPUT_FILE2 2>&1
            echo "$NTPQ_CHECK" >> $OUTPUT_FILE2 2>&1
        fi
        if [ -n "$CHRONY_CHECK" ]; then
            echo "" >> $OUTPUT_FILE2 2>&1
            echo "[#chronyc tracking]" >> $OUTPUT_FILE2 2>&1
            echo "$CHRONY_CHECK" >> $OUTPUT_FILE2 2>&1
        fi
        if [ -n "$TIMEDATECTL_CHECK" ]; then
            echo "" >> $OUTPUT_FILE2 2>&1
            echo "[#timedatectl]" >> $OUTPUT_FILE2 2>&1
            echo "$TIMEDATECTL_CHECK" >> $OUTPUT_FILE2 2>&1
        fi

        echo "[date "+%Y-%m-%d %T" 확인]" >> $OUTPUT_FILE 2>&1
        date "+%Y-%m-%d %T" 2>/dev/null >> $OUTPUT_FILE 2>&1

        echo "" >> $OUTPUT_FILE 2>&1
        echo "[NTP 연결 확인]" >> $OUTPUT_FILE 2>&1
        if [ -f "$OUTPUT_FILE2" ]; then
            cat "$OUTPUT_FILE2" >> $OUTPUT_FILE 2>&1
        else
            echo "-ntpq, chronyc, timedatectl 의 NTP가 활성화되어 있지 않습니다." >> $OUTPUT_FILE 2>&1
        fi
        
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CONFIGURE_NTP_AND_TIME_SYNCHRONIZATION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-175" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-73" 2>&1
}

#SRV-001
USE_VULNERABLE_SNMP_VERSION() {
    echo "USE_VULNERABLE_SNMP_VERSION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-001.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-001_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-001_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/snmpcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1
        
        if [ $SNMP_CHECK_01 = 1 ] ; then

            echo "[현재사용중인 SNMP 버전 확인]" >> $OUTPUT_FILE 2>&1
            if command -v snmpd >/dev/null 2>&1; then
                /usr/sbin/snmpd -v >> $OUTPUT_FILE 2>&1
            else
                if [ -f "/usr/sbin/snmpd" ]; then
                    /usr/sbin/snmpd -v >> $OUTPUT_FILE 2>&1
                else
                    if command -v snmpget >/dev/null 2>&1; then
                        snmpget --version >> $OUTPUT_FILE 2>&1 
                    else
                        if [ -f "/usr/bin/snmpget" ]; then
                            /usr/bin/snmpget --version >> $OUTPUT_FILE 2>&1
                        else
                            echo "-snmpget 명령어가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    fi
                fi
            fi

            #AIX
            if command -v lslpp >/dev/null 2>&1; then
                if [ -n "$(lslpp -l | grep -i snmp)" ]; then
                    lslpp -l | grep -i snmp >> $OUTPUT_FILE 2>&1
                else
                    echo "-snmp 패키지가 설치되어 있지 않습니다.(# lslpp -l | grep -i snmp)" >> $OUTPUT_FILE 2>&1
                fi
            fi
            echo "" >> $OUTPUT_FILE 2>&1

            #SNMPv3 에서 사용되는 지시어 createUser
            #SNMPv1, SNMPv2 에서 사용되는 지시어 com2sec, community, community
            if [ -n "$SNMP_PATH" ]; then
                for file in $SNMP_PATH; do

                    echo "[SNMPv3 여부 확인($file)]" >> $OUTPUT_FILE 2>&1
                    if egrep -i "com2sec|community" "$file" | grep -v "#" | grep -q .; then
                        echo "SNMPv1, SNMPv2 : 사용(지시어 : com2sec, community)" >> $OUTPUT_FILE 2>&1
                    else
                        echo "SNMPv1, SNMPv2 : 미사용(지시어 : com2sec, community)" >> $OUTPUT_FILE 2>&1
                    fi

                    if grep -i "createUser" "$file" | grep -v "#" | grep -q .; then
                        echo "SNMPv3 : 사용(지시어 : createUser)" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                            echo "[SNMPv3 authpriv 내용 존재여부]" >> $OUTPUT_FILE 2>&1
                            if grep -i "authpriv" "$file" | grep -v "#" | grep -q .; then
                                cat $file | grep -i "authpriv" | grep -v "#" >> $OUTPUT_FILE 2>&1
                            else
                                echo "SNMPv3 authpriv 내용 미존재" >> $OUTPUT_FILE 2>&1
                            fi

                            echo "[SNMPv3 MD5 or SHA 내용 존재여부]" >> $OUTPUT_FILE 2>&1
                            if egrep -i "MD5|SHA" "$file" | grep -v "#" | grep -q .; then
                                cat $file | egrep -i "MD5|SHA" | grep -v "#" >> $OUTPUT_FILE 2>&1
                            else
                                echo "SNMPv3 MD5 or SHA 내용 미존재" >> $OUTPUT_FILE 2>&1
                            fi
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        echo "SNMPv3 : 미사용(지시어 : createUser)" >> $OUTPUT_FILE 2>&1
                    fi
                    echo "" >> $OUTPUT_FILE 2>&1

                    if egrep -i "createUser|com2sec|community" "$file" | grep -v "#" | grep -q .; then
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            egrep -i -B 1  "createUser|com2sec|community" "$file" | grep -v "#" >> $OUTPUT_FILE 2>&1
                        else
                            #1:patterns, 2:file, 3:lines_before, 4:lines_after
                            grep_AB_shell "createUser|com2sec|community" "$file" "1" "0"
                            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                        fi
                    else
                        echo "[# cat $file]" >> $OUTPUT_FILE 2>&1
                        echo "-createUser(SNMPv3), com2sec, community(SNMPv1, SNMPv2) 지시어가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    fi
                done
            else
                echo "-snmp설정파일(snmpd.conf)이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
            fi

        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "USE_VULNERABLE_SNMP_VERSION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-001" 2>&1
}

#SRV-048
DISABLE_UNNECESSARY_WEB_SERVICES() {
    echo "DISABLE_UNNECESSARY_WEB_SERVICES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-048.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-048_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-048_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_UNNECESSARY_WEB_SERVICES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-048" 2>&1
}

#U-35,SRV-040
REMOVE_WEB_SERVICE_DIRECTORY_LISTING() {
    echo "REMOVE_WEB_SERVICE_DIRECTORY_LISTING_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-35_SRV-040.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-35_SRV-040_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-35_SRV-040_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[# cat $APACHE_CONFIG | grep -B 2 -A 2 -i \"Options\" | grep -v \"#\" ]" >> $OUTPUT_FILE 2>&1
                    if [ "$(cat "$APACHE_CONFIG" | grep "Options" | grep -v "#" | wc -l)" -gt 0 ] ; then
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            cat $APACHE_CONFIG | grep -B 2 -A 2 -i "Options" | grep -v "#" >> $OUTPUT_FILE 2>&1
                        else
                            #1:patterns, 2:file, 3:lines_before, 4:lines_after
                            grep_AB_shell "Options" "$APACHE_CONFIG" "2" "2"
                            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                        fi
                    else
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            if egrep -iR "Options" $APACHE_PATH | grep -v "#|Binary" | grep -q .; then
                                egrep -iR "Options" $APACHE_PATH | grep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "-Options 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            if [ -n "$GREP_R_APACHE_PATH_TMP" ]; then
                                echo "debug: It can take a long time ... U-35,SRV-040 APACHE"
                                for file in $GREP_R_APACHE_PATH_TMP; do
                                    if [ "$(egrep -i "Options" "$file" | grep -v "#|Binary" | wc -l)" -gt 0 ]; then
                                        echo "[# egrep -i \"Options\" $file | grep -v \"#|Binary\" ]" >> $OUTPUT_FILE 2>&1
                                        egrep -i "Options" "$file" 2>/dev/null | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                    fi
                                done
                            else
                                echo "-Options 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    fi
                else   
                    echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            # https://tomcat.apache.org/tomcat-9.0-doc/default-servlet.html#secure
            # default : listings="false"
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-35,SRV-040 TOMCAT"
                        for TOMCAT_WEB_XML_PATH in $TOMCAT_WEB_XML_PATHS; do
                            if [ -f "$TOMCAT_WEB_XML_PATH" ]; then
                                if [ "$(cat "$TOMCAT_WEB_XML_PATH" | grep -v "<!--" | grep -i "listings" | wc -l)" -gt 0 ]; then
                                    echo "[# cat $TOMCAT_WEB_XML_PATH | grep -v \"<\\!--\" | grep -A 1 -i  \"listings\"]" >> $OUTPUT_FILE 2>&1
                                    if [ $GREP_AB_TMP -gt 0 ]; then
                                        cat $TOMCAT_WEB_XML_PATH 2>/dev/null | grep -v "<!--" | grep -A 1 -i "listings" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                                    else
                                        #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                        grep_AB_shell "listings" "$TOMCAT_WEB_XML_PATH" "0" "1"
                                        cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                                    fi
                                else
                                    echo "[# cat $TOMCAT_WEB_XML_PATH | grep -v \"<\\!--\" | grep -A 1 -i  \"listings\"]" >> $OUTPUT_FILE 2>&1
                                    echo "-listings 설정이 존재하지 않습니다.(default : false)" >> $OUTPUT_FILE 2>&1
                                fi
                            fi
                        done
                else
                    echo "[TOMCAT 관련 설정파일를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-35,SRV-040 WEBTOB"
                    for WEBTOB_HTTP_M_PATH in $WEBTOB_HTTP_M_PATHS; do
                        if [ -f "$WEBTOB_HTTP_M_PATH" ]; then
                            if [ "$(cat "$WEBTOB_HTTP_M_PATH" | grep -v "#" | grep -i "INDEX" | wc -l)" -gt 0 ]; then
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"INDEX\" ]" >> $OUTPUT_FILE 2>&1
                                cat $WEBTOB_HTTP_M_PATH 2>/dev/null | grep -v "#" | grep -i "INDEX" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"INDEX\" ]" >> $OUTPUT_FILE 2>&1
                                echo "-INDEX 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[WEBTOB 관련 설정파일(http.m)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-JEUS 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-35,SRV-040 NGINX"
                    #변수로 확인(변수초기화)
                    CHECK_VAR_01=0
                    for NGINX_CONF_PATH in $NGINX_ALL_CONF_PATHS; do
                        if [ -f "$NGINX_CONF_PATH" ]; then
                            if [ "$(cat "$NGINX_CONF_PATH" | grep -v "#" | grep -i "autoindex" | wc -l)" -gt 0 ]; then
                                echo "[# cat $NGINX_CONF_PATH | grep -v \"#\" | grep -i \"autoindex\" ]" >> $OUTPUT_FILE 2>&1
                                cat $NGINX_CONF_PATH 2>/dev/null | grep -v "#" | grep -i "autoindex" >> $OUTPUT_FILE 2>&1
                                CHECK_VAR_01=1
                            fi
                        fi
                    done
                    if [ $CHECK_VAR_01 -eq 0 ]; then
                        echo "-*.conf 파일 에서 autoindex 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "============" >> $OUTPUT_FILE 2>&1
                        echo "-확인한 conf 파일 목록-" >> $OUTPUT_FILE 2>&1
                        for NGINX_CONF_PATH in $NGINX_ALL_CONF_PATHS; do
                            if [ -f "$NGINX_CONF_PATH" ]; then
                                echo "$NGINX_CONF_PATH" >> $OUTPUT_FILE 2>&1
                            fi
                        done
                    fi
                fi
            fi
            #####
        #####
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "REMOVE_WEB_SERVICE_DIRECTORY_LISTING_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-040" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-35" 2>&1
}

#U-36,SRV-045
RESTRICT_PERMISSIONS_FOR_WEB_SERVICE_PROCESSES() {
    echo "RESTRICT_PERMISSIONS_FOR_WEB_SERVICE_PROCESSES_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-36_SRV-045.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-36_SRV-045_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-36_SRV-045_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[# cat $APACHE_CONFIG | egrep -i \"user|group\" ]" >> $OUTPUT_FILE 2>&1
                    if [ "$(cat $APACHE_CONFIG | egrep -i "user|group" | grep -i -v "LogFormat" | wc -l)" -gt 0 ] ; then
                        cat $APACHE_CONFIG | egrep -i "user|group" | grep -i -v "LogFormat" >> $OUTPUT_FILE 2>&1
                    else
                        echo "-user,group 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    fi
                else   
                    echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    if [ "$(ps -ef | grep "tomcat" | grep -v "grep" | wc -l)" -gt 0 ] ; then
                        echo "[# ps -ef | grep \"tomcat\" | grep -v \"grep\" ]" >> $OUTPUT_FILE 2>&1
                        ps -ef | grep "tomcat" | grep -v "grep" >> $OUTPUT_FILE 2>&1
                    else
                        echo "[# ps -ef | grep \"tomcat\" | grep -v \"grep\" ]" >> $OUTPUT_FILE 2>&1
                        echo "-tomcat 서비스가 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    fi
                fi
            fi
            #####
            #####
            #https://technet.tmaxsoft.com/upload/download/online/webtob/pver-20180725-000001/administrator-guide/config_ref.html
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-36,SRV-045 WEBTOB"
                    for WEBTOB_HTTP_M_PATH in $WEBTOB_HTTP_M_PATHS; do
                        if [ -f "$WEBTOB_HTTP_M_PATH" ]; then
                            if [ "$(cat "$WEBTOB_HTTP_M_PATH" | grep -v "#" | egrep -i "user|group" | wc -l)" -gt 0 ]; then
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | egrep -i \"user|group\" ]" >> $OUTPUT_FILE 2>&1
                                cat $WEBTOB_HTTP_M_PATH 2>/dev/null | grep -v "#" | egrep -i "user|group" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | egrep -i \"user|group\" ]" >> $OUTPUT_FILE 2>&1
                                echo "-user, group 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[WEBTOB 관련 설정파일(http.m)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-JEUS 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-36,SRV-045 NGINX"
                    #변수로 확인(변수초기화)
                    CHECK_VAR_01=0
                    for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                        if [ -f "$NGINX_CONFIG_PATH" ]; then
                            if [ "$(cat "$NGINX_CONFIG_PATH" | grep -v "#" | egrep -i "user" | wc -l)" -gt 0 ]; then
                                echo "[# cat $NGINX_CONFIG_PATH | grep -v \"#\" | egrep -i \"user\" ]" >> $OUTPUT_FILE 2>&1
                                cat $NGINX_CONFIG_PATH 2>/dev/null | grep -v "#" | egrep -i "user" >> $OUTPUT_FILE 2>&1
                                CHECK_VAR_01=1
                            fi
                        fi
                    done
                    if [ $CHECK_VAR_01 -eq 0 ]; then
                        echo "nginx.conf 파일 에서 user 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "============" >> $OUTPUT_FILE 2>&1
                        echo "-확인한 conf 파일 목록-" >> $OUTPUT_FILE 2>&1
                        for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                            if [ -f "$NGINX_CONFIG_PATH" ]; then
                                echo "$NGINX_CONFIG_PATH" >> $OUTPUT_FILE 2>&1
                            fi
                        done
                    fi
                fi
            fi
            #####
        #####
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_PERMISSIONS_FOR_WEB_SERVICE_PROCESSES_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-045" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-36" 2>&1
}
#U-37,SRV-042
RESTRICT_ACCESS_TO_PARENT_DIRECTORIES_IN_WEB_SERVICE() {
    echo "RESTRICT_ACCESS_TO_PARENT_DIRECTORIES_IN_WEB_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-37_SRV-042.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-37_SRV-042_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-37_SRV-042_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[버전 확인]" >> $OUTPUT_FILE 2>&1
                    if command -v rpm >/dev/null 2>&1; then
                        if [ "$(rpm -qa httpd | wc -l)" -gt 0 ] ; then
                            rpm -qa httpd >> $OUTPUT_FILE 2>&1
                        else
                            echo "rpm -qa httpd 명령어 결과값이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    else
                        if command -v dpkg >/dev/null 2>&1; then
                            if [ "$(dpkg -l | grep apache | wc -l)" -gt 0 ] ; then
                                dpkg -l | grep apache >> $OUTPUT_FILE 2>&1
                            else
                                echo "dpkg -l | grep apache 명령어 결과값이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    fi
                    echo "" >> $OUTPUT_FILE 2>&1

                    echo "[# cat $APACHE_CONFIG | grep -i -B 2 -A 2  \"AllowOverride\" ]" >> $OUTPUT_FILE 2>&1
                    if [ "$(cat $APACHE_CONFIG | grep -i "AllowOverride" | wc -l)" -gt 0 ] ; then
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            cat $APACHE_CONFIG | grep -i -B 2 -A 2 "AllowOverride" >> $OUTPUT_FILE 2>&1
                        else
                            #1:patterns, 2:file, 3:lines_before, 4:lines_after
                            grep_AB_shell "AllowOverride" "$APACHE_CONFIG" "2" "2"
                            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                        fi
                        
                    else
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            if grep -iR "AllowOverride" $APACHE_PATH | egrep -v "#|Binary" | grep -q .; then
                                grep -iR "AllowOverride" $APACHE_PATH | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "-AllowOverride 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            if [ -n "$GREP_R_APACHE_PATH_TMP" ]; then
                                echo "debug: It can take a long time ... U-37,SRV-042 APACHE"
                                for file in $GREP_R_APACHE_PATH_TMP; do
                                    if [ "$(egrep -i "AllowOverride" "$file" | egrep -v "#|Binary" | wc -l)" -gt 0 ]; then
                                        echo "[# egrep -i \"AllowOverride\" $file | egrep -v \"#|Binary\" ]" >> $OUTPUT_FILE 2>&1
                                        egrep -i "AllowOverride" "$file" 2>/dev/null | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                    fi
                                done
                            else
                                echo "-AllowOverride 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    fi
                else   
                    echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
                echo "" >> $OUTPUT_FILE 2>&1
                echo "" >> $OUTPUT_FILE 2>&1
                echo "---------------" >> $OUTPUT_FILE 2>&1
                echo "[참고]" >> $OUTPUT_FILE 2>&1
                echo "Directory Traversal 취약점이 발견되지 않은 Apache 버전(2.048) 보다 높은 경우 양호하나 낮은 경우 AllowOverride 설정 시 인증절차 없이 접속 불가능 하여 대외 서비스 경우 필요성 검토 필요" >> $OUTPUT_FILE 2>&1
                echo "---------------" >> $OUTPUT_FILE 2>&1
            fi
            #####
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-TOMCAT 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            #https://technet.tmaxsoft.com/upload/download/online/webtob/pver-20180725-000001/administrator-guide/config_ref.html
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-37,SRV-042 WEBTOB"
                    for WEBTOB_HTTP_M_PATH in $WEBTOB_HTTP_M_PATHS; do
                        if [ -f "$WEBTOB_HTTP_M_PATH" ]; then
                            if [ "$(cat "$WEBTOB_HTTP_M_PATH" | grep -v "#" | grep -i "UpperDirRestrict" | wc -l)" -gt 0 ]; then
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"UpperDirRestrict\" ]" >> $OUTPUT_FILE 2>&1
                                cat $WEBTOB_HTTP_M_PATH 2>/dev/null | grep -v "#" | grep -i "UpperDirRestrict" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"UpperDirRestrict\" ]" >> $OUTPUT_FILE 2>&1
                                echo "-UpperDirRestrict 설정이 존재하지 않습니다.(default : N )" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[WEBTOB 관련 설정파일(http.m)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-JEUS 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-NGINX 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
        fi
        #####
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_ACCESS_TO_PARENT_DIRECTORIES_IN_WEB_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-042" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-37" 2>&1
}
#U-38,SRV-043
REMOVE_UNNECESSARY_FILES_IN_WEB_SERVICE() {
    echo "REMOVE_UNNECESSARY_FILES_IN_WEB_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-38_SRV-043.hangrp"
    #tmp 파일
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-38_SRV-043_REF01.hangrp"
    #취약
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-38_SRV-043_REF02.hangrp"
    #양호
    OUTPUT_FILE4="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-38_SRV-043_REF03.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-38,SRV-043 APACHE"
                    for path in $APACHE_DIR_PATH ; do
                        if [ -d "$path" ]; then

                            find "$path" -type d \( \
                            -iname "manual" \
                            -o -iname "examples" \
                            -o -iname "sample" \
                            -o -iname "cgi-bin" \
                            -o -iname "test" \
                            -o -iname "tests" \
                            -o -iname "samples" \
                            -o -iname "templates" \) -exec ls -ld {} + >> $OUTPUT_FILE2 2>&1

                            # "manual", "examples", "sample": 매뉴얼, 예제, 샘플 디렉토리, 문서화 정보나 소스 코드 포함 가능.
                            # "cgi-bin": CGI 스크립트 디렉토리, 실행 가능한 스크립트 포함 가능.
                            # "test", "tests": 테스트 디렉토리, 테스트 코드나 데이터 포함 가능.
                            # "samples", "templates": 샘플, 템플릿 디렉토리, 소스 코드나 디자인 포함 가능.

                            find "$path" -type f \( \
                            -iname "*.bak" \
                            -o -iname "*.tmp" \
                            -o -iname "*.temp" \
                            -o -iname "*.swp" \
                            -o -iname "*.swo" \
                            -o -iname "*.old" \
                            -o -iname "*.orig" \
                            -o -iname "*.log" \
                            -o -iname "*.git" \
                            -o -iname "*.svn" \
                            -o -iname "*.hg" \) -exec ls -l {} + >> $OUTPUT_FILE2 2>&1

                            # *.bak: 백업 파일들은 구성이나 중요한 데이터를 담고 있을 수 있음.
                            # *.tmp, *.temp: 임시 파일들은 종종 민감한 데이터를 포함하거나 보안 위험을 증가시킴.
                            # *.swp, *.swo: 텍스트 편집기에서 생성하는 스왑 파일, 민감한 내용 포함 가능.
                            # *.old, *.orig: 오래된 파일, 일반적으로 백업 용도.
                            # *.log: 로그 파일, 민감한 정보가 포함될 수 있음.
                            # *.git, *.svn, *.hg: 소스 관리 디렉토리, 민감한 코드나 설정 포함 가능.

                            if [ -s "$OUTPUT_FILE2" ]; then
                                WEBWAS_UNIQ=$(cat "$OUTPUT_FILE2" | sort | uniq | grep -v "README" )
                                if [ -n "$WEBWAS_UNIQ" ]; then
                                    echo "$WEBWAS_UNIQ" > $OUTPUT_FILE2 2>&1
                                fi
                            fi


                            if [ -s "$OUTPUT_FILE2" ]; then
                                echo "[# ls -alR $path ]" >> $OUTPUT_FILE3 2>&1
                                cat "$OUTPUT_FILE2" >> $OUTPUT_FILE3 2>&1
                                echo "" >> $OUTPUT_FILE3 2>&1
                            else
                                echo "[# ls -alR $path ]" >> $OUTPUT_FILE4 2>&1
                                echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE4 2>&1
                                echo "" >> $OUTPUT_FILE4 2>&1
                            fi
                        fi
                    done

                    echo "[불필요한 파일 확인(디렉터리 경로 : config 파일에 등록된 디렉터리 내용)]" >> $OUTPUT_FILE 2>&1
                    if [ -f "$OUTPUT_FILE3" ] ; then
                        cat "$OUTPUT_FILE3" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        if [ -f "$OUTPUT_FILE4" ] ; then
                            cat "$OUTPUT_FILE4" >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        else
                            echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        fi
                    fi
                else   
                    echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
                > $OUTPUT_FILE2 2>&1
                > $OUTPUT_FILE3 2>&1
                > $OUTPUT_FILE4 2>&1
            fi
            #####
            # https://tomcat.apache.org/tomcat-9.0-doc/default-servlet.html#secure
            # default : listings="false"
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-38,SRV-043 TOMCAT"
                    for TOMCAT_PATH_TMP_01 in $TOMCAT_PATHS; do
                        if [ -d "$TOMCAT_PATH_TMP_01" ]; then
                            find "$TOMCAT_PATH_TMP_01" \( -iname "*.bak" -o -iname "*manual*" -o -iname "*examples*" -o -iname "*sample*" -o -iname "cgi-bin" -o -iname "*.tmp" -o -iname "*test*" -o -iname "*.temp" -o -iname "*.swp" -o -iname "*.swo" -o -iname "*.old" -o -iname "*.orig" -o -iname "*manager*" -o -iname "*host-manager*" -o -iname "*docs*" \) -exec ls -l {} + >> $OUTPUT_FILE2 2>&1
                            if [ -s "$OUTPUT_FILE2" ]; then
                                echo "[# ls -alR $TOMCAT_PATH_TMP_01 ]" >> $OUTPUT_FILE3 2>&1
                                cat "$OUTPUT_FILE2" >> $OUTPUT_FILE3 2>&1
                                > $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE3 2>&1
                            else
                                echo "[# ls -alR $TOMCAT_PATH_TMP_01 ]" >> $OUTPUT_FILE4 2>&1
                                echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE4 2>&1
                                echo "" >> $OUTPUT_FILE4 2>&1
                            fi
                        fi
                    done

                    if [ -f "$OUTPUT_FILE3" ] ; then
                        cat "$OUTPUT_FILE3" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        if [ -f "$OUTPUT_FILE4" ] ; then
                            cat "$OUTPUT_FILE4" >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        else
                            echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        fi
                    fi
                else
                    echo "[TOMCAT 관련 설정파일(server.xml)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
                echo "" > $OUTPUT_FILE2 2>&1
                echo "" > $OUTPUT_FILE3 2>&1
                echo "" > $OUTPUT_FILE4 2>&1
            fi
            #####
            #####
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-38,SRV-043 WEBTOB"
                    for WEBTOB_INFO_DIR in $WEBTOB_INFO_DIRS; do
                        if [ -d "$WEBTOB_INFO_DIR" ]; then
                            find "$WEBTOB_INFO_DIR" \( -iname "*.bak" -o -iname "*manual*" -o -iname "*examples*" -o -iname "*sample*" -o -iname "cgi-bin" -o -iname "*.tmp" -o -iname "*test*" -o -iname "*.temp" -o -iname "*.swp" -o -iname "*.swo" -o -iname "*.old" -o -iname "*.orig" -o -iname "*manager*" -o -iname "*host-manager*" -o -iname "*docs*" \) -exec ls -l {} + >> $OUTPUT_FILE2 2>&1
                            if [ -s "$OUTPUT_FILE2" ]; then
                                echo "[# ls -alR $WEBTOB_INFO_DIR ]" >> $OUTPUT_FILE3 2>&1
                                cat "$OUTPUT_FILE2" >> $OUTPUT_FILE3 2>&1
                                echo "" >> $OUTPUT_FILE3 2>&1
                            else
                                echo "[# ls -alR $WEBTOB_INFO_DIR ]" >> $OUTPUT_FILE4 2>&1
                                echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE4 2>&1
                                echo "" >> $OUTPUT_FILE4 2>&1
                            fi
                        fi
                    done

                    if [ -f "$OUTPUT_FILE3" ] ; then
                        cat "$OUTPUT_FILE3" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        if [ -f "$OUTPUT_FILE4" ] ; then
                            cat "$OUTPUT_FILE4" >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        else
                            echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        fi
                    fi

                else
                    echo "[WEBTOB 관련 설정파일(http.m)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
                echo "" > $OUTPUT_FILE2 2>&1
                echo "" > $OUTPUT_FILE3 2>&1
                echo "" > $OUTPUT_FILE4 2>&1
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-38,SRV-043 JEUS"
                    for JEUS_INFO_PATH in $JEUS_INFO_PATHS; do
                        if [ -d "$JEUS_INFO_PATH" ]; then
                            find "$JEUS_INFO_PATH" \( -iname "*.bak" -o -iname "*manual*" -o -iname "*examples*" -o -iname "*sample*" -o -iname "cgi-bin" -o -iname "*.tmp" -o -iname "*test*" -o -iname "*.temp" -o -iname "*.swp" -o -iname "*.swo" -o -iname "*.old" -o -iname "*.orig" -o -iname "*manager*" -o -iname "*host-manager*" -o -iname "*docs*" \) -exec ls -l {} + >> $OUTPUT_FILE2 2>&1
                            if [ -s "$OUTPUT_FILE2" ]; then
                                echo "[# ls -alR $JEUS_INFO_PATH ]" >> $OUTPUT_FILE3 2>&1
                                cat "$OUTPUT_FILE2" >> $OUTPUT_FILE3 2>&1
                                echo "" >> $OUTPUT_FILE3 2>&1
                            else
                                echo "[# ls -alR $JEUS_INFO_PATH ]" >> $OUTPUT_FILE4 2>&1
                                echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE4 2>&1
                                echo "" >> $OUTPUT_FILE4 2>&1
                            fi
                        fi
                    done

                    if [ -f "$OUTPUT_FILE3" ] ; then
                        cat "$OUTPUT_FILE3" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        if [ -f "$OUTPUT_FILE4" ] ; then
                            cat "$OUTPUT_FILE4" >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        else
                            echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        fi
                    fi
                else
                    echo "[JEUS 관련 디렉터리를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
                echo "" > $OUTPUT_FILE2 2>&1
                echo "" > $OUTPUT_FILE3 2>&1
                echo "" > $OUTPUT_FILE4 2>&1
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-38,SRV-043 NGINX"
                    for NGINX_PATH_TMP_01 in $NGINX_HOME_PATHS; do
                        if [ -d "$NGINX_PATH_TMP_01" ]; then
                            find "$NGINX_PATH_TMP_01" \( -iname "*.bak" -o -iname "*manual*" -o -iname "*examples*" -o -iname "*sample*" -o -iname "cgi-bin" -o -iname "*.tmp" -o -iname "*test*" -o -iname "*.temp" -o -iname "*.swp" -o -iname "*.swo" -o -iname "*.old" -o -iname "*.orig" -o -iname "*manager*" -o -iname "*host-manager*" -o -iname "*docs*" \) -exec ls -l {} + >> $OUTPUT_FILE2 2>&1
                            if [ -s "$OUTPUT_FILE2" ]; then
                                echo "[# ls -alR $NGINX_PATH_TMP_01 ]" >> $OUTPUT_FILE3 2>&1
                                cat "$OUTPUT_FILE2" >> $OUTPUT_FILE3 2>&1
                                > $OUTPUT_FILE2 2>&1
                                echo "" >> $OUTPUT_FILE3 2>&1
                            else
                                echo "[# ls -alR $NGINX_PATH_TMP_01 ]" >> $OUTPUT_FILE4 2>&1
                                echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE4 2>&1
                                echo "" >> $OUTPUT_FILE4 2>&1
                            fi
                        fi
                    done

                    if [ -f "$OUTPUT_FILE3" ] ; then
                        cat "$OUTPUT_FILE3" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    else
                        if [ -f "$OUTPUT_FILE4" ] ; then
                            cat "$OUTPUT_FILE4" >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        else
                            echo "-불필요한 파일이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            echo
                        fi
                    fi
                fi
                echo "" > $OUTPUT_FILE2 2>&1
                echo "" > $OUTPUT_FILE3 2>&1
                echo "" > $OUTPUT_FILE4 2>&1
            fi
            #####
        fi
        #####
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "REMOVE_UNNECESSARY_FILES_IN_WEB_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-043" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-38" 2>&1
}

#U-39,SRV-047
DISABLE_SYMBOLIC_LINKS_IN_WEB_SERVICE() {
    echo "DISABLE_SYMBOLIC_LINKS_IN_WEB_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-39_SRV-047.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-39_SRV-047_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-39_SRV-047_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1

    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    if [ -f "$APACHE_CONFIG" ]; then
                        echo "[# cat $APACHE_CONFIG | grep -B 2 -A 2 -i \"FollowSymLinks\" | grep -v \"#\" ]" >> $OUTPUT_FILE 2>&1
                        if [ "$(cat "$APACHE_CONFIG" | grep -i "FollowSymLinks" | grep -v "#" | wc -l)" -gt 0 ] ; then
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                cat $APACHE_CONFIG | grep -B 2 -A 2 -i "FollowSymLinks" | grep -v "#" >> $OUTPUT_FILE 2>&1
                            else
                                #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                grep_AB_shell "FollowSymLinks" "$APACHE_CONFIG" "2" "2"
                                cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            fi
                            
                            echo "" >> $OUTPUT_FILE 2>&1
                        else
                            if [ $GREP_AB_TMP -gt 0 ]; then
                                if grep -iR "FollowSymLinks" $APACHE_PATH | egrep -v "#|Binary" | grep -q .; then
                                    grep -iR "FollowSymLinks" $APACHE_PATH | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                    echo "" >> $OUTPUT_FILE 2>&1
                                else
                                    echo "-FollowSymLinks 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                    echo "" >> $OUTPUT_FILE 2>&1
                                fi
                            else
                                if [ -n "$GREP_R_APACHE_PATH_TMP" ]; then
                                    echo "debug: It can take a long time ... U-39,SRV-047 APACHE"
                                    for file in $GREP_R_APACHE_PATH_TMP; do
                                        if [ "$(egrep -i "FollowSymLinks" "$file" | egrep -v "#|Binary" | wc -l)" -gt 0 ]; then
                                            echo "[# egrep -i \"FollowSymLinks\" $file | egrep -v \"#|Binary\" ]" >> $OUTPUT_FILE 2>&1
                                            egrep -i "FollowSymLinks" "$file" 2>/dev/null | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                        fi
                                    done
                                else
                                    echo "-FollowSymLinks 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                    echo "" >> $OUTPUT_FILE 2>&1
                                fi
                            fi
                        fi
                    else
                        echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                    fi

                else   
                    echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #https://happy-jjang-a.tistory.com/171
            #https://tomcat.apache.org/tomcat-8.0-doc/config/resources.html
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-39,SRV-047 TOMCAT"
                    for TOMCAT_SERVER_CONTEXT_XML_PATH in $TOMCAT_SERVER_CONTEXT_XML_PATHS; do
                        if [ -f "$TOMCAT_SERVER_CONTEXT_XML_PATH" ]; then
                            if [ "$(cat "$TOMCAT_SERVER_CONTEXT_XML_PATH" | grep -v "<!--" | grep -i "allowLinking" | wc -l)" -gt 0 ]; then
                                echo "[# cat $TOMCAT_SERVER_CONTEXT_XML_PATH | grep -v \"<\\!--\" | grep -i  \"allowLinking\"]" >> $OUTPUT_FILE 2>&1
                                if [ $GREP_AB_TMP -gt 0 ]; then
                                    cat $TOMCAT_SERVER_CONTEXT_XML_PATH 2>/dev/null | grep -v "<!--" | grep -A 1 -B 1 -i "allowLinking" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                                else
                                    #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                    grep_AB_shell "allowLinking" "$TOMCAT_SERVER_CONTEXT_XML_PATH" "1" "1"
                                    cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                                fi
                                
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $TOMCAT_SERVER_CONTEXT_XML_PATH | grep -v \"<\\!--\" | grep -i  \"allowLinking\"]" >> $OUTPUT_FILE 2>&1
                                echo "-allowLinking 설정이 존재하지 않습니다. (default false.)" >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[TOMCAT 관련 설정파일(server.xml)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            #https://technet.tmaxsoft.com/upload/download/online/webtob/pver-20180725-000001/administrator-guide/config_ref.html
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-WEBTOB 해당사항 없음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-JEUS 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-39,SRV-047 NGINX"
                    CHECK_VAR_01=0
                    #NGINX_CONFIG_PATHS
                    for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                        if [ -f "$NGINX_CONFIG_PATH" ]; then
                            if [ "$(cat "$NGINX_CONFIG_PATH" | grep -v "#" | grep -i "disable_symlinks" | wc -l)" -gt 0 ]; then
                                echo "[# cat $NGINX_CONFIG_PATH | grep -v \"#\" | grep -i \"disable_symlinks\" ]" >> $OUTPUT_FILE 2>&1
                                cat $NGINX_CONFIG_PATH | grep -v "#" | grep -i "disable_symlinks" >> $OUTPUT_FILE 2>&1
                                CHECK_VAR_01=1
                            fi
                        fi
                    done
                    if [ $CHECK_VAR_01 -eq 0 ]; then
                        echo "nginx.conf 파일 에서 disable_symlinks 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "============" >> $OUTPUT_FILE 2>&1
                        echo "-확인한 conf 파일 목록-" >> $OUTPUT_FILE 2>&1
                        for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                            if [ -f "$NGINX_CONFIG_PATH" ]; then
                                echo "$NGINX_CONFIG_PATH" >> $OUTPUT_FILE 2>&1
                            fi
                        done
                    fi
                fi
            fi
            #####
        #####
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "DISABLE_SYMBOLIC_LINKS_IN_WEB_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-047" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-39" 2>&1
}

#U-40,SRV-044
RESTRICT_FILE_UPLOAD_AND_DOWNLOAD_IN_WEB_SERVICE() {
    echo "RESTRICT_FILE_UPLOAD_AND_DOWNLOAD_IN_WEB_SERVICE_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-40_SRV-044.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-40_SRV-044_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-40_SRV-044_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[# cat $APACHE_CONFIG | grep -B 2 -A 2 -i \"LimitRequestBody\" | grep -v \"#\" ]" >> $OUTPUT_FILE 2>&1
                    if [ "$(cat "$APACHE_CONFIG" | grep -i "LimitRequestBody" | grep -v "#" | wc -l)" -gt 0 ] ; then
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            cat $APACHE_CONFIG | grep -B 2 -A 2 -i "LimitRequestBody" | grep -v "#" >> $OUTPUT_FILE 2>&1
                        else
                            #1:patterns, 2:file, 3:lines_before, 4:lines_after
                            grep_AB_shell "LimitRequestBody" "$APACHE_CONFIG" "2" "2"
                            cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                        fi
                        
                    else
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            if grep -iR "LimitRequestBody" $APACHE_PATH | egrep -v "#|Binary" | grep -q .; then
                                grep -iR "LimitRequestBody" $APACHE_PATH | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "-LimitRequestBody 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            if [ -z $GREP_R_APACHE_PATH_TMP ]; then
                                echo "debug: It can take a long time ... U-40,SRV-044 APACHE"
                                for file in $GREP_R_APACHE_PATH_TMP; do
                                    if [ "$(egrep -i "LimitRequestBody" "$file" | egrep -v "#|Binary" | wc -l)" -gt 0 ]; then
                                        echo "[# egrep -i \"LimitRequestBody\" $file | egrep -v \"#|Binary\" ]" >> $OUTPUT_FILE 2>&1
                                        egrep -i "LimitRequestBody" "$file" 2>/dev/null | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                    fi
                                done
                            else
                                echo "-LimitRequestBody 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    fi

                    echo "-현재버전-" >> $OUTPUT_FILE 2>&1
                    if command -v rpm >/dev/null 2>&1; then
                        if [ "$(rpm -qa httpd | wc -l)" -gt 0 ] ; then
                            rpm -qa httpd >> $OUTPUT_FILE 2>&1
                        else
                            echo "rpm -qa httpd 명령어 결과값이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        fi
                    else
                        if command -v dpkg >/dev/null 2>&1; then
                            if [ "$(dpkg -l | grep apache | wc -l)" -gt 0 ] ; then
                                dpkg -l | grep apache >> $OUTPUT_FILE 2>&1
                            else
                                echo "dpkg -l | grep apache 명령어 결과값이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    fi
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "-2.0 버전(Default:LimitRequestBody 0)-" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.0/mod/core.html#limitrequestbody" >> $OUTPUT_FILE 2>&1
                    echo "-2.2 버전(Default:LimitRequestBody 0)-" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.2/mod/core.html#limitrequestbody" >> $OUTPUT_FILE 2>&1
                    echo "-2.4 버전(Default:LimitRequestBody 1073741824)-" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.4/mod/core.html#limitrequestbody" >> $OUTPUT_FILE 2>&1

                else   
                    echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi

            
            #####
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-40,SRV-044 TOMCAT"
                    for TOMCAT_WEB_XML_PATH in $TOMCAT_WEB_XML_PATHS; do
                        if [ -f "$TOMCAT_WEB_XML_PATH" ]; then
                            if [ "$(cat "$TOMCAT_WEB_XML_PATH" | grep -v "<!--" | egrep -i "<max-file-size|<max-request-size" | wc -l)" -gt 0 ]; then
                                echo "[# cat $TOMCAT_WEB_XML_PATH | grep -v \"<\\!--\" | egrep -i  \"<max-file-size|<max-request-size\"]" >> $OUTPUT_FILE 2>&1
                                cat $TOMCAT_WEB_XML_PATH 2>/dev/null | grep -v "<!--" | egrep -i "<max-file-size|<max-request-size" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $TOMCAT_WEB_XML_PATH | grep -v \"<\\!--\" | egrep -i  \"<max-file-size|<max-request-size\"]" >> $OUTPUT_FILE 2>&1
                                echo "-max-file-size, max-request-size 또는 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[TOMCAT 관련 설정파일(server.xml)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            #https://technet.tmaxsoft.com/upload/download/online/webtob/pver-20180725-000001/administrator-guide/config_ref.html
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-40,SRV-044 WEBTOB"
                    for WEBTOB_HTTP_M_PATH in $WEBTOB_HTTP_M_PATHS; do
                        if [ -f "$WEBTOB_HTTP_M_PATH" ]; then
                            if [ "$(cat "$WEBTOB_HTTP_M_PATH" | grep -v "#" | grep -i "LimitRequestBody" | wc -l)" -gt 0 ]; then
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"LimitRequestBody\" ]" >> $OUTPUT_FILE 2>&1
                                cat $WEBTOB_HTTP_M_PATH 2>/dev/null | grep -v "#" | grep -i "LimitRequestBody" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"LimitRequestBody\" ]" >> $OUTPUT_FILE 2>&1
                                echo "-LimitRequestBody 설정이 존재하지 않습니다.(default : 0 )" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[WEBTOB 관련 설정파일(http.m)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-40,SRV-044 JEUS"
                    for JEUS_DOMAIN_XML_PATH in $JEUS_DOMAIN_XML_PATHS; do
                        if [ -f "$JEUS_DOMAIN_XML_PATH" ]; then
                            if [ "$(cat "$JEUS_DOMAIN_XML_PATH" | grep -v "<!--" | grep -i "max-post-size" | wc -l)" -gt 0 ]; then
                                echo "[# cat $JEUS_DOMAIN_XML_PATH | grep -v \"<\\!--\" | grep -i  \"max-post-size\"]" >> $OUTPUT_FILE 2>&1
                                if [ $GREP_AB_TMP -gt 0 ]; then
                                    cat $JEUS_DOMAIN_XML_PATH 2>/dev/null | grep -v "<!--" | grep -i -A 5 -B 5 "max-post-size" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                                else
                                    #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                    grep_AB_shell "max-post-size" "$JEUS_DOMAIN_XML_PATH" "5" "5"
                                    cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                                fi
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $JEUS_DOMAIN_XML_PATH | grep -v \"<\\!--\" | grep -i  \"max-post-size\"]" >> $OUTPUT_FILE 2>&1
                                echo "-max-post-size 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[JEUS 관련 디렉터리를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-40,SRV-044 NGINX"
                    CHECK_VAR_01=0
                    for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                        if [ -f "$NGINX_CONFIG_PATH" ]; then
                            if [ "$(cat "$NGINX_CONFIG_PATH" | grep -v "#" | grep -i "client_max_body_size" | wc -l)" -gt 0 ]; then
                                echo "[# cat $NGINX_CONFIG_PATH | grep -v \"#\" | grep -i \"client_max_body_size\" ]" >> $OUTPUT_FILE 2>&1
                                cat $NGINX_CONFIG_PATH | grep -v "#" | grep -i "client_max_body_size" >> $OUTPUT_FILE 2>&1
                                CHECK_VAR_01=1
                            fi
                        fi
                    done
                    if [ $CHECK_VAR_01 -eq 0 ]; then
                        echo "nginx.conf 파일 에서 client_max_body_size 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "============" >> $OUTPUT_FILE 2>&1
                        echo "-확인한 conf 파일 목록-" >> $OUTPUT_FILE 2>&1
                        for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                            if [ -f "$NGINX_CONFIG_PATH" ]; then
                                echo "$NGINX_CONFIG_PATH" >> $OUTPUT_FILE 2>&1
                            fi
                        done
                    fi
                fi
            fi
            #####
        #####
        fi

    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "RESTRICT_FILE_UPLOAD_AND_DOWNLOAD_IN_WEB_SERVICE_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-044" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-40" 2>&1
}

#U-41,SRV-046
SEGREGATE_WEB_SERVICE_AREAS() {
    echo "SEGREGATE_WEB_SERVICE_AREAS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-41_SRV-046.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-41_SRV-046_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-41_SRV-046_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[# cat $APACHE_CONFIG | grep -i \"DocumentRoot\" | grep -v \"#\" ]" >> $OUTPUT_FILE 2>&1
                    if [ "$(cat "$APACHE_CONFIG" | grep -i "DocumentRoot" | grep -v "#" | wc -l)" -gt 0 ] ; then
                        cat $APACHE_CONFIG | grep -i "DocumentRoot" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    else
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            if grep -iR "DocumentRoot" $APACHE_PATH | egrep -v "#|Binary" | grep -q .; then
                                grep -iR "DocumentRoot" $APACHE_PATH | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "-DocumentRoot 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            if [ -n "$GREP_R_APACHE_PATH_TMP" ]; then
                                echo "debug: It can take a long time ... U-41,SRV-046 APACHE"
                                for file in $GREP_R_APACHE_PATH_TMP; do
                                    if [ "$(egrep -i "DocumentRoot" "$file" | egrep -v "#|Binary" | wc -l)" -gt 0 ]; then
                                        echo "[# egrep -i \"DocumentRoot\" $file | egrep -v \"#|Binary\" ]" >> $OUTPUT_FILE 2>&1
                                        egrep -i "DocumentRoot" "$file" 2>/dev/null | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                    fi
                                done
                            else
                                echo "-DocumentRoot 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    fi
                else   
                    echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-41,SRV-046 TOMCAT"
                    for TOMCAT_SERVER_CONTEXT_XML_PATH in $TOMCAT_SERVER_CONTEXT_XML_PATHS; do
                        if [ -f "$TOMCAT_SERVER_CONTEXT_XML_PATH" ]; then
                            if [ "$(cat "$TOMCAT_SERVER_CONTEXT_XML_PATH" | grep -v "<!--" | egrep -i "appBase|docBase" | wc -l)" -gt 0 ]; then
                                echo "[# cat $TOMCAT_SERVER_CONTEXT_XML_PATH | grep -v \"<\\!--\" | egrep -i  \"appBase|docBase\"]" >> $OUTPUT_FILE 2>&1
                                cat $TOMCAT_SERVER_CONTEXT_XML_PATH 2>/dev/null | grep -v "<!--" | egrep -i "appBase|docBase" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $TOMCAT_SERVER_CONTEXT_XML_PATH | grep -v \"<\\!--\" | egrep -i  \"appBase|docBase\"]" >> $OUTPUT_FILE 2>&1
                                echo "-appBase, docBase 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[TOMCAT 관련 설정파일(server.xml)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            #https://technet.tmaxsoft.com/upload/download/online/webtob/pver-20180725-000001/administrator-guide/config_ref.html
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-41,SRV-046 WEBTOB"
                    for WEBTOB_HTTP_M_PATH in $WEBTOB_HTTP_M_PATHS; do
                        if [ -f "$WEBTOB_HTTP_M_PATH" ]; then
                            if [ "$(cat "$WEBTOB_HTTP_M_PATH" | grep -v "#" | grep -i "DocRoot" | wc -l)" -gt 0 ]; then
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"DocRoot\" ]" >> $OUTPUT_FILE 2>&1
                                cat $WEBTOB_HTTP_M_PATH 2>/dev/null | grep -v "#" | grep -i "DocRoot" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"DocRoot\" ]" >> $OUTPUT_FILE 2>&1
                                echo "-DocRoot 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[WEBTOB 관련 설정파일(http.m)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-JEUS 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-41,SRV-046 NGINX"
                    CHECK_VAR_01=0
                    #NGINX_ALL_CONF_PATHS
                    for NGINX_ALL_CONF_PATH in $NGINX_ALL_CONF_PATHS; do
                        if [ -f "$NGINX_ALL_CONF_PATH" ]; then
                            if [ "$(cat "$NGINX_ALL_CONF_PATH" | grep -v "#" | grep -i "root" | wc -l)" -gt 0 ]; then
                                echo "[# cat $NGINX_ALL_CONF_PATH | grep -v \"#\" | grep -i \"root\" ]" >> $OUTPUT_FILE 2>&1
                                cat $NGINX_ALL_CONF_PATH | grep -v "#" | grep -i "root" >> $OUTPUT_FILE 2>&1
                                CHECK_VAR_01=1
                            fi
                        fi
                    done
                    if [ $CHECK_VAR_01 -eq 0 ]; then
                        echo "*.conf 파일 에서 root 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "============" >> $OUTPUT_FILE 2>&1
                        echo "-확인한 conf 파일 목록-" >> $OUTPUT_FILE 2>&1
                        for NGINX_ALL_CONF_PATH in $NGINX_ALL_CONF_PATHS; do
                            if [ -f "$NGINX_ALL_CONF_PATH" ]; then
                                echo "$NGINX_ALL_CONF_PATH" >> $OUTPUT_FILE 2>&1
                            fi
                        done
                    fi
                fi
            fi
            #####
        #####
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "SEGREGATE_WEB_SERVICE_AREAS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-41" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-046" 2>&1
}

#U-71,SRV-148
HIDE_APACHE_WEB_SERVICE_INFORMATION() {
    echo "HIDE_APACHE_WEB_SERVICE_INFORMATION_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/U-71_SRV-148.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-71_SRV-148_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/U-71_SRV-148_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[# cat $APACHE_CONFIG | egrep -i \"ServerTokens|ServerSignature\" | grep -v \"#\" ]" >> $OUTPUT_FILE 2>&1
                    if [ "$(cat "$APACHE_CONFIG" | egrep -i "ServerTokens|Server Tokens|ServerSignature" | grep -v "#" | wc -l)" -gt 0 ] ; then
                        cat $APACHE_CONFIG | egrep -i "ServerTokens|Server Tokens|ServerSignature" | grep -v "#" >> $OUTPUT_FILE 2>&1
                    else
                        if [ $GREP_AB_TMP -gt 0 ]; then
                            if egrep -iR "ServerTokens|Server Tokens|ServerSignature" $APACHE_PATH | egrep -v "#|Binary" | grep -q .; then
                                egrep -iR "ServerTokens|Server Tokens|ServerSignature" $APACHE_PATH | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "-ServerTokens 또는 ServerSignature 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        else
                            if [ -n "$GREP_R_APACHE_PATH_TMP" ]; then
                                echo "debug: It can take a long time ... U-71,SRV-148 APACHE"
                                for file in $GREP_R_APACHE_PATH_TMP; do
                                    if [ "$(egrep -i "ServerTokens|Server Tokens|ServerSignature" "$file" | egrep -v "#|Binary" | wc -l)" -gt 0 ]; then
                                        echo "[# egrep -i \"ServerTokens|Server Tokens|ServerSignature\" $file | egrep -v \"#|Binary\" ]" >> $OUTPUT_FILE 2>&1
                                        egrep -i "ServerTokens|Server Tokens|ServerSignature" "$file" 2>/dev/null | egrep -v "#|Binary" >> $OUTPUT_FILE 2>&1
                                    fi
                                done
                            else
                                echo "-ServerTokens 또는 ServerSignature 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi

                    fi
                else   
                    echo "[APACHE 관련 config 를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
                echo "-현재버전-" >> $OUTPUT_FILE 2>&1
                if command -v rpm >/dev/null 2>&1; then
                    if [ "$(rpm -qa httpd | wc -l)" -gt 0 ] ; then
                        rpm -qa httpd >> $OUTPUT_FILE 2>&1
                    else
                        echo "rpm -qa httpd 명령어 결과값이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                    fi
                else
                    if command -v dpkg >/dev/null 2>&1; then
                        if [ "$(dpkg -l | grep apache | wc -l)" -gt 0 ] ; then
                            dpkg -l | grep apache >> $OUTPUT_FILE 2>&1
                        else
                            echo "dpkg -l | grep apache 명령어 결과값이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        fi
                    fi
                fi
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "-2.0 버전(Default : ServerTokens Full,ServerSignature Off)-" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.0/mod/core.html#servertokens" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.0/mod/core.html#serversignature" >> $OUTPUT_FILE 2>&1
                    echo "-2.2 버전(Default : ServerTokens Full,ServerSignature Off)-" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.2/mod/core.html#servertokens" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.2/mod/core.html#serversignature" >> $OUTPUT_FILE 2>&1
                    echo "-2.4 버전(Default : ServerTokens Full,ServerSignature Off)-" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.4/mod/core.html#servertokens" >> $OUTPUT_FILE 2>&1
                    echo "-https://httpd.apache.org/docs/2.4/mod/core.html#serversignature" >> $OUTPUT_FILE 2>&1
            fi
            #####
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스 버전 확인]]" >> $OUTPUT_FILE 2>&1
                    #java -cp $TOMCAT_CATLINA_JAR_PATHS org.apache.catalina.util.ServerInfo
                    echo "debug: It can take a long time ... U-71,SRV-148 TOMCAT1"
                    for TOMCAT_CATLINA_JAR_PATH in $TOMCAT_CATLINA_JAR_PATHS; do
                        if [ -s "$TOMCAT_CATLINA_JAR_PATH" ]; then
                            echo "[# java -cp $TOMCAT_CATLINA_JAR_PATH org.apache.catalina.util.ServerInfo]" >> $OUTPUT_FILE 2>&1
                            java -cp $TOMCAT_CATLINA_JAR_PATH org.apache.catalina.util.ServerInfo 2>/dev/null >> $OUTPUT_FILE 2>&1
                            echo "" >> $OUTPUT_FILE 2>&1
                        fi
                    done
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[server.xml 확인 8.5 버전 이후(showServerInfo, showReport)]" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-71,SRV-148 TOMCAT2"
                    for TOMCAT_SERVER_XML_PATH in $TOMCAT_SERVER_XML_PATHS; do
                        if [ -f "$TOMCAT_SERVER_XML_PATH" ]; then
                            if [ "$(cat "$TOMCAT_SERVER_XML_PATH" | grep -v "<!--" | egrep -i "showServerInfo|showReport" | wc -l)" -gt 0 ]; then
                                echo "[# cat $TOMCAT_SERVER_XML_PATH | grep -v \"<\\!--\" | egrep -i  \"showServerInfo|showReport\"]" >> $OUTPUT_FILE 2>&1
                                cat $TOMCAT_SERVER_XML_PATH 2>/dev/null | grep -v "<!--" | egrep -i "showServerInfo|showReport" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $TOMCAT_SERVER_XML_PATH | grep -v \"<\\!--\" | egrep -i  \"showServerInfo|showReport\"]" >> $OUTPUT_FILE 2>&1
                                echo "-showServerInfo, showReport 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "[web.xml 확인 8.5 버전 이전(<error-page>)]" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-71,SRV-148 TOMCAT3"
                    for TOMCAT_WEB_XML_PATH in $TOMCAT_WEB_XML_PATHS; do
                        if [ -f "$TOMCAT_WEB_XML_PATH" ]; then
                            if [ "$(cat "$TOMCAT_WEB_XML_PATH" | grep -v "<!--" | grep -A 4 -i "<error-page" | wc -l)" -gt 0 ]; then
                                echo "[# cat $TOMCAT_WEB_XML_PATH | grep -v \"<\\!--\" | grep -i  \"<error-page\"]" >> $OUTPUT_FILE 2>&1
                                cat $TOMCAT_WEB_XML_PATH 2>/dev/null | grep -v "<!--" | grep -A 4 -i "<error-page" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $TOMCAT_WEB_XML_PATH | grep -v \"<\\!--\" | grep -i  \"<error-page\"]" >> $OUTPUT_FILE 2>&1
                                echo "-error-page 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[TOMCAT 관련 설정파일(server.xml)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            #https://technet.tmaxsoft.com/upload/download/online/webtob/pver-20180725-000001/administrator-guide/config_ref.html
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-71,SRV-148 WEBTOB"
                    for WEBTOB_HTTP_M_PATH in $WEBTOB_HTTP_M_PATHS; do
                        if [ -f "$WEBTOB_HTTP_M_PATH" ]; then
                            if [ "$(cat "$WEBTOB_HTTP_M_PATH" | grep -v "#" | grep -i "ServerTokens" | wc -l)" -gt 0 ]; then
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"ServerTokens\" ]" >> $OUTPUT_FILE 2>&1
                                cat $WEBTOB_HTTP_M_PATH 2>/dev/null | grep -v "#" | grep -i "ServerTokens" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $WEBTOB_HTTP_M_PATH | grep -v \"#\" | grep -i \"ServerTokens\" ]" >> $OUTPUT_FILE 2>&1
                                echo "-ServerTokens 설정이 존재하지 않습니다.(default : off)" >> $OUTPUT_FILE 2>&1
                            fi
                        fi
                    done
                else
                    echo "[WEBTOB 관련 설정파일(http.m)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-JEUS 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... U-71,SRV-148 NGINX"
                    CHECK_VAR_01=0
                    for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                        if [ -f "$NGINX_CONFIG_PATH" ]; then
                            if [ "$(cat "$NGINX_CONFIG_PATH" | grep -v "#" | grep -i "server_tokens" | wc -l)" -gt 0 ]; then
                                echo "[# cat $NGINX_CONFIG_PATH | grep -v \"#\" | grep -i \"server_tokens\" ]" >> $OUTPUT_FILE 2>&1
                                cat $NGINX_CONFIG_PATH | grep -v "#" | grep -i "server_tokens" >> $OUTPUT_FILE 2>&1
                                CHECK_VAR_01=1
                            fi
                        fi
                    done
                    if [ $CHECK_VAR_01 -eq 0 ]; then
                        echo "nginx.conf 파일 에서 server_tokens 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                        echo "" >> $OUTPUT_FILE 2>&1
                        echo "============" >> $OUTPUT_FILE 2>&1
                        echo "-확인한 conf 파일 목록-" >> $OUTPUT_FILE 2>&1
                        for NGINX_CONFIG_PATH in $NGINX_CONFIG_PATHS; do
                            if [ -f "$NGINX_CONFIG_PATH" ]; then
                                echo "$NGINX_CONFIG_PATH" >> $OUTPUT_FILE 2>&1
                            fi
                        done
                    fi
                fi
            fi
            #####
        #####
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "HIDE_APACHE_WEB_SERVICE_INFORMATION_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/U-71" 2>&1
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-148" 2>&1
}
#SRV-060
CHANGE_DEFAULT_WEB_SERVICE_ACCOUNTS() {
    echo "CHANGE_DEFAULT_WEB_SERVICE_ACCOUNTS_START"
    OUTPUT_FILE="${CREATE_FILE_DIR}/VULNERABILITY/SRV-060.hangrp"
    OUTPUT_FILE2="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-060_REF01.hangrp"
    OUTPUT_FILE3="${CREATE_FILE_DIR}/VULNERABILITY_REF/SRV-060_REF02.hangrp"

    SECURITY_STATUS="CHECK"
    SECURITY_TMP01=""
    SECURITY_TMP02=""
    SECURITY_TMP03=""

    echo "" >> $OUTPUT_FILE 2>&1
    ###############################
    #REDHAT 계열, Solaris 계열, AIX, HP-UX
    if [ $Linux_CHECK_00 -eq 1 ] || [ $SOLARIS_CHECK_00 -eq 1 ] || [ $AIX_CHECK_00 -eq 1 ] || [ $HP_CHECK_00 -eq 1 ]; then
        echo "" >> $OUTPUT_FILE 2>&1
        cat "${CREATE_FILE_DIR}/Service_check/webcheck.hangrp" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE 2>&1

        
        if [ $WEB_CHECK_01 = 1 ] ; then
        #####
            if [ $PS_APACHE = 1 ] ; then
                if [ $PS_APACHE_STATUS = 1 ] ; then
                    echo "[[HTTPD,APACHE 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-Apache 해당사항 없음" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_TOMCAT = 1 ] ; then
                if [ $PS_TOMCAT_STATUS = 1 ] ; then
                    echo "[[TOMCAT 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... SRV-060 TOMCAT"
                    for TOMCAT_USERS_XML_PATH in $TOMCAT_USERS_XML_PATHS; do
                        if [ -f "$TOMCAT_USERS_XML_PATH" ]; then
                            if [ "$(cat "$TOMCAT_USERS_XML_PATH" | grep -i "password" | wc -l)" -gt 0 ]; then
                                echo "[# cat $TOMCAT_USERS_XML_PATH | grep -i  \"password\"]" >> $OUTPUT_FILE 2>&1
                                cat $TOMCAT_USERS_XML_PATH 2>/dev/null | grep -i "password" >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $TOMCAT_USERS_XML_PATH  | grep -i  \"password\"]" >> $OUTPUT_FILE 2>&1
                                echo "-password 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                            # 주석삭제
                            # if [ "$(cat "$TOMCAT_USERS_XML_PATH" | grep -v "<!--" | grep -i "password" | wc -l)" -gt 0 ]; then
                            #     echo "[# cat $TOMCAT_USERS_XML_PATH | grep -v \"<\\!--\" | grep -i  \"password\"]" >> $OUTPUT_FILE 2>&1
                            #     cat $TOMCAT_USERS_XML_PATH 2>/dev/null | grep -v "<!--" | grep -i "password" >> $OUTPUT_FILE 2>&1
                            #     echo "" >> $OUTPUT_FILE 2>&1
                            # else
                            #     echo "[# cat $TOMCAT_USERS_XML_PATH | grep -v \"<\\!--\" | grep -i  \"password\"]" >> $OUTPUT_FILE 2>&1
                            #     echo "-password 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            #     echo "" >> $OUTPUT_FILE 2>&1
                            # fi
                        fi
                    done
                else
                    echo "[TOMCAT 관련 설정파일(server.xml)를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            #https://technet.tmaxsoft.com/upload/download/online/webtob/pver-20180725-000001/administrator-guide/config_ref.html
            if [ $PS_WEBTOB = 1 ] ; then
                if [ $PS_WEBTOB_STATUS = 1 ] ; then
                    echo "[[WEBTOB 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-WEBTOB 해당사항 없음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_JEUS = 1 ] ; then
                if [ $PS_JEUS_STATUS = 1 ] ; then
                    echo "[[JEUS 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                    echo "debug: It can take a long time ... SRV-060 JEUS"
                    for JEUS_ACCOUNTS_PATH in $JEUS_ACCOUNTS_PATHS; do
                        if [ -f "$JEUS_ACCOUNTS_PATH" ]; then
                            if [ "$(cat "$JEUS_ACCOUNTS_PATH" | grep -i "password" | wc -l)" -gt 0 ]; then
                                echo "[# cat $JEUS_ACCOUNTS_PATH | grep -i  \"password\"]" >> $OUTPUT_FILE 2>&1
                                if [ $GREP_AB_TMP -gt 0 ]; then
                                    cat $JEUS_ACCOUNTS_PATH 2>/dev/null | grep -i -A 2 -B 2 "password" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                                else
                                    #1:patterns, 2:file, 3:lines_before, 4:lines_after
                                    grep_AB_shell "password" "$JEUS_ACCOUNTS_PATH" "2" "2"
                                    cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                                fi
                                echo "" >> $OUTPUT_FILE 2>&1
                            else
                                echo "[# cat $JEUS_ACCOUNTS_PATH | grep -i  \"password\"]" >> $OUTPUT_FILE 2>&1
                                echo "-password 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                                echo "" >> $OUTPUT_FILE 2>&1
                            fi
                            # 주석삭제
                            # if [ "$(cat "$JEUS_ACCOUNTS_PATH" | grep -v "<!--" | grep -i "password" | wc -l)" -gt 0 ]; then
                            #     echo "[# cat $JEUS_ACCOUNTS_PATH | grep -v \"<\\!--\" | grep -i  \"password\"]" >> $OUTPUT_FILE 2>&1
                            #     if [ $GREP_AB_TMP -gt 0 ]; then
                            #         cat $JEUS_ACCOUNTS_PATH 2>/dev/null | grep -v "<!--" | grep -i -A 2 -B 2 "password" | sed 's/ //g' >> $OUTPUT_FILE 2>&1
                            #     else
                            #         #1:patterns, 2:file, 3:lines_before, 4:lines_after
                            #         grep_AB_shell "password" "$JEUS_ACCOUNTS_PATH" "2" "2"
                            #         cat "${CREATE_FILE_DIR}/VULNERABILITY_REF/grepAB_tmp.hangrp" >> $OUTPUT_FILE 2>&1
                            #     fi
                            #     echo "" >> $OUTPUT_FILE 2>&1
                            # else
                            #     echo "[# cat $JEUS_ACCOUNTS_PATH | grep -v \"<\\!--\" | grep -i  \"password\"]" >> $OUTPUT_FILE 2>&1
                            #     echo "-password 설정이 존재하지 않습니다." >> $OUTPUT_FILE 2>&1
                            #     echo "" >> $OUTPUT_FILE 2>&1
                            # fi
                        fi
                    done
                else
                    echo "[JEUS 관련 디렉터리를 찾을 수 없습니다.]" >> $OUTPUT_FILE 2>&1
                    echo "" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
            #####
            if [ $PS_NGINX = 1 ] ; then
                if [ $PS_NGINX_STATUS = 1 ] ; then
                    echo "[[NGINX 서비스]]" >> $OUTPUT_FILE 2>&1
                    echo "-WEBTOB 해당사항 없음" >> $OUTPUT_FILE 2>&1
                fi
            fi
            #####
        #####
        fi
    fi
    ###############################
    echo "" >> $OUTPUT_FILE 2>&1
    echo "CHANGE_DEFAULT_WEB_SERVICE_ACCOUNTS_COMPLETE"
    echo $SECURITY_STATUS | head -n 1 > "${CREATE_FILE_DIR}/SECURITY_STATUS/SRV-060" 2>&1
}

COMMAND_COPY
USER_ENVIROMENT_FILE
#U-01,SRV-026
ACCOUNT_REMOTE_ACCESS_RESTRICTION
#U-02,SRV-069,SRV-075
PASSWORD_COMPLEXITY_CONFIGURATION
#U-03,SRV-127
ACCOUNT_LOCKOUT_THRESHOLD_CONFIGURATION
#U-04,SRV-070
USER_PASSWORD_ENCRYPT
#U-44
PROHIBIT_UID_OTHER_THAN_ROOT_TO_BE_0
#U-45,SRV-131
RESTRICT_SU_COMMAND_TO_SPECIFIC_GROUPS_INSUFFICIENT
#U-46
SET_PASSWORD_MINIMUM_LENGTH
#U-47
SET_MAXIMUM_PASSWORD_USAGE_PERIOD
#U-48
SET_MINIMUM_PASSWORD_USAGE_PERIOD
#U-49,SRV-074
REMOVE_UNUSED_ACCOUNTS
#U-50,SRV-073
UNNECESSARY_USERS_IN_ADMIN_GROUP
#U-51,SRV-164
PROHIBIT_NONEXISTENT_ACCOUNTS_FOR_GID
#U-52,SRV-142
PROHIBIT_DUPLICATE_UID
#U-53,SRV-165
USER_SHELL_CHECK
#U-54,SRV-028
SESSION_TIMEOUT_CONFIGURATION
#U-05,SRV-121
ROOT_HOME_PATH_PERMISSIONS_AND_PATH_CONFIGURATION
#U-06,SRV-095
SET_FILE_AND_DIRECTORY_OWNERSHIP
#U-07
SET_ETC_PASSWD_FILE_OWNERSHIP_AND_PERMISSIONS
#U-08
SET_ETC_SHADOW_FILE_OWNERSHIP_AND_PERMISSIONS
#U-09
SET_ETC_HOSTS_FILE_OWNERSHIP_AND_PERMISSIONS
#U-10
SET_ETC_XINETD_CONF_FILE_OWNERSHIP_AND_PERMISSIONS
#U-11
SET_ETC_SYSLOG_CONF_FILE_OWNERSHIP_AND_PERMISSIONS
#U-12
SET_ETC_SERVICES_FILE_OWNERSHIP_AND_PERMISSIONS
#U-55
SET_HOSTS_LPD_FILE_OWNERSHIP_AND_PERMISSIONS
#SRV-084
SET_INSUFFICIENT_PERMISSIONS_FOR_SYSTEM_CRITICAL_FILES
#U-13,SRV-091
CHECK_SUID_SGID_STICKY_BIT_SETTINGS_IN_FILES
#U-14
SET_OWNERSHIP_AND_PERMISSIONS_FOR_USER_SYSTEM_STARTUP_AND_ENVIRONMENT_FILES
#SRV-096
INSUFFICIENT_OWNERSHIP_OR_PERMISSIONS_FOR_USER_ENVIRONMENT_FILES
#U-15,SRV-093
CHECK__WORLD_WRITABLE_FILES
#U-16,SRV-144
CHECK_NONEXISTENT_DEVICE_FILES_IN_DEV
#U-17,SRV-025
PROHIBIT_USE_OF_HOME__rhosts_AND_hosts_equiv
#U-18,SRV-027
RESTRICT_ACCESS_BY_IP_AND_PORT
#U-56,SRV-122
MANAGE_UMASK_CONFIGURATION
#U-57,SRV-092
SET_HOME_DIRECTORY_OWNERSHIP_AND_PERMISSIONS
#U-58
MANAGE_EXISTENCE_OF_HOME_DIRECTORY_SPECIFIED
#U-59,SRV-166
SEARCH_AND_REMOVE_HIDDEN_FILES_AND_DIRECTORIES
#U-19
DISABLE_FINGER_SERVICE
#U-21
DISABLE_R_SERVICES
#U-23
DISABLE_VULNERABLE_SERVICES_TO_DOS_ATTACKS
#U-28
CHECK_NIS_AND_NISPLUS_CONFIGURATION
#U-29
DISABLE_TFTP_AND_TALK_SERVICES
#SRV-035
ENABLE_VULNERABLE_SERVICES
#U-20,SRV-013
DISABLE_ANONYMOUS_FTP
#U-61,SRV-037
CHECK_FTP_SERVICE
#U-62
RESTRICT_FTP_ACCOUNT_SHELL
#U-63,SRV-161
SET_FTPUSERS_FILE_OWNERSHIP_AND_PERMISSIONS
#U-64,SRV-011
CONFIGURE_FTPUSERS_FILE
#SRV-021
INCOMPLETE_ACCESS_CONTROL_CONFIGURATION_FOR_FTP_SERVICE
#SRV-171
EXPOSURE_OF_FTP_SERVICE_INFORMATION
#U-22
SET_CRON_FILE_OWNERSHIP_AND_PERMISSIONS
#U-65
SET_AT_FILE_OWNERSHIP_AND_PERMISSIONS
#SRV-081
INCOMPLETE_PERMISSIONS_CONFIGURATION_FOR_CRONTAB_SETTINGS_FILE
#SRV-094
INCOMPLETE_PERMISSIONS_CONFIGURATION_FOR_CRONTAB_REFERENCE_FILE
#SRV-112
UNCONFIGURED_CRON_SERVICE_LOGGING
#SRV-133
INCOMPLETE_USER_RESTRICTIONS_FOR_CRON_SERVICE
#U-24,SRV-015
DISABLE_NFS_SERVICE
#U-25
ENFORCE_ACCESS_CONTROLS_FOR_NFS
#U-69
RESTRICT_ACCESS_TO_NFS_CONFIGURATION_FILES
#SRV-014
INCOMPLETE_NFS_ACCESS_CONTROL
#U-26,SRV-034
REMOVE_AUTOMOUNTD
#U-27,SRV-016
CHECK_RPC_SERVICE
#U-30,SRV-007
CHECK_SENDMAIL_VERSION
#U-31,SRV-009
RESTRICT_SPAM_MAIL_RELAY
#U-32,SRV-010
PREVENT_SENDMAIL_EXECUTION_BY_REGULAR_USERS
#U-70,SRV-005
RESTRICT_EXPN_AND_VRFY_COMMANDS
#SRV-004
DISABLE_UNNECESSARY_SMTP_SERVICES
#SRV-006
IMPROVE_LOG_LEVEL_FOR_SMTP_SERVICE
#SRV-008
CONFIGURE_DOS_PREVENTION_FOR_SMTP_SERVICE
#SRV-170
PROTECT_SENSITIVE_INFORMATION_IN_SMTP_SERVICE
#U-33,SRV-064
APPLY_SECURITY_PATCHES_TO_DNS_VERSION
#U-34,SRV-066
CONFIGURE_DNS_ZONE_TRANSFER_SETTINGS
#SRV-062
PROTECT_SENSITIVE_INFORMATION_IN_DNS_SERVICE
#SRV-063
IMPROVE_RECURSIVE_QUERY_CONFIGURATION_FOR_DNS
#SRV-173
CONFIGURE_SECURE_DYNAMIC_UPDATES_FOR_DNS_SERVICE
#SRV-174
DISABLE_UNNECESSARY_DNS_SERVICES
#U-60,SRV-158
ENABLE_SSH_REMOTE_ACCESS
#U-66,SRV-147
CHECK_SNMP_SERVICE_STATUS
#U-67
CONFIGURE_COMPLEXITY_FOR_SNMP_COMMUNITY_STRINGS
#U-68
I_PROVIDE_LOGIN_WARNING_MESSAGE
#SRV-163
F_PROVIDE_LOGIN_WARNING_MESSAGE
#U-42,SRV-118
APPLY_LATEST_SECURITY_PATCHES_AND_VENDOR_RECOMMENDATIONS
#U-43,SRV-115
PERFORM_REGULAR_LOG_REVIEW_AND_REPORTING
#U-72,SRV-109
CONFIGURE_SYSTEM_LOGGING_PER_POLICY
#SRV-012
PROTECT_SENSITIVE_INFORMATION_IN_NETRC_FILE
#SRV-022
MANAGE_UNSET_PASSWORDS_AND_EMPTY_PASSWORDS_FOR_ACCOUNTS
#SRV-082
IMPROVE_PERMISSIONS_FOR_SYSTEM_CRITICAL_DIRECTORIES
#SRV-083
IMPROVE_PERMISSIONS_FOR_SYSTEM_STARTUP_SCRIPTS
#SRV-087
IMPROVE_PERMISSIONS_FOR_C_COMPILER
#SRV-108
IMPROVE_ACCESS_CONTROL_AND_MANAGEMENT_FOR_LOGS
#SRV-134
ENABLE_EXECUTION_PREVENTION_FOR_STACK_REGION
#SRV-135
IMPROVE_TCP_SECURITY_SETTINGS
#SRV-175
CONFIGURE_NTP_AND_TIME_SYNCHRONIZATION
#SRV-001
USE_VULNERABLE_SNMP_VERSION
#SRV-048
DISABLE_UNNECESSARY_WEB_SERVICES
#U-35,SRV-040
REMOVE_WEB_SERVICE_DIRECTORY_LISTING
#U-36,SRV-045
RESTRICT_PERMISSIONS_FOR_WEB_SERVICE_PROCESSES
#U-37,SRV-042
RESTRICT_ACCESS_TO_PARENT_DIRECTORIES_IN_WEB_SERVICE
#U-38,SRV-043
REMOVE_UNNECESSARY_FILES_IN_WEB_SERVICE
#U-39,SRV-047
DISABLE_SYMBOLIC_LINKS_IN_WEB_SERVICE
#U-40,SRV-044
RESTRICT_FILE_UPLOAD_AND_DOWNLOAD_IN_WEB_SERVICE
#U-41,SRV-046
SEGREGATE_WEB_SERVICE_AREAS
#U-71,SRV-148
HIDE_APACHE_WEB_SERVICE_INFORMATION
#SRV-060
CHANGE_DEFAULT_WEB_SERVICE_ACCOUNTS

#권한변경
#chmod -R 755 $CREATE_FILE_DIR

echo "GENERATE_INFRASTRUCTURE_DIAGNOSTIC_REPORT_START"

OS_CHECK_VALUE=""
if [ -f /etc/os-release ]; then
    OS_CHECK_VALUE=$(cat /etc/os-release | egrep -i "^ID=" | awk -F"=" '{print $2}' | sed 's/"//g')
fi

if [ "$OS_CHECK_VALUE" = "" ]; then
    if [ $SOLARIS_CHECK_00 -eq 1 ]; then
        OS_CHECK_VALUE="Solaris"
    elif [ $AIX_CHECK_00 -eq 1 ]; then
        OS_CHECK_VALUE="AIX"
    elif [ $HP_CHECK_00 -eq 1 ]; then
        OS_CHECK_VALUE="HP-UX"
    elif [ $SUSE_CHECK_00 -eq 1 ]; then
        OS_CHECK_VALUE="SUSE"
    else
        OS_CHECK_VALUE="Linux"
    fi
fi


CODE_STR=""

CODE_STR="U-01"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-01 root 계정 원격 접속 제한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 원격 터미널 서비스를 사용하지 않거나, 사용 시 root 직접 접속을 차단한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 원격 터미널 서비스 사용 시 root 직접 접속을 허용한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: root 계정은 운영체제의 모든기능을 설정 및 변경이 가능하여(프로세스, 커널변경 등) root 계정을 탈취하여 외부에서 원격을 이용한 시스템 장악 및 각종 공격으로(무작위 대입 공격) 인한 root 계정 사용 불가 위협" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-01_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-01_SRV-026.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-01_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-02"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-02 패스워드 복잡성 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능이 설정된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능이 설정되지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "참고: 기관별 정책 우선, 미존재시 문자 종류 중 2종류 이상을 조합하여 최소 10자리 이상 또는, 3종류 이상을 조합하여 최소 8자리 이상의 길이로 구성" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 복잡성 설정이 되어있지 않은 패스워드는 사회공학적인 유추가 가능 할 수 있으며 암호화된 패스워드 해시값을 무작위 대입공격, 사전대입 공격 등으로 단시간에 패스워드 크렉이 가능함 " >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-02_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-02_SRV-069_SRV-075.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-02_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-03"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-03 계정 잠금 임계값 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 계정 잠금 임계값이 10회 이하의 값으로 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 계정 잠금 임계값이 설정되어 있지 않거나, 10회 이하의 값으로 설정되지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "참고: 기관별 정책 우선" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 패스워드 탈취 공격(무작위 대입 공격, 사전 대입 공격, 추측 공격 등)의 인증 요청에 대해 설정된 패스워드와 일치 할 때까지 지속적으로 응답하여 해당 계정의 패스워드가 유출 될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-03_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-03_SRV-127.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-03_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-04"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-04 패스워드 파일 보호" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 쉐도우 패스워드를 사용하거나, 패스워드를 암호화하여 저장하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 쉐도우 패스워드를 사용하지 않고, 패스워드를 암호화하여 저장하지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 일부 오래된 시스템의 경우 /etc/passwd 파일에 패스워드가 평문으로 저장되므로 사용자 계정 패스워드가 암호화되어 저장되어 있는지 점검하여 비인가자의 패스워드 파일 접근 시에도 사용자 계정 패스워드가 안전하게 관리되고 있는지 확인하기 위함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-04_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-04_SRV-070.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-04_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-44"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-44 root 이외의 UID가 0금지" >> $CREATE_FILE_INFRA 2>&1
echo "양호: root 계정과 동일한 UID를 갖는 계정이 존재하지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: root 계정과 동일한 UID를 갖는 계정이 존재하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: root 계정과 동일 UID가 설정되어 있는 일반사용자 계정도 root 권한을 부여받아 관리자가 실행 할 수 있는 모든 작업이 가능함(서비스 시작, 중지, 재부팅, root 권한 파일 편집 등)/root와 동일한 UID를 사용하므로 사용자 감사 추적 시 어려움이 발생함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-44_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-44.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-44_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-45"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-45 root 계정 su 제한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: su 명령어를 특정 그룹에 속한 사용자만 사용하도록 제한되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: su 명령어를 모든 사용자가 사용하도록 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "참고: 일반 사용자 계정 없이 root 계정만 사용하는 경우 su 명령어 사용제한 불필요" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 무분별한 사용자 변경으로 타 사용자 소유의 파일을 변경 할 수 있으며 root 계정으로 변경하는 경우 관리자 권한을 획득 할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-45_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-45_SRV-131.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-45_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-46"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-46 패스워드 최소 길이 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 패스워드 최소 길이가 8자 이상으로 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 패스워드 최소 길이가 8자 미만으로 설정되어 있는 경우 " >> $CREATE_FILE_INFRA 2>&1
echo "참고: 패스워드 최소길이를 8자리 이상으로 설정하여도 특수문자, 대소문자, 숫자를 혼합하여 사용하여함" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 패스워드 문자열이 짧은 경우 유추가 가능 할 수 있으며 암호화된 패스워드 해시값을 무작위 대입공격, 사전대입 공격 등으로 단시간에 패스워드 크렉이 가능함 " >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-46_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-46.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-46_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-47"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-47 패스워드 최대 사용기간 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 패스워드 최대 사용기간이 90일(12주) 이하로 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 패스워드 최대 사용기간이 90일(12주) 이하로 설정되어 있지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "참고: 패스워드 정책 설정파일을 수정하여 패스워드 최대 사용기간을 90일(12주)로 설정" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 패스워드 최대 사용기간을 설정하지 않은 경우 비인가자의 각종 공격(무작위 대입 공격, 사전 대입 공격 등)을 시도할 수 있는 기간 제한이 없으므로 공격자 입장에서는 장기적인 공격을 시행할 수 있어 시행한 기간에 비례하여 사용자 패스워드가 유출될 수 있는 확률이 증가함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-47_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-47.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-47_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-48"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-48 패스워드 최소 사용기간 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 패스워드 최소 사용기간이 1일 이상 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 패스워드 최소 사용기간이 설정되어 있지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "참고: 패스워드 정책 설정파일을 수정하여 패스워드 최소 사용기간을 1일(1주)로 설정" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 최소 사용기간이 설정되어 있지 않아 반복적으로 즉시 변경이 가능한 경우 이전 패스워드 기억 횟수를 설정하여도 반복적으로 즉시 변경하여 이전 패스워드로 설정이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-48_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-48.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-48_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-49"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-49 불필요한 계정 제거" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 불필요한 계정이 존재하지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 불필요한 계정이 존재하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 로그인이 가능하고 현재 사용하지 않는 불필요한 계정은 사용중인 계정보다 상대적으로 관리가 취약하여 공격자의 목표가 되어 계정이 탈취될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-49_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-49_SRV-074.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-49_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-50"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-50 관리자 그룹에 최소한의 계정 포함" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 관리자 그룹에 불필요한 계정이 등록되어 있지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 관리자 그룹에 불필요한 계정이 등록되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 시스템을 관리하는 root 계정이 속한 그룹은 시스템 운영 파일에 대한 접근 권한이 부여되어 있으므로 해당 관리자 그룹에 속한 계정이 비인가자에게 유출될 경우 관리자 권한으로 시스템에 접근하여 계정 정보 유출, 환경설정 파일 및 디렉터리 변조 등의 위협이 존재함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-50_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-50_SRV-073.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-50_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-51"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-51 계정이 존재하지 않는 GID 금지" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 시스템 관리나 운용에 불필요한 그룹이 삭제 되어있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 시스템 관리나 운용에 불필요한 그룹이 존재할 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 계정이 존재하지 않는 그룹은 현재 사용되고 있는 그룹이 아닌 불필요한 그룹으로 삭제 조치가 필요함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-51_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-51_SRV-164.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-51_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-52"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-52 동일한 UID 금지" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 동일한 UID로 설정된 사용자 계정이 존재하지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 동일한 UID로 설정된 사용자 계정이 존재하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 중복된 UID가 존재할 경우 시스템은 동일한 사용자로 인식하여 소유자의 권한이 중복되어 불필요한 권한이 부여되며 시스템 로그를 이용한 감사 추적시 사용자가 구분되지 않음 (권한 할당은 그룹권한을 이용하여 운영)" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-52_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-52_SRV-142.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-52_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-53"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-53 사용자 shell 점검" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 로그인이 필요하지 않은 계정에 /bin/false(/sbin/nologin) 쉘이 부여되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 로그인이 필요하지 않은 계정에 /bin/false(/sbin/nologin) 쉘이 부여되지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협:  로그인이 불필요한 계정은 일반적으로 OS 설치 시 기본적으로 생성되는 계정으로 쉘이 설정되어 있을 경우, 공격자는 기본 계정들을 이용하여 시스템에 명령어를 실행 할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-53_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-53_SRV-165.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-53_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-54"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-54 Session Timeout 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: Session Timeout이 600초(10분) 이하로 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: Session Timeout이 600초(10분) 이하로 설정되지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: Session timeout 값이 설정되지 않은 경우 유휴 시간 내 비인가자의 시스템 접근으로 인해 불필요한 내부 정보의 노출 위험이 존재함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-54_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-54_SRV-028.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-54_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-05"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-05 root홈, 패스 디렉터리 권한 및 패스 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: PATH 환경변수에 \“.\” 이 맨 앞이나 중간에 포함되지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: PATH 환경변수에 \“.\” 이 맨 앞이나 중간에 포함되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: root 계정의 PATH(환경변수)에 정상적인 관리자 명령어(예: ls, mv, cp등)의 디렉터리 경로 보다 현재 디렉터리를 지칭하는 \“.\” 표시가 우선하면 현재 디렉터리에 변조된 명령어를 삽입하여 관리자 명령어 입력 시 악의적인 기능이 실행 될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-05_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-05_SRV-121.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-05_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-06"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-06 파일 및 디렉터리 소유자 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 소유자가 존재하지 않는 파일 및 디렉터리가 존재하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 소유자가 존재하지 않는 파일의 UID와 동일한 값으로 특정계정의 UID값을 변경하면 해당 파일의 소유자가 되어 모든 작업이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-06_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-06_SRV-095.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-06_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-07"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-07 /etc/passwd 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: /etc/passwd 파일의 소유자가 root이고, 권한이 644 이하인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: /etc/passwd 파일의 소유자가 root가 아니거나, 권한이 644 이하가 아닌경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 관리자(root) 외 사용자가 \“/etc/passwd\” 파일의 사용자 정보를 변조하여shell 변경, 사용자 추가/삭제 등 root를 포함한 사용자 권한 획득 가능" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
\echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-07_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-07.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-07_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-08"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-08 /etc/shadow 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: /etc/shadow 파일의 소유자가 root이고, 권한이 400 이하인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: /etc/shadow 파일의 소유자가 root가 아니거나, 권한이 400 이하가 아닌 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: /etc/shadow 파일을 관리자만 제어할 수 있게 하여 비인가자들의 접근을 차단하도록 shadow 파일 소유자 및 권한을 관리해야함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-08_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-08.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-08_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-09"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-09 /etc/hosts 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: /etc/hosts 파일의 소유자가 root이고, 권한이 600인 이하경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: /etc/hosts 파일의 소유자가 root가 아니거나, 권한이 600 이상인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: hosts 파일에 비인가자 쓰기 권한이 부여된 경우, 공격자는 hosts파일에 악의적인 시스템을 등록하여, 이를 통해 정상적인 DNS를 우회하여 악성사이트로의 접속을 유도하는 파밍(Pharming) 공격 등에 악용될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: hosts파일에 소유자외 쓰기 권한이 부여된 경우, 일반사용자 권한으로 hosts파일에 변조된 IP주소를 등록하여 정상적인 DNS를 방해하고 악성사이트로의 접속을 유도하는 파밍(Pharming) 공격 등에 악용될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-09_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-09.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-09_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-10"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-10 /etc/(x)inetd.conf 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: /etc/inetd.conf 파일의 소유자가 root이고, 권한이 600인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: /etc/inetd.conf 파일의 소유자가 root가 아니거나, 권한이 600이 아닌 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: (x)inetd.conf 파일에 소유자외 쓰기 권한이 부여된 경우, 일반사용자 권한으로 (x)inetd.conf 파일에 등록된 서비스를 변조하거나 악의적인 프로그램(서비스)를 등록할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-10_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-10.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-10_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-11"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-11 /etc/syslog.conf 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: /etc/syslog.conf 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: /etc/syslog.conf 파일의 소유자가 root(또는 bin, sys)가 아니거나, 권한이 644 이하가 아닌 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: syslog.conf 파일의 설정내용을 참조하여 로그의 저장위치가 노출되며 로그을 기록하지 않도록 설정하거나 대량의 로그를 기록하게 하여 시스템 과부하를 유도할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-11_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-11.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-11_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-12"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-12 /etc/services 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: /etc/services 파일의 소유자가 root(또는 bin, sys)이고, 권한이 644 이하인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: /etc/services 파일의 소유자가 root(또는 bin, sys)가 아니거나, 권한이 644 이하가 아닌 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: services 파일의 접근권한이 적절하지 않을 경우 비인가 사용자가 운영 포트번호를 변경하여 정상적인 서비스를 제한하거나, 허용되지 않은 포트를 오픈하여 악성 서비스를 의도적으로 실행할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-12_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-12.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-12_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-13"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-13 SUID, SGID, 설정 파일점검" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: SUID, SGID 파일의 접근권한이 적절하지 않을 경우 SUID, SGID 설정된 파일로 특정 명령어를 실행하여 root 권한 획득 가능함 " >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-13_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-13_SRV-091.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-13_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-14"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-14 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 홈 디렉터리 환경변수 파일 소유자가 root 또는, 해당 계정으로 지정되어 있고, 홈 디렉터리 환경변수 파일에 root와 소유자만 쓰기 권한이 부여된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 홈 디렉터리 환경변수 파일 소유자가 root 또는, 해당 계정으로 지정되지 않고, 홈 디렉터리 환경변수 파일에 root와 소유자 외에 쓰기 권한이 부여된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 홈 디렉터리 내의 사용자 파일 및 사용자별 시스템 시작파일 등과 같은 환경변수 파일의 접근권한 설정이 적절하지 않을 경우 비인가자가 환경변수 파일을 변조하여 정상 사용중인 사용자의 서비스가 제한 될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-14_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-14.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-14_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-15"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-15 world writable 파일 점검" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 시스템 중요 파일에 world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인하고 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 시스템 중요 파일에 world writable 파일이 존재하나 해당 설정 이유를 확인하고 있지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 시스템 파일과 같은 중요 파일에 world writable 설정이 될 경우, 일반사용자 및 비인가된 사용자가 해당 파일을 임의로 수정, 삭제가 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-15_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-15_SRV-093.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-15_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-16"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-16 /dev에 존재하지 않는 device 파일 점검" >> $CREATE_FILE_INFRA 2>&1
echo "양호: dev에 대한 파일 점검 후 존재하지 않은 device 파일을 제거한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: dev에 대한 파일 미점검 또는, 존재하지 않은 device 파일을 방치한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 공격자는 rootkit 설정파일들을 서버 관리자가 쉽게 발견하지 못하도록 /dev에 device 파일인 것처럼 위장하는 수법을 많이 사용함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-16_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-16_SRV-144.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-16_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-17"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-17 \$HOME/.rhosts, hosts.equiv" >> $CREATE_FILE_INFRA 2>&1
echo "양호: login, shell, exec 서비스를 사용하지 않거나, 사용 시 아래와 같은 설정이 적용된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 1./etc/hosts.equiv 및 \$HOME/.rhosts 파일 소유자가 root 또는, 해당 계정인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 2./etc/hosts.equiv 및 \$HOME/.rhosts 파일 권한이 600 이하인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 3./etc/hosts.equiv 및 \$HOME/.rhosts 파일 설정에 ‘+’ 설정이 없는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: login, shell, exec 서비스를 사용하고, 위와 같은 설정이 적용되지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: rlogin, rsh 등과 같은 ‘r’ command의 보안 설정이 적용되지 않은 경우, 원격지의 공격자가 관리자 권한으로 목표 시스템상의 임의의 명령을 수행시킬수 있으며, 명령어 원격 실행을 통해 중요 정보 유출 및 시스템 장애를 유발시킬 수 있음. 또한 공격자 백도어 등으로도 활용될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: r-command(rlogin, rsh등) 서비스의 접근통제에 관련된 파일로 권한설정을 미 적용한 경우 r-command 서비스 사용 권한을 임의로 등록하여 무단 사용이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-17_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-17_SRV-025.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-17_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-18"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-18 접속 IP 및 포트 제한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한을 설정한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 접속을 허용할 특정 호스트에 대한 IP 주소 및 포트 제한을 설정하지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 허용할 호스트에 대한 IP 및 포트제한이 적용되지 않은 경우, Telnet, FTP같은 보안에 취약한 네트워크 서비스를 통하여 불법적인 접근 및 시스템 침해사고가 발생할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-18_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-18_SRV-027.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-18_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-55"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-55 hosts.lpd 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: hosts.lpd 파일이 삭제되어 있거나 불가피하게 hosts.lpd 파일을 사용할 시 파일의 소유자가 root이고 권한이 600인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: hosts.lpd 파일이 삭제되어 있지 않거나 파일의 소유자가 root가 아니고 권한이 600이 아닌 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: hosts.lpd 파일의 접근권한이 적절하지 않을 경우 비인가자가 /etc/hosts.lpd 파일을 수정하여 허용된 사용자의 서비스를 방해할 수 있으며, 호스트 정보를 획득 할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-55_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-55.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-55_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-56"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-56 UMASK 설정 관리" >> $CREATE_FILE_INFRA 2>&1
echo "양호: UMASK 값이 022 이상으로 설정된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: UMASK 값이 022 이상으로 설정되지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 잘못된 UMASK 값으로 인해 파일 및 디렉터리 생성시 과도하게 퍼미션이 부여 될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-56_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-56_SRV-122.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-56_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-57"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-57 홈디렉토리 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 홈 디렉터리 소유자가 해당 계정이고, 타 사용자 쓰기 권한이 제거된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 홈 디렉터리 소유자가 해당 계정이 아니고, 타 사용자 쓰기 권한이 부여된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 홈 디렉터리 내 설정파일 변조 시 정상적인 서비스 이용이 제한될 우려가 존재함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-57_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-57_SRV-092.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-57_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-58"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-58 홈디렉토리로 지정한 디렉토리의 존재 관리" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 홈 디렉터리가 존재하지 않는 계정이 발견되지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 홈 디렉터리가 존재하지 않는 계정이 발견된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: passwd 파일에 설정된 홈디렉터리가 존재하지 않는 경우, 해당 계정으로 로그인시 홈디렉터리가 루트 디렉터리(\“/\”)로 할당되어 접근이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-58_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-58.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-58_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-59"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-59 숨겨진 파일 및 디렉토리 검색 및 제거" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 불필요하거나 의심스러운 숨겨진 파일 및 디렉터리를 삭제한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 불필요하거나 의심스러운 숨겨진 파일 및 디렉터리를 방치한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 숨겨진 파일 및 디렉터리 중 의심스러운 내용은 정상 사용자가 아닌 공격자에 의해 생성되었을 가능성이 높음으로 이를 발견하여 제거함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-59_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-59_SRV-166.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-59_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-19"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-19 Finger 서비스 비활성화" >> $CREATE_FILE_INFRA 2>&1
echo "양호: Finger 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: Finger 서비스가 활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 비인가자에게 사용자 정보가 조회되어 패스워드 공격을 통한 시스템 권한 탈취 가능성이 있으므로 사용하지 않는다면 해당 서비스를 중지하여야 함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-19_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-19.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-19_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-20"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-20 Anonymous FTP 비활성화" >> $CREATE_FILE_INFRA 2>&1
echo "양호: Anonymous FTP (익명 ftp) 접속을 차단한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: Anonymous FTP(익명 FTP)를 사용 시 anonymous 계정으로 로그인 후 디렉터리에 쓰기 권한이 설정되어 있다면 악의적인 사용자가 local exploit을 사용하여 시스템에 대한 공격을 가능하게 함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-20_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-20_SRV-013.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-20_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-21"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-21 r 계열 서비스 비활성화" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 불필요한 r 계열 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 불필요한 r 계열 서비스가 활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: rsh, rlogin, rexec 등의 r command를 이용하여 원격에서 인증절차 없이 터미널 접속, 쉘 명령어를 실행이 가능함 " >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-21_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-21.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-21_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-22"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-22 crond 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: crontab 명령어 일반사용자 사용가능하거나, crond 관련 파일 640 이상인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: root 외 일반사용자에게도 crontab 명령어를 사용할 수 있도록 할 경우, 고의 또는 실수로 불법적인 예약 파일 실행으로 시스템 피해를 일으킬 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-22_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-22.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-22_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-23"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-23 DoS 공격에 취약한 서비스 비활성화" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 사용하지 않는 DoS 공격에 취약한 서비스가 비활성화 된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 사용하지 않는 DoS 공격에 취약한 서비스가 활성화 된 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 해당 서비스가 활성화되어 있는 경우 시스템 정보 유출 및 DoS(서비스 거부 공격)의 대상이 될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-23_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-23.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-23_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-24"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-24 NFS 서비스 비활성화" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 불필요한 NFS 서비스 관련 데몬이 활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: NFS 서비스는 서버의 디스크를 클라이언트와 공유하는 서비스로 적정한 보안설정이 적용되어 있지 않다면 불필요한 파일 공유로 인한 유출위험이 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-24_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-24_SRV-015.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-24_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-25"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-25 NFS 접근 통제" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 불필요한 NFS 서비스를 사용하고 있고, everyone 공유를 제한하지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 접근제한 설정이 적절하지 않을 경우 인증절차 없이 비인가자의 디렉터리나 파일의 접근이 가능하며, 해당 공유 시스템에 원격으로 마운트하여 중요 파일을 변조하거나 유출할 위험이 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-25_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-25.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-25_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-26"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-26 automountd 제거" >> $CREATE_FILE_INFRA 2>&1
echo "양호: automountd 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: automountd 서비스가 활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 파일 시스템의 마운트 옵션을 변경하여 root 권한을 획득할 수 있으며, 로컬공격자가 automountd 프로세스 권한으로 임의의 명령을 실행할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-26_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-26_SRV-034.hangrp"  >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-26_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-27"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-27 RPC 서비스 확인" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 불필요한 RPC 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 불필요한 RPC 서비스가 활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 버퍼 오버플로우(Buffer Overflow), Dos, 원격실행 등의 취약성이 존재하는 RPC 서비스를 통해 비인가자의 root 권한 획득 및 침해사고 발생 위험이 있으므로 서비스를 중지하여야 함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-27_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-27_SRV-016.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-27_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-28"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-28 NIS, NIS+ 점검" >> $CREATE_FILE_INFRA 2>&1
echo "양호: NIS 서비스가 비활성화 되어 있거나, 필요 시 NIS+를 사용하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: NIS 서비스가 활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 보안상 취약한 서비스인 NIS를 사용하는 경우 비인가자가 타시스템의 root 권한 획득이 가능하므로 사용하지 않는 것이 가장 바람직하나 만약 NIS를 사용해야 하는 경우 사용자 정보보안에 많은 문제점을 내포하고 있는 NIS보다 NIS+를 사용하는 것을 권장함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-28_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-28.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-28_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-29"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-29 tftp, talk 서비스 비활성화" >> $CREATE_FILE_INFRA 2>&1
echo "양호: tftp, talk, ntalk 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: tftp, talk, ntalk 서비스가 활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 사용하지 않는 서비스나 취약점이 발표된 서비스 운용 시 공격 시도 가능" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-29_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-29.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-29_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-30"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-30 Sendmail 버전 점검" >> $CREATE_FILE_INFRA 2>&1
echo "양호: Sendmail 버전이 최신버전인 경우 " >> $CREATE_FILE_INFRA 2>&1
echo "취약: Sendmail 버전이 최신버전이 아닌 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 취약점이 발견된 Sendmail 버전의 경우 버퍼 오버플로우(Buffer Overflow) 공격에 의한 시스템 권한 획득 및 주요 정보 요출 가능성이 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-30_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-30_SRV-007.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-30_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-31"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-31 스팸 메일 릴레이 제한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: SMTP 서비스를 사용하며 릴레이 제한이 설정되어 있지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: SMTP 서버의 릴레이 기능을 제한하지 않는 경우, 악의적인 사용목적을 가진 사용자들이 스팸메일 서버로 사용하거나 Dos공격의 대상이 될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-31_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-31_SRV-009.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-31_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-32"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-32 일반사용자의 Sendmail 실행 방지" >> $CREATE_FILE_INFRA 2>&1
echo "양호: SMTP 서비스 미사용 또는, 일반 사용자의 Sendmail 실행 방지가 설정된경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: SMTP 서비스 사용 및 일반 사용자의 Sendmail 실행 방지가 설정되어 있지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 일반 사용자가 q 옵션을 이용해서 메일큐, Sendmail 설정을 보거나 메일큐를 강제적으로 drop 시킬 수 있어 악의적으로 SMTP 서버의 오류를 발생시킬 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-32_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-32_SRV-010.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-32_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-33"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-33 DNS 보안 버전 패치" >> $CREATE_FILE_INFRA 2>&1
echo "양호: DNS 서비스를 사용하지 않거나 주기적으로 패치를 관리하고 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: DNS 서비스를 사용하며 주기적으로 패치를 관리하고 있지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 최신버전(2016.01 기준 9.10.3-P2) 이하의 버전에서는 서비스거부 공격, 버퍼오버플로우(Buffer Overflow) 및 DNS 서버 원격 침입 등의 취약성이 존재함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-33_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-33_SRV_064.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-33_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-34"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-34 DNS Zone Transfer 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: DNS 서비스 미사용 또는, Zone Transfer를 허가된 사용자에게만 허용한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: DNS 서비스를 사용하며 Zone Transfer를 모든 사용자에게 허용한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 비인가자 Zone Transfer를 이용해 Zone 정보를 전송받아 호스트 정보, 시스템 정보, 네트워크 구성 형태 등의 많은 정보를 파악할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-34_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-34_SRV-066.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-34_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-35"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-35 웹서비스 디렉토리 리스팅 제거" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 디렉터리 검색 기능을 사용하지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 디렉터리 검색 기능을 사용하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 디렉터리 검색 기능이 활성화 되어 있을 경우, 사용자에게 디렉터리내 파일이 표시되어 WEB 서버 구조 노출뿐만 아니라 백업 파일이나 소스파일, 공개되어서는 안되는 파일 등이 노출 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-35_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-35_SRV-040.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-35_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-36"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-36 웹서비스 웹 프로세스 권한 제한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: Apache 데몬이 root 권한으로 구동되지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: Apache 데몬이 root 권한으로 구동되는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 웹서비스 데몬을 root 권한으로 실행시 웹서비스가 파일을 생성, 수정하는 과정에서 웹서비스에 해당하지 않는 파일도 root 권한에 의해 쓰기가 가능하며 해킹 발생시 root 권한이 노출 될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-36_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-36_SRV-045.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-36_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-37"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-37 웹서비스 상위 디렉토리 접근 금지" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 상위 디렉터리에 이동제한을 설정한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 상위 디렉터리에 이동제한을 설정하지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 상위 경로로 이동하는 것이 가능할 경우 접근하고자 하는 디렉터리의 하위 경로에 접속하여 상위경로로 이동함으로써 악의적인 목적을 가진 사용자의 접근이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-37_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-37_SRV-042.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-37_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-38"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-38 웹서비스 불필요한 파일 제거" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: Apache 설치 시 htdocs 디렉터리 내에 매뉴얼 파일은 시스템 관련정보를 노출하거나 해킹에 악용될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-38_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-38_SRV-043.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-38_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-39"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-39 웹서비스 링크 사용금지" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 심볼릭 링크, aliases 사용을 제한한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 심볼릭 링크, aliases 사용을 제한하지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 웹 루트 폴더(DocumentRoot)에 root 디렉터리(/)를 링크하는 파일이 있으며 디렉터리 인덱싱 기능이 차단되어 있어도 root 디렉터리 열람이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-39_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-39_SRV-047.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-39_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-40"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-40 웹서비스 파일 업로드 및 다운로드 제한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 파일 업로드 및 다운로드를 제한한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 파일 업로드 및 다운로드를 제한하지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 악의적 목적을 가진 사용자가 반복 업로드 및 웹 쉘 공격 등으로 시스템 권한을 탈취하거나 대용량 파일의 반복 업로드로 서버자원을 고갈시키는 공격의 위험이 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-40_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-40_SRV-044.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-40_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-41"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-41 웹서비스 영역의 분리" >> $CREATE_FILE_INFRA 2>&1
echo "양호: DocumentRoot를 별도의 디렉터리로 지정한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: DocumentRoot를 기본 디렉터리로 지정한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 웹 서버의 루트 디렉터리와 OS의 루트 디렉터리를 다르게 지정하지 않았을 경우, 비인가자가 웹 서비스를 통해 해킹이 성공할 경우 시스템 영역까지 접근이 가능하여 피해가 확장될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-41_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-41_SRV-046.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-41_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-60"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-60 ssh 원격접속 허용" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 원격 접속 시 SSH 프로토콜을 사용하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 원격 접속 시 Telnet, FTP 등 안전하지 않은 프로토콜을 사용하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 원격 접속 시 Telnet, FTP 등은 암호화되지 않은 상태로 데이터를 전송하기 때문에 아이디/패스워드 및 중요 정보가 외부로 유출될 위험성이 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-60_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-60_SRV-158.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-60_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-61"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-61 ftp 서비스 확인" >> $CREATE_FILE_INFRA 2>&1
echo "양호: FTP 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: FTP 서비스가 활성화 되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: FTP 서비스는 통신구간이 평문으로 전송되어 계정정보(아이디, 패스워드) 및 전송 데이터의 스니핑이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-61_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-61_SRV-037.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-61_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-62"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-62 ftp 계정 shell 제한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: ftp 계정에 /bin/false 쉘이 부여되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: ftp 계정에 /bin/false 쉘이 부여되어 있지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 불필요한 기본 계정에 쉘(Shell)을 부여할 경우, 공격자에게 해당 계정이 노출되어 ftp 기본 계정으로 시스템 접근하여 공격이 가능해짐" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-62_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-62.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-62_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-63"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-63 ftpusers 파일 소유자 및 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: ftpusers 파일의 소유자가 root이고, 권한이 640 이하인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: ftpusers 파일의 소유자가 root가 아니거나, 권한이 640 이하가 아닌경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: ftpusers 파일에 인가되지 않은 사용자를 등록하여 해당 계정을 이용, 불법적인 FTP 서비스에 접근이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-63_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-63_SRV-161.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-63_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-64"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-64 ftpusers 파일 설정(FTP 서비스 root 계정 접근제한)" >> $CREATE_FILE_INFRA 2>&1
echo "양호: FTP 서비스가 비활성화 되어 있거나, 활성화 시 root 계정 접속을 차단한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: FTP 서비스가 활성화 되어 있고, root 계정 접속을 허용한 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: FTP 서비스는 아이디 및 패스워드가 암호화되지 않은 채로 전송되어 스니핑에 의해서 관리자 계정의 아이디 및 패스워드가 노출될 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-64_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-64_SRV-011.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-64_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-65"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-65 at 서비스 권한 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: at 명령어 일반사용자 금지 및 at 관련 파일 640 이하인 경우 " >> $CREATE_FILE_INFRA 2>&1
echo "취약: at 명령어 일반사용자 사용가능하거나, at 관련 파일 640 이상인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: root 외 일반사용자에게도 at 명령어를 사용할 수 있도록 할 경우, 고의 또는 실수로 불법적인 예약 파일 실행으로 시스템 피해를 일으킬 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-65_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-65.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-65_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-66"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-66 SNMP 서비스 구동 점검" >> $CREATE_FILE_INFRA 2>&1
echo "양호: SNMP 서비스를 사용하지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: SNMP 서비스를 사용하는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: SNMP 서비스로 인하여 시스템의 주요 정보 유출 및 정보의 불법수정이 발생할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-66_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-66_SRV-147.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-66_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-67"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-67 SNMP 서비스 Community String의 복잡성 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: SNMP Community 이름이 public, private 이 아닌 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: SNMP Community 이름이 public, private 인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: Community String은 Default로 public, private로 설정된 경우가 많으며, 이를 변경하지 않으면 이 String을 악용하여 환경설정 파일 열람 및 수정을 통한 공격, 간단한 정보수집에서부터 관리자 권한 획득 및 Dos공격까지 다양한 형태의 공격이 가능함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-67_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-67.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-67_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-68"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-68 로그온 시 경고 메시지 제공" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 서버 및 Telnet, FTP, SMTP, DNS 서비스에 로그온 메시지가 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 서버 및 Telnet, FTP, SMTP, DNS 서비스에 로그온 메시지가 설정되어 있지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 로그인 배너가 설정되지 않을 경우 배너에 서버 OS 버전 및 서비스 버전이 공격자에게 노출될 수 있으며 공격자는 이러한 정보를 통하여 해당 OS 및 서비스의 취약점을 이용하여 공격을 시도할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-68_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-68.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-68_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-69"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-69 NFS 설정파일 접근권한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: NFS 접근제어 설정파일의 소유자가 root 이고, 권한이 644 이하인 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: NFS 접근제어 설정파일의 소유자가 root 가 아니거나, 권한이 644 이하가 아닌 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: NFS 접근제어 설정파일에 대한 권한 관리가 이루어지지 않을 시 인가되지 않은 사용자를 등록하고 파일시스템을 마운트하여 불법적인 변조를 시도할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-69_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-69.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-69_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-70"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-70 expn, vrfy 명령어 제한" >> $CREATE_FILE_INFRA 2>&1
echo "양호: SMTP 서비스 미사용 또는, noexpn, novrfy 옵션이 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: SMTP 서비스를 사용하고, noexpn, novrfy 옵션이 설정되어 있지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: VRFY, EXPN 명령어를 통하여 특정 사용자 계정의 존재유무를 알 수 있고, 사용자의 정보를 외부로 유출 할 수 있음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-70_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-70_SRV-005.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-70_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-71"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-71 Apache 웹 서비스 정보 숨김" >> $CREATE_FILE_INFRA 2>&1
echo "양호: ServerTokens Prod, ServerSignature Off로 설정되어있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: ServerTokens Prod, ServerSignature Off로 설정되어있지 않은 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: HTTP 헤더, 에러페이지에서 웹 서버 버전 및 종류, OS 정보 등 웹 서버와 관련된 불필요한 정보가 노출되지 않도록 하기 위함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-71_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-71_SRV-148.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-71_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-42"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-42 최신 보안패치 및 벤더 권고사항 적용" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 패치 적용 정책을 수립하여 주기적으로 패치관리를 하고 있으며, 패치 관련 내용을 확인하고 적용했을 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 패치 적용 정책을 수립하지 않고 주기적으로 패치관리를 하지 않거나 패치 관련 내용을 확인하지 않고 적용하지 않았을 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 최신 보안패치가 적용되지 않을 경우, 이미 알려진 취약점을 통하여 공격자에 의해 시스템 침해사고 발생 가능성이 존재함" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-42_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-42_SRV-118.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-42_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-43"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-43 로그의 정기적 검토 및 보고" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 접속기록 등의 보안 로그, 응용 프로그램 및 시스템 로그 기록에 대해 정기적으로 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어지는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 위 로그 기록에 대해 정기적으로 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어 지지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 로그의 검토 및 보고 절차가 없는 경우 외부 침입 시도에 대한 식별이 누락될 수 있고, 침입 시도가 의심되는 사례 발견 시 관련 자료를 분석하여 해당장비에 대한 접근을 차단하는 등의 추가 조치가 어려움" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-43_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-43_SRV-115.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-43_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-72"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-72 정책에 따른 시스템 로깅 설정" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 로그 기록 정책이 정책에 따라 설정되어 수립되어 있으며 보안정책에 따라 로그를 남기고 있을 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 로그 기록 정책 미수립 또는, 정책에 따라 설정되어 있지 않거나 보안정책에 따라 로그를 남기고 있지 않을 경우" >> $CREATE_FILE_INFRA 2>&1
echo "보안위협: 로깅 설정이 되어 있지 않을 경우 원인 규명이 어려우며, 법적 대응을 위한 충분한 증거로 사용할 수 없음" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-72_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-72_SRV-109.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-72_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

########################################
#추가항목

CODE_STR="U-73"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-73 NTP 설정 점검" >> $CREATE_FILE_INFRA 2>&1
echo "양호: NTP 서버 동기화가 설정되어 있는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: NTP 서버 동기화가 미설정되어 있는 경우 " >> $CREATE_FILE_INFRA 2>&1
echo "상세설명: NTP는 컴퓨터 시스템 간에 시각 동기화를 위한 네트워킹 프로토콜로, 이벤트 발생 시 정확한 로그 분석이 필요하므로 NTP 설정 여부를 점검" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-73_START" >> $CREATE_FILE_INFRA 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-175.hangrp" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-73_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-74"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-74 외부 인터넷 연결 여부 확인" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 공인망과 연결이 불필요하여 공인망에 연결이 되지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 공인망과 연결이 불필요하지만 공인망에 연결이 되는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-74_START" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
CHECK_INTERNET_STR="`ping -c 2 example.com 2>/dev/null`"
if [ -n "$CHECK_INTERNET_STR" ]; then
    echo "[ping -c 2 example.com]" >> $CREATE_FILE_INFRA 2>&1
    echo "$CHECK_INTERNET_STR" >> $CREATE_FILE_INFRA 2>&1
fi
CHECK_INTERNET_STR=""
echo "" >> $CREATE_FILE_INFRA 2>&1

CHECK_INTERNET_STR="`dig example.com 2>/dev/null`"
if [ -n "$CHECK_INTERNET_STR" ]; then
    echo "[dig example.com]" >> $CREATE_FILE_INFRA 2>&1
    echo "$CHECK_INTERNET_STR" >> $CREATE_FILE_INFRA 2>&1
fi
CHECK_INTERNET_STR=""
echo "" >> $CREATE_FILE_INFRA 2>&1

CHECK_INTERNET_STR="`nslookup example.com 2>/dev/null`"
if [ -n "$CHECK_INTERNET_STR" ]; then
    echo "[nslookup example.com]" >> $CREATE_FILE_INFRA 2>&1
    echo "$CHECK_INTERNET_STR" >> $CREATE_FILE_INFRA 2>&1
fi
CHECK_INTERNET_STR=""
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-74_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-75"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-75 외부 인터넷 연결 여부 확인" >> $CREATE_FILE_INFRA 2>&1
echo "양호: 공인망과 연결이 불필요하여 공인망에 연결이 되지 않는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "취약: 공인망과 연결이 불필요하지만 공인망에 연결이 되는 경우" >> $CREATE_FILE_INFRA 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-75_START" >> $CREATE_FILE_INFRA 2>&1

if [ -n "$INTENS_ID_STR_AWS" ] || [ -n "$INTENS_IP_STR_AWS" ]; then
    echo "[AWS 인스턴스 ID]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_ID_STR_AWS" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "[AWS 외부 IP 확인]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_IP_STR_AWS" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if [ -n "$INTENS_ID_STR_GCP" ] || [ -n "$INTENS_IP_STR_GCP" ]; then
    echo "[GCP 인스턴스 ID]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_ID_STR_GCP" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "[GCP 외부 IP 확인]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_EXTERNAL_IP_GCP" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "[GCP 내부 IP 확인]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_INTERNAL_IP_GCP" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if [ -n "$INTENS_ID_STR_AZURE" ] || [ -n "$INTENS_IP_STR_AZURE" ]; then
    echo "[AZURE 인스턴스 ID]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_ID_STR_AZURE" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "[AZURE 외부 IP 확인]" >> $CREATE_FILE_INFRA 2>&1
    echo "$INTENS_IP_STR_AZURE" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if command -v ifconfig >/dev/null 2>&1; then
    echo "[ ip(ifconfig) ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`ifconfig -a 2>/dev/null | awk '/inet / {print $2}' | cut -d '/' -f 1 `" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi

if command -v ip >/dev/null 2>&1; then
    echo "[ ip(ip addr) ]" >> $CREATE_FILE_INFRA 2>&1
    echo "`ip addr | awk '/inet / {print $2}' | cut -d '/' -f 1 2>/dev/null`" >> $CREATE_FILE_INFRA 2>/dev/null
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi


echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-75_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1

CODE_STR="U-76"
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "U-76 K8S 내용 확인" >> $CREATE_FILE_INFRA 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_INFRA 2>&1
echo "U-76_START" >> $CREATE_FILE_INFRA 2>&1

#kubectl version
echo "[kubectl version]" >> $CREATE_FILE_INFRA 2>&1
kubectl version 2>/dev/null >> $CREATE_FILE_INFRA 2>&1

mkdir -p ${CREATE_FILE_DIR}/K8S
K8S_PATH_LIST="/var/lib/kubelet/config.yaml /var/lib/kubelet/kubelet-config.json /etc/kubernetes/kubelet-config.yaml /etc/kubernetes/kubelet.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service /var/lib/kubelet/kubeconfig /etc/kubernetes/aws-auth-cm.yaml /etc/kubernetes/kubelet/kubelet-config.json /etc/systemd/system/kubelet.service.d/10-kubelet-args.conf /etc/kubernetes/kubelet-config.json"
#K8S의 권한 및 내용 확인
for K8S_PATH in $K8S_PATH_LIST
do
    if [ -f $K8S_PATH ]; then
        echo "[ $K8S_PATH ] 권한)" >> $CREATE_FILE_INFRA 2>&1
        ls -lL $K8S_PATH 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
        cat $K8S_PATH 2>/dev/null >> $CREATE_FILE_INFRA 2>&1

        file_name_K8S=$(echo "${K8S_PATH}" | tr '/' '_' | sed 's/^_//')
        cat $K8S_PATH 2>/dev/null >> ${CREATE_FILE_DIR}/K8S/${file_name_K8S}

        echo "" >> $CREATE_FILE_INFRA 2>&1
    fi
done

#/etc/kubernetes/pki의 권한
if [ -d "/etc/kubernetes/pki" ]; then
    echo "[/etc/kubernetes/pki 권한]" >> $CREATE_FILE_INFRA 2>&1
    ls -lL /etc/kubernetes/pki 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi
#/etc/kubernetes/pki/etcd/의 권한
if [ -d "/etc/kubernetes/pki/etcd" ]; then
    echo "[/etc/kubernetes/pki/etcd 권한]" >> $CREATE_FILE_INFRA 2>&1
    ls -lL /etc/kubernetes/pki/etcd 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
    echo "" >> $CREATE_FILE_INFRA 2>&1
fi


echo "" >> $CREATE_FILE_INFRA 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_INFRA 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
echo "U-76_END" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1


CODE_STR="SRV-001"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-001 안전한 네트워크 모니터링 서비스 사용" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 보안설정이 적용된 네트워크 모니터링 서비스를 사용하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 보안설정이 적용되지 않은 네트워크 모니터링 서비스를 사용하는 경우, SNMP v3 사용  가능한 환경에서 v2를 이용 시" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-001_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-001.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-001_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-004"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-004 불필요한 SMTP 서비스 실행" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: SMTP 서비스가 동작 중이지 않거나, 업무상 사용 중인 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 불필요한 SMTP 서비스가 동작 중인 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: SMTP 서비스는 인터넷에서 메일을 전송하는 SMTP 프로토콜을 기반으로 하는 서비스로, 악의적인 공격자가 SMTP 서비스를 실행 중인 서버의 정보를 획득하는 등 다양한 공격이 가능하므로 불필요한 SMTP 서비스 가동 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-004_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-004.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-004_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-005"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-005 SMTP 서비스의 expn/vrfy 명령어 실행 제한 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: expn, vrfy 명령어 사용을 허용하지 않고 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: expn, vrfy 명령어 사용을 허용했을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: SMTP 서비스에서 제공하는 expn/vrfy 명령어는 시스템 계정명 수집 가능성이 존재하므로, 해당 명령의 허용 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-005_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-70_SRV-005.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-005_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-006"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-006 SMTP 서비스 로그 수준 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: SMTP 로그 수준 설정이 적절한 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: SMTP 로그 수준 설정이 낮은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: SMTP 서비스는 일반적으로 로그 설정을 할 때, 중요한 이벤트만 기록하는 수준부터 발생한 모든 이벤트를 기록하는 수준까지 로그의 기록 정도를 설정할 수 있다. 로그 수준이 너무 낮게 설정되었을 경우, 오류 또는 침해행위로 인한 서비스 장애의 원인을 추적하지 못할 위협이 있기 때문에 로그 수준 설정의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-006_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-006.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-006_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-007"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-007 취약한 버전의 SMTP 서비스 사용" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: SMTP 서비스 버전이 최신 버전일 경우 또는 금융회사 내부 규정에 따라 패치 검토 및 패치를 수행하고 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: SMTP 서비스 버전이 최신이 아닐 경우 또는 금융회사 내부 규정의 패치 관리 절차를 준수하지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 특정 SMTP 서비스 버전에서 공개된 취약점이 존재할 경우, 악의적인 사용자가 이를 활용한 공격을 수행할 위협이 있으므로 취약한 SMTP 서비스 버전의 사용 여부 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-007_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-30_SRV-007.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-007_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-008"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-008 SMTP 서비스의 DoS 방지 기능 미설정" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: SMTP 서비스의 DoS 방지 관련 설정이 적용된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: SMTP 서비스의 DoS 방지 관련 설정이 적용되지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 네트워크 회선 용량 및 서버 처리 용량 초과로 인한 메일 서비스 거부 및 시스템 다운을 방지하기 위한 보안설정의 적정성을 점검 " >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-008_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-008.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-008_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-009"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-009 SMTP 서비스 스팸 메일 릴레이 제한 미설정" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 스팸 메일 릴레이 방지 설정을 했을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 스팸 메일 릴레이 방지 설정을 하지 않았을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: SMTP 서비스는 인터넷에서 메일을 전송하는 프로토콜로, 다른 메일 서버가 보낸 메일을 다시 발송하는 relay 기능을 제공하는데 해당 기능은 공격자가 정당한 인증 과정 없이 다량의 메일(스팸 메일 등) 발송을 할 위협이 존재하므로 이에 대한 설정을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-009_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-31_SRV-009.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-009_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-010"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-010 SMTP 서비스의 메일 queue 처리 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: SMTP 서비스의 메일 queue 처리 권한을 업무 관리자에게만 부여되도록 설정된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: SMTP 서비스의 메일 queue 처리 권한이 업무와 무관한 일반 사용자에게도 부여되도록 설정된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: SMTP 서비스 운영 시 메일 queue 처리 기능이 임의의 사용자에게 허용되어 있을 경우, 비인가자가 악의적으로 queue의 데이터를 삭제하는 등의 공격 발생 위협이 존재하므로 적절한 보안 설정이 되어있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-010_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-32_SRV-010.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-010_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-011"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-011 시스템 관리자 계정의 FTP 사용 제한 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: ftpusers 파일이 존재하고, ftpusers 파일 안에 시스템 계정(root)이 존재할 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: ftpusers 파일이 없거나, ftpusers 파일 안에 시스템 계정 미존재 혹은 주석처리 되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: FTP 서비스는 단독으로 사용 시 네트워크에서 계정과 패스워드가 암호화되지 않으므로, 중요한 시스템 관리자 계정들을 보호하기 위해 해당 계정들의 FTP 접속을 ftpusers 파일을 활용하여 제한하고 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-011_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-64_SRV-011.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-011_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-012"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-012 .netrc 파일 내 중요 정보 노출" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: .netrc 파일 내부에 아이디, 패스워드 등 민감한 정보가 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: .netrc 파일 내부에 아이디 ,패스워드 등 민감한 정보가 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: .netrc 파일은 ftp 나 rexec 사용 시 자동 로그인을 위한 계정과 패스워드를 저장할 수 있는 파일로 계정 정보를 평문으로 저장하는 취약한 설정이므로, 해당 설정 파일이 존재하는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-012_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-012.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-012_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-013"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-013 Anonymous 계정의 FTP 서비스 접속 제한 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: FTP 서비스 미사용 또는 Anonymous 설정 비활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: Anonymous FTP 설정 활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: FTP 서비스는 파일을 전송하기 위한 프로토콜을 기반으로 하는 서비스로, 임의의 사용자가 FTP 서비스를 이용할 수 있는 익명(Anonymous) FTP 기능이 활성화된 경우 악의적인 사용자도 손쉽게 접근이 가능하므로 해당 기능의 허용 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-013_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-20_SRV-013.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-013_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-014"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-014 NFS 접근통제 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: NFS 비활성화 혹은 적절한 접근통제가 이루어지고 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 아래의 조건 만족 시 취약" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 1. NFS 서비스 실행 중  " >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 2. NFS 설정 파일 내에 읽기/쓰기 권한 정의 등의 적절한 접근 통제 설정이 없을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 3. NFS 설정 파일의 접근권한이 소유자가 root가 아니고, 권한이 644보다 높게 부여된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: NFS 서비스는 원격지의 시스템에 위치한 파일을 공유할 수 있는 서비스로 잘못된 설정에 의해 원치 않는 파일 또는 디렉터리 등이 외부에 노출되고 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-014_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-014.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-014_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-015"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-015 불필요한 NFS 서비스 실행" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: nfsd 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: nfsd 서비스가 불필요하게 활성화 되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: NFS 서비스는 원격지의 시스템에 위치한 파일을 공유할 수 있는 서비스로 해당 서비스가 업무와 관계없이 불필요하게 실행되고 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-015_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-24_SRV-015.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-015_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-016"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-016 불필요한 RPC서비스 활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: rpc.cmsd, rpc.ttdbserverd, sadmind, rusersd, walld, sprayd, rstatd, rpc.nisd, rexd, rpc.pcnfsd, rpc.statd, rpc.ypupdated, rpc.rquotad, kcms_server, cachefsd 서비스가 비활성화 되어 있는 경우 (업무상 사용시 예외)" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: rpc.cmsd, rpc.ttdbserverd, sadmind, rusersd, walld, sprayd, rstatd, rpc.nisd, rexd, rpc.pcnfsd, rpc.statd, rpc.ypupdated, rpc.rquotad, kcms_server, cachefsd 서비스가 불필요하게 활성화 되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: RPC(Remote Procedure Call) 서비스는 손쉬운 분산 처리 환경을 제공하지만, 오래된 버전의 특정 서비스들은 알려진 취약점이 존재하거나 잠재적인 취약점 발견 가능성이 있으므로 해당 서비스가 업무와 관계없이 불필요하게 활성화 되어있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-016_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-27_SRV-016.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-016_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-021"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-021 FTP 서비스 접근 제어 설정 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 특정 IP 주소 또는 호스트에서만 FTP 서버에 접속하도록 접근제어 설정을 적용한 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 특정 IP 주소 또는 호스트에서만 FTP 서버에 접속하도록 접근제어 설정을 적용하지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: FTP는 파일을 전송하기 위한 프로토콜로 계정과 패스워드를 암호화하지 않고 평문 전송을 하며, 적절한 접근통제 정책 미적용 시 비인가자에게 시스템 파일이 노출될 수 있으므로 FTP 접근 제어 설정의 적절성 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-021_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-021.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-021_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-022"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-022 계정의 비밀번호 미설정, 빈 암호 사용 관리 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 계정들의 비밀번호가 모두 설정되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 비밀번호가 설정되지 않은 계정이 존재할 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템 접속 계정에 대한 비밀번호가 설정되어 있지 않은 경우 비인가자가 계정을 도용하여 인가되지 않은 파일 및 서비스에 접근할 수 있는 위협이 존재하므로, 계정에 비밀번호가 설정되어 있지 않거나 빈 비밀번호를 설정하였는지를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-022_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-022.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-022_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-025"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-025 취약한 hosts.equiv 또는 .rhosts 설정 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: /etc/hosts.equiv, 각 계정들의 \$HOME/.rhosts 파일이 없을 경우 혹은 신뢰된 호스트들의 목록만 가지고 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: /etc/hosts.equiv 또는 각 계정들의 \$HOME/.rhosts 파일에 '+' 설정이나 불필요한 계정/호스트 IP가 존재할 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: hosts.equiv, .rhosts 파일 내에 등록된 시스템이나 사용자는 시스템 접근 시 인증 절차 없이 r 계열 명령어(rexec, rlogin등)를 사용이 가능함. 특히 hosts.equiv, .rhosts 파일 내에 + + 구문 존재 시 시스템 root를 제외한 모든 사용자가 인증절차 없이 r 계열 명령어를 실행할 수 있는 등 보안 수준이 낮으므로 이러한 설정이 존재하는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-025_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-17_SRV-025.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-025_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-026"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-026 root 계정 원격 접속 제한 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: root 계정의 원격 접속이 허용되지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 1.Telnet 사용 시: /etc/securetty 파일이 존재하지 않거나 파일 내에 pts/0 ~ pts/x 등 가상 터미널이 허용된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 2.SSH 사용 시: /etc/ssh/sshd_config 파일에 PermitRootLogin yes로 설정되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템 관리를 위한 root 계정의 원격 접속 허용은 악의적인 사용자가 무작위 대입 공격을 통해 시스템의 관리자 권한을 획득할 수 있는 위협을 증가시키므로, root 계정의 직접적인 원격 접속을 차단하고 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-026_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-01_SRV-026.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-026_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-027"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-027 서비스 접근 IP 및 포트 제한 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 시스템 서비스로의 접근통제가 적절하게 수행되고 있을 경우 (방화벽, tcp-wrapper, 3rd-party 제품 등을 활용)" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 시스템 서비스로의 접근통제가 적절하게 수행되고 있지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 서비스로의 접근이 통제되지 않을 경우 악의적인 사용자의 공격 목표가 될 수 있기 때문에 보안상 접근통제가 필요함. 방화벽, 3rd-party 제품 또는 tcpwrapper를 활용하여 서비스에 대한 IP 및 포트 접근제어를 수행하고 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-027_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-18_SRV-027.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-027_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-028"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-028 원격 터미널 접속 타임아웃 미설정" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 세션 타임아웃 값이 900초 이하(15분)로 설정 되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 세션 타임아웃 값이 900초 이하(15분)로 설정 되어 있지 않을 경우 또는 내부규정 시간 보다 초과된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 사용자 부재시, 비인가자에 의한 시스템 무단 사용을 방지하기 위해 일정시간 사용하지 않는 세션에 대한 자동 종료시간 설정 여부를 점검하고, 세션 종료시간이 설정되어 있을 경우 과도하게 설정 되어 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-028_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-54_SRV-028.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-028_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-034"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-034 불필요한 서비스 활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 불필요한 autmountd 서비스가 비활성화된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 취약한 버전의 automountd 서비스가 불필요하게 활성화된 경우 " >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템 운영 중 불필요한 서비스들이 설치되어 실행되고 있는 경우, 시스템의 성능 저하를 야기하거나 잠재적인 보안 취약점이 발생할 수 있으므로 업무와 관계 없이 활성화되어 있는 서비스를 점검( 취약한 버전의 automountd , NetBIOS, DMI, WebDAV, RDS 등 일반적으로 불필요한 서비스 점검 )" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-034_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-26_SRV-034.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-034_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-035"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-035 취약한 서비스 활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 아래의 항목 중 해당 사항이 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 아래의 항목 중 해당하는 조건이 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 1. tftp, talk, ntalk 서비스가 불필요하게 활성화된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 2. finger 서비스 활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 3. rexec, rlogin, rsh 서비스 활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 4. DoS 공격에 취약한 echo, discard, daytime, chargen 서비스 활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 5. NIS, NIS+ 서비스 활성화" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: ※ 단, OS 백업솔루션에서 tftp를 반드시 사용해야 하는 경우 업무와 연관 유무를 고려 후 예외 처리" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 알려진 취약점이 존재하는 서비스를 실행할 경우, 공격자의 침입 경로로 활용될 수 있기 때문에 취약한 서비스나 취약한 버전의 서비스가 실행되고 있는지 점검 ( tftp, talk, ntalk, finger, 취약한 r 계열 서비스, echo, discard, daytime, chargen, NIS, NIS+ 서비스 등)" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-035_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-035.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-035_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-037"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-037 취약한 FTP 서비스 실행" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: FTP 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: FTP 서비스가 활성화 되어 있는 경우(단, 업무상 필요하여 FTPS를 활용하는 등 통신 암호화를 위한 별도의 보안수단이 적용된 경우는 양호)" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: FTP는 파일을 전송하기 위한 프로토콜로 계정과 패스워드를 암호화하지 않고 평문 전송을 하여 네트워크 스니핑의 위협이 존재하므로, 해당 서비스가 추가 보안 수단 없이 취약하게 실행되고 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-037_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-61_SRV-037.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-037_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-040"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-040 웹 서비스 디렉터리 리스팅 방지 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 디렉터리 리스팅이 허용되지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 디렉터리 리스팅이 허용된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 디렉터리 리스팅은 디렉터리에 대한 요청 시 그 디렉터리에 기본 문서가 존재하지 않을 경우 디렉터리 내에 존재하는 모든 파일들의 목록을 출력함. 해당 기능이 활성화 되어 있는 경우 백업 파일이나 소스 파일 등 중요 파일이 외부에 노출될 수 있으므로 해당 기능의 활성화 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-040_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-35_SRV-040.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-040_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-042"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-042 웹 서비스 상위 디렉터리 접근 제한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: Directory Traversal 취약점이 존재하지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: Directory Traversal 취약점이 존재하는 웹 서버 버전을 사용하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 상위 디렉터리로 이동이 가능하면 하위경로에 접속한 후 상위로 이동하여 중요 파일들에 대한 접근이 가능한 위협이 존재하므로 \"..\" 와 같은 상위 경로를 사용하지 못하도록 적절하게 설정하였는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-042_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-37_SRV-042.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-042_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-043"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-043 웹 서비스 경로 내 불필요한 파일 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 불필요한 파일이 존재하지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 1. 디폴트 cgi-bin이 존재할 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 2. 임시 파일, 백업 파일 등이 존재할 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 웹 서비스 설치 시 기본으로 생성되는 설명 파일 또는 테스트 페이지로 인한 불필요한 정보 노출이 발생할 수 있으므로, 불필요한 파일의 존재 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-043_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-38_SRV-043.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-043_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-044"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-044 웹 서비스 파일 업로드 및 다운로드 용량 제한 미설정" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 파일 업로드 및 다운로드 용량 제한이 설정이 되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 파일 업로드 및 다운로드 용량 제한이 설정이 안되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 웹 서버에 불필요한 대량의 파일 업로드, 다운로드로 인한 서비스 거부 공격 위협이 존재하므로, 서버에 영향을 줄 정도의 대량의 업로드와 다운로드에 대한 통제 여부를 점검 " >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-044_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-40_SRV-044.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-044_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-045"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-045 웹 서비스 프로세스 권한 제한 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 웹 서비스의 요청 처리 프로세스의 실행 계정이 적절하게 설정되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 웹 서비스의 요청 처리 프로세스의 실행 계정이 관리자 권한으로 설정된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: o 웹 서버에 대한 요청을 처리하는 프로세스의 권한을 제한하지 않을 경우, 취약점 존재 시 공격자가 해당 서버의 높은 권한을 획득 가능한 위협이 존재함. 웹 서버 요청을 처리하는 프로세스 권한이 적절하게 설정되어 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-045_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-36_SRV-045.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-045_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-046"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-046 웹 서비스 경로 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 웹 서비스 경로 중 "/" 등 기타 업무와 영역이 분리되지 않은 경로 또는 불필요한 경로가 존재하지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 웹 서비스 경로 중 "/" 등 기타 업무와 영역이 분리되지 않은 경로 또는 불필요한 경로가 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 웹 서비스 경로를 기타 업무와 영역이 분리되지 않은 경로로 설정하거나, 불필요한 경로가 존재할 경우 외부에서 시스템의 중요 파일이나 기능에 비인가 접근이 발생할 위협이 존재하므로 웹 서비스 경로 설정의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-046_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-41_SRV-046.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-046_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-047"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-047 웹 서비스 경로 내 불필요한 링크 파일 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 웹 서비스 경로 내에 불필요한 링크가 존재하지 않거나, 링크를 허용하는 설정이 비활성화된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 웹 서비스 경로 내에 불필요한 링크가 존재하고 링크를 허용하는 설정이 활성화된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 웹 서버에 설정된 웹 서비스 루트 경로를 벗어나는 외부 링크 파일이 있다면, 공격자에 의한 비인가 접근 가능성이 존재하므로 불필요한 링크 파일 존재 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-047_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-39_SRV-047.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-047_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-048"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-048 불필요한 웹 서비스 실행" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 웹 서비스가 실행되고 있지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 웹 서비스가 불필요하게 실행 중인 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 웹 서비스는 구동 중일 경우 잠재적인 보안 취약점이 발생할 수 있고 흔히 공격의 목표가 되는 서비스이므로, 업무와 관계 없이 불필요하게 활성화되어 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-048_START" >> $CREATE_FILE_FINANCE 2>&1
cat  "${CREATE_FILE_DIR}/VULNERABILITY/SRV-048.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-048_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-060"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-060 웹 서비스 기본 계정(아이디 또는 비밀번호) 미변경" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 관리자 계정/패스워드가 디폴트 설정 이외의 다른 값으로 설정되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 관리자 계정/패스워드가 디폴트 값으로 설정되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: Tomcat은 Apache 웹 서버에 JSP와 자바 서블릿을 실행시킬 수 있는 기능을 제공하는 자바 애플리케이션 서버로 Tomcat이 설치될 때 기본으로 설정되는 계정을 변경하지 않을 경우 비인가자에 의한 시스템 접근이 발생할 수 있으므로 기본 계정에 대한 보안 설정의 적절성 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-060_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-060.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-060_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-062"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-062 DNS 서비스 정보 노출" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: DNS 응답에 불필요한 정보가 노출되지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: DNS 응답에 서비스명과 버전 정보가 함께 노출되고 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "※ 정보 노출: 서비스명 + 버전 정보가 노출되는 경우 취약" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: DNS 서버 종류 및 버전 등의 정보가 노출될 경우 공격자가 기타 공격에 활용할 가능성이 있으므로, 적절한 보안 설정이 되었는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-062_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-062.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-062_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-063"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-063 DNS Recursive Query 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: Recurisve query를 금지하고 있거나, 신뢰된 호스트만 허용하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: Recursive query를 접근 통제 없이 허용하고 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 공격자가 스푸핑 IP 주소(IP Spoofing)로 다량의 DNS 응답을 보내는 공격(DNS Cache Poisoning-DNS 캐시에 거짓정보가 들어가게 하는 공격) 등의 DNS 공격 위협이 존재하므로 DNS 서버가 불필요하게 Recursive Query를 지원하고 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-063_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-063.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-063_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-064"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-064 취약한 버전의 DNS 서비스 사용" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 1. 알려진 취약점이 없는 DNS 버전을 사용하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 2. dig @localhost +short porttest.dns-oarc.net TXT 명령 결과가 다음과 같은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: z.y.x.w.v.u.t.s.r.q.p.o.n.m.l.k.j.i.h.g.f.e.d.c.b.a.pt.dns-oarc.net." >> $CREATE_FILE_FINANCE 2>&1
echo "양호: \"IP-of-GOOD is GOOD: 26 queries in 2.0 seconds from 26 ports with std dev 17685.51\"" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 1. 패치관리에 대한 금융회사의 내부규정을 준수하지 않을 경우, 단 금융회사 내부규정에 명시되지 않은 경우 통상 1개월 이내 최신 버전으로 패치 적용할 것을 권고" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 2. dig @localhost +short porttest.dns-oarc.net TXT 명령 결과가 다음과 같은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: porttest.y.x.w.v.u.t.s.r.q.p.o.n.m.l.k.j.i.h.g.f.e.d.c.b.a.pt.dns-oarc.net." >> $CREATE_FILE_FINANCE 2>&1
echo "취약: \"해당서버IP is POOR: 26 queries in 3.6 seconds from 1 ports with std dev 0\"" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: DNS 서비스 운영 시 낮은 버전을 사용하고 있을 경우 Cache Poisoning(CVE-2008-1447) 공격, 서비스 거부 공격, 버퍼 오버플로우(Buffer Overflow), DNS 원격 침입 등의 알려진 취약점이 존재하므로 주기적인 DNS 보안 패치를 통해 안전한 서비스를 운영하고 있는지에 대한 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-064_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-33_SRV_064.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-064_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-066"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-066 DNS Zone Transfer 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: zone transfer를 위한 서버 제한 설정이 적용되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: zone transfer를 위한 서버 제한 설정이 적용되어 있지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: DNS 서버에 저장되어 있는 도메인 정보의 사본을 전송하는 DNS Zone Transfer 기능이 내부 DNS 서버만 접근할 수 있도록 통제되어 있지 않다면, 임의의 공격자가 도메인 내 호스트 목록 정보를 획득하여 공격에 활용할 수 있기 때문에 해당 기능의 설정 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-066_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-34_SRV-066.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-066_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-069"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-069 비밀번호 관리정책 설정 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 비밀번호 관련 정책들이 설정되어 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 비밀번호 관련 정책들이 설정되어 있지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 사용자 비밀번호에 대한 관리정책 설정이 미흡할 경우 유추하기 쉬운 비밀번호 설정, 주기적인 비밀번호 미변경 등 비인가자에 의한 계정 탈취 가능성이 높아지는 위협이 존재하므로 적절한 비밀번호 관리정책이 설정되어 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-069_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-02_SRV-069_SRV-075.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-069_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-070"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-070 취약한 패스워드 저장 방식 사용" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: shadow 패스워드를 사용하거나, 패스워드를 암호화하여 저장하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: shadow 패스워드를 사용하지 않고, 패스워드를 암호화하여 저장하지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 취약한 패스워드 저장 방식을 사용할 경우, 공격자에게 계정의 로그인 정보가 탈취되어 악용될 위협이 존재하므로 관련 설정의 적절성 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-070_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-04_SRV-070.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-070_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-073"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-073 관리자 그룹에 불필요한 사용자 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 관리자 그룹에 불필요한 관리자 계정이 없을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 관리자 그룹에 불필요한 관리자 계정이 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템에 다수의 관리자 계정이 존재할 경우, 공격자가 탈취를 시도할 수 있는 관리자 계정이 많아지므로 관리자 그룹에 업무상 필요한 최소한의 사용자만 등록하여 사용하고 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-073_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-50_SRV-073.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-073_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-074"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-074 불필요하거나 관리되지 않는 계정 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 분기별 1회 이상 로그인 한 기록이 있고, 비밀번호를 변경하고 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 분기별 1회 이상 로그인 한 기록이 없거나, 비밀번호를 변경하지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템 설치 시 기본으로 생성되는 계정, 업무상 더 이상 사용되지 않는 계정 등 불필요한 계정이나 장기간 비밀번호가 변경되지 않은 계정이 존재할 경우 비인가자의 계정 탈취 위협이 증가하므로 불필요한 계정 삭제 및 내부 정책에 따른 주기적인 비밀번호 변경을 실시하고 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-074_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-49_SRV-074.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-074_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-075"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-075 유추 가능한 계정 비밀번호 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 시스템의 모든 계정이 비밀번호 복잡도를 만족하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 비밀번호가 미설정되었거나, 복잡도를 만족하지 않는 계정이 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "※ 복잡도: 영문 숫자 특수문자 2개 조합 시 10자리 이상, 3개 조합 시 8자리 이상 (계정명, 기관명이 포함된 경우 취약)" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 패스워드 설정 시 문자/숫자/특수문자를 모두 포함하여 강력한 패스워드가 설정될 수있도록 암호 복잡성을 설정하여야 하며 영/숫자만으로 이루어진 암호는 현재 공개된 패스워드 크랙 유틸리티 및 무작위 공격에 의해 쉽게 유추할 수 될 수 있으므로 회사에서 정한 비밀번호 관리정책 준수 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-075_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-02_SRV-069_SRV-075.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-075_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-081"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-081 Crontab 설정파일 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: /var/spool/cron/crontab/* 에 others 읽기 쓰기 권한이 없음, at 접근제어 파일의 소유자가 root 이고 권한이 640 이하, cron.allow 와 cron.deny 파일의 소유자가 root이고 권한이 640 이하" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: cron 서비스 관련 설정 파일들이 양호 기준보다 많은 권한이 부여된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: cron은 특정 시간에 특정 작업을 수행할 수 있는 데몬으로 공격에 악용되거나 정보가 노출될 위협이 존재함. 이에 따라 cron 서비스를 보호하기 위해 서비스의 설정 파일들에 부여된 권한의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-081_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-081.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-081_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-082"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-082 시스템 주요 디렉터리 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 시스템 주요 디렉터리에 others 쓰기 권한이 없을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 시스템 주요 디렉터리에 others 쓰기 권한이 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템 주요 디렉터리에 대한 권한 설정 미흡으로 인하여 중요 파일에 대한 접근 및 변조가 발생할 위협이 존재하므로, 시스템 주요 디렉터리에 부여된 권한의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-082_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-082.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-082_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-083"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-083 시스템 스타트업 스크립트 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: others에 쓰기 권한이 없을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: others에 쓰기 권한이 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템 스타트업 스크립트의 소유권 및 권한 설정이 미흡할 경우, 임의의 공격자가 스크립트의 내용 변경 등을 통해 시스템 침입에 악용할 위협이 존재하므로, 해당 파일에 대한 권한 설정의 적절성을 점검 " >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-083_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-083.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-083_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-084"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-084 시스템 주요 파일 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 시스템 주요 파일의 권한이 조건보다 낮게 부여된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 시스템 주요 파일의 권한이 조건보다 높게 부여된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템 중요 파일에 대한 권한 설정이 미흡할 경우, 중요 정보가 유출, 다른 공격에 활용, 또는 파일 자체가 변조될 위협이 존재하므로 주요 중요 파일의 권한이 일반적으로 권장되는 권한 수준으로 부여되었는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-084_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-084.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-084_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-087"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-087 C 컴파일러 존재 및 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 컴파일러가 없거나 others 실행 권한이 없을 시 " >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 컴파일러에 others 실행 권한이 존재할 시" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 공격자가 시스템에 침입 후 공격 코드가 작성된 소스 파일을 컴파일하여 시스템 공격(관리자 권한 획득, 서비스 거부 유발 등)에 악용 가능하므로, 시스템에 C 컴파일러 존재 여부 및 권한 부여의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-087_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-087.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-087_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-091"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-091 불필요하게 SUID, SGID bit가 설정된 파일 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 불필요하게 SUID ,SGID가 설정된 파일이 없을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 불필요하게 SUID ,SGID가 설정된 파일이 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: SUID(Set User-ID)와 SGID(Set Group-ID)가 설정된 파일은 취약점이 존재할 경우, 권한 상승 공격에 활용될 수 있으므로 불필요한 SUID, SGID가 설정된 파일이 존재하는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-091_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-13_SRV-091.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-091_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-092"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-092 사용자 홈 디렉터리 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 홈 디렉터리의 소유자와 실 사용자가 일치하고, 계정간 중복 홈 디렉터리가 존재하지 않고, 불필요한 others 쓰기 권한이 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 홈 디렉터리의 소유자와 실 사용자가 일치하지 않거나, 계정간 중복 홈 디렉터리가 존재하거나, 불필요한 others 쓰기 권한이 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 사용자 계정별 홈 디렉터리 경로 및 권한이 올바로 설정되지 않을 경우, 비인가 접근이 발생할 가능성이 존재하므로 사용자별 홈 디렉터리 경로 및 접근 권한의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-092_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-57_SRV-092.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-092_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-093"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-093 불필요한 world writable 파일 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 불필요한 world writable 파일이 존재하지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 불필요한 world writable 파일이 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: World Writable 파일 또는 디렉터리가 존재할 경우 이를 임의의 사용자가 변경하여 추가적인 공격에 활용할 위협이 존재하므로, 모든 사용자가 변경할 수 있는 불필요한 World Writable 파일 및 디렉터리 권한이 존재하는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-093_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-15_SRV-093.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-093_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-094"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-094 Crontab 참조파일 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: crontab 참조파일에 others 쓰기 권한이 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: crontab 참조파일에 others 쓰기 권한이 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: Crontab에 정의된 작업에서 실행 또는 참조하는 파일에 others 쓰기 권한이 있는 경우, 파일 내용을 수정하여 악의적인 작업의 수행이 가능하므로 해당 파일 권한의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-094_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-094.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-094_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-095"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-095 존재하지 않는 소유자 및 그룹 권한을 가진 파일 또는 디렉터리 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 존재하지 않는 UID 및 GID를 가진 파일 및 디렉터리가 존재하지 않음" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 존재하지 않는 UID 및 GID 파일 및 디렉터리가 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 사용하지 않는 디렉터리나 파일의 존재는 시스템 자원의 낭비 및 관리의 부재가 발생할 수 있으므로, 불필요한 계정이 삭제된 이후 해당 계정이 생성한 디렉터리 및 파일 등이 서버에 불필요하게 남아있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-095_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-06_SRV-095.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-095_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-096"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-096 사용자 환경파일의 소유자 또는 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 사용자 환경 파일에 others에 부여된 권한이 없을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 사용자 환경 파일에 others에 읽기 혹은 쓰기 권한이 부여된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 사용자 shell 환경 파일에 others 권한이 부여되어 있으면 사용자 정보가 유출되거나 다른 공격에 활용될 수 있으므로, 관련 파일에 대한 권한 설정의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-096_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-096.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-096_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-108"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-108 로그에 대한 접근통제 및 관리 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 디렉터리 내 로그 파일들의 권한이 644 이하일 때" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 디렉터리 내 로그 파일들을 소유자 이외의 사용자가 수정 가능할 때" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 로그에 대한 접근통제가 미흡할 경우, 비인가자가 로그에서 정보를 획득하거나 로그 자체를 변조할 수 있는 위협이 존재하므로, 로그에 대한 접근 권한의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-108_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-108.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-108_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-109"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-109 시스템 주요 이벤트 로그 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: syslog 로그 기록 정책이 내부 정책에 부합하게 설정되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: syslog 로그 기록 정책이 내부 정책에 부합하게 설정되지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템 문제 발생 시 원활한 원인 파악/문제 해결 등을 위해서 각종 보안 로그가 저장 및 관리되어야 하며, 특히 인증 관련이나 중요 이벤트 로그가 남도록 설정되었는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-109_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-72_SRV-109.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-109_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-112"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-112 Cron 서비스 로깅 미설정" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: syslog 로그 기록 정책 또는 다른 로그 프로그램으로 cron 로그가 기록되는 경우 " >> $CREATE_FILE_FINANCE 2>&1
echo "취약: syslog 로그 기록 정책 또는 다른 로그 프로그램으로 cron 로그가 기록되지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: Cron 서비스 실행에 대한 로깅 미설정 시 비인가자에 의한 시스템 행위를 추적할 수 없으므로 적절한 로깅 설정이 되어있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-112_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-112.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-112_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-115"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-115 로그의 정기적 검토 및 보고 미수행" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 로그 기록에 대해 정기적 검토, 분석, 보고서 작성 및 보고 등의 절차를 수행하고 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 로그 기록에 대해 정기적 검토가 이루어지지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 각종 공격이나 시스템 오류에 대해 원활히 추적이 가능하려면, 로그에 대한 관리와 분석이 중요하므로 정기적으로 로그에 대한 검토 및 보고가 이루어지고 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-115_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-43_SRV-115.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-115_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-118"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-118 주기적인 보안패치 및 벤더 권고사항 미적용" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 보안 패치 관리를 적절하게 수행하고 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 보안 패치를 검토하는 절차가 없고, 보안 패치를 적용하지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 공개된 취약점에 의한 침해를 방지하고, 시스템에 대한 안전성 향상을 위해 최신/긴급 패치에 대한 검토, 계획 수립, 계획에 따른 이행(또는 보호방안 수립) 여부 등을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-118_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-42_SRV-118.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-118_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-121"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-121 root 계정의 PATH 환경변수 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: PATH 변수 내부에 \".\", \"::\" 가 존재하지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo 취약: PATH 변수 중간에 \".\" 혹은 \"::\" 또는 불필요한 임의의 경로가 존재할 경우 >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 사용자가 특정 명령어를 실행할 때 PATH에 지정된 디렉터리를 검색하여 해당 명령어를 찾기 때문에, 관리자의 PATH 환경변수에 현재 디렉터리 또는 알 수 없는 디렉터리가 포함되지 않았는지 점검이 필요함. PATH에 현재 디렉터리 또는 임의의 디렉터리가 포함되어 있고 실행할 명령(예 : ls, cd 등)과 동일한 이름을 가진 악성 프로그램이 해당 디렉터리에 숨겨져 있다면 실행시키고자 했던 원래의 프로그램 대신 악성 프로그램이 실행되어 시스템이 침해 당할 수 있는 위협이 존재하므로, 시스템의 PATH 설정이 적절한지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-121_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-05_SRV-121.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-121_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-122"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-122 UMASK 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 모든 계정의 umask 값과 설정 파일 등에 적용된 umask값이 022 이상인 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: umask값이나 설정 파일 등에 적용된 umask값이 022미만인 계정이 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: umask 값은 신규 파일이나 디렉터리 생성 시 기본으로 설정되는 권한을 결정하는 값으로, umask 설정에 따라 특정 사용자가 새로운 파일 또는 디렉터리를 생성했을 때 다른 사용자에게 의도치 않은 접근 권한이 부여될 가능성이 존재하므로 적절한 umask 값이 설정되었는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-122_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-56_SRV-122.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-122_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-127"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-127 계정 잠금 임계값 설정 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: /etc/pam.d/password-auth 파일과 /etc/pam.d/system-auth 파일에 계정 잠금 임계값 설정이 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: /etc/pam.d/password-auth 파일과 /etc/pam.d/system-auth 파일에 계정 잠금 임계값 설정이 존재하지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 계정 비밀번호에 대한 무작위 대입 공격으로 비인가자가 계정 정보를 탈취할 위협이 존재하므로 로그인 입력 횟수 제한 등의 임계값 설정 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-127_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-03_SRV-127.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-127_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-131"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-131 SU 명령 사용가능 그룹 제한 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: /etc/pam.d/su 파일에 auth required pam_wheel.so use_uid 라인이 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: /etc/pam.d/su 파일에 auth required pam_wheel.so use_uid 라인이 존재하지 않거나 주석 처리 되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: su(set user or superuser or switch user) 명령은 로그아웃 하지 않고 다른 사용자로 전환할 수 있게 해주는 명령으로, 관리자 비밀번호를 알고 있을 때 이 명령을 통해 관리자 권한을 획득(관리자로 전환) 가능하므로 su 명령을 사용할 수 있는 그룹을 설정하여 해당 그룹에 속한 사용자에게만 명령을 허용하고 있는지 여부를 점검 " >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-131_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-45_SRV-131.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-131_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-133"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-133 Cron 서비스 사용 계정 제한 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: cron.allow, cron.deny 파일 내부에 계정이 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: cron.allow, cron.deny 파일 둘 다 없는 경우(root만 cron 사용 가능)" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: cron.allow 파일이 없고 cron.deny 파일에 내부에 계정이 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: cron은 특정 시간에 특정 작업을 수행할 수 있는 데몬으로 공격에 악용되거나 정보가 노출될 위협이 존재함. 이에 따라 cron 서비스를 이용할 수 있는 계정을 정의하는 방식 등의 접근 통제를 수행하고 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-133_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-133.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-133_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-134"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-134 스택 영역 실행 방지 미설정" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 스택 영역 실행 방지가 설정된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 스택 영역 실행 방지가 적용되지 않은 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 스택 영역에서의 실행이 가능한 경우, "stack smashing" 등의 버퍼 오버플로우 공격에 취약하므로, 스택 영역 실행 기능에 대한 보안설정의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-134_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-134.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-134_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-135"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-135 TCP 보안 설정 미비" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: TCP\_STRONG\_ISS 값이 2로 설정된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: TCP\_STRONG\_ISS 값이 1 또는 0 으로 설정된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 하이재킹 공격이나 IP Spoofing, DoS 와 같은 네트워크 공격 위협을 감소시키기 위해, TCP 연결의 보안을 강화하는 설정이 활성화 되어 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-135_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-135.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-135_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-142"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-142 중복 UID가 부여된 계정 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 동일한 UID로 설정된 사용자 계정이 존재하지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 동일한 UID로 설정된 사용자 계정이 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 시스템에 중복 UID가 존재하는 경우, 접근통제와 감사 추적의 어려움이 발생할 수 있으므로, 동일한 UID가 부여된 계정의 존재 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-142_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-52_SRV-142.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-142_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-144"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-144 /dev 경로에 불필요한 파일 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: /dev 경로에 존재하지 않는 device 파일이 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: /dev 경로에 존재하지 않는 불필요한 device 파일이 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "※ 단, /dev 경로 내 파일 중 mqueue, shm 파일은 시스템에서 생성 또는 삭제가 주기적으로 일어나므로 예외" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 디바이스가 존재하지 않거나 이름이 잘못 입력된 경우 시스템은 /dev 디렉터리에 계속해서 파일이 생성되거나, 에러가 발생할 가능성이 존재함. 또한 /dev 디렉터리는 악의적인 공격자가 rootkit을 숨기는 경로로 사용되는 경우도 있음. 따라서 파일 시스템 손상 및 장애 등의 문제를 방지하기 위해 실제 존재하지 않는 디바이스 파일이 해당 경로에 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-144_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-16_SRV-144.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-144_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-147"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-147 불필요한 네트워크 모니터링 서비스 실행" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 불필요한 네트워크 모니터링 서비스를 사용하지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 불필요한 네트워크 모니터링 서비스가 실행 중인 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-147_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-66_SRV-147.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-147_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-148"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-148 웹 서비스 정보 노출" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 웹 서버 응답에 노출되는 정보가 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 웹 서버 응답에 노출되는 정보(서비스명 + 버전정보)가 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "※ 정보 노출: 서비스명 + 버전 정보가 노출되는 경우 취약" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 웹 서버 종류 및 버전 등에 대한 정보가 노출될 경우 공격자가 기타 공격에 활용할 가능성이 있으므로 적절한 보안 설정이 되었는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-148_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-71_SRV-148.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-148_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-158"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-158 불필요한 Telnet 서비스 실행" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: Telnet 서비스가 비활성화 되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: Telnet 서비스가 불필요하게 활성화 되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: Telnet 서비스는 Password 인증 방식 사용 시 데이터를 평문으로 송수신하기 때문에 인증 시 아이디/패스워드가 노출될 수 있는 위협이 존재하므로 가급적 사용하지 않는 것이 바람직하여, 업무와 관계없이 불필요하게 활성화되어 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-158_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-60_SRV-158.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-158_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-161"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-161 ftpusers 파일의 소유자 및 권한 설정 미흡" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: ftpusers 파일의 소유자가 root이고, 권한이 640 이하인 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: ftpusers 파일의 소유자가 root가 아니거나, 권한이 640 이하가 아닌 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: ftpusers 파일에서 FTP 서비스에 접근 가능한 사용자 계정을 관리할 수 있으므로, 해당 파일에 대한 권한 설정의 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-161_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-63_SRV-161.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-161_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-163"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-163 시스템 사용 주의사항 미출력" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 시스템 사용 주의사항을 출력하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 시스템 사용 주의사항 미출력 시 또는 표시 문구 내에 시스템 버전 정보가 노출되는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 비인가자의 부적절한 로그인 권한 획득을 사전에 방지하기 위하여 로그인 시 경고 및 시스템 사용 주의사항 등의 문구를 표시하고 있는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-163_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-163.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-163_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-164"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-164 구성원이 존재하지 않는 GID 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 구성원이 존재하지 않는 GID가 존재하지 않는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 구성원이 존재하지 않는 GID가 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 계정이 존재하지 않는 그룹 권한(GID)이 존재할 경우, 해당 그룹이 소유한 파일이 비인가자에게 노출될 위협이 존재하므로 소속된 계정이 없는 GID가 존재하는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-164_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-51_SRV-164.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-164_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-165"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-165 불필요하게 Shell이 부여된 계정 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 로그인이 필요하지 않은 계정에 /bin/false(nologin) 등이 부여된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 로그인이 필요하지 않은 계정에 shell이 부여된 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "※ 일반적으로 Daemon 실행을 위한 계정은 Shell이 불필요( 예: ftp, apache, www-data ) " >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 로그인이 불필요한 계정들에 /bin/false 등을 부여하여 계정 탈취 시의 피해를 감소시키기 위한 설정을 적용하고 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-165_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-53_SRV-165.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-165_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-166"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-166 불필요한 숨김 파일 또는 디렉터리 존재" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: 불필요한 숨김 파일이 존재하지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: 불필요한 숨김 파일이 존재하는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: 악의적인 목적으로 생성한 파일 혹은 디렉터리를 숨김파일로 저장하는 경우가 많으므로, 숨김 파일 및 디렉터리 중 침해 행위로 인해 생성된 파일이 존재하는지 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-166_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/U-59_SRV-166.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-166_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-170"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-170 SMTP 서비스 정보 노출" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: SMTP 접속 배너에 노출되는 정보가 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: SMTP 접속 배너에 노출되는 정보가 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "※ 정보 노출: 서비스명 + 버전 정보가 노출되는 경우 취약" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: SMTP 접속 시 노출되는 배너에서 공격자가 유용한 정보를 획득할 가능성이 존재하므로, 불필요하게 노출되는 정보 유무를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-170_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-170.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-170_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-171"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-171 FTP 서비스 정보 노출" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: FTP 접속 배너에 노출되는 정보가 없는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: FTP 접속 배너에 노출되는 정보가 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "※ 정보 노출: 서비스명 + 버전 정보가 노출되는 경우 취약" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: FTP 접속 시 노출되는 배너에서 공격자가 유용한 정보 획득할 가능성이 존재하므로, 불필요하게 노출되는 정보 존재 유무를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-171_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-171.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-171_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-173"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-173 DNS 서비스의 취약한 동적 업데이트 설정" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: DNS 서비스의 동적 업데이트 기능이 비활성화 되었거나, 활성화 시 적절한 접근통제를 수행하고 있을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: DNS 서비스의 동적 업데이트 기능이 불필요하게 활성화 되어있거나, 필요에 의해 사용 중이어도 적절한 접근통제를 수행하고 있지 않을 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: DNS(Domain Name Service) 서비스의 동적 업데이트 기능이 불필요하게 활성화되어 있고 신뢰할 수 있는 출처 이외에도 업데이트가 가능한 경우, 악의적인 사용자에 의해 DNS 레코드가 변조될 위협이 존재하므로, 해당 기능의 설정 적절성을 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-173_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-173.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-173_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-174"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-174 불필요한 DNS 서비스 실행" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: DNS 서비스가 실행 중이지 않거나, 필요에 의해 사용 중인 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: DNS 서비스가 불필요하게 실행 중인 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: DNS(Domain Name Service)는 도메인 이름과 IP간의 변환을 위한 서비스로, 불필요하게 운영할 경우 잠재적인 보안 취약점으로 인한 공격의 경로가 될 수 있으므로 해당 서비스가 업무와 관계없이 활성화되어 있는지 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-174_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-174.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-174_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1

CODE_STR="SRV-175"
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-175 NTP 및 시각 동기화 미설정" >> $CREATE_FILE_FINANCE 2>&1
echo "양호: NTP 서버 동기화가 설정되어 있는 경우" >> $CREATE_FILE_FINANCE 2>&1
echo "취약: NTP 서버 동기화가 미설정되어 있는 경우 " >> $CREATE_FILE_FINANCE 2>&1
echo "상세설명: NTP는 컴퓨터 시스템 간에 시각 동기화를 위한 네트워킹 프로토콜로, 이벤트 발생 시 정확한 로그 분석이 필요하므로 NTP 설정 여부를 점검" >> $CREATE_FILE_FINANCE 2>&1
echo "---------------------------------------------------------" >> $CREATE_FILE_FINANCE 2>&1
echo "${CODE_STR}_CHECK_$(cat "${CREATE_FILE_DIR}/SECURITY_STATUS/${CODE_STR}")" >> $CREATE_FILE_FINANCE 2>&1
echo "[+] 점검현황" >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-175_START" >> $CREATE_FILE_FINANCE 2>&1
cat "${CREATE_FILE_DIR}/VULNERABILITY/SRV-175.hangrp" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1
echo "--[ServerInfo]--" >> $CREATE_FILE_FINANCE 2>&1
echo "(항목코드) : $CODE_STR" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(운영체제) : $OS_CHECK_VALUE" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(호스트명) : $(hostname)" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "(IP주소) : $HOST_IP" 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "SRV-175_END" >> $CREATE_FILE_FINANCE 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1



#참고자료
echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[+] ps -ef" >> $CREATE_FILE_INFRA 2>&1
echo "[+] ps -ef" >> $CREATE_FILE_FINANCE 2>&1
ps -ef >> $CREATE_FILE_INFRA 2>&1
ps -ef >> $CREATE_FILE_FINANCE 2>&1
echo "[-] ps -ef" >> $CREATE_FILE_INFRA 2>&1
echo "[-] ps -ef" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[+] netstat -an" >> $CREATE_FILE_INFRA 2>&1
echo "[+] netstat -an" >> $CREATE_FILE_FINANCE 2>&1
netstat -an 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
netstat -an 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "[-] netstat -an" >> $CREATE_FILE_INFRA 2>&1
echo "[-] netstat -an" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[+] ss -an" >> $CREATE_FILE_INFRA 2>&1
echo "[+] ss -an" >> $CREATE_FILE_FINANCE 2>&1
ss -an 2>/dev/null >> $CREATE_FILE_INFRA 2>&1
ss -an 2>/dev/null >> $CREATE_FILE_FINANCE 2>&1
echo "[-] ss -an" >> $CREATE_FILE_INFRA 2>&1
echo "[-] ss -an" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[+] U-59 (숨겨진파일 및 디렉터리)" >> $CREATE_FILE_INFRA 2>&1
echo "[+] SRV-166 (숨겨진파일 및 디렉터리)" >> $CREATE_FILE_FINANCE 2>&1
cat $CHECK_HIIDEN_FILE >> $CREATE_FILE_INFRA 2>&1
cat $CHECK_HIIDEN_FILE >> $CREATE_FILE_FINANCE 2>&1
echo "[-] U-59 (숨겨진파일 및 디렉터리)" >> $CREATE_FILE_INFRA 2>&1
echo "[-] SRV-166 (숨겨진파일 및 디렉터리)" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[+] U-42 (패키지 버전 정보)" >> $CREATE_FILE_INFRA 2>&1
echo "[+] SRV-118 (패키지 버전 정보)" >> $CREATE_FILE_FINANCE 2>&1
cat $CHECK_LATEST_PATCHES_FILE >> $CREATE_FILE_INFRA 2>&1
cat $CHECK_LATEST_PATCHES_FILE >> $CREATE_FILE_FINANCE 2>&1
echo "[-] U-42 (패키지 버전 정보)" >> $CREATE_FILE_INFRA 2>&1
echo "[-] SRV-118 (패키지 버전 정보)" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[+] U-06 (소유자,그룹 미존재)" >> $CREATE_FILE_INFRA 2>&1
echo "[+] SRV-095 (소유자,그룹 미존재)" >> $CREATE_FILE_FINANCE 2>&1
cat $CHECK_NOUSER_NOGROUP_FILE >> $CREATE_FILE_INFRA 2>&1
cat $CHECK_NOUSER_NOGROUP_FILE >> $CREATE_FILE_FINANCE 2>&1
echo "[-] U-06 (소유자,그룹 미존재)" >> $CREATE_FILE_INFRA 2>&1
echo "[-] SRV-095 (소유자,그룹 미존재)" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[+] U-13 (불필요한 SUID_SGID)" >> $CREATE_FILE_INFRA 2>&1
echo "[+] SRV-091 (불필요한 SUID_SGID)" >> $CREATE_FILE_FINANCE 2>&1
cat $CHECK_SUID_SGID_FILE >> $CREATE_FILE_INFRA 2>&1
cat $CHECK_SUID_SGID_FILE >> $CREATE_FILE_FINANCE 2>&1
echo "[-] U-13 (불필요한 SUID_SGID)" >> $CREATE_FILE_INFRA 2>&1
echo "[-] SRV-091 (불필요한 SUID_SGID)" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1

echo "[+] U-15 (WORLD_WRITABLE_FILES)" >> $CREATE_FILE_INFRA 2>&1
echo "[+] SRV-093 (WORLD_WRITABLE_FILES)" >> $CREATE_FILE_FINANCE 2>&1
cat $CHECK_WORLD_WRITABLE_FILES >> $CREATE_FILE_INFRA 2>&1
cat $CHECK_WORLD_WRITABLE_FILES >> $CREATE_FILE_FINANCE 2>&1
echo "[-] U-15 (WORLD_WRITABLE_FILES)" >> $CREATE_FILE_INFRA 2>&1
echo "[-] SRV-093 (WORLD_WRITABLE_FILES)" >> $CREATE_FILE_FINANCE 2>&1
echo "" >> $CREATE_FILE_INFRA 2>&1
echo "" >> $CREATE_FILE_FINANCE 2>&1


echo "#########################################################" >> $CREATE_FILE_INFRA 2>&1
echo "#########################################################" >> $CREATE_FILE_FINANCE 2>&1


echo "GENERATE_INFRASTRUCTURE_DIAGNOSTIC_REPORT_COMPLETE"

#문자열 처리
#sed -i -e '/(default/!s/(ault/(default/g' -e '/(default/!s/(defa/(default/g' "$CREATE_FILE_FINANCE"
sed -e '/(default/!s/(ault/(default/g' -e '/(default/!s/(defa/(default/g' "$CREATE_FILE_FINANCE" > "$CREATE_FILE_FINANCE.tmp"
mv "$CREATE_FILE_FINANCE.tmp" "$CREATE_FILE_FINANCE"

#sed -i -e '/(default/!s/(ault/(default/g' -e '/(default/!s/(defa/(default/g' "$CREATE_FILE_INFRA"
sed -e '/(default/!s/(ault/(default/g' -e '/(default/!s/(defa/(default/g' "$CREATE_FILE_INFRA" > "$CREATE_FILE_INFRA.tmp"
mv "$CREATE_FILE_INFRA.tmp" "$CREATE_FILE_INFRA"

OS_CHECK_VALUE=""
if [ $SOLARIS_CHECK_00 -eq 1 ]; then
    OS_CHECK_VALUE="Solaris"
elif [ $AIX_CHECK_00 -eq 1 ]; then
    OS_CHECK_VALUE="AIX"
elif [ $HP_CHECK_00 -eq 1 ]; then
    OS_CHECK_VALUE="HP-UX"
elif [ $SUSE_CHECK_00 -eq 1 ]; then
    OS_CHECK_VALUE="SUSE"
else
    OS_CHECK_VALUE="Linux"
fi

# 압축
tar -cf "_+${OS_CHECK_VALUE}+$(hostname)+${HOST_IP}+${VER_info}.tar" "$CREATE_FILE_DIR"

echo "#########################################################"
echo "#########################################################"
echo "#########################################################"
echo "#The script has terminated successfully.#"
echo "#########################################################"
echo "#########################################################"
echo "#########################################################"