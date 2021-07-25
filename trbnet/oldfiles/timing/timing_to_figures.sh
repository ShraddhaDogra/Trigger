latex $1.tex
a=`dvitype --output-level=1 $1.dvi | sed -n '/totalpages=.*$/s/^.*ges=//p'`
dvips $1.dvi

for ((b=1; b <= a ; b++))  # Double parentheses, and "LIMIT" with no "$".
do
  echo $b

  psselect -p$b-$b $1.ps > $1_$b.ps
  ps2epsi $1_$b.ps $1_$b.eps
  #convert -density 150x150 $1_$b.eps $1_$b.png
  convert -density 75x75  $1_$b.eps $1_$b.png
  rm $1_$b.ps $1_$b.eps
done   

