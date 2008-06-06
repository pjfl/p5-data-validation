#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Class::Null;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use lib qq($Bin/../lib);
use Exception::Class ( q(TestException) => { fields => [ qw(arg1 arg2) ] } );
use Test::More tests => 34;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

BEGIN { use_ok q(Data::Validation) }

sub test_val {
   eval { Data::Validation->check_field( q(TestException), @_ ) };

   return Exception::Class->caught( q(TestException) ) || Class::Null->new();
}

my $f = {};

ok(  test_val( $f, undef, 1 )->error eq q(eNoCheckfield), q(NoCheckfield) );

$f->{test}->{validate} = q(isHexadecimal);

ok(  test_val( $f, q(test), q(alive) )->error eq q(eHexadecimal),
     q(Not hexadecimal) );
ok( !test_val( $f, q(test), q(dead) )->error, q(Is hexadecimal) );

$f->{test}->{validate} = q(isMandatory);

ok(  test_val( $f, q(test), undef )->error eq q(eMandatory),
     q(Missing field) );
ok( !test_val( $f, q(test), 1 )->error, q(Mandatory field) );

$f->{test}->{validate} = q(isPrintable);

ok(  test_val( $f, q(test), q() )->error eq q(ePrintable),
     q(Not printable) );
ok( !test_val( $f, q(test), q(q; *) )->error, q(Printable) );

$f->{test}->{validate} = q(isSimpleText);

ok(  test_val( $f, q(test), q(*3$%^) )->error eq q(eSimpleText),
     q(Not simple text) );
ok( !test_val( $f, q(test), q(this is text) )->error, q(Simple text) );

$f->{test}->{validate} = q(isValidHostname);

ok(  test_val( $f, q(test), q(does_not_exist) )->error eq q(eValidHostname),
     q(Not valid hostname) );
ok( !test_val( $f, q(test), q(localhost) )->error, q(Valid hostname) );
ok( !test_val( $f, q(test), q(127.0.0.1) )->error, q(Valid hostname) );

$f->{test}->{validate} = q(isValidIdentifier);

ok(  test_val( $f, q(test), 1 )->error eq q(eValidIdentifier),
     q(InvalidIdentifier) );
ok( !test_val( $f, q(test), q(x) )->error, q(ValidIdentifier) );

$f->{test}->{validate} = q(isValidNumber isValidInteger);

ok(  test_val( $f, q(test), 1.1 )->error eq q(eValidInteger),
     q(InvalidInteger) );
ok( !test_val( $f, q(test), 1 )->error, q(Integer field) );

$f->{test}->{validate} = q(isValidNumber isValidInteger isBetweenValues);
$f->{test}->{min_value} = 2;
$f->{test}->{max_value} = 4;

ok(  test_val( $f, q(test), 5 )->error eq q(eBetweenValues), q(Out of range) );
ok( !test_val( $f, q(test), 3 )->error, q(In range) );

$f->{test}->{validate} = q(isEqualTo);
$f->{test}->{value} = 4;

ok(  test_val( $f, q(test), 5 )->error eq q(eEqualTo), q(Not equal) );
ok( !test_val( $f, q(test), 4 )->error, q(Is equal to) );

$f->{test}->{validate} = q(isValidLength);
$f->{test}->{min_length} = 2;
$f->{test}->{max_length} = 4;

ok(  test_val( $f, q(test), q(qwerty) )->error eq q(eValidLength),
     q(Invalid length) );
ok( !test_val( $f, q(test), q(qwe) )->error, q(Valid length) );

$f->{test}->{validate} = q(isValidEmail);

ok(  test_val( $f, q(test), q(fred) )->error eq q(eValidEmail),
     q(Invalid email) );
ok( !test_val( $f, q(test), q(a@b.c) )->error, q(Valid email) );

$f->{test}->{validate} = q(isValidPassword);

ok(  test_val( $f, q(test), q(fred) )->error eq q(eValidPassword),
     q(Invalid password) );
ok(  test_val( $f, q(test), q(freddyBoy) )->error eq q(eValidPassword),
     q(Invalid password) );
ok( !test_val( $f, q(test), q(qw3erty) )->error, q(Valid password) );

$f->{test}->{validate} = q(isValidPath);

ok(  test_val( $f, q(test), q(this is not ok;) )->error eq q(eValidPath),
     q(Invalid path) );
ok( !test_val( $f, q(test), q(/this/is/ok) )->error, q(Valid path) );

$f->{test}->{validate} = q(isValidPostcode);

ok(  test_val( $f, q(test), q(CA123445) )->error eq q(eValidPostcode),
     q(Invalid postcode) );
ok( !test_val( $f, q(test), q(SW1A 4WW) )->error, q(Valid postcode) );

$f->{subr_field_name }->{validate  } = q(isValidPostcode);
$f->{subr_field_name1}->{validate  } = q(isValidPath);
$f->{subr_field_name2}->{validate  } = q(isValidPassword);
$f->{subr_field_name3}->{validate  } = q(isValidEmail);
$f->{subr_field_name4}->{validate  } = q(isValidLength);
$f->{subr_field_name4}->{min_length} = 2;
$f->{subr_field_name4}->{max_length} = 4;

my $vals = { field_name  => q(SW1A 4WW),
             field_name1 => q(/this/is/ok),
             field_name2 => q(qw3erty),
             field_name3 => q(a@b.c),
             field_name4 => q(qwe) };

eval { Data::Validation->check_form( q(TestException), $f, q(subr_), $vals ) };
my $e = Exception::Class->caught( q(TestException) ) || Class::Null->new();
ok( !$e->error, q(Valid form) );

$vals->{field_name2} = q(tooeasy);

eval { Data::Validation->check_form( q(TestException), $f, q(subr_), $vals ) };
$e = Exception::Class->caught( q(TestException) ) || Class::Null->new();
ok(  $e->error eq q(eValidPassword), q(Invalid form) );
