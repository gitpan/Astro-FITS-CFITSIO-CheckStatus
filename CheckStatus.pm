package Astro::FITS::CFITSIO::CheckStatus;

use 5.006;
use strict;
use warnings;

use Carp;

require Astro::FITS::CFITSIO;

our $VERSION = '0.02';


# Preloaded methods go here.

# tie scalar to hash so we can keep track of the croak routine to be used.
sub TIESCALAR
{
  my ( $class, $croak ) = @_;
  $croak ||= \&Carp::croak;

  if ( UNIVERSAL::isa( $croak, 'Log::Log4perl::Logger' ) )
  {
    my $logger = $croak;
    $croak = 
      sub { local $Log::Log4perl::caller_depth = 2;
	    $logger->fatal( @_ ) && croak (@_) };
  }

  bless { value => 0, croak => $croak }, $class;
}

sub FETCH
{
  $_[0]->{value};
}

sub STORE
{

  if ( $_[0]->{value} = $_[1] )
  {
    Astro::FITS::CFITSIO::fits_get_errstatus($_[0]->{value} , my $txt);
    $_[0]->{croak}->("CFITSIO error: $txt" );
  }
}

1;
__END__

=head1 NAME

Astro::FITS::CFITSIO::CheckStatus - automatically catch CFITSIO status errors

=head1 SYNOPSIS

  use Astro::FITS::CFITSIO::CheckStatus;

  # call Carp::croak upon error
  tie my $status, 'Astro::FITS::CFITSIO::CheckStatus';
  $fptr = Astro::FITS::CFITSIO::create_file( $file, $status );

  # call user specified function upon error:
  tie my $status, 'Astro::FITS::CFITSIO::CheckStatus', $mycroak;
  $fptr = Astro::FITS::CFITSIO::create_file( $file, $status );

  # call Log::Log4perl->logcroak;
  $logger = Log::Log4perl::get_logger();
  tie my $status, 'Astro::FITS::CFITSIO::CheckStatus', $logger;
  $fptr = Astro::FITS::CFITSIO::create_file( $file, $status );

=head1 DESCRIPTION

The B<CFITSIO> library uses the concept of a status variable passed to
each B<CFITSIO> function call to return an error status.  At present,
the B<Astro::FITS::CFITSIO> Perl interface mirrors the B<CFITSIO>
interfaces directly, and does not do anything special to handle error
returns (e.g., by throwing an exception).  It should be noted that
B<CFITSIO> routines will not perform their requested action if a
non-zero status value is passed in, so as long as the same status
variable is used throughout, B<CFITSIO> routines won't do extra work
after an error. However, this can lead to the situation where one does
not know at which step the error occurred.

In order to immediately catch an error, the status error must be
checked after each call to a B<CFITSIO> routine.  Littering one's code
with status variable checks is ugly.

This module resolves the impasse by tieing the status variable to a
class which will check the value every time it is set, and throw an
exception (via B<Carp::croak>) containing the B<CFITISO> error message
if the value is non-zero.  The caller may provide an alternate means
of throwing the exception, either by passing in a subroutine
reference,

  tie my $status, 'Astro::FITS::CFITSIO::CheckStatus', 
           sub { die "An awful thing happened: @_" };
  $fptr = Astro::FITS::CFITSIO::create_file( $file, $status );

or a reference to a B<Log::Log4perl::Logger> object.

  $logger = Log::Log4perl::get_logger();
  tie my $status, 'Astro::FITS::CFITSIO::CheckStatus', $logger;
  $fptr = Astro::FITS::CFITSIO::create_file( $file, $status );

In the latter case, it will be equivalent to calling C<$logger-E<gt>logcroak>.


=head2 EXPORT

None by default.


=head1 AUTHOR

Diab Jerius, E<lt>djerius@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by The Smithsonian Astrophysical Observatory.

This software is released under the GNU General Public License.
You may find a copy at L<http://www.fsf.org/copyleft/gpl.html>.

=head1 SEE ALSO

L<Astro::FITS::CFITSIO>, L<perl>.

=cut
