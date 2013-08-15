# @(#)$Ident: Password.pm 2013-07-29 15:14 pjf ;

package Data::Validation::Constraints::Password;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.14.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moo;

extends q(Data::Validation::Constraints);

around '_validate' => sub {
   my ($orig, $self, $val) = @_; my $min_length = $self->min_length || 6;

   length $val < $min_length and return 0;
   $val =~ tr{A-Z}{a-z}; $val =~ tr{a-z}{}d;
   return length $val > 0 ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
