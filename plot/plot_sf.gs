"reinit"
"set display color white"
"c"

"set lwid 13 5.5"
"set lwid 14 8.0"
"set lwid 15 2.5"
"set annot 1 15"
"set strsiz 0.18"
"set xlopts 1 15 0.18"
"set ylopts 1 15 0.18"
"set clopts 1 15 0.18"
"set rgb 200 100 100 100 220"
"set grid on 3 200 4"

"set font 11 file /home/der0318/.grads/Helvetica.ttf"
"set font 11"

path="/data/der0318/FF/"
model.1="CM1"
model.2="SCALE"
model.3="VVM"

"open "path"/gs_ctl/sf.ctl"

"set mproj off"

i=1
while(i<=3)

e=1
while(e<=5)

"set grads off"
"set parea 1.2 10 1.2 7.5"
"set vrange 0.6 1"
"set ylint 0.1"
"set xlabs 0||10||20||30||40||50"

*if (model.i=VVM); "set ccolor 2"; endif
*if (model.i=SCALE); "set ccolor 11"; endif
*if (model.i=CM1); "set ccolor 1"; endif
t=170
if (model.i=VVM); "set rgb 231 250 60 0 "t""; endif
if (model.i=SCALE); "set rgb 231 0 160 255 "t""; endif
if (model.i=CM1); "set rgb 231 0 0 0 "t""; endif

"set ccolor 231"
"set cthick 15"
"set cmark 0"

"set t 1 1201"
ens=5*(i-1)+e
"d sf(e="ens")"

say i' 'e
e=e+1
endwhile

i=i+1
endwhile


"set string 1 c 15 0"
"set strsiz 0.18"
"draw string 5.6 0.5 time [days]"

"set string 1 c 15 90"
"set strsiz 0.18"
"draw string 0.5 4.35 SF"

"set string 1 c 15 0"
"set strsiz 0.22"
"draw string 5.6 7.8 Subsidence Fraction"

"printim ./figure/sf_ens.png x2048 y1536"
*"c"

