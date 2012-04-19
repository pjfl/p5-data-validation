package Data::Validation::Constraints::Email;

# @(#)$Id$

use strict;
use Moose;
use Email::Valid;

use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );

extends 'Data::Validation::Constraints';

override '_validate' => sub {
   my ($self, $val) = @_; return Email::Valid->address( $val ) ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
