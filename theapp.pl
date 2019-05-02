#!/usr/bin/env perl
use Mojolicious::Lite;

use FindBin;
use lib $FindBin::Bin;

use Syntax::Keyword::Try;
use Theapp::Schema;

my $db_file = '/home/lew/theapp.db';
unlink $db_file if -e $db_file;
my $schema = Theapp::Schema->connect('dbi:SQLite:' . $db_file);
$schema->deploy;

get '/customers/:field/:value' => sub {
    my $c = shift;
    my ($field, $value) = map { $c->stash($_) } qw/field value/;

    my (%result);
    try {
        my %customer = $schema->resultset('Customer')->search(
            { $field => $value })->first->get_columns;
        %result = (status => 'ok', customer => \%customer);
    } catch {
        $c->app->log->debug("Can't get find: $field $value: $@");
        %result = (status => 'FAILED', error => $@);
    }

    $c->render(json => \%result);
};

get '/customers' => sub {
    my $c = shift;

    my (@customers, %result);
    try {
        $result{customers} = [ 
            map { 
                { 
                    $_->get_columns
                } 
            } $schema->resultset('Customer')->all
        ];
        $result{status} = 'ok';
    } catch {
        $c->app->log->debug("Can't get customers: $@");
        %result = (status => 'FAILED', error => $@);
    }

    $c->render(json => \%result);
};

post '/customers' => sub {
    my $c = shift;

    my ($new_customer, %result);
    try {
        $new_customer = $schema->resultset('Customer')->create($c->req->json);
        %result = (status => 'ok', id => $new_customer->id);
    } catch {
        $c->app->log->debug("Can't create customer: $@");
        %result = (status => 'FAILED', error => $@);
    }

    $c->render(json => \%result);
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
