use strict;
use warnings;

use Module::Build 0.4004;

my $perl_ver = 5.010001;
my $name     = 'Data-Validation'; $name =~ s{ - }{::}gmx;
my $prereqs  = {
  'build_requires' => {
    'Class::Null' => '1.09',
    'Module::Build' => '0.4004',
    'version' => '0.88'
  },
  'configure_requires' => {
    'Module::Build' => '0.4004',
    'version' => '0.88'
  },
  'recommends' => {
    'Class::Usul' => 'v0.58.0'
  },
  'requires' => {
    'Email::Valid' => '1.196',
    'Exporter::Tiny' => '0.042',
    'HTTP::Tiny' => '0.054',
    'Module::Runtime' => '0.014',
    'Moo' => '2.000001',
    'Regexp::Common' => '2013031301',
    'Try::Tiny' => '0.22',
    'Unexpected' => 'v0.38.0',
    'namespace::autoclean' => '0.22',
    'perl' => '5.010001'
  },
  'test_requires' => {
    'File::Spec' => '0',
    'Module::Metadata' => '0',
    'Sys::Hostname' => '0'
  },
};
my $testing  = sub { $ENV{AUTOMATED_TESTING}
                  || $ENV{PERL_CPAN_REPORTER_CONFIG}
                  || $ENV{PERL5_CPANPLUS_IS_VERSION} };
my $whimper  = sub { print {*STDOUT} $_[ 0 ]."\n"; exit 0 };
my $stop     = sub {
   $testing->() or $whimper->( $_[ 0 ] );
   $prereqs->{build_requires} = { %{ $prereqs->{configure_requires} } };
   $prereqs->{build_requires}->{ 'Test::Requires' } = 0.06;
   delete $prereqs->{requires};
};

# Not interested in reports below min perl ver
$] < $perl_ver and $stop->( "Minimum required Perl version is ${perl_ver}" );

Module::Build->new(
   'module_name' => $name,
   'notes'       => { min_perl_version => $perl_ver, testing => $testing->() },
   %{ $prereqs },

)->create_build_script;

exit 0;
