function testpass {
echo `pwd`
touch FAILS
for i in *.xml
do 
  ln -sf $i test.xml
  if $SAX_EXAMPLE | grep Error > /dev/null
  then
    echo Failed $i >> FAILS
  else 
    : #echo Passed $i
  fi
done
rm test.xml
diff FAILS XFAIL
rm FAILS
}

function testfail {
echo `pwd`
touch FAILS
for i in *.xml
do 
  ln -sf $i test.xml
  if $SAX_EXAMPLE | grep Error > /dev/null
  then
    : #echo Passed $i
  else 
    echo Failed $i >> FAILS
  fi
done
rm test.xml
diff FAILS XFAIL
rm FAILS
}

function testoasispass {
echo `pwd`
touch FAILS
for i in *pass*.xml
do 
  ln -sf $i test.xml
  if $SAX_EXAMPLE | grep Error > /dev/null
  then
    echo Failed $i >> FAILS
  else 
    : #echo Passed $i
  fi
done
rm test.xml
diff FAILS XpassFAIL
rm FAILS
}

function testoasisfail {
echo `pwd`
touch FAILS
for i in *fail*.xml
do 
  ln -sf $i test.xml
  if $SAX_EXAMPLE | grep Error > /dev/null
  then
    : #echo Passed $i
  else 
    echo Failed $i >> FAILS
  fi
done
rm test.xml
diff FAILS XfailFAIL
rm FAILS
}

cd ibm
SAX_EXAMPLE=../../../sax_example.exe

#cd invalid
#for i in *
#do
#  (cd $i; testfail)
#done

cd not-wf
for i in *
do
  (cd $i; testfail)
done

cd ../valid
for i in *
do
  (cd $i; testpass)
done

cd ../xml-1.1
SAX_EXAMPLE=../../../../sax_example.exe

cd not-wf
for i in *
do
  (cd $i; testfail)
done

cd ../valid
for i in *
do
  (cd $i; testpass)
done
exit


# James Clark tests
cd xmltest
SAX_EXAMPLE=../../../sax_example.exe

cd not-wf
cd sa
testfail

cd ../not-sa
testfail

cd ../ext-sa
testfail

cd ../../valid
cd sa
testpass

cd ../not-sa
testpass

cd ../ext-sa
testpass

cd ../../../sun
SAX_EXAMPLE=../../sax_example.exe

cd not-wf
testfail

cd ../valid
testpass

cd ../../oasis
SAX_EXAMPLE=../sax_example.exe

testoasisfail
testoasispass


