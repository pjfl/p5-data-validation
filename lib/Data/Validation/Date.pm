package Data::Validation::Date;

# @(#)$Id$

use strict;
use warnings;
use base qw(Data::Validation);

use CatalystX::Usul::Time;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _validate {
   my ($me, $val) = @_;

   return defined CatalystX::Usul::Class::Time->str2time( $val ) ? 1 : 0;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
