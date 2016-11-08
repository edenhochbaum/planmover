use strict;
use warnings;

use lib '/home/eden/planmover/perllib';

use Getopt::Long (); # TODO
use IPC::Run3 ();
use JSON;

Getopt::Long::GetOptions(
	'message=s'	=> \my $message,
	'link=s'	=> \my $link,
	'username=s'	=> \my $username,
);


die 'no message' unless $message;
#die 'no link' unless $link;
#die 'no username' unless $username;

my @cmd = (
	'sudo',
	'/usr/bin/aws',
	'lambda',
	'invoke',
	(
		'--invocation-type',
		'RequestResponse',
	),
	(
		'--region',
		'us-west-2',
	),
	(
		'--function-name',
		'foo',
	),
	(
		'--payload',
		JSON::encode_json({
			message		=> $message,
#			link		=> $link,
#			username	=> $username,
		}),
	),
	(
		'--profile',
		'ehochbaum',
	),
	'/home/eden/planmover/logs.txt',
);

IPC::Run3::run3(\@cmd);

