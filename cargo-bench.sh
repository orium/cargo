LOOPS=20

function median() {
    left=$(cut -d' ' -f2 $1 | sort -n | tail -$(($LOOPS/2)) | head -1)
    right=$(cut -d' ' -f2 $1 | sort -n | tail -$(($LOOPS/2+1)) | head -1)

    echo $((($left+$right)/2))
}

function avg() {
    sum=0

    for v in $(cut -d' ' -f2 $1); do
        sum=$(($sum+$v))
    done

    echo $(($sum/$LOOPS))
}



for i in $(seq 1 $LOOPS); do
    echo -n "$i "

    CARGO_PROFILE=1 cargo-master generate-lockfile -v 2>&1 \
        | grep resolve-main-loop | grep -o '[0-9]*'
done | tee cargo-master

echo "MASTER    Median  $(median cargo-master)"
echo "MASTER    Average $(avg cargo-master)"

for i in $(seq 1 $LOOPS); do
    echo -n "$i "

    CARGO_PROFILE=1 cargo-rpds generate-lockfile -v 2>&1 \
        | grep resolve-main-loop | grep -o '[0-9]*'
done | tee cargo-rpds

echo "RPDS      Median  $(median cargo-rpds)"
echo "RPDS      Average $(avg cargo-rpds)"

for i in $(seq 1 $LOOPS); do
    echo -n "$i "

    CARGO_PROFILE=1 cargo-rpds-rc generate-lockfile -v 2>&1 \
        | grep resolve-main-loop | grep -o '[0-9]*'
done | tee cargo-rpds-rc

echo "RPDS-RC   Median  $(median cargo-rpds-rc)"
echo "RPDS-RC   Average $(avg cargo-rpds-rc)"

# RUST resolve-main-loop
#
# MASTER Median  35
# MASTER Average 35
# RPDS   Median  32
# RPDS   Average 32

# SERVO resolve-main-loop
#
# MASTER    Median  1870
# MASTER    Average 2640
# RPDS      Median  1695
# RPDS      Average 2805
# RPDS-RC   Median  1339
# RPDS-RC   Average 3221
