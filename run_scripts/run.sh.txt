#!/bin/bash

vcs -licqueue -lca -timescale=1ns/1ns+vcs+flush+all+warn=all -sverilog+incdir+$UVM_HOME/src $UVM_HOME/src/uvm.sv $UVM_HOME/src/dpi/uvm_dpi.cc -CFLAGS -DVCS -f filelist.f  && ./simv +vcs+lic+wait '+UVM_TESTNAME=bringup_test'  


