# @(#)$Ident: Date.pm 2013-05-16 21:18 pjf ;

package Data::Validation::Constraints::Date;

use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moose;
use Class::Usul::Time qw(str2time);

extends q(Data::Validation::Constraints);

override '_validate' => sub {
   my $self = shift; return defined str2time( $_[ 0 ] ) ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
