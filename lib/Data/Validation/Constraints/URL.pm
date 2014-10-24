package Data::Validation::Constraints::URL;

use namespace::autoclean;

use Moo;
use Data::Validation::Constants;
use LWP::UserAgent;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception( 'ValidURL', {
   parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid URL' } );

sub _validate {
   my ($self, $val) = @_; my $ua = LWP::UserAgent->new();

   $val !~ m{ \A http: }mx and $val = "http://localhost${val}";
   $ua->agent( 'isValidURL/0.1 '.$ua->agent );

   my $res = $ua->request( HTTP::Request->new( GET => $val ) );

   return $res->is_success() ? 1 : 0;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
