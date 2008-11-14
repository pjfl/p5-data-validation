#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

my $requires = { 'perl'                         => q(5.008),
                 'charnames'                    => q(1.05),
                 'version'                      => q(0.74),
                 'Class::MOP'                   => q(0.53),
                 'Email::Valid'                 => q(0.179),
                 'LWP::UserAgent'               => q(2.036),
                 'Moose'                        => q(0.38),
                 'Moose::Role'                  => q(0.55),
                 'Moose::Util::TypeConstraints' => q(0.21),
                 'Regexp::Common'               => q(2.120),
                 'Scalar::Util'                 => q(1.19) };
#my $cond  = q($ENV{PERL5LIB} =~ m{ icerider }imx or $^O =~ m{ irix }imx);
my $build = Module::Build->new
   ( build_requires     => { 'Exception::Class'    => q(1.23),
                             'Class::Null'         => q(1.09),
                             'Test::Harness'       => q(2.64),
                             'Test::More'          => q(0.74),
                             'version'             => q(0.74) },
     configure_requires => { 'ExtUtils::MakeMaker' => q(6.42),
                             'version'             => q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/Data/Validation.pm),
     license            => q(perl),
     module_name        => q(Data::Validation),
     notes              => { cpan_testers_version => 1 },
     requires           => $requires,
     sign               => 1 );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
