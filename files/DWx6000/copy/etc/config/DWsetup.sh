#!/bin/sh
#
#####################################################################
##
##            DWx6000 Configure for Owrt 12.09 @linux3.3
##
##            { auto config for WLAN changes ... }
##
##            Copyright 2013, by Dasan InfoTEK 
##
##                         ...jslee@dsintek.com...
#####################################################################


DIALOG=${DIALOG=dialog}

tempfile="/tmp/DWconfig_main$$"
trap "rm -f $tempfile; exit" 0 1 2 5 15


FreqTBL="  Please enter  ... (Channel_NO) or (auto) !! \n \
2.4G =   (1)2.412   (2)2.417   (3)2.422   (4)2.427   (5)2.432 \n \
         (6)2.437   (7)2.442   (8)2.447   (9)2.452  (10)2.457 \n \
        (11)2.462  (12)2.467  (13)2.472 \n \
5.xG = (149)5.745 (153)5.765 (157)5.785 (161)5.805 (165)5.825 \n\n \
Recommand Channel Pairs: { A:RF1 - B:RF2 } \n \
   for 2.4GHz { 1 - 5 }, { 3 - 7 }, { 5 - 9 }, { 7 - 11 } \n \
   for 5.8GHz { 149 - 157 }, { 153 - 161 }, { 157 - 165 } \n \
   for Multi-Band { any(1~13) - any(149~165) } \n "


###########
readCFG() {
###########

DW_hostname=`uci get system.@system[0].hostname`
DW_logIP=`uci get system.@system[0].log_ip`
DW_hostID=`echo $DW_hostname | sed -e 's/[^0-9]//g' | tail -c 4`
DW_TYPE=`echo $DW_hostname | cut -c-3`
##
if [ "$DW_TYPE" = "DWB" ] ; then
	DWtype="ap"
	DWmode="BRIDGE-MODE"
fi
if [ "$DW_TYPE" = "DWS" ] ; then
	DWtype="sta"
	DWmode="SERVER-Mode"
fi

## Wcnt=`iw dev | grep wlan | wc -l`
Wcnt=`iw list | grep Wiphy | wc -l`

hwMAC0=`iw dev wlan0 info | grep addr | awk '{print $2}'  `
hwMAC1=`iw dev wlan1 info | grep addr | awk '{print $2}'  `

cfMAC0=`uci get wireless.radio0.macaddr`
cfMAC1=`uci get wireless.radio1.macaddr`

DW_ip=`uci get network.lan.ipaddr`
DW_mask=`uci get network.lan.netmask`
DW_gate=`uci get network.lan.gateway`
DW_dns=`uci get network.lan.dns`


## "Name=$DW_hostname Hid=$DW_hostID TYPE=$DW_TYPE $DWtype"
DW_SSID0=`echo $DW_TYPE | cut -c-2 `
DW_SSID1="$DW_SSID0"
DW_SSID0=`echo "$DW_SSID0""-""$DW_hostID""A"`
DW_SSID1=`echo "$DW_SSID1""-""$DW_hostID""B"`

DWxSSID0=`uci get wireless.@wifi-iface[0].ssid`
DWxSSID1=`uci get wireless.@wifi-iface[1].ssid`

DW_asso0=`iwinfo wlan0 assoclist | grep dBm`
DW_asso1=`iwinfo wlan1 assoclist | grep dBm`

DW_asso0a=`echo $DW_asso0 | cut -f1 -d"d"`
DW_asso0b=`echo $DW_asso0 | cut -f2 -d"/"`
DW_asso0=`echo "$DW_asso0a""/ ""$DW_asso0b"`

DW_asso1a=`echo $DW_asso1 | cut -f1 -d"d"`
DW_asso1b=`echo $DW_asso1 | cut -f2 -d"/"`
DW_asso1=`echo "$DW_asso1a""/ ""$DW_asso1b"`


DW_asso0="$DWxSSID0 $DW_asso0"
DW_asso1="$DWxSSID1 $DW_asso1"

DW_WLact=`brctl show | grep wlan | xargs`

if [ "$DW_WLact" = "wlan0" ] ; then
	DW_asso0="<ACT> $DW_asso0"
	DW_asso1="--*-- $DW_asso1"
fi
if [ "$DW_WLact" = "wlan1" ] ; then
	DW_asso0="--*-- $DW_asso0"
	DW_asso1="<ACT> $DW_asso1"
fi

DW_CH0=`uci get wireless.radio0.channel`
DW_CH1=`uci get wireless.radio1.channel`


DWrunCH0=`iw dev wlan0 info | grep channel | awk '{print $2}' `
DWrunFR0=`iw dev wlan0 info | grep channel | awk '{print $3}' | cut -c2-`

DWrunCH1=`iw dev wlan1 info | grep channel | awk '{print $2}' `
DWrunFR1=`iw dev wlan1 info | grep channel | awk '{print $3}' | cut -c2-`




}
###########
readCFG
###########

echo
echo "%% HostName=$DW_hostname  HostID=$DW_hostID  TYPE=$DW_TYPE""_""$DWtype"
echo

echo "%% Installed $Wcnt WLAN-Cards!"
echo "%% hwMAC0=$hwMAC0  hwMAC1=$hwMAC1"
echo "%% cfMAC0=$cfMAC0  cfMAC1=$cfMAC1"

echo
echo "%% IPaddr = $DW_ip"
echo "%% IPmask = $DW_mask"
echo "%% IPgate = $DW_gate" 
echo



textinput() {
	$DIALOG \
	--ascii-lines --title "INPUT BOX" --clear \
	--inputbox "$1" 20 76 "$2" 2> $tempfile

	retval=$?

	case $retval in
	0)
		inputvar=`cat $tempfile`;;
	1)
		inputvar=$2
		;;
	255)
		inputvar=$2
		;;
	esac

	if [ "$inputvar" = "--" ] ; then inputvar="" ; fi
}

menuREBOOT() {
	textinput "ReBOOT Now?? [Yes/No]\n\n \
Please Enter: \n [YES]/[no] \n" \
	"NO"
	if [ "$inputvar" = "YES" ] ; then
	  ##sync
	  sleep 2
	  echo ; echo ".... All Interface Restart...!!"
	  sleep 2
	  ##clear
	  echo ; echo ".... System Reboot Now!!"
	  reboot
	  while : ; do
		sleep 1
		echo -n "."
	  done
	fi	
}


menuinput() {
	menucmd=`cat <<END
$DIALOG --ascii-lines --clear --cr-wrap --title "[[ DWx6000 SYSTEM Configurations ]]" \
	--menu "Name=$DW_hostname ($DW_TYPE $DW_hostID $DWtype) [ssid: $DW_SSID0 $DW_SSID1] <$DWmode>\
	\n $DW_asso0 \n $DW_asso1 \nPlease menu select: \n" 22 76 13 \
	$1 \
	2> $tempfile
END
`

eval $menucmd

	retval=$?

	case $retval in
	0)
		inputvar=`cat $tempfile`
		;;
	1)
		inputvar=$2
		;;
	255)
		inputvar=$2
		;;
	esac

	if [ "$inputvar" = "--" ] ; then inputvar="" ; fi
}


changeMAC() {

	echo ""
	
}





############<==((( begin )))

rm -f $tempfile

mchoice="";

############
while : ; do
############

inputvar=""

readCFG


menuinput '"0REVIEW_ALL"  "REVIEW STAT/CONFIGURE _______(REVIEW!)"
	"TEST_ROAMING" "TEST WIRELESS ROAMING _______(ROAMING!)"
	"1DW_HostNAME" "SYSTEM NAME _________________($DW_hostname)"
	"2NET_IPaddr"  "NET IP Address ______________($DW_ip)"
	"3NET_IPmask"  "NET IP Subnet Mask __________($DW_mask)"
	"4NET_Gateway" "Gateway IP Address __________($DW_gate)"
	"5NET_IPdns"   "DNS Server IP Address _______($DW_dns)"
	"6NET_IPslog"  "Syslog Server IP Address ____($DW_logIP)"

	"7WLAN_FreqA"  "A:RF1 Ch_No/Freq($DWrunCH0/$DWrunFR0) __($DW_CH0)"
	"8WLAN_FreqB"  "B:RF2 Ch_No/Freq($DWrunCH1/$DWrunFR1) __($DW_CH1)"
	
	"SAVE_COMMIT"  "Save and Commit ALL Configures __(SAVE!)"
	"REBOOT_Unit"  "Reboot System (Did you SAVE ?) __(DONE!)"

	"WLANcardInit" "Init NEW Wireless Card/Adapter __(WLAN!)"'

case $inputvar in


TEST_ROAMING)

	DWtype0=`iw dev wlan0 info | grep type | awk '{print $2}'`

	if [ "$DWtype0" != "managed" ] ; then
		clear
		echo ; echo "TEST_ROAMING can use only ... [DWS6000] / <SERVER-MODE> !!"
		sleep 2
	else
		DWassoWC0=`iwinfo wlan0 assoclist | grep dBm | wc -w`	
		DWassoWC1=`iwinfo wlan1 assoclist | grep dBm | wc -w`
		if [ $DWassoWC0 -lt 9 ] || [ $DWassoWC1 -lt 9 ] ; then
			clear
			echo ; echo "TEST_ROAMING can use only ... Dual/Redundant WLAN Associated !!"
			sleep 2
		else
			DW_WLact=`brctl show | grep wlan | xargs`
			if [ "$DW_WLact" = "wlan0" ] ; then
				brctl delif br-lan wlan0
				brctl addif br-lan wlan1
			fi
			if [ "$DW_WLact" = "wlan1" ] ; then
				brctl delif br-lan wlan1
				brctl addif br-lan wlan0
			fi
			## brctl show
		fi
	fi
	;;


1DW_HostNAME)
	textinput "Please enter HOST-NAME ... \n\n \
Examples: \n BRIDGE(BASE,AP): DWB6000-G123   SERVER(Remote): DWS6000-M123 \n" \
	"$DW_hostname"
	uci set system.@system[0].hostname="$inputvar"
	;;

2NET_IPaddr)
	textinput "Please enter IP Address ... \n\n \
Examples: \n 10.1.1.123  192.168.0.123 \n" \
	"$DW_ip"
	uci set network.lan.ipaddr="$inputvar"
	;;

3NET_IPmask)
	textinput "Please enter Subnet Mask ... \n\n \
Examples: \n 255.255.255.0 \n" \
	"$DW_mask"
	uci set network.lan.netmask="$inputvar"
	;;

4NET_Gateway)
	textinput "Please enter Gateway IP Address ... \n\n \
Examples: \n 10.1.1.1  192.168.0.254 \n" \
	"$DW_gate"
	uci set network.lan.gateway="$inputvar"
	;;

5NET_IPdns)
	textinput "Please enter DNS Server IP Address ... \n\n \
Examples: \n 168.126.63.1 \n" \
	"$DW_dns"
	uci set network.lan.dns="$inputvar"
	;;

6NET_IPslog)
	textinput "Please enter DNS Server IP Address ... \n\n \
Examples: \n 168.126.63.1 \n" \
	"$DW_logIP"
	uci set system.@system[0].log_ip="$inputvar"
	;;

7WLAN_FreqA)
	textinput "Please enter A:RF1 Frequency CHANNEL-NO ... \n\n \
Examples: $FreqTBL \n" \
	"$DW_CH0"
	uci set wireless.radio0.channel="$inputvar"
	;;

8WLAN_FreqB)
	textinput "Please enter B:RF2 Frequency CHANNEL-NO ... \n\n \
Examples: $FreqTBL \n" \
	"$DW_CH1"
	uci set wireless.radio1.channel="$inputvar"
	;;

SAVE_COMMIT)
	textinput "Commit All Configures & Save Now?? [Yes/No]\n\n \
Please Enter: \n [YES]/[no] \n" \
	"NO"
	if [ "$inputvar" = "YES" ] ; then
		clear
		echo ; echo "[DWx6000].... Commit All Configures Save Now!!"
		
		if [ "$DW_TYPE" = "DWB" ] ; then
			uci set wireless.@wifi-iface[0].mode=ap
			uci set wireless.@wifi-iface[1].mode=ap
			# uci set wireless.radio0.channel=9
			# uci set wireless.radio1.channel=149
			###
			### uci set network.lan.stp=1
		fi
		if [ "$DW_TYPE" = "DWS" ] ; then
			uci set wireless.@wifi-iface[0].mode=sta
			uci set wireless.@wifi-iface[1].mode=sta
			# uci set wireless.radio0.channel=auto
			# uci set wireless.radio1.channel=auto
			###
			### uci set network.lan.stp=0
		fi		
		
		uci set wireless.@wifi-iface[0].ssid=$DW_SSID0
		uci set wireless.@wifi-iface[1].ssid=$DW_SSID1
		###
		uci commit system
		uci commit network
		uci commit wireless		
		sync
		sleep 2
	fi	
	;;
	
REBOOT_Unit)	
	menuREBOOT
	;;


WLANcardInit)
	clear
	readCFG  ##<===!!
	echo
	echo "[DWx6000].... WLAN Informations :"
	echo
	echo "   WLAN-Card-A:MAC=$hwMAC0"
	echo "   Configure-A:MAC=$cfMAC0"
	if [ "$hwMAC0" = "$cfMAC0" ] ; then
		echo "   ----------------------- MAC_compOK !"
	else
		echo "   ----------------------- MAC_compERROR !"	
	fi
	echo
	echo "   WLAN-Card-B:MAC=$hwMAC1"
	echo "   Configure-B:MAC=$cfMAC1"
	if [ "$hwMAC1" = "$cfMAC1" ] ; then
		echo "   ----------------------- MAC_compOK !"
	else
		echo "   ----------------------- MAC_compERROR !"	
	fi
	echo
	echo "Init NEW Wireless Card/Adapter MAC-Address ??"
	echo "     Will be INIT ... ALL-WIRLESS-CONFIGURE !"
	echo
    read -p "Please Enter [YES]/[no]: " yn
	if [ "$yn" = "YES" ] ; then
	
		echo "%% --------(Init WLAN H/W Configure)----------- %%"
		rm /etc/config/wireless
		wifi detect > /tmp/DTwireless
		cp /etc/config/DWwireless /etc/config/wireless
		##
		if [ "$DW_TYPE" = "DWB" ] ; then
			uci set wireless.@wifi-iface[0].mode=ap
			uci set wireless.@wifi-iface[1].mode=ap
			uci set wireless.radio0.channel=9
			uci set wireless.radio1.channel=149
			###
			### uci set network.lan.stp=1
		fi
		if [ "$DW_TYPE" = "DWS" ] ; then
			uci set wireless.@wifi-iface[0].mode=sta
			uci set wireless.@wifi-iface[1].mode=sta
			uci set wireless.radio0.channel=auto
			uci set wireless.radio1.channel=auto
			###
			### uci set network.lan.stp=0
		fi
		
		uci set wireless.radio0.macaddr=`uci get /tmp/DTwireless.radio0.macaddr`
		uci set wireless.radio1.macaddr=`uci get /tmp/DTwireless.radio1.macaddr`
		
		uci set wireless.@wifi-iface[0].ssid=$DW_SSID0
		uci set wireless.@wifi-iface[1].ssid=$DW_SSID1
		
		uci commit wireless
		uci commit network
		uci commit system
		
		echo "%% MAC-Addr---Reload-Done!!"
		sleep 3
		
		menuREBOOT
		
	fi	
	;;


##*)
##	rm $tempfile >/dev/null 2>/dev/null
##	exit 0
##	;;
	
esac

####(while : ; do)
done
####(while : ; do)

###########################################################################((END))

##  AP-MODE :: iw dev wlan0.sta1 station dump
## STA-MODE :: iw dev wlan0 station dump


if [ "$hwMAC0" = "$cfMAC0" ] && [ "$hwMAC1" = "$cfMAC1" ] ; then
	echo "%% wlan0 & wlan1 MAC_compOK !"
else
	echo "%% wlan0 & wlan1 MAC_compERR ?"

	echo "%% --------(Init WLAN H/W)----------- %%"
	rm /etc/config/wireless
	wifi detect > /tmp/DTwireless
	##
	cp /etc/config/DWwireless /etc/config/wireless
	##
	uci set wireless.radio0.macaddr=`uci get /tmp/DTwireless.radio0.macaddr`
	uci set wireless.radio1.macaddr=`uci get /tmp/DTwireless.radio1.macaddr`
	uci commit wireless	

	echo "%% MAC-Addr---Reload-Done!!"

fi

##############################(rc.local)
DW_hostname=`uci get system.@system[0].hostname`
DW_TYPE=`echo $DW_hostname | cut -c-3`
if [ "$DW_TYPE" = "DWS" ] ; then
	echo " " > /dev/console
	echo "-----(1 of 2 wlan0/1)-----" > /dev/console
	/usr/sbin/brctl show > /dev/console
	/usr/sbin/brctl delif br-lan wlan1 > /dev/console
	/usr/sbin/brctl show > /dev/console
	echo "--------------------------" > /dev/console
	echo " " > /dev/console
fi




