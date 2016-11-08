package PlanMover::MungeHTML;

use strict;
use warnings;

# I can't get the damn handlebars cpan module installed, let's just fake it for now
sub Munge {
	my ($text, $args) = @_;
	$text =~ s/EVENTID/$args->{EVENTID}/g;
	return $text;
}

1;
