package Data::Validation::Constraints::Date;

use namespace::autoclean;

use Class::Usul::Time     qw( str2time );
use Data::Validation::Constants;
use Unexpected::Functions qw( has_exception );
use Moo;

extends q(Data::Validation::Constraints);

has_exception 'ValidDate' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid date';

sub validate {
   return defined str2time( $_[ 1 ] ) ? 1 : 0;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
