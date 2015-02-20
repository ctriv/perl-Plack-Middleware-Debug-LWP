package Plack::Middleware::Debug::LWP;

use strict;
use warnings;

use LWPx::Profile;
use parent qw(Plack::Middleware::Debug::Base);

=head1 NAME

Plack::Middleware::Debug::LWP - LWP Profiling Panel

=head1 SYNOPSIS

	enable 'Debug::LWP';

=head1 DESCRIPTION

This module provides a panel for the L<Plack::Middleware::Debug> that gives
profiling information for L<LWP::UserAgent> requests.

=cut


 
sub run {
	my($self, $env, $panel) = @_;
	
	LWPx::Profile::start_profiling();
	
	return sub {
		my $res = shift;
		
		my $profile = LWPx::Profile::stop_profiling();
		
		my @lines;
		my ($time, $requests);
		while (my ($req, $stats) = each %$profile) {
			my ($short_req) = $req =~ m/^(.*?)\n/s;
			my $summary = sprintf("%.5f/%d (%.5f avg)", $stats->{total_duration}, $stats->{count}, $stats->{total_duration} / $stats->{count});
			push(@lines, $req, $summary);
			$requests += $stats->{count};
			$time     += $stats->{total_duration};
		}
		
		my $summary = sprintf("%d requests / %.2f seconds", $requests, $time);
		
		$panel->nav_title("LWP Requests");
		$panel->title("LWP Requests ($summary)");
		$panel->nav_subtitle($summary);

		$panel->content(
			$self->render_list_pairs(\@lines)
		);
	};
}



=head1 TODO

=over 2

=item *

The docs are pretty middling at the moment.

=back

=head1 AUTHORS

    Chris Reinhardt
    crein@cpan.org

    Mark Ng
    cpan@markng.co.uk   
    
=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

L<Plack::Middleware::Debug>, L<LWP::UserAgent>, L<LWPx::Profile>, perl(1)

=cut

1;
__END__
