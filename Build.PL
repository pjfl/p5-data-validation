#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

my $requires = { 'perl'                  => q(5.8),
                 'charnames'             => q(1.05),
                 'version'               => q(0.74),
                 'Class::Accessor::Fast' => q(0.31),
                 'Class::Null'           => q(1.09),
                 'Email::Valid'          => q(0.179),
                 'Exception::Class'      => q(1.23),
                 'File::Spec::Functions' => q(1.3),
                 'LWP::UserAgent'        => q(2.036),
                 'Readonly'              => q(1.03),
                 'Regexp::Common'        => q(2.120),
                 'Scalar::Util'          => q(1.19) };
my $build = Module::Build->new
   ( build_requires     => { 'Test::More' => q(0.74), 'version'=> q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/Data/Validation.pm),
     license            => q(perl),
     module_name        => q(Data::Validation),
     requires           => $requires );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
