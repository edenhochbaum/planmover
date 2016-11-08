use strict;
use warnings;

use lib '/home/eden/planmover/perllib';

use constant _POLLING_HOLDOFF_MICROSECONDS => 300_000; # .3 seconds

use Getopt::Long (); # TODO
use athenahealthapi;
use Data::Dumper;
use Time::HiRes ();
use PlanMover::Slack ();

my $version = 'preview1';
my $key = 'c7rn2wrjm39a4c6uhk8kna23';
my $secret = $ENV{MDP_SECRET};

# this is our private practice
#my $practiceid = '1959251';

# this is public sandbox practice
my $practiceid = '195900';

my $driver = athenahealthapi->new($version, $key, $secret, $practiceid);

# {
#  path => the path (URI) of the resource as a string,
#  params => the request parameters as a hashref (optional),
#  headers => the request headers as a hashref (optional),
# }
#my $s = $driver->POST({
#	path => '/appointments/changed/subscription',
#	params => {
#		eventname => 'CheckIn',
#	},
#});

# polling loop
while (1) {
	Time::HiRes::usleep(_POLLING_HOLDOFF_MICROSECONDS());

	my $g = $driver->GET({
		path => '/appointments/changed', #/subscription',
	});
	if ($g->{totalcount}) {
		print Dumper($g);
		my $updatedappointment = $g->{appointments}[0];

		my $args = {};

		my @fields = qw(lastmodifiedby patientid appointmentid);
		@{$args}{@fields} = @{$updatedappointment}{@fields};
		$args->{patientname} = 'Eden HOCHBAUM';
		
		PlanMover::Slack::PostFirstSlackMessage($args);
	}
}

#my $updatedappointments = $g->{appointments};
#foreach my $updatedappointment (@{$updatedappointments // []}) {

#	my $updatedappointmentid = $updatedappointment->{appointmentid};
#	print sprintf('got updatedappointmentid: [%i]', $updatedappointmentid);

#	my $theupdatedappointment = $driver->GET({
#		path => '/appointments/' . $updatedappointmentid,
#		params => {
#			showinsurance => 'true',
#			showcopay => 'true',
#		},
#	});

#	my $insurances = $theupdatedappointment->{insurances};
#	unless (@{$insurances // []}) {
#	}
#	print Dumper($theupdatedappointment);
#}

