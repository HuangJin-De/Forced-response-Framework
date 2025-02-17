#!/usr/bin/bash

datapath=/data/der0318/FF_data/
linkpath=/data/der0318/FF/FF_data/

mkdir $linkpath
cd $linkpath

for model in $(ls $datapath) # 3 models
do

  for run in $(ls $datapath/$model | grep 0p25)
  do

    if [ $model == 'VVM-done' ]
    then



      echo $model/$run

      mkdir -p $model/$run
      cd $model/$run

      cp -r ${datapath}/${model}/${run}/TOPO.nc .
      cp -r ${datapath}/${model}/${run}/INPUT .
      cp -r ${datapath}/${model}/${run}/fort.98 .
      cp -r ${datapath}/${model}/${run}/make_ctl.sh .

      mkdir archive
      cd archive
     
      tfinal=$(ls $datapath/$model/$run/archive/*Dynamic* | tail -n 1 | rev | cut -d. -f 2-3 | rev | cut -d- -f 2-3) 
      n=0
      for t in $(seq 0 1 $tfinal)
      do
        dt=$(printf '%06g' $t)
        dn=$(printf '%06g' $n)
        for name in $(ls -I "*post*" ${datapath}/${model}/${run}/archive/*$dt*)
        do
          temp=$(echo $name | cut -d. -f 2- | cut -d- -f 1)
          #echo $name'  at:'$t
          #echo $name ${run}.$temp-$dn.nc
          ln -s $name ${run}.${temp}-$dn.nc
        done
        n=$(($n+1))
      done

      cd ..
      ./make_ctl.sh
 


    elif [ $model == 'SCALE-done' ]
    then



      echo $model/$run

      mkdir -p $model/$run
      cd $model/$run

      cp -r $datapath/$model/$run/hist.ctl .

      n=1   
      for name in $(ls $datapath/$model/$run/history*)
      do
        dn=$(printf '%06g' $n)

        #echo $name ${run}.history-$dn.nc
        ln -s $name ${run}.history-$dn.nc

        n=$(($n+1))
      done



    elif [ $model == 'CM1-done' ]
    then



      echo $model/$run
    
      mkdir -p $model/$run
      cd $model/$run

      cp $datapath/$model/$run/cm1out_u.ctl .
      cp $datapath/$model/$run/cm1out_v.ctl .
      cp $datapath/$model/$run/cm1out_w.ctl .
      cp $datapath/$model/$run/cm1out_s.ctl .

      for name in $(ls $datapath/$model/$run/cm1out_00*.dat)
      do
        #echo $name
        ln -s $name . 
      done
 
      

    fi

    cd $linkpath
  done
done





