"reinit"

path="/data/der0318/FF/FF_data/"
model.1="CM1"
model.2="SCALE"
model.3="VVM"

i=1
while(i<=1)

if (model.i=VVM); ts=2; te=2400; pw="pw"; endif
if (model.i=SCALE); ts=1; te=2399; pw="pw/1000"; endif
if (model.i=CM1);  ts=2; te=2400; pw="pwat*1000"; endif

e=1
while(e<=5)

if (model.i=VVM); gsctl="gs_ctl_files/dynamic.ctl" ; endif
if (model.i=SCALE); gsctl="hist.ctl" ; endif
if (model.i=CM1); gsctl="cm1out_w.ctl" ; endif

"open "path"/"model.i"/FF_fixed_0p25K_en"e"/"gsctl""

"set fwrite ../data/"model.i"_en"e".dat"
"set gxout fwrite"
"set undef -999"

"set z 19"
"set x 1 512"
"set y 1 128"
"set t "ts+25" "te-25""
"define a=tloop(mean(w,t-24,t+24))"
"define b=const(maskout(const(a,0.,-a),a),1.,-u)"
"set x 1"
"set y 1"
"define a=amean(b,x=1,x=512,y=1,y=128)"

"set t "ts" "te""
"d a"

"disable fwrite"

"close 1"

say i' 'e
e=e+1
endwhile


i=i+1
endwhile

