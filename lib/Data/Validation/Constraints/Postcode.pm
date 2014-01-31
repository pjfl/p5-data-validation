package Data::Validation::Constraints::Postcode;

use namespace::sweep;

use Moo;
use Data::Validation::Constants;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception( 'ValidPostcode', {
   parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid postcode' } );

around '_validate' => sub {
   my ($orig, $self, $val) = @_;

   my @patterns = ( 'AN NAA',  'ANN NAA',  'AAN NAA', 'AANN NAA',
                    'ANA NAA', 'AANA NAA', 'AAA NAA', );

   for (@patterns) { s{ A }{[A-Z]}gmx; s{ N }{\\d}gmx; s{ [ ] }{\\s+}gmx; }

   my $pattern = join '|', @patterns;

   return $val =~ m{ \A (?:$pattern) \z }mox ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
