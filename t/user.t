use Test::More tests => 2;

use_ok 'Astro::FITS::CFITSIO::CheckStatus;';

use Astro::FITS::CFITSIO;

# try a user defined croak like thing.
tie my $status, 'Astro::FITS::CFITSIO::CheckStatus', 
  sub { die "An awful thing happened: @_" };

eval {
Astro::FITS::CFITSIO::open_file( 'file_does_not_exist.fits', 
	   Astro::FITS::CFITSIO::READONLY(),$status );
};
ok ($@ && $@ =~ "awful thing");
