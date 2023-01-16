# Scripts for MicroSim

- submic: shell script that submits a Microsim python script as a job to the Ohio Supercomputer Center's (OSC) resource manager 
- submicSet.pl: Perl script that submits several microsim trials to OSC's resource manager (SLURM)
- checkTrialsetInputFile.pl: a Perl script used by submic to check the validity of the microsim input file prior to submitting the calculation to SLURM
- microsimTrialset.pm: a Perl module with some useful microsim perl functions
- getTrialsetLogFile.pl: a Perl script that extracts the results from all small scale calculations submicSet.pl created and submitted
