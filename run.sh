#!/bin/bash

raco make orig/*.rkt pr-opt/*.rkt hand-opt/*.rkt

mkdir dumps 2> /dev/null || true

N_ITERS=$((echo $1 | grep '[0-9]') || echo 3)
OUT_FILE=dumps/dump-`date +%y-%m-%d-%H:%M`

function extract-racket-time {
    echo -n $(racket $1/$2.rkt 2>&1 | awk '{ print $3/1000 }') >> $OUT_FILE ;
}

# run-shootout file arg
function run-shootout {
    echo -n $((time -p (racket $1 $2 2>&1 > /dev/null)) 2>&1 \
	| awk '$0 ~ /real/ { print $2 }')
}

echo -n > $OUT_FILE

for F in orig/*.rkt ; do
    benchmark=`basename $F .rkt`
    for version in orig pr-opt hand-opt ; do
	for i in `seq $N_ITERS` ; do
	    echo -n "($benchmark $version " >> $OUT_FILE
	    case $benchmark in
		binarytrees)
		    run-shootout $version/$benchmark.rkt 18 >> $OUT_FILE
		    ;;
		mandelbrot)
		    run-shootout $version/$benchmark.rkt 3000 >> $OUT_FILE
		    ;;
		heapsort)
		    run-shootout $version/$benchmark.rkt 2500000 >> $OUT_FILE
		    ;;
		nbody)
		    run-shootout $version/$benchmark.rkt 3000000 >> $OUT_FILE
		    ;;
		moments)
		    run-shootout $version/$benchmark.rkt 0 < moments-2000 \
			>> $OUT_FILE
		    ;;
		video|images-entry)
		    extract-racket-time $version $benchmark
		    ;;
		*)
		    echo unknown benchmark $benchmark
		    echo -n 0 >> $OUT_FILE
		    ;;
	    esac
	    echo ")" >> $OUT_FILE
	done
    done
done

racket analysis.rkt
