# @(#)$Ident: Postcode.pm 2013-07-29 14:28 pjf ;

package Data::Validation::Constraints::Postcode;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.14.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moo;

extends q(Data::Validation::Constraints);

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
