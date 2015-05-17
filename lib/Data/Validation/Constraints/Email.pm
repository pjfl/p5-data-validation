package Data::Validation::Constraints::Email;

use namespace::autoclean;

use Data::Validation::Constants;
use Email::Valid;
use Moo;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception( 'ValidEmail', {
   parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid email address' } );

sub validate {
   return Email::Valid->address( $_[ 1 ] ) ? 1 : 0;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
