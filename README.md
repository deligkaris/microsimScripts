# Scripts for MicroSim

- submic: shell script that submits a Microsim python script as a job to the Ohio Supercomputer Center's (OSC) resource manager 
- checkTrialsetInputFile.pl: a Perl script used by submic to check the validity of the microsim input file prior to submitting the calculation to SLURM
- microsimTrialset.pm: a Perl module with functions in microsim perl scripts
- submicSet.pl: a Perl script that breaks a large scale microsim simulation to many smaller scale microsim simulations and submits them to SLURM
- getTrialsetLogFile.pl: a Perl script that extracts the results from all small scale calculations submicSet.pl created and submitted
