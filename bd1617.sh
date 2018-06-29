#!/bin/bash
#ESercizitazioni - PRogetto
exec mysql -h localhost                            -P3306 -u grossett -D grossett-ES --local-infile=1 --password=$( cat $HOME/bd1617.password )
