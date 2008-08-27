#!/bin/sh

FOXHOME=/Users/tow/devel/FoX

(cd $FOXHOME; make)
rm *.exe
(cd $FOXHOME/sax/test;
make clean sax_well_formed.ns.no.exe sax_well_formed.ns.yes.exe sax_valid.ns.no.exe sax_valid.ns.yes.exe)
cp $FOXHOME/sax/test/sax_well_formed.*.exe .
cp $FOXHOME/sax/test/sax_valid.*.exe .

(cd $FOXHOME/examples;
make clean dom_canonicalize.ns.no.exe dom_canonicalize.ns.yes.exe)
cp $FOXHOME/examples/dom_canonicalize.ns.no.exe $FOXHOME/examples/dom_canonicalize.ns.yes.exe .
