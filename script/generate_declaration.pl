#!/usr/bin/perl
use strict;
use 5.010;

my $work_dir = shift @ARGV;
my @declarnations;
my @externals;
my $extern_header_file;

if ($work_dir eq "") {
    say "Please specify the work directory for makefile producing.";
    exit 1;
} else {
    $work_dir = $1 if $work_dir =~ /(\w+)\/?$/;
    $extern_header_file = "$work_dir/inc/external.h";

    &visit_workspace($work_dir);
    &generate_extern_header_file();
}

sub generate_extern_header_file {
    my @sorted = sort @externals;

    open EXTERN_HEAD, '>', $extern_header_file or
        die "Failed to create file $extern_header_file, $?\n";

    print EXTERN_HEAD "#ifndef HAVE_DEFINED_EXTERNAL_H\n";
    print EXTERN_HEAD "#define HAVE_DEFINED_EXTERNAL_H\n\n";

    foreach (@sorted) {
        print EXTERN_HEAD "$_\n";
    }

    print EXTERN_HEAD "\n#endif\n\n";

    close EXTERN_HEAD;
}

sub visit_workspace {
    my $base = shift @_;

    if ( -e -d $base) {
        opendir WORKSPACE, $base or
            die "Failed to open work directory $base, $?\n";

        my @work_list = readdir(WORKSPACE);

        foreach my $entry (@work_list) {
            chomp;
            next if $entry =~ /^\.$/;
            next if $entry =~ /^\.\.$/;
            next if $entry =~ /^inc$/;

            my $sub_dir = "$base/$entry";
            if (-e -d $sub_dir) {
                &create_submodule_declaration($sub_dir);
                &visit_workspace($sub_dir)
            }
        }

        closedir WORKSPACE;
    }
}

sub create_submodule_declaration {
    my $base_dir;
    my $module_path;

    $base_dir = shift @_;
    $base_dir =~ /\w+/ or
        die "Script DO NOT know how to make one makefile without a module name.";

    opendir SUBMODULE, $base_dir or
        die "Failed to open work directory $base_dir, $?\n";
    while (readdir(SUBMODULE)) {
        next if /^\.$/;
        next if /^\.\.$/;
        next if /\.h$/;
        next if /\.s$/;
        next if /[Mm]akefile/;

        $module_path = "$base_dir/$_";
        &filter_source_file_declaration($module_path);
    }

    &generate_submodule_header_file($base_dir);

    closedir SUBMODULE;
}

sub generate_submodule_header_file {
    if (0 != $#declarnations) {
        my $md_name = shift @_;
        my @sorted = sort @declarnations;
        my $basename = $1 if $md_name =~ /\/(\w+)$/;
        my $dec_fname = "$md_name/$basename" . "_declaration.h";
        my $macro = uc($basename . "_declaration_h");

        open DECL, '>', $dec_fname or die "$! $dec_fname";
        print DECL "#ifndef $macro\n";
        print DECL "#define $macro\n\n";

        foreach (@sorted) {
            print DECL "$_\n";
        }

        print DECL "\n#endif\n";
        close DECL;
    }

    @declarnations = undef;
}


sub filter_source_file_declaration() {
    my $filename = shift @_;
    my $body = 1;
    my $head;
    my $extern;
    my $basename = $1 if $filename =~ /\/([^\/]+)$/;

    print "    Scan     .. $basename ";

    open IMP, '<', $filename or die "$! $filename.";

    while (<IMP>) {
        chomp;
        next if /^$/;
        next if /:$/;
        next if /;$/;

        if (/^\w/) {
            $body = 0;
        } elsif (/^{/) {
            $body = 1;
        }

        if ("$body" eq "0") {
            my $real = $_;
            $real = $1 if (/^\s+(.*)/);
            $head = $head . "$real ";
        } elsif ($head){
            print ".";
            $head =~ s/\s$/;/g;
            $extern = "extern $head";
            unshift @declarnations, $head;
            unshift @externals, $extern unless $extern =~ "static";
            $head = undef;
        }
    }

    print "\n";

    close IMP;
}

