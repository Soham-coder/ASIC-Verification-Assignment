#!/bin/csh -f

cd /home/runner

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/apps/vcsmx/vcs/S-2021.09/linux/bin/vcselab $* \
    -o \
    simv \
    -nobanner \
    +vcs+lic+wait \

cd -

