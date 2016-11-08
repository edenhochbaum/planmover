package PlanMover::Slack;

use strict;
use warnings;

use IPC::Run3 ();

sub PostFirstSlackMessage {
	my ($args) = @_;
	# what do we want here?
	
	# just hard-code this for the demo, even though easy enough to generate dynamically
	my $practiceuser = 'ehochbaum1 (Eden Hochbaum)';
	my $patientname = 'Daniel JONES';

	my $message = sprintf(
		"%s, TOS payment wasn't collected at checkin for %s's appointment.  Please %s",
		$practiceuser,
		$patientname,
		sprintf(
			'<%s|%s>', 
			sprintf('https://www.edentest.com/htdocs/apptcheckin/eventid/%i', $args->{appointmentid}),
			'take survey',
		),
	);
	
	PostSlackMessage($message, 'foo');
	return;
}

sub PostSecondSlackMessage {
	my ($args) = @_;
	# what do we want here?
	
	# just hard-code this for the demo, even though easy enough to generate dynamically
	my $practiceuser = 'ehochbaum1 (Eden Hochbaum)';
	my $patientname = 'Daniel JONES';

	my $message = sprintf(
		'%s just submitted feedback for missed TOS payment from %s at checkin.  %s',
		$practiceuser,
		$patientname,
		sprintf(
			'<%s|%s>',
			'https://www.edentest.com',
			'View submission.',
		),
	);
	
	PostSlackMessage($message, 'bar');
	return;
}

# note, link is like "<http://www.cnn.com|please take survery>"
sub PostSlackMessage {
	my ($message) = @_;

	# TODO: don't block on this
	IPC::Run3::run3([
		'/usr/bin/perl',
		'/home/eden/planmover/scripts/lambda.pl',
		(
			'--message',
			$message,
		),
	]);

	return;
}

1;
