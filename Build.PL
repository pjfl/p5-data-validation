#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

my $dist     = q(lib/Data/Validation.pm);
my $requires = { 'perl'                  => q(5.8),
                 'Class::Accessor::Fast' => q(0.31),
                 'Email::Valid'          => q(0.179),
                 'LWP::UserAgent'        => q(2.036),
                 'Regexp::Common'        => q(2.120),
                 'Scalar::Util'          => q(1.19) };
my $build    = Module::Build->new( create_makefile_pl => q(traditional),
                                   create_readme      => 1,
                                   create_packlist    => 0,
                                   dist_version_from  => $dist,
                                   license            => q(perl),
                                   module_name        => q(Data::Validation),
                                   requires           => $requires );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
