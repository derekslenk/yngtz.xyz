#!/bin/bash
echo "timestamp outflow inflow risedrop level" > csv/three-gorges.csv
echo "timestamp outflow inflow risedrop level" > csv/cuntan.csv
echo "timestamp outflow inflow risedrop level" > csv/hankou.csv
echo "timestamp outflow inflow risedrop level" > csv/hankou-prev.csv
echo "timestamp outflow inflow risedrop level" > csv/yichang.csv
echo "timestamp wulong_outflow wulong_inflow wulong_risedrop wulong_level" > csv/wulong.csv
echo "timestamp shashi_outflow shashi_inflow shashi_risedrop shashi_level" > csv/shashi.csv
echo "timestamp chenglingji_outflow chenglingji_inflow chenglingji_risedrop chenglingji_level" > csv/chenglingji.csv

find out/ -name '*.html' | xargs cat | grep "var sssq =" | cut -d "=" -f 2 | cut -d ";" -f 1 | \
    jq -r '(map(select(.stnm=="三峡水库"))[]) | "\(.tm/1000) \(.oq) \(.q) \(.wptn) \(.z)"' | \
    sort | uniq >> csv/three-gorges.csv &

find out/ -name '*.html' | xargs cat | grep "var sssq =" | cut -d "=" -f 2 | cut -d ";" -f 1 | \
    jq -r '(map(select(.stnm=="寸滩"))[]) | "\(.tm/1000) \(.oq) \(.q) \(.wptn) \(.z)"' | \
    sort | uniq >> csv/cuntan.csv &

find out/ -name '*.html' | xargs cat | grep "var sssq =" | cut -d "=" -f 2 | cut -d ";" -f 1 | \
    jq -r '(map(select(.stnm=="汉口"))[]) | "\(.tm/1000) \(.oq) \(.q) \(.wptn) \(.z)"' | \
    sort | uniq | \
    egrep -v "^1595113260 0 2330 6 42.57$" >> csv/hankou.csv &

find out/ -name '*.html' | xargs cat | grep "var sssq =" | cut -d "=" -f 2 | cut -d ";" -f 1 | \
    jq -r '(map(select(.stnm=="汉口"))[]) | "\(.tm/1000) \(.oq) \(.q) \(.wptn) \(.z)"' | \
    sort | uniq >> csv/hankou-prev.csv &

find out/ -name '*.html' | xargs cat | grep "var sssq =" | cut -d "=" -f 2 | cut -d ";" -f 1 | \
    jq -r '(map(select(.stnm=="宜昌"))[]) | "\(.tm/1000) \(.oq) \(.q) \(.wptn) \(.z)"' | \
    sort | uniq >> csv/yichang.csv &

find out/ -name '*.html' | xargs cat | grep "var sssq =" | cut -d "=" -f 2 | cut -d ";" -f 1 | \
    jq -r '(map(select(.stnm=="武隆"))[]) | "\(.tm/1000) \(.oq) \(.q) \(.wptn) \(.z)"' | \
    sort | uniq >> csv/wulong.csv &

find out/ -name '*.html' | xargs cat | grep "var sssq =" | cut -d "=" -f 2 | cut -d ";" -f 1 | \
    jq -r '(map(select(.stnm=="沙市"))[]) | "\(.tm/1000) \(.oq) \(.q) \(.wptn) \(.z)"' | \
    sort | uniq >> csv/shashi.csv &

find out/ -name '*.html' | xargs cat | grep "var sssq =" | cut -d "=" -f 2 | cut -d ";" -f 1 | \
    jq -r '(map(select(.stnm=="城陵矶(七)"))[]) | "\(.tm/1000) \(.oq) \(.q) \(.wptn) \(.z)"' | \
    sort | uniq >> csv/chenglingji.csv &

wait

join csv/cuntan.csv csv/wulong.csv > csv/cuntan-wulong.csv
join csv/shashi.csv csv/chenglingji.csv > csv/shashi-chenglingji.csv

./three-gorges.gnuplot
./cuntan.gnuplot
./hankou.gnuplot
./hankou-prev.gnuplot
./yichang.gnuplot
./shashi-chenglingji.gnuplot

ALL="three-gorges three-gorges-3d three-gorges-24h cuntan cuntan-3d cuntan-24h hankou hankou-3d hankou-24h hankou-prev yichang yichang-3d yichang-24h shashi-chenglingji shashi-chenglingji-3d shashi-chenglingji-24h"

for fn in $ALL; do
    pdftocairo -png graphs/$fn.pdf -singlefile -scale-to 1600 graphs/$fn-upsample &
done

wait

for fn in $ALL; do
    convert graphs/$fn-upsample.png -filter Lanczos -distort Resize 50% graphs/$fn.png &
done

wait

exit 0

for fn in $ALL; do
    advpng -4 -z graphs/$fn.png &
done

wait
