#! /usr/bin/perl -w
#################################################################################################################
#
# author: Christos Deligkaris
# date: November 2022
# function: divides a large microsim trial set calculation to smaller trial set calculations and submits them
#
#################################################################################################################
use diagnostics;
use strict;
use List::MoreUtils qw(uniq);
use Cwd;
use Cwd 'abs_path';
use File::Path qw(make_path);
# had to install these on OSC: https://www.osc.edu/resources/getting_started/howto/howto_install_your_own_perl_modules
# 1) module load cpanminus 
# 2) perl -I /apps/cpanminus/1.7044/perl5/lib/perl5 -Mlocal::lib
# 3) cpanm Array::Compare
# 4) cpanm Data::Types
# 5) cpanm Text::CSV_XS
use Array::Compare;
use Data::Types qw/:all/;
use Text::CSV_XS;

use lib '/users/PAS2164/deligkaris/SCRIPTS/'; # add directory to search path for modules
use microsimTrialset qw(readInputFile getComputingParameters writeInputFile submitJob writeSubFile writeCancelJobFile);

#definitions
my (@sampleSizes,@durations); 	# trial set parameters
my (@dementia,@cv);  		# risk factors
my ($sampleSizesRef,$durationsRef,$dementiaRef,$cvRef); # references to arrays
my ($nTrialsPerRiskset,$nRisksets,$nCalculations); 	# help divide calculation in smaller scale calculations
my ($nTrialsPerCalculation,$nCalculationsPerRiskset,$nCores,$nProcesses);	# parameters of small scale calculations
my ($nNodes,$nTasksPerNode,$nSocketsPerNode,$nCoresPerSocket,$timePerCalculation); # parameters of small scale calculations
my ($iDem,$iCv,$iCalculationPerRiskset); 	# iterators
my (@cancelJobs); 	# store commands to cancel all submitted jobs (just in case)
my (@folders,$folder,$folderInputFile,$folderSubFile,@folderDementia,@folderCv); 	# folder and folder arrays
my ($inputFile,$fhInput,$fhSub,$subReturn,$fhCancelJobs);	# file and filehandles
my ($csv,$row);

# check that script gets input file
if(@ARGV < 1 || @ARGV > 1) { #need to get exactly one argument
	print "\n ERROR in $0: Must provide exactly one argument \n";
	exit 1;
}

# readInputFile will return nProcesses which we will ignore here because we do not need it, and may be undef
($sampleSizesRef,$durationsRef,$dementiaRef,$cvRef,$nTrialsPerRiskset,undef) = readInputFile($ARGV[0]);

# derefence arrays and assign to array variables
@sampleSizes = @$sampleSizesRef;
@durations = @$durationsRef;
@dementia = @$dementiaRef;
@cv = @$cvRef;

($nTrialsPerCalculation,$nCores,$nProcesses,$nNodes,$nTasksPerNode,$nSocketsPerNode,$nCoresPerSocket,$timePerCalculation) = getComputingParameters();

# calculate some important quantities
$nRisksets = scalar(@dementia) * scalar(@cv);
$nCalculationsPerRiskset = $nTrialsPerRiskset / $nTrialsPerCalculation;
$nCalculations = $nRisksets * $nCalculationsPerRiskset;

@cancelJobs = ();	# array that will hold shell script commands that allow to cancel all submitted calculations
$folderSubFile = "subCommand.sh";	# file name of shell script that submits job

foreach $iDem (0..scalar(@dementia)-1) {
        foreach $iCv (0..scalar(@cv)-1) {
                foreach $iCalculationPerRiskset (0..$nCalculationsPerRiskset-1) {

			$folder = "DEMENTIA-".$iDem."-CV-".$iCv."-SET-".$iCalculationPerRiskset;
			mkdir($folder);
        		chdir($folder);
			
			$folderInputFile = writeInputFile($folder,\@sampleSizes,\@durations,$dementia[$iDem],$cv[$iCv],$nTrialsPerCalculation,$nProcesses);

			writeSubFile($folderSubFile,$folderInputFile,$nNodes,$nTasksPerNode,$timePerCalculation,$nSocketsPerNode,$nCoresPerSocket);

			submitJob($folderSubFile,$cancelJobsRef,$folder);			

		        chdir("../");
		}
	}
}			

writeCancelJobFile(\@cancelJobs);


