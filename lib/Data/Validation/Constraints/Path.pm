# @(#)$Ident: Path.pm 2013-07-29 15:14 pjf ;

package Data::Validation::Constraints::Path;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.14.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moo;

extends q(Data::Validation::Constraints);

around '_validate' => sub {
   my ($orig, $self, $val) = @_; return $val =~ m{ [;&*{} ] }mx ? 0 : 1;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
