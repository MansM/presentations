#!/bin/bash

echo "<html><head><title>Presentations</title></head><body>" > index.html
echo "<h1>Presentations</h1>" >> index.html
echo "<ul>" >> index.html
for f in *.md
do 
  echo $f
  sed -e "s#src=\"images#src=\"../images#g" -i $f
  reveal-md $f --static ${f%.*}
  sed -e "s#href=\"/css#href=\"/presentations/${f%.*}/css#g" -i ${f%.*}/index.html
  sed -e "s#src=\"/lib#src=\"/presentations/${f%.*}/lib#g" -i ${f%.*}/index.html
  sed -e "s#src=\"/js#src=\"/presentations/${f%.*}/js#g" -i ${f%.*}/index.html
  sed -e "s#src: '/lib#src: '/presentations/${f%.*}/lib#g" -i ${f%.*}/index.html
  sed -e "s#src: '/plugin#src: '/presentations/${f%.*}/plugin#g" -i ${f%.*}/index.html
  echo "<li><a href=\"${f%.*}\">${f%.*}</a></li>" >> index.html
  rm $f
done
echo "</ul>" >> index.html
echo "</body></html>" >> index.html