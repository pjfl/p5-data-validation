package Data::Validation::Constraints::Email;

use namespace::sweep;

use Moo;
use Data::Validation::Constants;
use Email::Valid;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception( 'ValidEmail', {
   parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid email address' } );

around '_validate' => sub {
   return Email::Valid->address( $_[ 2 ] ) ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
