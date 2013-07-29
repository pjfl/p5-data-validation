# @(#)$Ident: Email.pm 2013-07-29 14:37 pjf ;

package Data::Validation::Constraints::Email;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.12.%d', q$Rev: 0 $ =~ /\d+/gmx );

use Moo;
use Email::Valid;

extends q(Data::Validation::Constraints);

around '_validate' => sub {
   return Email::Valid->address( $_[ 2 ] ) ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
