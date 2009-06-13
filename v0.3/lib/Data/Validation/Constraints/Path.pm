package Data::Validation::Constraints::Path;

# @(#)$Id$

use strict;
use Moose;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

extends 'Data::Validation::Constraints';

override '_validate' => sub {
   my ($self, $val) = @_; return $val =~ m{ [;&*{} ] }mx ? 0 : 1;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
