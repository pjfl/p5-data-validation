package Data::Validation::Constraints::Password;

# @(#)$Id$

use Moose;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

extends 'Data::Validation::Constraints';

override '_init' => sub {
   my $self = shift;

   $self->min_length( $self->min_length || 6 );
   return $self;
};

override '_validate' => sub {
   my ($me, $val)   = @_;
   (my $tmp = $val) =~ tr{A-Z}{a-z}; $tmp =~ tr{a-z}{}d;

   return 0 if     (length $val < $me->min_length);
   return 0 unless (length $tmp > 0);
   return 1;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
