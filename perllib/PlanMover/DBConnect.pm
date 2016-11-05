package PlanMover::DBConnect;

use strict;
use warnings;

use DBI;

BEGIN {
	$ENV{DBNAME}		||= 'edentestalpha';
	$ENV{DBHOST}		||= 'edentestalpha.cdcnwhesdbho.us-west-2.rds.amazonaws.com';
	$ENV{DBUSERNAME}	||= 'edentestalpha';
	$ENV{DBPASSWORD}	||= 'No7h84JNH1XY';
}

sub GetDBH {
	my $connstring;
	if (exists $ENV{DBHOST}) {
            $connstring = "dbi:Pg:dbname=$ENV{DBNAME};host=$ENV{DBHOST}";
        }

	return DBI->connect($connstring, $ENV{DBUSERNAME}, $ENV{DBPASSWORD}, {
		AutoCommit => 1,
		RaiseError => 1,
		PrintError => 1,
	});
}

1;
