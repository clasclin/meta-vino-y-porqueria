#!/usr/bin/env perl
#
# new-project - template for new perl scripts
#

use strict;
use warnings;
use utf8;

use Getopt::Long 'GetOptions';
use Pod::Usage 'pod2usage';
use File::Basename qw/ fileparse dirname basename /;
use Carp 'croak';
use POSIX 'strftime';
use experimental 'switch';
use IPC::Cmd 'can_run';
use Data::Dumper::Names;

GetOptions(
    'help|?'         => \(my $help),
    'man'            => \(my $man),
    'project-name=s' => \(my $name),
    'description=s'  => \(my $description))
    or croak("Error on command line arguments!");

if ($help) {
    pod2usage( -verbose => 1 );
}
elsif ($man) {
    pod2usage( -verbose => 2 );
}
elsif ( $name && $description ) {
    check_dependencies();
    build_project($name, $description);
}
else {
    pod2usage( 
        -msg     => "Missing required args or there is a wrong number of them",
        -verbose => 1,
    );
}

sub check_dependencies {
    foreach ( 'git', 'vim' ) {
        can_run($_) or die "$_: is missing";
    }
}

sub build_project {
    my ( $name, $description ) = @_;

    my $project = "$ENV{HOME}/proyectos/$name";
    my $lib     = "$project/lib";
    my $test    = "$project/t";
    my $script  = "$project/$name.pl";
    my $module  = "$project/lib/$name.pm";
    my $readme  = "$project/README.md";
    my $licence = "$project/LICENCE";
    my $git     = "$project/.gitignore";

    print "$project - $description\n\n";

    if ( -d $project ) {
        die "The project already exists: $project";
    }
    else {
        new_dir($_)  for ( $project, $lib, $test );
        new_file($_) for ( $script, $module, $readme, $licence, $git );
    
        chmod 0775, $script;
        system 'git', 'init', $project;
        exec 'vim', $script;
    }
}

sub new_dir {
    my $dir = shift;
    mkdir $dir unless -d $dir;
}

sub new_file {
    my $full_path = shift;

    my @ext = qw/ pl pm md pl6 pm6 /;
    my ( $full_name, undef, $suffix ) = fileparse($full_path, @ext);
    $full_name =~ s/\.$//g;

    my $template;
    for ( $suffix ) {
        when ( $suffix =~ /[pl|pl6]$/ ) {
            $template = use_template({
                    script_name => $full_name, 
                    module_name => ucfirst($full_name),
                    template    => 'pl',
            });
        }
        when ( $suffix =~ /[pm|pm6]$/ ) {
            $template = use_template({
                    module_name => ucfirst($full_name),
                    template    => 'pm',
            });
            $full_path = dirname($full_path) . "/" . ucfirst($full_name) . "." . $suffix;
        }
        when ( $full_name =~ 'LICENCE' ) {
            $template = use_template({
                    template    => 'lic',
            });
        }
        when ( $full_name =~ '.gitignore' ) {
            $template = use_template({
                    template    => 'git',
            });
        }
        when ( $full_name =~ 'README' ) {
            $template = use_template({
                    script_name => $full_name,
                    template    => 'md',
            });
        }
        default {
            croak "Unknown «$full_name»";
        }
    }
    print "$full_path\n";
    save_template($full_path, $template->$*);
}

sub save_template {
    my ( $name, $data ) = @_;

    unless ( -f $name ) {
        #binmode STDOUT, ':encoding(utf-8)';
        open my $fh, '>>', $name;
        print $fh $data;
        close $fh;
    }
}

sub use_template {
    my $args = shift;

    my $script_name = $args->%{script_name} // 'meh';
    my $module_name = $args->%{module_name} // 'Meh';
    my $template    = $args->%{template};

    my $year = strftime "%Y", localtime;

    my %templates = (
        pl => 
              <<~END
              #!/usr/bin/env perl
              #
              # $script_name - $description.
              #

              use strict;
              use warnings;

              #use utf8::all;
              #use autodie;
              #use diagnostics;
              #use Data::Dumper::Names;

              use Getopt::Long 'GetOptions';
              use Pod::Usage   'pod2usage';

              use lib 'lib';
              use $module_name;

              GetOptions(
                  'help|?' => \\(my \$help),
                  'man'    => \\(my \$man),
              ) or die "Unkown command line option!";

              if (\$help) {
                  pod2usage( -verbose => 1 );
              }
              elsif (\$man) {
                  pod2usage( -verbose => 2 );
              }
              else {
                  pod2usage(
                      -msg     => "Missing required args or there is a wrong number of them",
                      -verbose => 1,
                  );
              }

              __END__

              =pod
              
              =head1 NAME
              
              $script_name - $description.
              
              =head1 SYNOPSIS
              
                  Options
                      --help    Show help.
                      --man     More help. 
              
              =head1 EXAMPLES

              =head1 LICENSE
              
              MIT License
              
              =head1 AUTHOR
              
              clasclin - clasclin\@gmail.com
              
              =head1 BUGS
              
              It is perfect, no bugs haha.
              
              =cut

              END
        ,
        pm =>
              <<~END
              package $module_name;

              use strict;
              use warnings;
              use Exporter 'import';

              our \@EXPORT_OK   = qw( );
              our \%EXPORT_TAGS = ( all => \\\@EXPORT_OK );

              1;

              END
        ,
        md =>
              <<~END
              ## NAME

              $script_name - $description

              ## SYNOPSIS

              ## DESCRIPTION

              ## EXAMPLES

              ## AUTHOR

              Cristian Sanabria (clasclin)

              ## BUGS

              ## SEE ALSO

              END
        ,
        git =>
              <<~'END'
              lib/.precomp/*
              !lib
              *swp
              .precomp/*
              END
        ,
        lic => 
              <<~END
              MIT License

              Copyright (c) $year clasclin

              Permission is hereby granted, free of charge, to any person obtaining a copy
              of this software and associated documentation files (the "Software"), to deal
              in the Software without restriction, including without limitation the rights
              to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
              copies of the Software, and to permit persons to whom the Software is
              furnished to do so, subject to the following conditions:

              The above copyright notice and this permission notice shall be included in all
              copies or substantial portions of the Software.

              THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
              IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
              FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
              AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
              LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
              OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
              SOFTWARE.
              END
        ,
    );

    return \$templates{$template};
}

__END__

=pod

=head1 NAME

new-proyect - create the necesary files and directories for a given proyect

=head1 SYNOPSIS

    Options
        --help          Show help. 
        --man           More help.
        --project-name  Name for the proyect.
        --description   A brief description of the project.

=head1 EXAMPLES

The name of the project and a description are required, otherwise a error
will be raised

new-project.pl --project-name meh --description 'Meh is used as a template'

=head1 LICENSE

MIT License

=head1 AUTHOR

clasclin - clasclin@gmail.com

=head1 BUGS

It's perfect, no bugs haha.

=cut

