#! /usr/bin/perl -w
#################################################################################################################
#
# author: Christos Deligkaris
# date: November 2022
# function: extracts the results of a large microsim trial set calculation from the smaller trial set calculations 
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

#use lib '/users/PAS2164/deligkaris/MICROSIM/SCRIPTS/'; # add directory to search path for modules
use lib '/fs/ess/PAS2139/christos/MICROSIM/SCRIPTS/';
use microsimTrialset qw(getLogFile getFolderLogFile readInputFile getComputingParameters writeInputFile submitJob writeSubFile writeCancelJobFile);

#definitions
my (@sampleSizes,@durations); 	# trial set parameters
my (@dementia,@cv);  		# risk factors
my ($sampleSizesRef,$durationsRef,$dementiaRef,$cvRef); # references to arrays
my ($nTrialsPerRiskset,$nConcurrentTrials,$nRisksets,$nCalculations); 	# help divide calculation in smaller scale calculations
my ($nTrialsPerCalculation,$nCalculationsPerRiskset,$nCores,$nProcesses);	# parameters of small scale calculations
my ($nNodes,$nTasksPerNode,$nSocketsPerNode,$nCoresPerSocket,$timePerCalculation); # parameters of small scale calculations
my ($iRiskset); 	# iterators
my (@cancelJobs); 	# store commands to cancel all submitted jobs (just in case)
my (@folders,$folder,$folderInputFile,$folderSubFile,@folderDementia,@folderCv); 	# folder and folder arrays
my ($microsimScript,$inputFile,$fhInput,$fhSub,$subReturn,$fhCancelJobs);	# file and filehandles
my ($csv,$row);
my ($header,$logFile,$fhLog,$folderLogFile,$fhFolder,$folderLogFileContents);

# check that script gets input file
if(@ARGV < 1 || @ARGV > 1) { #need to get exactly one argument
	print "\n ERROR in $0: Must provide exactly one argument \n";
	exit 1;
}

#all trialset-related parameters
($sampleSizesRef,$durationsRef,$dementiaRef,$cvRef,$nTrialsPerRiskset,$nConcurrentTrials,
#all SLURM-related parameters
$nNodes,$nCores,$nProcesses,$nTasksPerNode,$nSocketsPerNode,$nCoresPerSocket,$timePerCalculation) = readInputFile($ARGV[0]);
# get the name of the python script
$microsimScript = $ARGV[1];
# derefence arrays and assign to array variables
@sampleSizes = @$sampleSizesRef;
@durations = @$durationsRef;
@dementia = @$dementiaRef;
@cv = @$cvRef;
# calculate some important quantities
$nRisksets = scalar(@dementia);

$header = 1;

$logFile = getLogFile($ARGV[0]);
open($fhLog,'>',$logFile);

foreach $iRiskset (0..$nRisksets-1) {
        $folder = "RISKSET-".$iRiskset;
        chdir($folder);

        $folderLogFile = getFolderLogFile($folder);

        if( open($fhFolder,'<',$folderLogFile) ) {
                if ($header == 1) {
                        $folderLogFileContents = do { local $/; <$fhFolder> };
                        $header=0;
                }
                else {
                        <$fhFolder>;    # skip header
                        $folderLogFileContents = do { local $/; <$fhFolder> };
                }
                close $fhFolder;
                print $fhLog "$folderLogFileContents";
                chdir("../");
        }
        else {
                close $fhFolder;
                print("ERROR in $0: cannot open $folderLogFile in $folder\n");
                chdir("../");
        }
}

close $fhLog;

