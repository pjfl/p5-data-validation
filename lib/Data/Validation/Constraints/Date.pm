# @(#)$Ident: Date.pm 2013-07-29 14:38 pjf ;

package Data::Validation::Constraints::Date;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.13.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moo;
use Class::Usul::Time qw( str2time );

extends q(Data::Validation::Constraints);

around '_validate' => sub {
   return defined str2time( $_[ 2 ] ) ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
