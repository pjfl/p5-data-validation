#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Class::Null;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use lib qq($Bin/../lib);
use Exception::Class ( q(TestException) => { fields => [ qw(arg1 arg2) ] } );
use Test::More tests => 37;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

BEGIN { use_ok q(Data::Validation) }

sub test_val {
   my $config = shift; my $e;
   my $validator
      = Data::Validation->new( exception => q(TestException), %{ $config } );
   my $value  = eval { $validator->check_field( @_ ) };

   return $e if ($e = TestException->caught());

   return $value;
}

my $f = {};

ok( test_val( $f, undef, 1 )->error eq q(eNoFieldDefinition),
    q(No field definition 1) );
ok( test_val( $f, q(test), 1 )->error eq q(eNoFieldDefinition),
    q(No field definition 2) );

$f->{fields}->{test}->{validate} = q(isHexadecimal);

ok( test_val( $f, q(test), q(alive) )->error eq q(eHexadecimal),
    q(Not hexadecimal) );
ok( test_val( $f, q(test), q(dead) ) eq q(dead), q(Is hexadecimal) );

$f->{fields}->{test}->{validate} = q(isMandatory);

ok( test_val( $f, q(test), undef )->error eq q(eMandatory),
    q(Missing field) );
ok( test_val( $f, q(test), 1 ) eq q(1), q(Mandatory field) );

$f->{fields}->{test}->{validate} = q(isPrintable);

ok( test_val( $f, q(test), q() )->error eq q(ePrintable),
    q(Not printable) );
ok( test_val( $f, q(test), q(q; *) ) eq q(q; *), q(Printable) );

$f->{fields}->{test}->{validate} = q(isSimpleText);

ok( test_val( $f, q(test), q(*3$%^) )->error eq q(eSimpleText),
    q(Not simple text) );
ok( test_val( $f, q(test), q(this is text) ) eq q(this is text),
    q(Simple text) );

$f->{fields}->{test}->{validate} = q(isValidHostname);

ok( test_val( $f, q(test), q(does_not_exist) )->error eq q(eValidHostname),
    q(Not valid hostname) );
ok( test_val( $f, q(test), q(localhost) ) eq q(localhost), q(Valid hostname) );
ok( test_val( $f, q(test), q(127.0.0.1) ) eq q(127.0.0.1), q(Valid hostname) );

$f->{fields}->{test}->{validate} = q(isValidIdentifier);

ok( test_val( $f, q(test), 1 )->error eq q(eValidIdentifier),
    q(InvalidIdentifier) );
ok( test_val( $f, q(test), q(x) ) eq q(x), q(ValidIdentifier) );

$f->{fields}->{test}->{validate} = q(isValidNumber isValidInteger);

ok( test_val( $f, q(test), 1.1 )->error eq q(eValidInteger),
    q(InvalidInteger) );
ok( test_val( $f, q(test), 1 ) == 1, q(Integer field) );

$f->{fields}->{test}->{validate}
   = q(isValidNumber isValidInteger isBetweenValues);
$f->{constraints}->{test} = { min_value => 2, max_value => 4 };

ok( test_val( $f, q(test), 5 )->error eq q(eBetweenValues), q(Out of range) );
ok( test_val( $f, q(test), 3 ) == 3, q(In range) );

$f->{fields}->{test}->{validate} = q(isEqualTo);
$f->{constraints}->{test} = { value => 4 };

ok( test_val( $f, q(test), 5 )->error eq q(eEqualTo), q(Not equal) );
ok( test_val( $f, q(test), 4 ) == 4, q(Is equal to) );

$f->{fields}->{test}->{validate} = q(isValidLength);
$f->{constraints}->{test} = { min_length => 2, max_length => 4 };

ok( test_val( $f, q(test), q(qwerty) )->error eq q(eValidLength),
    q(Invalid length) );
ok( test_val( $f, q(test), q(qwe) ) eq q(qwe), q(Valid length) );

$f->{fields}->{test}->{validate} = q(isMatchingRegex);
$f->{constraints}->{test} = { pattern => q(...-...) };

ok( test_val( $f, q(test), q(123 456) )->error eq q(eMatchingRegex),
    q(Non Matching Regex) );
ok( test_val( $f, q(test), q(123-456) ) eq q(123-456),
    q(Matching Regex) );

$f->{fields}->{test}->{validate} = q(isValidEmail);

ok( test_val( $f, q(test), q(fred) )->error eq q(eValidEmail),
    q(Invalid email) );
ok( test_val( $f, q(test), q(a@b.c) ) eq q(a@b.c), q(Valid email) );

$f->{fields}->{test}->{validate} = q(isValidPassword);

ok( test_val( $f, q(test), q(fred) )->error eq q(eValidPassword),
    q(Invalid password) );
ok( test_val( $f, q(test), q(freddyBoy) )->error eq q(eValidPassword),
    q(Invalid password) );
ok( test_val( $f, q(test), q(qw3erty) ) eq q(qw3erty), q(Valid password) );

$f->{fields}->{test}->{validate} = q(isValidPath);

ok( test_val( $f, q(test), q(this is not ok;) )->error eq q(eValidPath),
    q(Invalid path) );
ok( test_val( $f, q(test), q(/this/is/ok) ) eq q(/this/is/ok), q(Valid path) );

$f->{fields}->{test}->{validate} = q(isValidPostcode);

ok( test_val( $f, q(test), q(CA123445) )->error eq q(eValidPostcode),
    q(Invalid postcode) );
ok( test_val( $f, q(test), q(SW1A 4WW) ) eq q(SW1A 4WW), q(Valid postcode) );

$f->{fields}->{subr_field_name }->{validate  } = q(isValidPostcode);
$f->{fields}->{subr_field_name1}->{validate  } = q(isValidPath);
$f->{fields}->{subr_field_name2}->{validate  } = q(isValidPassword);
$f->{fields}->{subr_field_name3}->{validate  } = q(isValidEmail);
$f->{fields}->{subr_field_name4}->{validate  } = q(isValidLength);
$f->{constraints}->{subr_field_name4} = { min_length => 2,
                                          max_length => 4 };

my $validator = Data::Validation->new( exception => q(TestException),
                                       %{ $f } );
my $vals      = { field_name  => q(SW1A 4WW),
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
