#!/usr/bin/env perl

use strict;
use warnings;
use Sys::Hostname;
use Cwd;
use POSIX qw(strftime);
use Data::Dumper;

################################################################################
### -- VARIABLES --
###
my $hostname = `hostname -s`;
my %blocks;
my %blocks_default = (
    left => [
        ['user', 'host'],
        ['path'],
    ],
    right => [
        ['errorcode'],
        ['time'],
        ['load'],
    ],
);
my %skin;
my %skin_default = (
    left => [
        { fg => '236', bg => '103' },
        { fg => '253', bg => '239' },
        { fg => '244', bg => '236' },
    ],
    right => [
        { fg => '253', bg => '088' },
        { fg => '253', bg => '239' },
        { fg => '244', bg => '236' },
    ],
);
my %symbols;
{
    use utf8;
    %symbols = (
        right_full  => "",
        right_mini  => "",
        left_full   => "",
        left_mini   => "",
        lock        => "",
        branch      => "",
    );
}
my %prompt = ( left => [[]], right => [[]] );

################################################################################
### -- FUNCTIONS --
###
sub ltrim {
    my $s = shift;
    $s =~ s/^\s+//;
    return $s
}

sub rtrim {
    my $s = shift;
    $s =~ s/\s+$//;
    return $s
};

sub trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s
};

sub get_user {
    my $username = $ENV{LOGNAME} || $ENV{USER} || getpwuid($<);

    return $username;
}

sub get_host {
    my $host = $ENV{HOST} ? $ENV{HOST} : hostname;
    $host =~ s/^([^\.]*).*/$1/;
    chomp $host;

    return $host;
}

sub get_git {
    my $git_branch;

    if (-e "/usr/bin/git") {
        $git_branch = `/usr/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null`;
        chomp $git_branch;
    }

    if ($git_branch) {
        $git_branch = "$symbols{branch} $git_branch";
    }

    return $git_branch;
}

sub get_readonly {
    my $readonly = "";

    if (!-w getcwd) {
        $readonly = $symbols{lock};
    }

    return $readonly;
}

sub get_path {
    my $path = getcwd;

    return $path;
}

sub get_errorcode {
    my $code = "";

    $code = $ENV{ERRORCODE} if $ENV{ERRORCODE};

    return $code;
}

sub get_time {
    my $time_format = strftime "%H:%M:%S", localtime;

    return $time_format;
}

sub get_date {
    my $date_format = strftime "%Y-%m-%d", localtime;

    return $date_format;
}

sub get_load {
    my $load = `/usr/bin/uptime`;

    $load =~ s/.*load average: (.*)/$1/;
    chomp $load;

    return $load;
}

sub build_prompt {
    my $sub_call;
    my $idx_block = 0;
    my $idx_slice = 0;

    $prompt{length} = 0;

    ### Process sections.
    foreach my $section ('left', 'right') {
        # print "\nSECTION: $section\n\n";

        ### Process blocks within each section.
        foreach my $block (@{$blocks{$section}}) {
            # print "BLOCK $idx_block\n";
            # print "    $block\n";

            ### Process slices within each block.
            foreach my $slice (@{$block}) {
                my $info = "get_" . $slice;
                my $value = __PACKAGE__->$info;

                # print "        SLICE $idx_slice\n";
                # print "            $slice\n";

                ### Add slice separator to total length if there will be one.
                if ($section eq 'left' && $idx_slice != (scalar(@{$block})-1)) {
                    $prompt{length} += 1;
                }

                ### Store slice for block
                $prompt{$section}[$idx_block][$idx_slice] = " $value ";

                if ($section ne 'right' && trim($value)) {
                    $prompt{length} += length($prompt{$section}[$idx_block][$idx_slice]);
                }

                $idx_slice++;
            }

            ### Add left block separator to total length if there will be one.
            if ($section eq 'left' && exists $prompt{left}[$idx_block]) {
                $prompt{length} += 1;
            }

            $idx_block++;
            $idx_slice = 0;
        }
        $idx_block = 0;
    }
}

sub style_prompt {
    my $length = 0;
    my $idx_block = 0;
    my $idx_slice = 0;
    my $term_width = `tput cols`;
    my %buffer;

    chomp $term_width;

    print "\n";

    ### Process each section for display
    foreach my $section ('left', 'right') {
        ### Process the blocks
        foreach my $block (@{$prompt{$section}}) {
            %buffer = (); ### Clear the buffer for the previous block

            $buffer{bg} = "";
            $buffer{fg} = "";
            $buffer{symbol_bg} = "";
            $buffer{symbol_fg} = "";
            $buffer{end} = "[0m";

            ### Get background color for current block
            if (exists($skin{$section}[$idx_block]{bg})) {
                $buffer{bg} = "[48;5;$skin{$section}[$idx_block]{bg}m";
                $buffer{symbol_fg} = "[38;5;$skin{$section}[$idx_block]{bg}m";
            }
            ### Get foreground color for current block
            if (exists($skin{$section}[$idx_block]{fg})) {
                $buffer{fg} = "[38;5;$skin{$section}[$idx_block]{fg}m";
            }
            ### Get next block background color for use with special symbols
            if (exists($skin{$section}[$idx_block + 1]{bg}) &&
                    $idx_block != scalar(@{$prompt{$section}}) - 1) {
                $buffer{symbol_bg} = "[48;5;$skin{$section}[$idx_block + 1]{bg}m";
            }

            ### Start the block
            if ($section eq 'right' && $buffer{symbol_fg}) {
                $buffer{text} .= $buffer{symbol_fg} . $buffer{symbol_bg};
                $buffer{text} .= $symbols{right_full};
                $buffer{text} .= $buffer{end};
                $length++;
            }
            $buffer{text} .= $buffer{fg} . $buffer{bg};

            ### Process the slices
            foreach my $slice (@{$block}) {
                if (trim($slice)) {
                    if ($section eq 'right') {
                        my $total = $prompt{length} + length($slice) + $length;

                        if ($term_width > $total) {
                            $length += length($slice);
                        } else {
                            next;
                        }
                    }

                    $buffer{text} .= $slice;

                    if ($idx_slice != (scalar(@{$block}) - 1)) {
                        $buffer{text} .= $symbols{"${section}_mini"};
                        $length++ if $section eq 'right';
                    }
                } else {
                    next;
                }
                $idx_slice++;
            }

            ### Close out the block
            $buffer{text} .= $buffer{end};

            if ($section eq 'left') {
                if ($buffer{symbol_fg}) {
                    $buffer{text} .= $buffer{symbol_bg} . $buffer{symbol_fg};
                    $buffer{text} .= $symbols{left_full};
                    $buffer{text} .= $buffer{end};
                } else {
                    $prompt{length}--;
                }

                $prompt{buffer} .= $buffer{text};
            } else {
                $prompt{buffer} = $buffer{text} . $prompt{buffer};
            }

            $idx_slice = 0;
            $idx_block++;
        }

        ### Add padding so that the right section lines up
        if ($section eq 'right') {
            my $padding = $term_width - $prompt{length} - $length;

            if ($padding < 0) {
                $prompt{buffer} = "";
            } else {
                printf "%-${padding}s", "";
            }
        }

        ### Flush the prompt buffer
        print $prompt{buffer};
        $prompt{buffer} = "";

        $idx_block = 0;
    }

    print "\n\$ ";

    return;
}

sub prompt_config_error {
    print "PROMPT_CONFIG_ERROR> ";
    exit;
}

sub prompt_skin_error {
    print "PROMPT_SKIN_ERROR> ";
    exit;
}

################################################################################
### -- MAIN --
###
binmode STDOUT, ":encoding(UTF-8)";

### Load user provided prompt configuration. If configuration generates a
### warning, set prompt to PROMPT_CONFIG_ERROR>
if (defined $ENV{PROMPT_CONFIG}) {
    {
        my $config_error = \&prompt_config_error;

        $SIG{__WARN__} = $config_error;
        %blocks = eval $ENV{PROMPT_CONFIG};
    }
}

### Load user provided skin configuration. If configuration generates a
### warning, set prompt to PROMPT_SKIN_ERROR>
if (defined $ENV{PROMPT_SKIN}) {
    {
        my $skin_error = \&prompt_skin_error;

        $SIG{__WARN__} = $skin_error;
        %skin = eval $ENV{PROMPT_SKIN};
    }
}

### Verify the configuration is in the proper format.
###  HashRef[ArrayRef[ArrayRef]]
foreach my $section ('left', 'right') {
    if (!exists $blocks{$section}) {
        $blocks{$section} = $blocks_default{$section};
    }
    if (ref($blocks{$section}) eq 'ARRAY') {
        foreach my $block (@{$blocks{$section}}) {
            if (ref($block) ne 'ARRAY') {
                prompt_config_error();
            }
        }
    } else {
        prompt_config_error();
    }
}

### Verify the skin is in the proper format.
###  HashRef[ArrayRef[HashRef]]
foreach my $section ('left', 'right') {
    if (!exists $skin{$section}) {
        $skin{$section} = $skin_default{$section};
    }
    if (ref($skin{$section}) eq 'ARRAY') {
        foreach my $block (@{$skin{$section}}) {
            if (ref($block) ne 'HASH') {
                prompt_skin_error();
            }
        }
    } else {
        prompt_skin_error();
    }
}

build_prompt();

# foreach my $section ('left', 'right') {
#     print "\nSECTION: $section\n\n";
#     foreach my $block (@{$prompt{$section}}) {
#         print "    BLOCK: $block\n";
#         foreach my $slice (@{$block}) {
#             print "        SLICE: $slice\n";
#         }
#     }
# }

style_prompt();

### vim: fdm=manual
