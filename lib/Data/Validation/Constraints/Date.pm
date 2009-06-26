package Data::Validation::Constraints::Date;

# @(#)$Id$

use strict;
use Moose;
use CatalystX::Usul::Time;

use version; our $VERSION = qv( sprintf '0.4.%d', q$Rev$ =~ /\d+/gmx );

extends 'Data::Validation::Constraints';

override '_validate' => sub {
   my ($self, $val) = @_;

   return defined CatalystX::Usul::Time->str2time( $val ) ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
