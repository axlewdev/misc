#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use Theapp::Schema;

my $db_file = $ARGV[0];

unlink $db_file if -e $db_file;

my $schema = Theapp::Schema->connect('dbi:SQLite:' . $db_file);
$schema->deploy;

my $customer_rs = $schema->resultset("Customer");

$customer_rs->populate([
    {
        name => 'Boris',
        orders => [
            { desc => 'Boris order 1' },
            { desc => 'Boris order 2' }
        ]
    },
    {
        name => 'James',
        orders => [
            { desc => 'James order 1' },
            { desc => 'James order 2' }
        ]
    }
]);