#!/bin/bash

#A function that prints out the help manual
function usage(){
	cat<<-END
Usage: ./wtograph [OPTION]... 

Plot a graph about how many user and uniq users you have on the server,
that refreshes in every second (if -t|--time is not specified)

Dependencies:
	gnuplot 5.0

Options:
   -h, --help 		    display this help menu
   -s, --save	  	    saves the graph on exit to a file
   			     named graph+current date+current time.txt
   -t, --title NAME         set the title of the graph to NAME
   			     (default: Number of users on the server)
   -xl, --xlabel NAME       set the xlabel of the graph to NAME
   			     (default: Time(s))
   -yl, --ylabel NAME       set the ylabel of the graph to NAME
   			     (default: Number of users)
   -pl, --plotline NAME     set the plotline name of the graph to NAME
   			     (default: Number of Users over Time)
   -ul, --uniqline NAME     set the uniq plotline name of the graph to NAME
   			     (default: Number of Uniq Users over Time)
   -sf, --savefile FILE     saves the graph on exit to a file 
  			     named FILE 
   -sd, --savedata          save the data.dat file which contains the 
   			     seconds past the start time, and the user numbers
   -st, -settime TIME     specify the refresh time in second 
   			     (default=1)
   -c, --cols COLS         set output width to COLS (default dynamic max value)
   			     your max value is=$(tput cols)
   -l, --lines LINES        set output height to LINES
  			     (default takes up the whole terminal)
                             your max value is=$(tput lines)
   -sp, --savepng FILE      saves the graph to a png file

Written by:Iles Illés Tamás
Report bugs to titomi1@gmail.hu
	END
}

#Variable setups, mostly "booleans" (0|1), and default value
GRAPHTITLE="Number of Users on the Server"
XLABEL="Time(s)"
YLABEL="Number of users"
PLOTTEDLINE="Number of Users over Time"
PLOTTEDUNIQLINE="Number of Uniq Users over Time"

OUTPUTFILE="graph_$(date +%Y-%m-%d-%H:%M:%S).txt"
PNGGRAPHTITLE=="graph_$(date +%Y-%m-%d-%H:%M:%S).png"

let INTERVAL=1
let SAVEFILE=0
let SAVEDATA=0
let ISCOLAUTO=1
let ISLINEAUTO=1
let SAVEPNG=0

let COLS=$(tput cols)
let LINES=$(tput lines)

#Argument handler
if [ $# -ne 0 ]
then	
while [ -n "$1" ]
do
	case $1 in
		-h|--help )        usage
			           exit 0
			           ;;
	        -s|--save ) 	   let SAVEFILE=1
				   ;;
	        -t|--title )	   shift
				   GRAPHTITLE="$1"
				   ;;
		-xl|--xlabel )	   shift
				   XLABEL="$1"
				   ;;
		-yl|--ylabel )     shift
				   YLABEL="$1"
				   ;;
		-pl|--plotline )   shift
				   PLOTTEDLINE="$1"
				   ;;
	        -ul|--uniqline )   shift
				   PLOTTEDUNIQLINE="$1"
				   ;;
		-sf|--savefile )   let SAVEFILE=1
				   shift
				   OUTPUTFILE="$1"
			           ;;
	        -sd|--savedata )   let SAVEDATA=1
				   ;;
		-st|--settime )    shift
				   let INTERVAL=$1				
			           ;;
		-c|--cols )	   let ISCOLAUTO=0
     	         	           shift
				   let COLS=$1			
			           ;;
		-l|--lines )       let ISLINEAUTO=0
				   shift
				   let LINES=$1
		       		   ;;
	        -sp|--savepng )    let SAVEPNG=1
				   shift
				   PNGGRAPHTITLE="$1"
				   ;;
		* )                echo "Invalid option -- '$1'"
				   usage
			           exit 1
	esac
	shift			
done
fi

#Function for ploting in ascii
function plot(){
	gnuplot -e "set term dumb $COLS $LINES;
		    set autoscale;
		    set title \"$GRAPHTITLE\";
		    set xlabel \"$XLABEL\";
		    set yr [0:$YMAX];
		    plot \"data.dat\" using 1:2 title '$PLOTTEDLINE'  with fstep, \
			  \"data.dat\" using 1:3 title '$PLOTTEDUNIQLINE' with fstep;
		    pause 1;
		    reread;"|GREP_COLOR="1;31" egrep -C $LINES --color=auto '\*'
}

#Function for ploting in png
function plotpng(){
	gnuplot -e "reset;
		    set term pngcairo size 640,480 enhanced font 'Verdena,10';
		    set border linewidth 1.5;
		    set output '$PNGGRAPHTITLE';
		    set style line 1 linecolor rgb '#dd181f' linetype 1 linewidth 2;
		    set style line 2 linecolor rgb '#0060ad' linetype 1 linewidth 2;
		    set title \"$GRAPHTITLE\";
		    set xlabel \"$XLABEL\";
		    set ylabel \"$YLABEL\";
		    set yr [0:$YMAX];
		    plot \"data.dat\" using 1:2 title '$PLOTTEDLINE'  with lines linestyle 1, \
			  \"data.dat\" using 1:3 title '$PLOTTEDUNIQLINE' with lines linestyle 2"

}

function getdata (){
	let LASTMEASURE=$MEASURE
	let LASTUNIQMEASURE=$UNIQMEASURE
	let MEASURE=$(w -h|wc -l)
	let UNIQMEASURE=$(w -h|cut -d " " -f 1|sort|uniq|wc -l)	
	let LTIME=LTIME+INTERVAL
	if [ $MEASURE -gt $MAX ]
	then
		let MAX=MEASURE
	fi
	if [ $LASTMEASURE -eq $MEASURE ] && [ $LASTUNIQMEASURE -eq $UNIQMEASURE ]
	then
		if [ $FIRSTCHANGE -eq 1 ]
		then
			let FIRSTCHANGE=0	
		else	
			sed -i '$ d' $DATAFILE	
		fi
	else 
		let FIRSTCHANGE=1
	fi
	echo "$LTIME $MEASURE $UNIQMEASURE"|cat >> $DATAFILE
}



#Function that handles ctrl-c
function catchctrlc(){	
	if [ $SAVEPNG -eq 1 ]
	then
		plotpng	
	fi
	if [ $SAVEFILE -eq 1 ]
	then
		plot|tee "$OUTPUTFILE"
	fi
	
	if [ $SAVEDATA -eq 1 ]
	then
		mv $DATAFILE "data_$(date +%Y-%m-%d-%H:%M:%S).dat"
	else
		rm $DATAFILE
	fi
	clear	
	exit 0
}

trap 'catchctrlc' SIGINT
		
#Main loop function idk why did I put it in a function *shrug*
function mainloop(){
	DATAFILE="data.dat"
	rm $DATAFILE
	touch $DATAFILE
	let LTIME=0
	let MAX=0
	let MEASURE=$(w -h|wc -l)
	let UNIQMEASURE=$(w -h|cut -d " " -f 1|sort|uniq|wc -l)	
	let FIRSTCHANGE=1
	echo "$LTIME $MEASURE $UNIQMEASURE"|cat >> $DATAFILE
	while [ $LTIME -lt 10000 ];
	do	
		if [ $ISCOLAUTO -eq 1 ]
		then
			let COLS=$(tput cols)
		fi
		if [ $ISLINEAUTO -eq 1 ]
		then
			let LINES=$(tput lines)
		fi
		let YMAX=MAX+2
		getdata
		plot
		sleep 1
	done
}

mainloop
