# @(#)$Ident: Email.pm 2013-05-16 21:14 pjf ;

package Data::Validation::Constraints::Email;

use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moose;
use Email::Valid;

extends 'Data::Validation::Constraints';

override '_validate' => sub {
   my ($self, $val) = @_; return Email::Valid->address( $val ) ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
