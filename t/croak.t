use Test::More tests => 2;

use_ok 'Astro::FITS::CFITSIO::CheckStatus;';

use Astro::FITS::CFITSIO;

# try the default croak
tie my $status, 'Astro::FITS::CFITSIO::CheckStatus';
eval {
Astro::FITS::CFITSIO::open_file( 'file_does_not_exist.fits', 
	   Astro::FITS::CFITSIO::READONLY(),$status );
};
ok ($@ && $@ =~ "CFITSIO error: could not open the named file");
