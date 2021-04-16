package Data::Validation::Constraints::URL;

use namespace::autoclean;

use Data::Validation::Constants qw( EXCEPTION_CLASS FALSE TRUE );
use HTTP::Tiny;
use Moo;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception('ValidURL', {
   error   => 'Parameter [_1] is not a valid URL',
   parents => ['InvalidParameter'],
});

sub validate {
   my ($self, $val) = @_;

   $val = "http://localhost${val}" if $val !~ m{ \A http: }mx;

   my $res = HTTP::Tiny->new->get($val);

   return $res->{success} ? TRUE : FALSE;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
