package Data::Validation::Constraints::Email;

use namespace::autoclean;

use Data::Validation::Constants qw( EXCEPTION_CLASS FALSE TRUE );
use Email::Valid;
use Moo;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception('ValidEmail', {
   error   => 'Parameter [_1] is not a valid email address',
   parents => ['InvalidParameter'],
});

sub validate {
   my ($self, $x) = @_;

   return Email::Valid->address($x) ? TRUE : FALSE;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
