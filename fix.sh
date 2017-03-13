#!/bin/bash
for f in *.md; do echo $f; reveal-md $f --static ${f%.*};  done
for f in *.md; do echo $f; sed -e "s#href=\"/css#href=\"/presentations/${f%.*}/css#g" -i ${f%.*}/index.html; done
for f in *.md; do echo $f; sed -e "s#src=\"/lib#src=\"/presentations/${f%.*}/lib#g" -i ${f%.*}/index.html; done
for f in *.md; do echo $f; sed -e "s#src=\"/js#src=\"/presentations/${f%.*}/js#g" -i ${f%.*}/index.html; done
for f in *.md; do echo $f; sed -e "s#src: \'/lib#src: \'/presentations/${f%.*}/lib#g" -i ${f%.*}/index.html; done
for f in *.md; do echo $f; sed -e "s#src: \'/plugin#src: \'/presentations/${f%.*}/plugin#g" -i ${f%.*}/index.html; done