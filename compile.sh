#!/bin/bash

repo=$(basename $(git remote show origin -n | grep "Fetch URL:" |awk {'print $3 '}))
repo=${repo%.*}
echo "<html><head><title>Presentations</title></head><body>" > index.html
echo "<h1>Presentations</h1>" >> index.html
echo "<ul>" >> index.html
for f in *.md
do 
  echo $f
  sed -e "s#src=\"images#src=\"../images#g" -i $f # html images fix
  sed -e "s#(images/#(../images/#g" -i $f #md images fix
  reveal-md $f --static ${f%.*}
  # fixing locations of css, js and plugin files
  sed -e "s#href=\"/css#href=\"/${repo}/${f%.*}/css#g" -i ${f%.*}/index.html
  sed -e "s#src=\"/lib#src=\"/${repo}/${f%.*}/lib#g" -i ${f%.*}/index.html
  sed -e "s#src=\"/js#src=\"/${repo}/${f%.*}/js#g" -i ${f%.*}/index.html
  sed -e "s#src: '/lib#src: '/${repo}/${f%.*}/lib#g" -i ${f%.*}/index.html
  sed -e "s#src: '/plugin#src: '/${repo}/${f%.*}/plugin#g" -i ${f%.*}/index.html
  echo "<li><a href=\"${f%.*}\">${f%.*}</a></li>" >> index.html
  rm $f
done
echo "</ul>" >> index.html
echo "</body></html>" >> index.html