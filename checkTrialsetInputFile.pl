#! /usr/bin/perl -w 
#################################################################################################################
##
## author: Christos Deligkaris
## date: November 2022
## function: divides a large microsim trial set calculation to smaller trial set calculations and submits them
##
##################################################################################################################
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

use lib '/users/PAS2164/deligkaris/MICROSIM/SCRIPTS/'; # add directory to search path for modules
use microsimTrialset qw(checkIfProbability checkIfInteger checkIfPositive checkIfDivisibleBy2 checkIfIntegerMultiple checkIfSorted checkIfUnique readInputFile getComputingParameters writeInputFile submitJob writeSubFile writeCancelJobFile);

#definitions
my (@sampleSizes,@sampleSizesSorted,@sampleSizesUnique,$sampleSizesSize,$sampleSizesUniqueSize);
my (@durations,@durationsSorted,@durationsUnique,$durationsSize,$durationsUniqueSize);
my (@dementia,@cv);
my ($sampleSizesRef,$durationsRef,$dementiaRef,$cvRef,$nTrialsPerRiskset,$nProcesses);
my ($csv,$row,$inputFile,$comparator);
my ($nTrialsPerCalculation,$nCores,$nProcessesDefault,$nNodes,$nTasksPerNode,$nSocketsPerNode,$nCoresPerSocket,$timePerCalculation);

if(@ARGV < 1 || @ARGV > 1) { #need to get exactly one argument
	print "\n ERROR in $0: Must provide exactly one argument \n";
	exit 1;
}

($sampleSizesRef,$durationsRef,$dementiaRef,$cvRef,$nTrialsPerRiskset,$nProcesses) = readInputFile($ARGV[0]);
# derefence arrays and assign to array variables
@sampleSizes = @$sampleSizesRef;
@durations = @$durationsRef;
@dementia = @$dementiaRef;
@cv = @$cvRef;

($nTrialsPerCalculation,$nCores,$nProcessesDefault,$nNodes,$nTasksPerNode,$nSocketsPerNode,$nCoresPerSocket,$timePerCalculation) = getComputingParameters();

# check if sample size elements meet conditions
if( not(checkIfSorted(\@sampleSizes)) | not(checkIfUnique(\@sampleSizes)) | not(checkIfInteger(\@sampleSizes)) | not(checkIfPositive(\@sampleSizes)) | not(checkIfDivisibleBy2(\@sampleSizes)) | not(checkIfIntegerMultiple(\@sampleSizes,$sampleSizes[0])) ) {
	print "\nERROR in $0: sample sizes must be sorted, unique, integers, positive, divisible by 2, integer multiples of smallest element\n\n";
	exit 1;
}

# check if durations meet conditions
if( not(checkIfSorted(\@durations)) | not(checkIfUnique(\@durations)) | not(checkIfPositive(\@durations)) | not(checkIfInteger(\@durations))  ) {
        print "\nERROR in $0: durations must be sorted, unique, positive and integers\n\n";
        exit 1;
}

# dementia and cv elements must be probabilities
if( not(checkIfProbability(\@dementia))  ) {
        print "\nERROR in $0: dementia not valid probabilities\n\n";
        exit 1;
}
if( not(checkIfProbability(\@cv))  ) {
        print "\nERROR in $0: cv not valid probabilities\n\n";
        exit 1;
}

# nTrialsPerRiskset must be integer, positive, integer multiple of nTrialsPerCalculation
if ( not(is_int($nTrialsPerRiskset)) | ($nTrialsPerRiskset<0) | ($nTrialsPerRiskset % $nTrialsPerCalculation != 0) ) {
	print "\n ERROR in $0: nTrialsPerRiskset must be integers, positive and integer multiple of nTrialsPerCalculation ($nTrialsPerCalculation)\n\n";
	exit 1;
}

# nProcesses must be the optimal value as defined in getComputingParameters
if (defined $nProcesses) {
	if ( $nProcesses != $nProcessesDefault ) {
		print "\n ERROR in $0: nProcesses must be the optimal value of $nProcessesDefault as defined in getComputingParameters\n\n";
		exit 1;
	}
}

# if did not fail until now, assume all is well
exit 0;
