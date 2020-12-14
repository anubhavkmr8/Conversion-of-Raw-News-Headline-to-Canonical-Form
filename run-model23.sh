#!/bin/bash

# parameter for cores avaialble in machine. USE $ sudo bash ./run-model23.sh 4
CORES=${1:-4}
echo -e "\n$(tput setaf 2)STARTING SCRIPT$(tput sgr 0)"
echo -e "\n$(tput setaf 2)AVAILABLE CORES = $CORES$(tput sgr 0)"
echo -e "\n$(tput setaf 2)EXPECTED TIME TO COMPLETE - Around 20-25 mins$(tput sgr 0)"
echo -e "\n$(tput setaf 2)Author - anubhav.kumar.eee17@itbhu.ac.in$(tput sgr 0)"
sleep 5

# MOSES INSTALLATION AND COMPILATION USING BOOST
echo -e "\n$(tput setaf 2)INSTALLATION SCRIPT RUNNING$(tput sgr 0)"

# Installing required libraries
echo -e "\n$(tput setaf 2)Installing libraries$(tput sgr 0)"
sudo apt-get install g++
sudo apt-get install git
sudo apt-get install subversion
sudo apt-get install automake
sudo apt-get install libtool
sudo apt-get install zlib1g-dev
sudo apt-get install libicu-dev
sudo apt-get install libboost-all-dev
sudo apt-get install libbz2-dev
sudo apt-get install liblzma-dev
sudo apt-get install python-dev
sudo apt-get install graphviz
sudo apt-get install imagemagick
sudo apt-get install make
sudo apt-get install cmake
sudo apt-get install libgoogle-perftools-dev
sudo apt-get install autoconf
sudo apt-get install doxygen
# at home

# Installing boost
echo -e "\n$(tput setaf 2)Installing boost$(tput sgr 0)"
wget https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz
tar zxvf boost_1_64_0.tar.gz
rm -r boost_1_64_0.tar.gz
cd boost_1_64_0/
./bootstrap.sh 
./b2 -j4 --prefix=$PWD --libdir=$PWD/lib64 --layout=system link=static install || echo -e FAILURE

# Installing moses
echo -e "\n$(tput setaf 2)Installing moses$(tput sgr 0)"
cd ..
git clone git://github.com/moses-smt/mosesdecoder.git moses
cd moses
./bjam --with-boost=../boost_1_64_0 -j8

# Installing GIZA++ (for word alignment)
echo -e "\n$(tput setaf 2)Installing GIZA$(tput sgr 0)"
cd ..
git clone https://github.com/moses-smt/giza-pp.git
cd giza-pp
make
# This should create the binaries ~/giza-pp/GIZA++-v2/GIZA++, ~/giza-pp/GIZA++-v2/snt2cooc.out and ~/giza-pp/mkcls-v2/mkcls. These need to be copied to somewhere that Moses can find them as follows
cd ..
cd moses
mkdir tools
cp ../giza-pp/GIZA++-v2/GIZA++ ../giza-pp/GIZA++-v2/snt2cooc.out ../giza-pp/mkcls-v2/mkcls tools

# Installing collins parser
echo -e "\n$(tput setaf 2)Installing Collins Parser$(tput sgr 0)"
cd ..
wget http://people.csail.mit.edu/mcollins/PARSER.tar.gz
tar xzf PARSER.tar.gz
rm -r PARSER.tar.gz
cd COLLINS-PARSER/code
make
cd ..

# Installing mxpost POS tagger
cd ..
mv COLLINS-PARSER collins
echo -e "\n$(tput setaf 2)Installing MXPOST POS Tagger$(tput sgr 0)"
mkdir mxpost
cd mxpost
wget ftp://ftp.cis.upenn.edu/pub/adwait/jmx/jmx.tar.gz
tar xzf jmx.tar.gz
rm -r jmx.tar.gz
echo '#!/usr/bin/env bash' > mxpost
echo "export CLASSPATH=$(pwd)/mxpost.jar" >> mxpost
echo "java -mx30m tagger.TestTagger $(pwd)/tagger.project" >> mxpost
chmod +x mxpost
echo 'This is a test .' | ./mxpost

echo -e "\n$(tput setaf 2)INSTALLATION COMPLETE$(tput sgr 0)"
echo -e "\n$(tput setaf 2)For Model2 - Moses PB-SMT, tokenized & truecased corpus present in /split directory$(tput sgr 0)"
echo -e "\n$(tput setaf 2)For Model3 - Moses Syntax (tree-to-tree), POS tagging and parsing pre-processed corpus in /split to /xml directory$(tput sgr 0)"



# POS TAGGING, PARSING & CONVERTING TO XMLS FOR MODEL 3 (creating data files in /xml from /split)
cd ..
echo -e "/n$(tput setaf 2)POS Tagging, Parsing & XML conversion$(tput sgr 0)"
mkdir xml
#cd ..
cd moses/scripts/training/wrappers
./parse-en-collins.perl --mxpost=../../../../mxpost --collins=../../../../collins < ../../../../split/train.clean.rw > ../../../../xml/train.xml.rw
./parse-en-collins.perl --mxpost=../../../../mxpost --collins=../../../../collins < ../../../../split/train.clean.tr > ../../../../xml/train.xml.tr
./parse-en-collins.perl --mxpost=../../../../mxpost --collins=../../../../collins < ../../../../split/validate.clean.rw > ../../../../xml/validate.xml.rw
./parse-en-collins.perl --mxpost=../../../../mxpost --collins=../../../../collins < ../../../../split/validate.clean.tr > ../../../../xml/validate.xml.tr
./parse-en-collins.perl --mxpost=../../../../mxpost --collins=../../../../collins < ../../../../split/test.clean.rw > ../../../../xml/test.xml.rw
./parse-en-collins.perl --mxpost=../../../../mxpost --collins=../../../../collins < ../../../../split/test.clean.tr > ../../../../xml/test.xml.tr
cd ../../../.. # at home



# LANGUAGE MODEL CREATION
echo -e "\n$(tput setaf 2)Creating language model on train.clean.tr for translation fluency in test corpus$(tput sgr 0)"
mkdir lm
cd lm
../moses/bin/lmplz -o 3 < ../split/train.clean.tr > train.arpa.tr
../moses/bin/build_binary train.arpa.tr train.blm.tr
cd .. # at home
DOME=$(pwd)



# MODEL 2 Moses PB-SMT
echo -e "/n$(tput setaf 2)BUILDING MODEL2 Moses PB-SMT - STARTING$(tput sgr 0)"
echo -e "/n$(tput setaf 2)BUILDING MODEL2 Moses PB-SMT - TRAINING$(tput sgr 0)"
mkdir work-pbsmt
cd work-pbsmt
nohup nice $DOME/moses/scripts/training/train-model.perl -cores $CORES -root-dir train -corpus $DOME/split/train.clean -f rw -e tr -alignment grow-diag-final-and -reordering msd-bidirectional-fe -lm 0:3:$DOME/lm/train.blm.tr:8 -external-bin-dir $DOME/moses/tools >& training.out &
wait ${!}
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses PB-SMT - TUNING$(tput sgr 0)"
nohup nice $DOME/moses/scripts/training/mert-moses.pl $DOME/split/validate.clean.rw $DOME/split/validate.clean.tr $DOME/moses/bin/moses train/model/moses.ini --mertdir $DOME/moses/bin/ --decoder-flags="-threads all" &> mert.out &
wait ${!}
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses PB-SMT - TESTING$(tput sgr 0)"
nohup nice $DOME/moses/bin/moses -f $DOME/work-pbsmt/mert-work/moses.ini < $DOME/split/test.clean.rw > $DOME/work-pbsmt/test.model2.moses-pbsmt.transformed.tr 2> $DOME/work-pbsmt/transformed.out
wait ${!}
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses PB-SMT - BLEU SCORE$(tput sgr 0)"
BLEUMODEL2=$($DOME/moses/scripts/generic/multi-bleu.perl -lc $DOME/split/test.clean.tr < $DOME/work-pbsmt/test.model2.moses-pbsmt.transformed.tr | head -n 1)
echo -e "$BLEUMODEL2"
cp test.model2.moses-pbsmt.transformed.tr $DOME/split
cd .. # at home
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses PB-SMT - COMPLETE$(tput sgr 0)"



# MODEL 3 Moses Syntax
echo -e "\n$(tput setaf 2)BUILDING MODEL3 Moses SYNTAX (with linguistic knowledge using POS tagged parse trees) - STARTING$(tput sgr 0)"
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses SYNTAX - TRAINING$(tput sgr 0)"
mkdir work-syntax
cd work-syntax
nohup nice $DOME/moses/scripts/training/train-model.perl --score-options="--GoodTuring" --source-syntax --target-syntax -hierarchical -glue-grammar -xml -cores $CORES -root-dir train -corpus $DOME/xml/train.xml -f rw -e tr -alignment grow-diag-final-and -lm 0:3:$DOME/lm/train.blm.tr:8 -external-bin-dir $DOME/moses/tools >& training.out &
wait ${!}
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses SYNTAX - TUNING$(tput sgr 0)"
nohup nice $DOME/moses/scripts/training/mert-moses.pl $DOME/xml/validate.xml.rw $DOME/split/validate.clean.tr $DOME/moses/bin/moses_chart train/model/moses.ini --mertdir $DOME/moses/bin/ --inputtype=3 --decoder-flags="-threads all" &> mert.out &
wait ${!}
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses SYNTAX - TESTING$(tput sgr 0)"
nohup nice $DOME/moses/bin/moses_chart -f $DOME/work-syntax/mert-work/moses.ini < $DOME/split/test.clean.rw > $DOME/work-syntax/test.model3.moses-syntax.transformed.tr 2> transformed.out
wait ${!}
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses SYNTAX - BLEU SCORE$(tput sgr 0)"
BLEUMODEL3=$($DOME/moses/scripts/generic/multi-bleu.perl -lc $DOME/split/test.clean.tr < $DOME/work-syntax/test.model3.moses-syntax.transformed.tr | head -n 1)
echo -e "$BLEUMODEL3"
cp test.model3.moses-syntax.transformed.tr $DOME/split
cd .. # at home
echo -e "\n$(tput setaf 2)BUILDING MODEL2 Moses SYNTAX - COMPLETE$(tput sgr 0)"


echo -e "\n$(tput setaf 2)FOR MODEL2 -> MOSES PB-SMT$(tput sgr 0)"
echo -e "$(tput setaf 2)Transformed test file -> /split/test.model2.moses-pbsmt.transformed.tr$(tput sgr 0)"
echo -e "$(tput setaf 2)$BLEUMODEL2$(tput sgr 0)"

echo -e "\n$(tput setaf 2)FOR MODEL3 -> MOSES SYNTAX$(tput sgr 0)"
echo -e "$(tput setaf 2)Transformed test file -> /split/test.model3.moses-syntax.transformed.tr$(tput sgr 0)"
echo -e "$(tput setaf 2)$BLEUMODEL3$(tput sgr 0)"
echo -e "\nEXIT"