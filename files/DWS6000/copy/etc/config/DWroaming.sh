#!/bin/sh
#
#####################################################################
##
##            DWx6000 Configure for Owrt 12.09 @linux3.3
##
##            (DWroaming.sh):{ Redundant Roaming with DUAL-WLAN }
##
##            Copyright 2013, by Dasan InfoTEK 
##
##                         ...jslee@dsintek.com...
##
##
##
##     DWroaming.sh SNRmin SNRdelta FpingCNT FpingIP
##     --------------------------------------------------------------------------
##       SNRmin   : [0].... Disable-SNR-Roaming, Nomal=[10~15]
##       SNRdelta : [0].... Disable-SNR-Roaming, Nomal=[15~25]
##       SNR-Roaming.!! if{mySNR < SNRmin}--&&--{[mySNR] > [otherSNR+SNRdelta]}!!
##     --------------------------------------------------------------------------
##       FpingCNT : [0].....Disable-PING-Roaming, Nomal=[3,1~4] ;If Fail more [3]=4,5,
##       FpingIP  : [10.1.1.123]
##
#####################################################################

	## Dual--UnASSO : DW_WLactCNT=0
	## Dual--ACT :: DW_WLact==2

SNRmin="$1"
SNRdelta="$2"
##
FpingCNT="$3"
FpingIP="$4"


echo ""
echo ">>[ DWroaming.sh ] SNRmin=$SNRmin SNRdelta=$SNRdelta FpingCNT=$FpingCNT IP=$FpingIP"


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


Fp_ToutCNT=0
Fp_aliveCNT=0
##----------!

############
while : ; do
############

	DW_WLact=`brctl show | grep wlan | xargs`
	
	DW_WLactCNT=`brctl show | grep -c wlan`
	
	DW_asso0=`iwinfo wlan0 assoclist | grep dBm`
	DW_asso1=`iwinfo wlan1 assoclist | grep dBm`

	DWassoWC0=`echo "$DW_asso0" | wc -w`
	DWassoWC1=`echo "$DW_asso1" | wc -w`
	
	DWassoSNR0=`echo "$DW_asso0" | cut -f2 -d"(" | cut -c5-6 `
	DWassoSNR1=`echo "$DW_asso1" | cut -f2 -d"(" | cut -c5-6 `
	##
	fpsleep 1
	##
	DWassoSNR0t=`echo "$DW_asso0" | cut -f2 -d"(" | cut -c5-6 `
	DWassoSNR1t=`echo "$DW_asso1" | cut -f2 -d"(" | cut -c5-6 `
	##
	DWassoSNR0=`expr $DWassoSNR0 + $DWassoSNR0t `
	DWassoSNR1=`expr $DWassoSNR1 + $DWassoSNR1t `
	##
	fpsleep 1
	##
	DWassoSNR0t=`echo "$DW_asso0" | cut -f2 -d"(" | cut -c5-6 `
	DWassoSNR1t=`echo "$DW_asso1" | cut -f2 -d"(" | cut -c5-6 `
	##
	DWassoSNR0=`expr \( $DWassoSNR0 + $DWassoSNR0t \) / 3 `
	DWassoSNR1=`expr \( $DWassoSNR1 + $DWassoSNR1t \) / 3 `
	##------------------------------------------------------Avr(+/3)!!

##	echo ">> DWassoSNR0 = $DWassoSNR0  >> DWassoSNR1 = $DWassoSNR1 "


#	DW_WLactCNT=`expr "$DW_WLactCNT" \* 1`
#	DWassoWC0=`expr $DWassoWC0 \* 1`
#	DWassoWC1=`expr $DWassoWC1 \* 1`
#	DWassoSNR0=`expr $DWassoSNR0 \* 1`
#	DWassoSNR1=`expr $DWassoSNR1 \* 1`


### if [ $SNRmin -gt 0 ] && [ $SNRmin -lt 50 ] && [ $SNRdelta -gt 5 ] && [ $SNRdelta -lt 50 ] ; then
########################################################################################################

	if [ $DWassoWC0 -gt 9 ] && [ $DWassoWC1 -gt 9 ] ; then  ############# Dual--ASSO
		
		if [ $DWassoSNR0 -gt 10 ] || [ $DWassoSNR1 -gt 10 ] ; then  ## Dual--ACT :: DW_WLactCNT==2
		############( ONE-of-SNR_>>_minMINminMIN )################
			if [ $DW_WLactCNT -gt 1 ] ; then  						## Dual--ACT :: DW_WLactCNT==2
				if [ $DWassoSNR0 -gt $DWassoSNR1 ] ; then
					/usr/sbin/brctl delif br-lan wlan1  ##-
					/usr/sbin/brctl addif br-lan wlan0  ##+
				else
					/usr/sbin/brctl delif br-lan wlan0  ##-
					/usr/sbin/brctl addif br-lan wlan1  ##+
				fi
			else
				if [ $DW_WLactCNT -lt 1 ] ; then  					## None--ACT :: DW_WLactCNT==0
					/usr/sbin/brctl addif br-lan wlan0  ##+
					/usr/sbin/brctl addif br-lan wlan1  ##+
				else
					########################################		## One---ACT :: DW_WLactCNT==1
					if [ $SNRmin -gt 0 ] ; then
						DWassoSNR0x2=`expr $DWassoSNR0 + $SNRdelta `  ##`expr $DWassoSNR0 + \( $DWassoSNR0 / 3 \) `
						DWassoSNR1x2=`expr $DWassoSNR1 + $SNRdelta `  ##`expr $DWassoSNR1 + \( $DWassoSNR1 / 3 \) `
						if [ $DWassoSNR1 -lt $SNRmin ] && [ $DWassoSNR0 -gt $DWassoSNR1x2 ] ; then 
							if [ "$DW_WLact" != "wlan0" ] ; then
								/usr/sbin/brctl delif br-lan wlan1  ##-
								/usr/sbin/brctl addif br-lan wlan0  ##+
								##
								echo " $DW_WLact ---> Wlan1==>Wlan0"
								continue ##------------------------------>>>
							fi
						fi
						if [ $DWassoSNR0 -lt $SNRmin ] && [ $DWassoSNR1 -gt $DWassoSNR0x2 ] ; then 
							if [ "$DW_WLact" != "wlan1" ] ; then
								/usr/sbin/brctl delif br-lan wlan0  ##-
								/usr/sbin/brctl addif br-lan wlan1  ##+
								##
								echo " $DW_WLact ---> Wlan0==>Wlan1"
								continue ##------------------------------>>>
							fi
						fi
					fi
					########################################
					########################################----------------(FpingCNT==="3")
					if [ $FpingCNT -gt 0 ] && [ $FpingCNT -lt 5 ] ; then
						Acnt=0
						Fcnt=0
						for i in 1 2 3 4 5 ## 6 7 8 9 10
						do
							  ret1=`fping -p 10 -t 7 -r 1 $FpingIP | tail -c 6`
							  if [ "$ret1" = "alive" ] ; then
								Acnt=`expr $Acnt + 1`
							  else
								Fcnt=`expr $Fcnt + 1`
							  fi
						done
						####
						if [ $Fcnt -gt $FpingCNT ] ; then     ##--(Fcnt==="4~5")
							if [ $Fp_aliveCNT -gt 1 ] ; then  ##-----------------X2-Looped!!
								if [ "$DW_WLact" != "wlan0" ] ; then
									/usr/sbin/brctl delif br-lan wlan1  ##-
									/usr/sbin/brctl addif br-lan wlan0  ##+
									##
									echo " Ping-Failed ---> Wlan1==>Wlan0"
								else
									/usr/sbin/brctl delif br-lan wlan0  ##-
									/usr/sbin/brctl addif br-lan wlan1  ##+
									##
									echo " Ping-Failed ---> Wlan0==>Wlan1"
								fi
								##----------!
								Fp_aliveCNT=0
								##----------!!-----(After-Exec--PingRoaming)!!
							fi
							Fp_ToutCNT=`expr $Fp_ToutCNT + 1`
							if [ $Fp_ToutCNT -gt 9999 ] ; then
								Fp_ToutCNT=100
							fi
						else
							Fp_aliveCNT=`expr $Fp_aliveCNT + 1`
							if [ $Fp_aliveCNT -gt 9999 ] ; then
								Fp_aliveCNT=100
							fi
							Fp_ToutCNT=0  ##---------Fp_ToutCNT::NotUSEed~~Yet~~
						fi
					fi
					########################################
				fi
			fi
		fi
		
	else
		if [ $DWassoWC0 -lt 9 ] && [ $DWassoWC1 -lt 9 ] ; then  ############# None------ASSO
			if [ $DW_WLactCNT -lt 2 ] ; then
				/usr/sbin/brctl addif br-lan wlan0  ##+
				/usr/sbin/brctl addif br-lan wlan1  ##+
			fi
		else
			################################################	############# ONE-------ASSO
			if [ $DWassoWC0 -gt 9 ] && [ $DWassoWC1 -lt 9 ] ; then  ###### wlan0--ASSO
				if [ "$DW_WLact" != "wlan0" ] ; then
					/usr/sbin/brctl delif br-lan wlan1  ##-
					/usr/sbin/brctl addif br-lan wlan0  ##+
					##
					echo "00000000000000000000000000000000000> Wlan0"
				fi
			fi
			if [ $DWassoWC0 -lt 9 ] && [ $DWassoWC1 -gt 9 ] ; then  ###### wlan1--ASSO
				if [ "$DW_WLact" != "wlan1" ] ; then
					/usr/sbin/brctl delif br-lan wlan0  ##-
					/usr/sbin/brctl addif br-lan wlan1  ##+
					##
					echo "00000000000000000000000000000000000> Wlan1"
				fi
			fi
		fi
	fi

########################################################################################################
### fi  ##if [ $SNRmin -gt 0 ] && [ $SNRmin -lt 50 ] ; then

####(while : ; do)
done
####(while : ; do)


