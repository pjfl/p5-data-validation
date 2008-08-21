package Data::Validation::Password;

# @(#)$Id$

use strict;
use warnings;
use base qw(Data::Validation);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _init {
   my ($me, $args) = @_; my $self = $me->NEXT::_init( $args );

   $self->min_length( $self->min_length || 6 );
   return $self;
}

sub _validate {
   my ($me, $val)   = @_;
   (my $tmp = $val) =~ tr{A-Z}{a-z}; $tmp =~ tr{a-z}{}d;

   return 0 if     (length $val < $me->min_length);
   return 0 unless (length $tmp > 0);
   return 1;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
