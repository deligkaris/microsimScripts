package microsimTrialset;

use diagnostics;
use strict;
use List::MoreUtils qw(uniq);
use Cwd;
use Cwd 'abs_path';
use File::Path qw(make_path);
use File::Basename;
# had to install these on OSC: https://www.osc.edu/resources/getting_started/howto/howto_install_your_own_perl_modules
# 1) module load cpanminus 
# 2) perl -I /apps/cpanminus/1.7044/perl5/lib/perl5 -Mlocal::lib
# 3) cpanm Array::Compare
# 4) cpanm Data::Types
# 5) cpanm Text::CSV_XS
use Array::Compare;
use Data::Types qw/:all/;
use Text::CSV_XS;

our (@ISA);
BEGIN {
	require Exporter;
	@ISA = qw(Exporter);
}
our @EXPORT = qw(getLogFile getFolderLogFile checkIfProbability checkIfInteger checkIfPositive checkIfDivisibleBy2 checkIfIntegerMultiple checkIfUnique checkIfSorted readInputFile getComputingParameters writeInputFile submitJob writeSubFile writeCancelJobFile);

sub checkIfProbability {

	my($arrayToBeCheckedRef) = @_;
        my(@arrayToBeChecked);

	@arrayToBeChecked = @$arrayToBeCheckedRef;

        for (@arrayToBeChecked) {
                if (  ($_ < 0) | ($_ > 1) ) {
                        return 0;       # if not within [0,1], return False
                }
        }
        return 1; # if all are within [0,1], return True	

}

sub checkIfInteger {

        my($arrayToBeCheckedRef) = @_;
	my(@arrayToBeChecked);

        @arrayToBeChecked = @$arrayToBeCheckedRef;

        for (@arrayToBeChecked) {
                if ( not(is_int(scalar $_)) ) {
                        return 0;       # if non-integer, return False
                }
        }
        return 1;       # if all integers, return True
}

sub checkIfPositive {

        my($arrayToBeCheckedRef) = @_;
	my(@arrayToBeChecked);

        @arrayToBeChecked = @$arrayToBeCheckedRef;
        for (@arrayToBeChecked) {
                if (  $_ < 0 ) {
                        return 0;       # if negative, return False
                }
        }
        return 1; # if none are negative, return True
}

sub checkIfDivisibleBy2 {

        my($arrayToBeCheckedRef) = @_;
	my(@arrayToBeChecked);

        @arrayToBeChecked = @$arrayToBeCheckedRef;

        for (@arrayToBeChecked) {
                if ( ($_ % 2) != 0 ) {
                        return 0;       # if not divisible by 2, return False
                }
        }
        return 1; # if all are divisible by 2, return True
}

sub checkIfIntegerMultiple {

        my($arrayToBeCheckedRef,$multipleOf) = @_;
	my(@arrayToBeChecked);

        @arrayToBeChecked = @$arrayToBeCheckedRef;

        for (@arrayToBeChecked) {
                if ( ($_ % $multipleOf) != 0 ) {
                        return 0;       # if not integer multiple of the smallest element, return False
                }
        }
        return 1; # if all are integer multiple of smallest element, return True
}

sub checkIfUnique {

        my($arrayToBeCheckedRef) = @_;
        my(@arrayToBeChecked,@arrayToBeCheckedUnique);
        my($arrayToBeCheckedUniqueSize,$arrayToBeCheckedSize);

        @arrayToBeChecked = @$arrayToBeCheckedRef;
        # find unique elements
        @arrayToBeCheckedUnique = uniq @arrayToBeChecked;

        # forcing the array to scalar context will give you the size of the array
        $arrayToBeCheckedUniqueSize = @arrayToBeCheckedUnique;
        $arrayToBeCheckedSize = @arrayToBeChecked;

        # return false if array elements are not unique 
        if( $arrayToBeCheckedUniqueSize != $arrayToBeCheckedSize ) {
  	      return 0; # return false if elements are not unique
        }
        else {
              return 1; # return true if elements are unique
        }
}

sub checkIfSorted {

        my($arrayToBeCheckedRef) = @_;
        my(@arrayToBeChecked,@arrayToBeCheckedSorted);
	my($comparator);

        @arrayToBeChecked = @$arrayToBeCheckedRef;

        #sort arrays
        @arrayToBeCheckedSorted = (sort { $a <=> $b } @arrayToBeChecked);
 
        $comparator = Array::Compare->new(WhiteSpace=>0);

        #exit if sample sizes and durations were not ordered in input file (~~ is the smart match operator that compares arrays)
        #if( $comparator->compare(\@sampleSizesPartsSorted, \@sampleSizesParts) ) { #sample sizes must be sorted
        if( not(@arrayToBeCheckedSorted ~~ @arrayToBeChecked) ) { #arrays must be sorted
	        return 0;  # return False, array is not sorted
        }
        else {
        	return 1;  # return True, array is sorted
        }
}

sub readInputFile {

	my($inputFile) = @_; # input: the input file name
	# local variables
	my($csv,$row,$fh);
	my(@sampleSizes,@durations,@dementia,@cv,$nTrialsPerRiskset,$nProcesses);

	# use a CSV parsing library to read the input CSV file
 	# better than reading the file manually
 	$csv = Text::CSV_XS->new ({ allow_whitespace => 1 });
 
 	#get data from the CSV input file, row by row
 	open $fh, "<", "$inputFile" or die "$inputFile: $!";
 	$row = $csv->getline($fh); # skip the header
 	$row = $csv->getline($fh); # read sample sizes
 	@sampleSizes = @$row;
 	$row = $csv->getline($fh); # read durations
 	@durations = @$row;
 	$row = $csv->getline($fh); # read dementia thresholds
 	@dementia = @$row;
 	$row = $csv->getline($fh); # read cv thresholds
 	@cv = @$row;
 	$row = $csv->getline($fh); # read number of trials
 	$nTrialsPerRiskset = $$row[0];
	$row = $csv->getline($fh); # read number of processes (optional)
	$nProcesses = $$row[0];	   # works even if $row is undef	

	# must return references to arrays (hence \@), perl cannot return arrays
	return \@sampleSizes,\@durations,\@dementia,\@cv,$nTrialsPerRiskset,$nProcesses; 
}

sub getComputingParameters {

	my ($nTrialsPerCalculation,$nCores,$nProcesses,$nNodes,$nTasksPerNode,$nSocketsPerNode,$nCoresPerSocket,$timePerCalculation);

	# these parameters are based on testing with Microsim performance on the OSC cluster
	$nTrialsPerCalculation = 50;
	$nCores = 24;
	$nProcesses = 10;
	$nNodes = 1;
	$nTasksPerNode = 24;
	$nSocketsPerNode = 1;
	$nCoresPerSocket = $nCores;
	$timePerCalculation = "12:00:00";

	return $nTrialsPerCalculation,$nCores,$nProcesses,$nNodes,$nTasksPerNode,$nSocketsPerNode,$nCoresPerSocket,$timePerCalculation;
}

sub getFolderLogFile {

	my($folder) = @_;
	my($logFile);

	$logFile = lc($folder)."-inputLog.csv";

	return $logFile;
}
	
sub getLogFile {

	my($inputFile) = @_;
	my($logFile,$inputFileName);

	#print($inputFile);
	#print(@inputFileParts);
	#@inputFileParts = split('.', $inputFile);
	($inputFileName,undef,undef) = fileparse($inputFile,'\..*'); 
	#$logFile = $inputFileParts[0]."Log.csv";
	$logFile = $inputFileName."Log.csv";

	return $logFile;
}

sub writeInputFile {

	my ($folder,$sampleSizesRef,$durationsRef,$dementia,$cv,$nTrialsPerCalculation,$nProcesses) = @_;
	my (@sampleSizes,@durations);
	my ($inputFile,$fh);

	# dereference array references to arrays
	@sampleSizes = @$sampleSizesRef;
	@durations = @$durationsRef;

	$inputFile = lc($folder)."-input.csv";
       	open($fh,'>',$inputFile);
       	print $fh "# sample sizes, durations, dementia thresholds, cv thresholds, trialset size, processes\n";
       	print $fh join(', ',@sampleSizes), "\n";
       	print $fh join(', ',@durations), "\n";
       	print $fh "$dementia\n$cv\n$nTrialsPerCalculation\n$nProcesses";
       	close $fh;

	return $inputFile;
}

sub submitJob {

	my($folderSubFile,$cancelJobsRef,$folder) = @_;
	my(@cancelJobs);
	my($subReturn);

	# dereference array reference to array
	@cancelJobs = @$cancelJobsRef;

	$subReturn = `./$folderSubFile`;	# backquotes `` submit command to shell and return result
	if( $subReturn =~ m/^Submitted batch job (\d+)/ ) {	# $1 refers to the first pattern that matched (\d+)
		push(@cancelJobs,"scancel $1\n");
	}
	else {
	        die("\nERROR: calculation on folder $folder was not submitted\n");      
	}
}

sub writeSubFile {

	my($folderSubFile,$folderInputFile,$nNodes,$nTasksPerNode,$timePerCalculation,$nSocketsPerNode,$nCoresPerSocket) = @_;
	my($fh);

        open($fh,'>',$folderSubFile);
        print $fh    "submicMp $folderInputFile ".
        			"--nodes=$nNodes ".
                                "--ntasks-per-node=$nTasksPerNode ".
                                "--time=$timePerCalculation  ".
                                "--constraint=48core ".
                                "--sockets-per-node=$nSocketsPerNode ".
                                "--cores-per-socket=$nCoresPerSocket ".
                                "--distribution=*:block:*";
        chmod 0740, $fh;	# make script executable
        close $fh;
}

sub writeCancelJobFile {

	my($cancelJobsRef) = @_;
	my(@cancelJobs);
	my($fh);

	# dereference array reference to array
	@cancelJobs = @$cancelJobsRef;

	open($fh,'>',"cancelJobs.sh");
	chmod 0740, $fh;	# make script executable
	print $fh @cancelJobs;
	close $fh;
}


