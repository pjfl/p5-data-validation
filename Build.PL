#!/usr/bin/perl

# @(#)$Id: Build.PL 23 2008-02-07 20:23:36Z pjf $

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 23 $ =~ /\d+/gmx );

my $dist     = q(lib/Data/CloudWeights.pm);
my $requires = { 'perl'                  => q(5.8),
                 'Class::Accessor::Fast' => q(0.31) };
my $build    = Module::Build->new( create_makefile_pl => q(traditional),
                                   create_readme      => 1,
                                   create_packlist    => 0,
                                   dist_version_from  => $dist,
                                   license            => q(perl),
                                   module_name        => q(Data::CloudWeights),
                                   requires           => $requires );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
