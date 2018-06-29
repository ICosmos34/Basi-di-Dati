#!/bin/bash
#ESercizitazioni - PRogetto
exec mysql -h basidati1617.studenti.math.unipd.it -P 3306 -u grossett -D grossett-ES --local-infile=1 --password=$( cat $HOME/bd1617.password )
