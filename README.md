# Scripts for MicroSim

- submic: bash shell script that checks the microsim input file and submits the calculation to the resource manager (SLURM)
- checkTrialsetInputFile.pl: a Perl script used by submic to check the validity of the microsim input file prior to submitting the calculation to SLURM
- microsimTrialset.pm: a Perl module with functions in microsim perl scripts
- submicSet.pl: a Perl script that breaks a large scale microsim simulation to many smaller scale microsim simulations and submits them to SLURM
- getTrialsetLogFile.pl: a Perl script that extracts the results from all small scale calculations submicSet.pl created and submitted
