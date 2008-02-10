package Data::Validation::Path;

# @(#)$Id: Path.pm 271 2008-01-07 00:11:26Z pjf $

use strict;
use warnings;
use base qw(Data::Validation);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 271 $ =~ /\d+/gmx );

sub _validate {
   my ($me, $val) = @_; my $pat = qr([;&*{} ]); return $val !~ $pat ? 1 : 0;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
