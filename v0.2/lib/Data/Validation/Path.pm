package Data::Validation::Path;

# @(#)$Id$

use strict;
use warnings;
use base qw(Data::Validation);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _validate {
   my ($me, $val) = @_; my $pat = qr([;&*{} ]); return $val !~ $pat ? 1 : 0;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
