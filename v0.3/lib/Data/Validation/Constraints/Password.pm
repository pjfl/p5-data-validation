package Data::Validation::Constraints::Password;

# @(#)$Id$

use strict;
use Moose;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

extends 'Data::Validation::Constraints';

override '_validate' => sub {
   my ($self, $val) = @_;

   my $min_length = $self->min_length || 6;
   return 0 if (length $val < $min_length);

   $val =~ tr{A-Z}{a-z}; $val =~ tr{a-z}{}d;
   return 0 unless (length $val > 0);
   return 1;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
