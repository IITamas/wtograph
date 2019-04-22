# wtograph

Usage: ./wtograph [OPTION]...

Plot a graph about how many user and uniq users you have on the server,
that refreshes in every second (if -t|--time is not specified)

Example plot:

![alt text](https://github.com/IITamas/wtograph/blob/master/plotted_image.png)

Dependencies:
        gnuplot 5.0


Options:

   -h, --help               display this help menu

   -s, --save               saves the graph on exit to a file
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


