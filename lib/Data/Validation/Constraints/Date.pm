package Data::Validation::Constraints::Date;

use namespace::autoclean;

use Class::Usul::Time           qw( str2time );
use Data::Validation::Constants qw( EXCEPTION_CLASS FALSE TRUE );
use Moo;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception( 'ValidDate', {
   parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] is not a valid date' } );

sub validate {
   return defined str2time( $_[ 1 ] ) ? TRUE : FALSE;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
