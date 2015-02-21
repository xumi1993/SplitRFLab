#!/bin/bash

# Script to test the writing of sac data and compare what goes in to
# what comes out

# you must have saclst installed for this to work

ifile1=TA.O23A.little.BHZ
ofile1=TA.O23A.little.BHZ.v2

# Run with default arguments
matlab -nosplash -nojvm -r "testWrite; exit"

saclst all f $ifile1 > $ifile1.hdr
saclst all f $ofile1 > $ofile1.hdr

paste $ifile1.hdr $ofile1.hdr

