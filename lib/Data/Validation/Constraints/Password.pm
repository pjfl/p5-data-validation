package Data::Validation::Constraints::Password;

use namespace::autoclean;

use Moo;
use Data::Validation::Constants;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception( 'ValidPassword', {
   parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid password' } );

around '_validate' => sub {
   my ($orig, $self, $val) = @_; my $min_length = $self->min_length || 6;

   length $val < $min_length and return 0;
   $val =~ tr{A-Z}{a-z}; $val =~ tr{a-z}{}d;
   return length $val > 0 ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
