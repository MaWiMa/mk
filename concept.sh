#!/bin/bash
# ./concept.sh MedienkonzeptAusbildungsvorbereitung.asciidoc

file=$1
yamlfile="CONCEPT-theme.yml"

if [ ! -f $yamlfile ]
then
   echo "$yamlfile must exist"
   exit
fi 

if [ -z "$file" ]
then
   echo "Syntax:   Scriptname filename"
   echo "Beispiel: $0 somefile.asciidoc"
   exit
fi

if [ ! -f $file ]
then
   echo "$file must exist"
   exit
fi

echo $file

git add $file
git commit $file
commit="$(git log -n 1 --date=iso8601 --grep $file|grep commit|cut -d" " -f 2|cut -c-7)"
author="$(git log -n 1 --date=iso8601 --grep $file|grep -i author|cut -d" " -f 4)"
date="$(git log -n 1 --date=iso8601 --grep $file|grep -i date|cut -d" " -f 4)"
time="$(git log -n 1 --date=iso8601 --grep $file|grep -i date|cut -d" " -f 5)"
echo ""
echo "last changing commit of $file is: $commit"
echo "last changing editor of $file is: $author"
echo "last changing date   of $file is: $date"
echo "last changing time   of $file is: $time"
echo ""

#echo "sed is working"
sed -i \
  -e 's/^\(\s*commit\s*:\s*\).*/\1'\"$commit'\"/' \
  -e 's/^\(\s*author\s*:\s*\).*/\1'\"$author'\"/' \
  -e 's/^\(\s*date\s*:\s*\).*/\1'\"$date'\"/' \
  -e 's/^\(\s*time\s*:\s*\).*/\1'\"$time'\"/' \
  $yamlfile
#echo "sed is ready"

filebase=$(basename $file .asciidoc)
#hmtl=${filebase}.hmtl
pdf=${filebase}.pdf
#epub=${filebase}.epub

#echo "asciidoctor starts working on $file"
#asciidoctor -a imagesdir=images $file
#echo ""
#echo "asciidoctor has made $hmtl"
#echo ""

#echo "asciidoctor-epub starts working on $file"
#asciidoctor-epub3 -a imagesdir=images $file
#echo ""
#echo "asciidoctor has made $epub"
#echo ""

echo "asciidoctor-pdf starts working on $file"
asciidoctor-pdf -a pdf-style=CONCEPT -a pdf-stylesdir=. -a pdf-fontsdir=fonts -a imagesdir=images -a author="Norbert Reschke" $file
echo ""
echo "asciidoctor has made $pdf"
echo ""
big=$(ls -al --block-size=1K $pdf|cut -d" " -f5)
echo "hexapdf starts optimizing $pdf"
hexapdf optimize $pdf hexa.pdf && mv hexa.pdf $pdf
echo "hexapdf has work done and"
small=$(ls -al --block-size=1K $pdf|cut -d" " -f5)
echo "now size (in K) of $pdf shrinked from $big to $small"

#restore yamlfile
#echo "sed is working"
sed -i \
  -e 's/^\(\s*commit\s*:\s*\).*/\1'\"dummy'\"/' \
  -e 's/^\(\s*author\s*:\s*\).*/\1'\"dummy'\"/' \
  -e 's/^\(\s*date\s*:\s*\).*/\1'\"dummy'\"/' \
  -e 's/^\(\s*time\s*:\s*\).*/\1'\"dummy'\"/' \
  $yamlfile
#echo "sed is ready"
