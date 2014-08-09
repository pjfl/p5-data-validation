package Data::Validation::Constraints::Path;

use namespace::autoclean;

use Moo;
use Data::Validation::Constants;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception( 'ValidPath', {
   parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid pathname' } );

around '_validate' => sub {
   my ($orig, $self, $val) = @_; return $val =~ m{ [;&*{} ] }mx ? 0 : 1;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
