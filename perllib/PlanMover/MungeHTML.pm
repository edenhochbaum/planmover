package PlanMover::MungeHTML;

use strict;
use warnings;

sub Munge {
	my ($text, $args) = @_;
	$text =~ s/EVENTID/$args->{EVENTID}/g;
	return $text;
}

1;
