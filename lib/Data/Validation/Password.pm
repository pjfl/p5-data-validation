package Data::Validation::Password;

# @(#)$Id: Password.pm 271 2008-01-07 00:11:26Z pjf $

use strict;
use warnings;
use base qw(Data::Validation);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 271 $ =~ /\d+/gmx );

sub _init {
   my ($me, $args) = @_;

   $me->{min_length} = $args->{min_length} || 6;
   return $me
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
