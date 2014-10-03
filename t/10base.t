use strict;
use warnings;
use File::Spec::Functions qw( catdir updir );
use FindBin               qw( $Bin );
use lib               catdir( $Bin, updir, 'lib' );

use Module::Build;
use Sys::Hostname;
use Test::More;

my $builder; my $notes = {}; my $perl_ver;

BEGIN {
   $builder   = eval { Module::Build->current };
   $builder and $notes = $builder->notes;
   $perl_ver  = $notes->{min_perl_version} || 5.008;
   # Disable CPAN Testing on k83
   lc hostname eq 'k83' and $perl_ver += ($notes->{testing} || 0);
}

use Test::Requires "${perl_ver}";
use Test::Requires { 'Regexp::Common' => 2013031301 };
use Class::Null;
use English qw( -no_match_vars );

use_ok 'Data::Validation';

sub test_val {
   my $config    = shift;
   my $validator = Data::Validation->new( %{ $config } );
   my $value     = eval { $validator->check_field( @_ ) };
   my $e         = Data::Validation::Exception->caught();

   $e and $e->instance_of( 'Constraint' ) and return $e->class;

   if ($e) { $e = $e->as_string; chomp $e; return $e }

   return $value;
}

my $f = {};

is test_val( $f, undef, 1 ),   q(Field '[?]' undefined), 'No field def 1';
is test_val( $f, q(test), 1 ), q(Field 'test' undefined), 'No field def 2';

$f->{fields}->{test}->{validate} = q(isHexadecimal);
is test_val( $f, q(test), q(alive) ), q(Hexadecimal), 'Not hexadecimal';
is test_val( $f, q(test), q(dead) ),  q(dead),         'Is hexadecimal';

$f->{fields}->{test}->{validate} = q(isMandatory);
is test_val( $f, q(test), undef ), q(Mandatory), 'Missing field';
is test_val( $f, q(test), 1 ),     q(1),          'Mandatory field';

$f->{fields}->{test}->{validate} = q(isPrintable);
is test_val( $f, q(test), q() ),   q(Printable), 'Not printable';
is test_val( $f, q(test), q(q; *) ), q(q; *),       'Printable';

$f->{fields}->{test}->{validate} = q(isSimpleText);
is test_val( $f, q(test), q(*3$%^) ),        q(SimpleText),  'Not simple text';
is test_val( $f, q(test), q(this is text) ), q(this is text), 'Simple text';

SKIP: {
   $f->{fields}->{test}->{validate} = q(isValidHostname);

   (test_val( $f, q(test), q(example.com)        ) eq q(example.com)    and
    test_val( $f, q(test), q(google.com)         ) eq q(google.com)     and
    test_val( $f, q(test), q(does_not_exist)     ) eq q(ValidHostname) and
    test_val( $f, q(test), q(does_not_exist.com) ) eq q(ValidHostname) and
    test_val( $f, q(test), q(does.not.exist.com) ) eq q(ValidHostname) and
    test_val( $f, q(test), q(does.not.exist.example.com) ) eq q(ValidHostname))
      or skip 'valid hostname test - Broken resolver', 8;

   is test_val( $f, q(test), q(does_not_exist) ), q(ValidHostname),
      'Invalid hostname - does_not_exist';
   is test_val( $f, q(test), q(does_not_exist.com) ), q(ValidHostname),
      'Invalid hostname - does_not_exist.com';
   is test_val( $f, q(test), q(does.not.exist.com) ), q(ValidHostname),
      'Invalid hostname - does.not.exist.com';
   is test_val( $f, q(test), q(does.not.exist.example.com) ),
      q(ValidHostname), 'Invalid hostname - does.not.exist.example.com';
   is test_val( $f, q(test), q(127.0.0.1) ), q(127.0.0.1),
      'Valid hostname - 127.0.0.1';
   is test_val( $f, q(test), q(example.com) ), q(example.com),
      'Valid hostname - example.com';
   is test_val( $f, q(test), q(localhost) ), q(localhost),
      'Valid hostname - localhost';
   is test_val( $f, q(test), q(google.com) ), q(google.com),
      'Valid hostname - google.com';
}

$f->{fields}->{test}->{validate} = q(isValidIdentifier);
is test_val( $f, q(test), 1 ),     q(ValidIdentifier), 'Invalid Identifier';
is test_val( $f, q(test), q(x) ),  q(x),               'Valid Identifier';

$f->{fields}->{test}->{validate} = q(isValidNumber isValidInteger);
is test_val( $f, q(test), 1.1 ),   q(ValidInteger), 'Invalid Integer';
is test_val( $f, q(test), q(1a) ), q(ValidNumber),  'Invalid Number';
is test_val( $f, q(test), 1 ),     1,               'Valid Integer';

$f->{fields}->{test}->{validate}
   = q(isValidNumber isValidInteger isBetweenValues);
$f->{constraints}->{test} = { min_value => 2, max_value => 4 };
is test_val( $f, q(test), 5 ), q(BetweenValues), 'Out of range';
is test_val( $f, q(test), 3 ), 3,                'In range';

$f->{fields}->{test}->{validate} = q(isEqualTo);
$f->{constraints}->{test} = { value => 4 };
is test_val( $f, q(test), 5 ), q(EqualTo), 'Not equal';
is test_val( $f, q(test), 4 ), 4,          'Is equal';

$f->{fields}->{test}->{validate} = q(isValidLength);
$f->{constraints}->{test} = { min_length => 2, max_length => 4 };
is test_val( $f, q(test), q(qwerty) ), q(ValidLength), 'Invalid length';
is test_val( $f, q(test), q(qwe) ),    q(qwe),         'Valid length';

$f->{fields}->{test}->{validate} = q(isMatchingRegex);
$f->{constraints}->{test} = { pattern => q(...-...) };
is test_val( $f, q(test), q(123 456) ), q(MatchingRegex), 'Non Matching Regex';
is test_val( $f, q(test), q(123-456) ), q(123-456),       'Matching Regex';

$f->{fields}->{test}->{validate} = q(isValidEmail);
is test_val( $f, q(test), q(fred) ),  q(ValidEmail), 'Invalid email';
is test_val( $f, q(test), q(a@b.c) ), q(a@b.c),      'Valid email';

$f->{fields}->{test}->{validate} = q(isValidPassword);
is test_val( $f, q(test), q(fred) ), q(ValidPassword), 'Invalid password 1';
is test_val( $f, q(test), q(freddyBoy) ), q(ValidPassword),
   'Invalid password 2';
is test_val( $f, q(test), q(qw3erty) ), q(qw3erty), 'Valid password';

$f->{fields}->{test}->{validate} = q(isValidPath);
is test_val( $f, q(test), q(this is not ok;) ), q(ValidPath),
   'Invalid path';
is test_val( $f, q(test), q(/this/is/ok) ), q(/this/is/ok), 'Valid path';

$f->{fields}->{test}->{validate} = q(isValidPostcode);
is test_val( $f, q(test), q(CA123445) ), q(ValidPostcode), 'Invalid postcode';
is test_val( $f, q(test), q(SW1A 4WW) ), q(SW1A 4WW),      'Valid postcode';

$f->{fields}->{subr_field_name }->{validate} = q(isValidPostcode);
$f->{fields}->{subr_field_name1}->{validate} = q(isValidPath);
$f->{fields}->{subr_field_name2}->{validate} = q(isValidPassword);
$f->{fields}->{subr_field_name3}->{validate} = q(isValidEmail);
$f->{fields}->{subr_field_name4}->{validate} = q(isValidLength);
$f->{fields}->{subr_field_name5}->{validate} = q(compare);
$f->{constraints}->{subr_field_name5} = { other_field => q(field_name4) };

my $validator = Data::Validation->new( %{ $f } );
my $vals = { field_name  => q(SW1A 4WW),
             field_name1 => q(/this/is/ok),
             field_name2 => q(qw3erty),
             field_name3 => q(a@b.c),
             field_name4 => q(qwe),
             field_name5 => q(qwe) };

eval { $validator->check_form( q(subr_), $vals ) };

my $e = Unexpected->caught() || Class::Null->new();

ok !$e->error, 'Valid form';

$vals->{field_name5} = q(not_the_same_as_field4);
eval { $validator->check_form( q(subr_), $vals ) };
$e = Unexpected->caught() || Class::Null->new();
like $e->args->[0]->as_string, qr{ \Qdoes not 'eq' field\E }mx,
   'Non matching fields';

ok $e->args->[0]->args->[0] eq q(field_name5)
   && $e->args->[0]->args->[1] eq q(eq)
   && $e->args->[0]->args->[2] eq q(field_name4), 'Field comparison args';

$f->{constraints}->{subr_field_name5}->{operator} = q(ne);
eval { $validator->check_form( q(subr_), $vals ) };
$e = Unexpected->caught() || Class::Null->new();
ok !$e->as_string, 'Not equal field comparison';

$f->{constraints}->{subr_field_name5}->{operator} = q(eq);
$vals->{field_name5} = q(qwe);
delete $f->{constraints}->{subr_field_name5}->{other_field};
eval { $validator->check_form( q(subr_), $vals ) };
$e = Unexpected->caught() || Class::Null->new();
like $e->args->[0]->as_string, qr{ \Qhas no comparison field\E }mx,
   'No comparison field';

$f->{constraints}->{subr_field_name5}->{other_field} = q(field_name4);
$vals->{field_name2} = q(tooeasy);
eval { $validator->check_form( q(subr_), $vals ) };
$e = Unexpected->caught() || Class::Null->new();
like $e->args->[0]->as_string, qr{ \Qnot a valid password\E }mx, 'Invalid form';

$f->{fields}->{test}->{validate} = q(isMatchingRegex);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
is test_val( $f, q(test), q(123 456) ), q(MatchingRegex),
   'Non Matching Regex 1';

$f->{fields}->{test}->{filters} = q(filterEscapeHTML);
$f->{constraints}->{test} = { pattern => q(\A .+ \z) };
is test_val( $f, q(test), q(&amp;"&<>") ),
   q(&amp;&quot;&amp;&lt;&gt;&quot;), 'Filter EscapeHTML';

$f->{fields}->{test}->{filters} = q(filterLowerCase);
$f->{constraints}->{test} = { pattern => q(\A [a-z ]+ \z) };
is test_val( $f, q(test), q(HELLO WORLD) ), q(hello world), 'Filter LowerCase';

$f->{fields}->{test}->{filters} = q(filterNonNumeric);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
is test_val( $f, q(test), q(1a2b3c) ), q(123), 'Filter NonNumeric';

$f->{fields}->{test}->{filters} = q(filterReplaceRegex);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
$f->{filters}->{test} = { pattern => q(\-), replace => q(0) };
is test_val( $f, q(test), q(1-2-3) ), q(10203), 'Filter RegexReplace';

$f->{fields}->{test}->{filters} = q(filterTrimBoth);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
is test_val( $f, q(test), q( 123456 ) ), 123456, 'Filter TrimBoth';

$f->{fields}->{test}->{filters} = q(filterUpperCase);
$f->{constraints}->{test} = { pattern => q(\A [A-Z ]+ \z) };
is test_val( $f, q(test), q(hello world) ), q(HELLO WORLD), 'Filter UpperCase';

$f->{fields}->{test}->{filters} = q(filterWhiteSpace);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
is test_val( $f, q(test), q(123 456) ), 123456, 'Filter WhiteSpace';

delete $f->{constraints}->{test};
$f->{fields}->{test}->{filters} = q(filterZeroLength);
is test_val( $f, q(test), q() ), undef, 'Filter ZeroLength - positive';
delete $f->{fields}->{test}->{filters};
is test_val( $f, q(test), q() ), q(), 'Filter ZeroLength - negative';

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
