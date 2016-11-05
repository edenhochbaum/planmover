#!/usr/bin/perl
use strict;
use warnings;

use lib '/home/eden/planmover/perllib';

#use HTTP::Headers;
use Plack::Request;
use Plack::Response;
use Data::Dumper;
use Carp::Assert ();
use Router::Simple;
use File::Slurp;

use PlanMover::DBConnect;
use PlanMover::MungeHTML;

my $router = Router::Simple->new();
$router->connect('/api/*', {
	controller	=> 'Api',
	action		=> 'process_api',
});
$router->connect('/htdocs/:page/eventid/:eventid', {
	action		=> 'render_page',
});

$router->connect('/htdocs/:page/submit', {
	action		=> 'page_submit',
});

my $routingmiddleware = sub {
	my ($env) = shift; # PSGI env

	my $plackresponse;

	if (my $p = $router->match($env)) {
		Carp::Assert::assert(
			($p->{action} eq 'render_page' || $p->{action} eq 'page_submit'),
			sprintf('failed to recognize page action [%s]', $p->{action}),
		);
		Carp::Assert::assert(
			($p->{page} eq 'apptcreation'),
			sprintf('failed to recognize page [%s]', $p->{page}),
		);
			
		my $action = $p->{action};
		my $page = $p->{page};

		if ($action eq 'render_page') {
			my $eventid = $p->{eventid};

			Carp::Assert::assert($eventid =~ /\d+/, sprintf('expected integer eventid [%s]', $eventid));

			my $filetext = File::Slurp::read_file('/home/eden/planmover/htdocs/templates/html/apptcreation.html');

			my $newfiletext = PlanMover::MungeHTML::Munge($filetext, {EVENTID=>'boo'});
			
			$plackresponse = Plack::Response->new(200);
			$plackresponse->content_type('text/html');
			
			$plackresponse->body($newfiletext);
		}
		else { # submit
			my $plackrequest = Plack::Request->new($env);
			my $bodyparameters = $plackrequest->body_parameters;

			my $dbh = PlanMover::DBConnect::GetDBH();
			$dbh->ping or die 'could not ping dbh here';

			my $sth = $dbh->prepare('select * from planmover.survey where 1=1') or die 'failed prepare: ' . $dbh->errstr;
			$sth->execute() or die 'could not execute statemenet: ' . $sth->errstr;

			while(my @data = $sth->fetchrow_array()) {
				$body .= Dumper(\@data);
			}

			$plackresponse = Plack::Response->new(200);
			$plackresponse->content_type('text/html');
			$plackresponse->body($body);
		}

		return $plackresponse->finalize();
	}
	else {
		print STDERR 'here with no match';
		$plackresponse = Plack::Response->new(404);
		$plackresponse->content_type('text/html');
		$plackresponse->body('not found');

		return $plackresponse->finalize();
	}


	return $plackresponse->finalize();
};

my $authorizationmiddleware = sub {
	my ($env) = shift;

	# TODO: if unauthorized, block; else
	return $routingmiddleware->($env);
};

my $authenticationmiddleware = sub {
	my ($env) = shift;

	# TODO: if unauthenticated, block; else
	return $authorizationmiddleware->($env);
};

# re-route to secure https site
my $httpsenforcementmiddleware = sub {
	my ($env) = shift; # PSGI env

	unless ((Plack::Request->new($env)->headers()->header('X-Forwarded-Proto') // '') eq 'https') {
		# TODO: perform the appropriate redirect
		my $plackresponse = Plack::Response->new(200);
		$plackresponse->content_type('text/html');
		$plackresponse->body("sorry, I don't accept requests w/o tls for now");

		return $plackresponse->finalize();
	}

	return $authenticationmiddleware->($env);
};
