#!/bin/sh
#
#

fpsleep() {
	cntP1=`expr $1 \* 1`
	while [ true ]
	do
	  if [ $cntP1 -gt 0 ] ; then
		## fping -q 127.0.0.1 -i 2 -p 2 -t 1
		fping -q 127.0.0.1 -i 1 -p 1 -t 1
	  else
		break
	  fi
	  cntP1=`expr $cntP1 - 1`
	done
}

actIF() {
	#
	DWt0=0
	DWt1=0
	#
	for ii in 1 2 3 4 5
	do
		DWassoT0=`iwinfo wlan0 assoclist | grep dBm | awk '{print $9}' `
		DWassoT1=`iwinfo wlan1 assoclist | grep dBm | awk '{print $9}' `
		## Not Null ##
		if [ -n "$DWassoT0" ] && [ -n "$DWassoT1" ] ; then
		##
			if [ $DWassoT0 -lt $DWassoT1 ] ; then
				DWt0=`expr $DWt0 + 1`
			fi
			if [ $DWassoT0 -gt $DWassoT1 ] ; then
				DWt1=`expr $DWt1 + 1`
			fi
			
			## fpsleep 1
		##
		 #else
		 #	echo "...?input-null?..."
		fi
	done
	
	rxIF="NONE"
	if [ $DWt0 -gt 3 ] ; then
		rxIF="wlan0"
	fi
	if [ $DWt1 -gt 3 ] ; then
		rxIF="wlan1"
	fi
}



lastWLAN="wlan"

while : ; do

	#####
	actIF
	#####
	
	if [ "$rxIF" != "NONE" ] && [ "$lastWLAN" != "$rxIF" ] ; then
	
		brctl delif br-lan wlan0.sta1
		brctl delif br-lan wlan1.sta1
		##
		fpsleep 1
		##
		brctl addif br-lan wlan0.sta1
		brctl addif br-lan wlan1.sta1
		
			#if [ "$rxIF" != "wlan0" ] ; then
			#	brctl addif br-lan wlan1.sta1
			#	fpsleep 1
			#	brctl addif br-lan wlan0.sta1
			#else
			#	brctl addif br-lan wlan0.sta1
			#	fpsleep 1
			#	brctl addif br-lan wlan1.sta1
			#fi

	
		echo ">changed $lastWLAN => $rxIF ; $DWassoT0 , $DWassoT1"

		lastWLAN="$rxIF"
	fi

	## echo $rxIF
	## echo "$DWassoT0 , $DWassoT1"

done


