#!/usr/bin/env perl
# Copyright (C) 2013 by Brian McCloskey
#
# This file is part of term256color.
#
# term256color is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# term256color is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with term256color.  If not, see <http://www.gnu.org/licenses/>.
################################################################################
use strict;
use warnings;

if (`tput cols` < 84) {
    print "Terminal width needs to be at least 84 columns for the chart to display\n";
    print "properly. Resize your terminal and re-run the script.\n";
    exit 1;
}

my $filler = sprintf "%7s", '';
my $header;

sub fg($) {my $color = shift;return "[38;5;${color}m";}
sub bg($) {my $color = shift;return "[48;5;${color}m";}
sub end() {return "[0m";}

### Display ANSI colors
$header = sprintf "%-84s", "BASE16 CODES (000..015)";
print bg("238").fg("249").${header}.end()."\n";

foreach my $group (0, 8) {
    foreach my $row (0..2) {
        foreach my $column (0..7) {
            my $color = sprintf "%03d", ($column + $group);

            if ($row == 0 || $row == 2) {
                print bg($color).${filler}.end();
            } else {
                my $f = fg("016");
                my $label = sprintf "%-7s", "  ${color}";

                if ($column + $group == 0) {
                    $f = fg("255");
                }
                print ${f}.bg($color).${label}.end();
            }
        }

        if ($row + $group == 1) {
            print "   xterm-256-color chart\n";
        } else {
            print "\n";
        }
    }
}

print "\n";

### Display RGB colors
$header = sprintf "%-84s", "EXTENDED CODES (016..231)";
print bg("238").fg("249")."${header}".end()."\n";

my @cell;

foreach my $block (16, 93, 160) {
    foreach my $block_row (0..5) {
        foreach my $block_col (0..5) {
            my $modifier;

            if ($block == 93) {
                $modifier = $block - $block_row;
            } else {
                $modifier = $block + $block_row;
            }

            $cell[$block_col] = $modifier + (6 * $block_col);
            $cell[$block_col + 6] = $modifier + (66 -  (6 * $block_col));
        }
        foreach my $cell_row (0..2) {
            foreach my $cell_col (0..11) {
                my $color = sprintf "%03d", $cell[$cell_col];

                if ($cell_row == 0 || $cell_row == 2) {
                    print bg($color).${filler}.end();
                } else {
                    my $label = sprintf "%-7s", "  $color";
                    my $f = fg("016");

                    if ($cell_col < 2 || $cell_col > 9) {
                        $f = fg("255");
                    }
                    print ${f}.bg($color).${label}.end();
                }
            }
            print "\n";
        }
    }
    print "\n";
}

### Display Grey tones
$header = sprintf "%-84s", "GREYSCALE CODES (232..255)";
print bg("238").fg("249")."${header}".end()."\n";

foreach my $group (0, 12) {
    foreach my $row (0..2) {
        foreach my $column (0..11) {
            my $color = sprintf "%3d", (232 + $group + $column);

            if ($row == 0 || $row == 2) {
                print bg($color).${filler}.end();
            } else {
                my $f = fg("016");
                my $label = sprintf "%-7s", "  ${color}";

                if ($group == 0) {
                    $f = fg("255");
                }
                print ${f}.bg($color).${label}.end();
            }
        }

        print "\n";
    }
}

print "\n";


