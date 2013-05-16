# @(#)$Ident: Postcode.pm 2013-05-16 21:13 pjf ;

package Data::Validation::Constraints::Postcode;

use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moose;

extends 'Data::Validation::Constraints';

override '_validate' => sub {
   my ($self, $val) = @_;
   my @patterns   = ( 'AN NAA',  'ANN NAA',  'AAN NAA', 'AANN NAA',
                      'ANA NAA', 'AANA NAA', 'AAA NAA', );

   foreach (@patterns) { s{ A }{[A-Z]}gmx; s{ N }{\\d}gmx; s{ [ ] }{\\s+}gmx; }

   my $pattern = join q(|), @patterns;

   return $val =~ m{ \A (?:$pattern) \z }mox ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
