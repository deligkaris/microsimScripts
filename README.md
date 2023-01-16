# Scripts for MicroSim

Note: In order to run any of these, they will need to be in your path.

- submic: shell script that submits a Microsim python script as a job to the Ohio Supercomputer Center's (OSC) resource manager (SLURM).

  Usage: submic yourPythonFile.py yourSlurmArguments(optional). The script will set by default the most important SLURM parameters,
  which you can override on the command line. Before using this script, you will need to modify the microsimDir variable and set it
  to the location of your Microsim directory.
  
- submicSet.pl: Perl script that submits several microsim trials to OSC's resource manager (SLURM)
- checkTrialsetInputFile.pl: a Perl script used by submic to check the validity of the microsim input file prior to submitting the calculation to SLURM
- microsimTrialset.pm: a Perl module with some useful microsim perl functions
- getTrialsetLogFile.pl: a Perl script that extracts the results from all small scale calculations submicSet.pl created and submitted
