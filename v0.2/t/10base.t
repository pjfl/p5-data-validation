# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );
use File::Spec::Functions;
use FindBin qw( $Bin );
use lib catdir( $Bin, updir, q(lib) );

use English qw( -no_match_vars );
use Test::More;

BEGIN {
   if ($ENV{AUTOMATED_TESTING} || $ENV{PERL_CR_SMOKER_CURRENT}
       || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx) {
      plan skip_all => q(CPAN Testing stopped);
   }

   plan tests => 46;
}

use Class::Null;
use Exception::Class ( q(TestException) => { fields => [ qw(args) ] } );

use_ok q(Data::Validation);

sub test_val {
   my $config    = shift; $config->{exception} = q(TestException);
   my $validator = Data::Validation->new( %{ $config } );
   my $value     = eval { $validator->check_field( @_ ) };
   my $e;

   return $e->error if ($e = TestException->caught());

   die $EVAL_ERROR  if ($EVAL_ERROR);

   return $value;
}

my $f = {};
ok( test_val( $f, undef, 1 ) eq q(No definition for field),
    q(No field definition 1) );
ok( test_val( $f, q(test), 1 ) eq q(No definition for field),
    q(No field definition 2) );

$f->{fields}->{test}->{validate} = q(isHexadecimal);
ok( test_val( $f, q(test), q(alive) ) eq q(eHexadecimal), q(Not hexadecimal) );
ok( test_val( $f, q(test), q(dead) ) eq q(dead), q(Is hexadecimal) );

$f->{fields}->{test}->{validate} = q(isMandatory);
ok( test_val( $f, q(test), undef ) eq q(eMandatory), q(Missing field) );
ok( test_val( $f, q(test), 1 ) eq q(1), q(Mandatory field) );

$f->{fields}->{test}->{validate} = q(isPrintable);
ok( test_val( $f, q(test), q() ) eq q(ePrintable), q(Not printable) );
ok( test_val( $f, q(test), q(q; *) ) eq q(q; *), q(Printable) );

$f->{fields}->{test}->{validate} = q(isSimpleText);
ok( test_val( $f, q(test), q(*3$%^) ) eq q(eSimpleText), q(Not simple text) );
ok( test_val( $f, q(test), q(this is text) ) eq q(this is text),
    q(Simple text) );

$f->{fields}->{test}->{validate} = q(isValidHostname);
ok( test_val( $f, q(test), q(does_not_exist) ) eq q(eValidHostname),
    q(Not valid hostname) );
ok( test_val( $f, q(test), q(localhost) ) eq q(localhost),
    q(Valid hostname 1) );
ok( test_val( $f, q(test), q(127.0.0.1) ) eq q(127.0.0.1),
    q(Valid hostname 2) );

$f->{fields}->{test}->{validate} = q(isValidIdentifier);
ok( test_val( $f, q(test), 1 ) eq q(eValidIdentifier), q(Invalid Identifier) );
ok( test_val( $f, q(test), q(x) ) eq q(x), q(Valid Identifier) );

$f->{fields}->{test}->{validate} = q(isValidNumber isValidInteger);
ok( test_val( $f, q(test), 1.1 ) eq q(eValidInteger), q(Invalid Integer) );
ok( test_val( $f, q(test), q(1a) ) eq q(eValidNumber), q(Invalid Number) );
ok( test_val( $f, q(test), 1 ) == 1, q(Valid Integer) );

$f->{fields}->{test}->{validate}
   = q(isValidNumber isValidInteger isBetweenValues);
$f->{constraints}->{test} = { min_value => 2, max_value => 4 };
ok( test_val( $f, q(test), 5 ) eq q(eBetweenValues), q(Out of range) );
ok( test_val( $f, q(test), 3 ) == 3, q(In range) );

$f->{fields}->{test}->{validate} = q(isEqualTo);
$f->{constraints}->{test} = { value => 4 };
ok( test_val( $f, q(test), 5 ) eq q(eEqualTo), q(Not equal) );
ok( test_val( $f, q(test), 4 ) == 4, q(Is equal) );

$f->{fields}->{test}->{validate} = q(isValidLength);
$f->{constraints}->{test} = { min_length => 2, max_length => 4 };
ok( test_val( $f, q(test), q(qwerty) ) eq q(eValidLength),
    q(Invalid length) );
ok( test_val( $f, q(test), q(qwe) ) eq q(qwe), q(Valid length) );

$f->{fields}->{test}->{validate} = q(isMatchingRegex);
$f->{constraints}->{test} = { pattern => q(...-...) };
ok( test_val( $f, q(test), q(123 456) ) eq q(eMatchingRegex),
    q(Non Matching Regex) );
ok( test_val( $f, q(test), q(123-456) ) eq q(123-456), q(Matching Regex) );

$f->{fields}->{test}->{validate} = q(isValidEmail);
ok( test_val( $f, q(test), q(fred) ) eq q(eValidEmail), q(Invalid email) );
ok( test_val( $f, q(test), q(a@b.c) ) eq q(a@b.c), q(Valid email) );

$f->{fields}->{test}->{validate} = q(isValidPassword);
ok( test_val( $f, q(test), q(fred) ) eq q(eValidPassword),
    q(Invalid password 1) );
ok( test_val( $f, q(test), q(freddyBoy) ) eq q(eValidPassword),
    q(Invalid password 2) );
ok( test_val( $f, q(test), q(qw3erty) ) eq q(qw3erty), q(Valid password) );

$f->{fields}->{test}->{validate} = q(isValidPath);
ok( test_val( $f, q(test), q(this is not ok;) ) eq q(eValidPath),
    q(Invalid path) );
ok( test_val( $f, q(test), q(/this/is/ok) ) eq q(/this/is/ok), q(Valid path) );

$f->{fields}->{test}->{validate} = q(isValidPostcode);
ok( test_val( $f, q(test), q(CA123445) ) eq q(eValidPostcode),
    q(Invalid postcode) );
ok( test_val( $f, q(test), q(SW1A 4WW) ) eq q(SW1A 4WW), q(Valid postcode) );

$f->{fields}->{subr_field_name }->{validate  } = q(isValidPostcode);
$f->{fields}->{subr_field_name1}->{validate  } = q(isValidPath);
$f->{fields}->{subr_field_name2}->{validate  } = q(isValidPassword);
$f->{fields}->{subr_field_name3}->{validate  } = q(isValidEmail);
$f->{fields}->{subr_field_name4}->{validate  } = q(isValidLength);
$f->{constraints}->{subr_field_name4} = { min_length => 2,
                                          max_length => 4 };

my $validator
   = Data::Validation->new( exception => q(TestException), %{ $f } );
my $vals = { field_name  => q(SW1A 4WW),
             field_name1 => q(/this/is/ok),
             field_name2 => q(qw3erty),
             field_name3 => q(a@b.c),
             field_name4 => q(qwe) };
eval { $validator->check_form( q(subr_), $vals ) };
my $e = TestException->caught() || Class::Null->new();
ok( !$e->error, q(Valid form) );

$vals->{field_name2} = q(tooeasy);
eval { $validator->check_form( q(subr_), $vals ) };
$e = TestException->caught() || Class::Null->new();
ok(  $e->error eq q(eValidPassword), q(Invalid form) );

$f->{fields}->{test}->{validate} = q(isMatchingRegex);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
ok( test_val( $f, q(test), q(123 456) ) eq q(eMatchingRegex),
    q(Non Matching Regex 1) );

$f->{fields}->{test}->{filters} = q(filterEscapeHTML);
$f->{constraints}->{test} = { pattern => q(\A .+ \z) };
ok( test_val( $f, q(test), q(&amp;"&<>") )
    eq q(&amp;&quot;&amp;&lt;&gt;&quot;), q(Filter EscapeHTML) );

$f->{fields}->{test}->{filters} = q(filterLowerCase);
$f->{constraints}->{test} = { pattern => q(\A [a-z ]+ \z) };
ok( test_val( $f, q(test), q(HELLO WORLD) ) eq q(hello world),
    q(Filter LowerCase) );

$f->{fields}->{test}->{filters} = q(filterNonNumeric);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
ok( test_val( $f, q(test), q(1a2b3c) ) eq q(123), q(Filter NonNumeric) );

$f->{fields}->{test}->{filters} = q(filterReplaceRegex);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
$f->{filters}->{test} = { pattern => q(\-), replace => q(0) };
ok( test_val( $f, q(test), q(1-2-3) ) eq q(10203), q(Filter RegexReplace) );

$f->{fields}->{test}->{filters} = q(filterTrimBoth);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
ok( test_val( $f, q(test), q( 123456 ) ) == 123456, q(Filter TrimBoth) );

$f->{fields}->{test}->{filters} = q(filterUpperCase);
$f->{constraints}->{test} = { pattern => q(\A [A-Z ]+ \z) };
ok( test_val( $f, q(test), q(hello world) ) eq q(HELLO WORLD),
    q(Filter UpperCase) );

$f->{fields}->{test}->{filters} = q(filterWhiteSpace);
$f->{constraints}->{test} = { pattern => q(\A \d+ \z) };
ok( test_val( $f, q(test), q(123 456) ) == 123456, q(Filter WhiteSpace) );

# Local Variables:
# mode: perl
# tab-width: 3
# End:
