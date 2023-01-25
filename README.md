# Scripts for MicroSim

Note: In order to run any of these, they will need to be in your path.

- submic: shell script that submits a Microsim python script as a job to the Ohio Supercomputer Center's (OSC) resource manager (SLURM).

  Usage: submic yourPythonFile.py yourSlurmArguments(optional). 
  
  The script will set by default the most important SLURM parameters, which you can override on the command line, if you want. 
  Before using this script for the first time, you will need to modify the microsimDir variable and set it
  to the location of your MicroSim directory, which is specific to your machine. This script can be used with 
  little to none modifications in any computing cluster that utilizes SLURM as the resource manager (not just OSC) and 
  likely with few modifications in cases the resource manager is different.
  
- submicSet.pl: Perl script that submits several microsim trials to OSC's resource manager (SLURM)

  Usage: submicSet.pl yourSetInputFile.csv yourPythonScript.py. 

  The CSV input file includes parameters like risk factors, trial population sizes, durations, number of nodes, number of cores etc.
  The Python input file is the python script you would like to use in order to run a single microsim trial. Sample input files
  are included in this repository. Requires the scripts submic, microsimTrialset.pm and checkTrialsetInputFile.pl.

- checkTrialsetInputFile.pl: a Perl script used to check the validity of the submicSet CSV input file prior to submitting the 
  calculations to the resource manager 

- microsimTrialset.pm: Perl module with some useful functions

- getTrialsetLogFile.pl: a Perl script that extracts the results from all calculations submicSet.pl created and submitted
