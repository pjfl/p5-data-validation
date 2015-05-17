package Data::Validation::Constraints::URL;

use namespace::autoclean;

use Data::Validation::Constants;
use HTTP::Tiny;
use Moo;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception( 'ValidURL', {
   parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid URL' } );

sub validate {
   my ($self, $val) = @_;

   $val !~ m{ \A http: }mx and $val = "http://localhost${val}";

   my $res = HTTP::Tiny->new->get( $val );

   return $res->{success} ? 1 : 0;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
