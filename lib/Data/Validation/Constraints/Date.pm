package Data::Validation::Constraints::Date;

use namespace::autoclean;

use Data::Validation::Constants qw( EXCEPTION_CLASS FALSE TRUE );
use Data::Validation::Utils     qw( ensure_class_loaded );
use Moo;

extends q(Data::Validation::Constraints);

EXCEPTION_CLASS->add_exception('ValidDate', {
   error   => 'Parameter [_1] is not a valid date',
   parents => ['InvalidParameter'],
});

sub validate {
   my ($self, $x) = @_;

   ensure_class_loaded 'Class::Usul::Time';

   return defined Class::Usul::Time::str2time($x) ? TRUE : FALSE;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
