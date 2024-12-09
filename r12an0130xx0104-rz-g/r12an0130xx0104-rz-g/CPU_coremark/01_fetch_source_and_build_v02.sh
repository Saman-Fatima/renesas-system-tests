#!/bin/bash

#Step1: Set Parameters
TOOLCHAIN_VERSION=`ls /opt/poky/ | egrep -w '3.1.21' | head -n 1`
WORK=`pwd`

#Step2: Check TOOLCHAIN_VERSION if not found then install SDK 3.1.21 version
if [ "$TOOLCHAIN_VERSION" = "" ] ; then
	echo " Not find file SDK installer, please prepare SDK to run next"
fi

#Step3: Clone Coremark

git clone https://github.com/eembc/coremark.git 

cp 0001-Makefile-remove-run-binary-file-after-compile-proces.patch coremark/

cd coremark/ 

#Step4: Source the environment setup script for the Poky cross-compiler
source /opt/poky/${TOOLCHAIN_VERSION}/environment-setup-aarch64-poky-linux 

#Step5: Apply patch and makefile 
if [ ! -f "0001-Makefile-remove-run-binary-file-after-compile-proces.patch" ] 
then
	echo "No such patch file"
	echo "Please check the copy file.patch step" 
else
	git reset --hard HEAD
	git checkout -b tmp f3e8f2e0941e42961aadcc52750b1b5577c157c9
	git am 0001-Makefile-remove-run-binary-file-after-compile-proces.patch
	make ITERATIONS=50 XCFLAGS="-DMULTITHREAD=2 -DUSE_PTHREAD -pthread"
fi

echo "FINISH. Check binary at $WORK/coremark/"
