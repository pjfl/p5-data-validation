requires "Email::Valid" => "1.196";
requires "Exporter::Tiny" => "0.042";
requires "HTTP::Tiny" => "0.056";
requires "Module::Runtime" => "0.014";
requires "Moo" => "2.000001";
requires "Regexp::Common" => "2013031301";
requires "Try::Tiny" => "0.22";
requires "Type::Tiny" => "1.000005";
requires "Unexpected" => "v0.39.0";
requires "namespace::autoclean" => "0.26";
requires "perl" => "5.010001";
recommends "Class::Usul" => "v0.63.0";

on 'build' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};

on 'test' => sub {
  requires "Class::Null" => "1.09";
  requires "File::Spec" => "0";
  requires "Module::Build" => "0.4004";
  requires "Module::Metadata" => "0";
  requires "Sys::Hostname" => "0";
  requires "version" => "0.88";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};
