#!/bin/bash

if [ ! -f ffmpeg-bash-player.sh ]; then
    echo "Please rename this script to ffmpeg-bash-player.sh"
    exit
 fi

if [ -f "ffmpeg-bash-config.sh" ]; then
    echo "Enter full path to media dir without quotes. Leave blank for current dir." 
    echo -n '>'
    read DIR
    if [ -z "$DIR" ]; then
	mv "ffmpeg-bash-config.sh" ".ffmpeg.sh"
	chmod +x ".ffmpeg.sh"
    else
	cp "ffmpeg-bash-config.sh" "$DIR"
	cp "ffmpeg-bash-player.sh" "$DIR"
	cd "$DIR"
	mv "ffmpeg-bash-config.sh" ".ffmpeg.sh"
	chmod +x ".ffmpeg.sh"
	chmod +x "ffmpeg-bash-player.sh"
	exec ./ffmpeg-bash-player.sh
    fi
fi

if [ ! -f .ffmpeg.sh ]; then
    if [ ! -f ~/ffmpeg-bash-config.sh ]; then
	echo 'Config file not found in home or current working directory... :('
	exit
     fi
    cp ~/ffmpeg-bash-config.sh .
    mv "ffmpeg-bash-config.sh" ".ffmpeg.sh"
    chmod +x ".ffmpeg.sh"
 fi

if [ ! -f .watched ]; then echo "ffmpeg-bash-player.sh" > .watched; fi

if [ ! -f .play ]; then echo "0" > .play; fi

if [ ! -f .map1 ]; then echo "0" > .map1; echo "1" > .map2; fi

if [ ! -f .rez ]; then echo "1280x720" > .rez;fi

if [ -f ".complete" ]; then rm .complete; fi

if [ -f ".ffrw" ]; then rm .ffrw; fi

ls -p | grep -v '/$' > /tmp/showlist
awk '{if (f==1) { r[$0] } else if (! ($0 in r)) { print $0 } } ' f=1 .watched f=2 /tmp/showlist > /tmp/list.txt

INU=`head -n 1 /tmp/list.txt`
if [ -z "$INU" ]; then
echo -n "Series complete. Remove player files? "
                while true; do
                  read -n1 -p 'y/n>' yn
                  case $yn in
                    [Yy]* ) \
                        echo
                    rm -f ".ffmpeg.sh" ".inu" ".map1" ".map2" ".play" ".rez"
                    rm -f ".running" ".time" ".watched" ".lastplay"
                        exit
                           break;;
                    [Nn]* ) \
                        echo
                        exit
                           break;;
                            * ) echo 'Please answer y/n';;
                      esac
                    done
		fi



if [ ! -f .running ]; then
    touch .running
	if [ ! -f .lastplay ]; then
	TIME=`cat .play`
	else
	TIME=`cat .lastplay`
	fi
    echo $INU at $TIME is on deck
    echo '(e)xaimne, set (i)ntro, (a)uto, (p)lay, (s)kip, (r)eset, (q)uit'
while true; do
    read -n1 -p '>' eiprq
    case $eiprq in
        [Ee]* ) \
		echo -n "xaimne"
		echo
		echo "---------------------------"  > /tmp/fftime.txt
		ffprobe -hide_banner "$INU" >> /tmp/fftime.txt 2>&1
		echo "---------------------------" >> /tmp/fftime.txt
		echo "ffprobe info written to /tmp/fftime.txt"
	        MAP1=`cat .map1` ; MAP2=`cat .map2` ; REZ=`cat .rez`
		echo "Current channels are 0:$MAP1 and 0:$MAP2 Resolution is $REZ"
		echo -n "Video Channel >"
		read MAP1
		if [ -z "$MAP1" ]
  		  then
		   MAP1=`cat .map1`
		   echo "Video Channel is 0:$MAP1 unchanged"
		  else
		   echo $MAP1 > .map1
		   echo "Video Channel changed to 0:$MAP1"
		fi
		echo -n "Audio Channel >"
                read MAP2
                if [ -z "$MAP2" ]
                  then
                   MAP2=`cat .map2`
                   echo "Audio Channel is 0:$MAP2 unchanged"
                  else
                   echo $MAP2 > .map2
                   echo "Audio Channel changed to 0:$MAP2"
                fi
		echo -n "Set resolution ie 1280x720 >"
		read REZ
                if [ -z "$REZ" ]
                  then
                   REZ=`cat .rez`
                   echo "Resolution is $REZ unchanged"
                  else
                   echo $REZ > .rez
                   echo "Resolution changed to $REZ"
                fi
		rm .running
		exec ./ffmpeg-bash-player.sh
                   break;;
        [Ii]* ) \
		echo -n "ntro"
		echo
		echo -n "Enter desired start time in seconds >"
		read INTRO
		echo $INTRO > .play
		rm .running
                exec ./ffmpeg-bash-player.sh
                   break;;
        [Aa]* ) \
		echo -n "uto play"
		touch .autoplay
		echo
                   break;;
        [Ss]* ) \
		echo -n "kip"
                echo
		echo "Skipping $INU"
		echo $INU >> .watched
		rm .running
		exec ./ffmpeg-bash-player.sh
                   break;;
        [Pp]* ) \
		echo -n "lay"
                echo
                   break;;
        [Rr]* ) \
		echo -n "eset"
		echo
		echo -n "Type RESET if you're reallly sure!!!! >"
		read RESET
		if [ "$RESET" = "RESET" ]; then
		    rm -f ".ffmpeg.sh" ".inu" ".map1" ".map2" ".play" ".rez"
		    rm -f ".running" ".time" ".watched" ".lastplay"
                echo -n "Player reset. Exit? "
                while true; do
                  read -n1 -p 'y/n>' yn
                  case $yn in
                    [Yy]* ) \
                        echo
                        exit
                           break;;
                    [Nn]* ) \
                        echo
                        exec ./ffmpeg-bash-player.sh
                           break;;
                            * ) echo 'Please answer y/n';;
                      esac
                    done
		else
		    echo "Did not reset."
		    rm .running
		    exec ./ffmpeg-bash-player.sh
		fi
                   break;;
        [Qq]* ) \
		echo -n "uit"
                echo
		rm .running
		exit
                   break;;
        * ) echo 'Please answer (e) (i) (a) (p) (r), or (q).';;
    esac
done
fi



if [ -f ".lastplay" ]; then

    TIME=`cat .lastplay`
    num=$TIME;min=0;hour=0;day=0
    if((num>59));then ((sec=num%60));((num=num/60))
        if((num>59));then ((min=num%60));((num=num/60))
            if((num>23));then ((hour=num%24));((day=num/24))
            else ((hour=num));fi
        else ((min=num));fi
    else ((sec=num));fi
    if((sec<9));then ZERO=`echo -n "0"$sec`;wait;sec=`echo -n $ZERO`;fi
    if((min<9));then ZERO=`echo -n "0"$min`;wait;min=`echo -n $ZERO`;fi
    if((hour<9));then ZERO=`echo -n "0"$hour`;wait;hour=`echo -n $ZERO`;fi
    HHMMSS=`echo "$hour"':'"$min"':'"$sec"`

    echo "Resuming $INU at $HHMMSS"

else

    echo "Playing $INU"
    TIME=`cat .play`
fi

echo $TIME > ".time"
echo $INU > ".inu"
bash .ffmpeg.sh


wait
AUTOPLAY=`cat /tmp/fftime.txt | grep "Exiting normally, received signal 2."`

if [ -z "$AUTOPLAY" ]; then
      echo "KEEP AUTO PLAY LOOP" >> /tmp/fftime.txt
        touch .complete
else
      echo "BREAK AUTO PLAY LOOP" >> /tmp/fftime.txt
        if [ -f ".autoplay" ]; then mv .autoplay .ffrw; fi
fi



if [ ! -f .autoplay ]; then


FFTIME=`cat /tmp/fftime.txt | grep -o -P 'time=.{0,8}' | awk 'END{print}' | sed 's|time=||g'`
IFS=: read h m s <<<"$FFTIME" ; SEC=$((10#$s+10#$m*60+10#$h*3600)) ; SUM=$(($SEC + $TIME))
wait

if [ ! -f .complete ]; then
echo $SUM > .lastplay
fi

num=$SUM;min=0;hour=0;day=0
    if((num>59));then ((sec=num%60));((num=num/60))
        if((num>59));then ((min=num%60));((num=num/60))
            if((num>23));then ((hour=num%24));((day=num/24))
            else ((hour=num));fi
        else ((min=num));fi
    else ((sec=num));fi
if((sec<9));then ZERO=`echo -n "0"$sec`;wait;sec=`echo -n $ZERO`;fi
if((min<9));then ZERO=`echo -n "0"$min`;wait;min=`echo -n $ZERO`;fi
if((hour<9));then ZERO=`echo -n "0"$hour`;wait;hour=`echo -n $ZERO`;fi
HHMMSS=`echo "$hour"':'"$min"':'"$sec"`
echo "Stopped at $HHMMSS"
wait


echo '(r)esume, (b)ack, (f)orward, (w)atched, (s)ettings, (q)uit'

while true; do
    read -n1 -p '>' rwsq
    case $rwsq in
        [Rr]* ) \
	    echo -n "esume"
	    echo
	    exec ./ffmpeg-bash-player.sh
		   break;;
        [Bb]* ) \
            echo -n "ack"
            echo
	    echo -n "Enter amount you want to rewind in seconds. >"
	    read BACK
	    SEEK=`cat .lastplay`
	    NEWTIME=$(($SEEK - $BACK))
	    echo $NEWTIME > .lastplay
	    echo "Rewinding $BACK seconds."
	    if [ -f ".ffrw" ]; then mv .ffrw .autoplay; fi
            exec ./ffmpeg-bash-player.sh
                   break;;
        [Ff]* ) \
            echo -n "orward"
            echo
            echo -n "Enter amount you want to fast forward in seconds. >"
            read FORWARD
            SEEK=`cat .lastplay`
            NEWTIME=$(($SEEK + $FORWARD))
            echo $NEWTIME > .lastplay
            echo "Fast forwarding $FORWARD seconds."
            if [ -f ".ffrw" ]; then mv .ffrw .autoplay; fi
            exec ./ffmpeg-bash-player.sh
                   break;;

        [Ww]* ) \
            echo -n "atched"
	    echo
	    echo $INU >> .watched && echo "$INU marked as watched"
	    rm .lastplay ; rm .running
	    exec ./ffmpeg-bash-player.sh
		   break;;
        [Ss]* ) \
            echo -n "ettings"
	    echo
            rm .running
            exec ./ffmpeg-bash-player.sh
            echo
                   break;;
        [Qq]* ) \
            echo -n "uit"
	    rm .running
		if [ -f ".lastplay" ]; then
		if [ ! -f .complete ]; then
		echo
		echo -n "Save play posistion? "
		while true; do
	    	  read -n1 -p 'y/n>' yn
	    	  case $yn in
	            [Yy]* ) \
			echo
			exit
			   break;;
                    [Nn]* ) \
			rm .lastplay
                        echo
                        exit
                           break;;
			    * ) echo 'Please answer y/n';;
		      esac
		    done
		 fi
		fi
            echo
                   break;;
        * ) echo 'Please answer (q) (r) (b) (f) (s) or (w).';;
    esac
done
else
   if [ -f ".lastplay" ]; then rm .lastplay; fi
   echo $INU >> .watched
   exec ./ffmpeg-bash-player.sh
fi
exit
