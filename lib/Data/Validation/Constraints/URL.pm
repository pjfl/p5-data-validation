# @(#)$Ident: URL.pm 2013-07-29 15:53 pjf ;

package Data::Validation::Constraints::URL;

use namespace:sweep;
use version; our $VERSION = qv( sprintf '0.14.%d', q$Rev: 1 $ =~ /\d+/gmx );

use Moo;
use LWP::UserAgent;

extends q(Data::Validation::Constraints);

around '_validate' => sub {
   my ($orig, $self, $val) = @_; my $ua = LWP::UserAgent->new();

   $val !~ m{ \A http: }mx and $val = "http://localhost${val}";
   $ua->agent( 'isValidURL/0.1 '.$ua->agent );

   my $res = $ua->request( HTTP::Request->new( GET => $val ) );

   return $res->is_success() ? 1 : 0;
};

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
