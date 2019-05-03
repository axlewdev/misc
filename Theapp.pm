package Theapp;
use Mojo::Base 'Mojolicious';

use Cwd;
use FindBin;
use lib $FindBin::Bin;
use Theapp::Schema;
use Syntax::Keyword::Try;

# It is DB deploy on the fly.
my $cwd = cwd;
my $db_file = "$cwd/theapp_population.db";
`$cwd/db_populate.pl $db_file`; # populate db
my $schema = Theapp::Schema->connect('dbi:SQLite:' . $db_file);

sub startup {
    my $self = shift;

    $self->helper(
        schema => sub {
            Theapp::Schema->connect('dbi:SQLite:' . $db_file)
        });

    my $r = $self->routes;
    $r->get('/customers/:field/:value')->to('customer#find_customer');
    $r->get('/customers')->to('customer#customers_list');
    $r->post('/customers')->to('customer#create');
    $r->delete('/customers/:id')->to('customer#delete');
    $r->patch('/customers/:id')->to('customer#update');

    # Order routes
    $r->post('/orders/customer/:customer_id')->to('order#create');
    $r->patch('/orders/:id')->to('order#update');
    $r->delete('/orders/:id')->to('order#delete');
    $r->get('/orders/:id')->to('order#read');
}

# The methods below should be placed at Controller.pm

sub _read {
    my $self = shift;
    my ($id, $class, $c) = @_;

    my %result;
    try {
        my $item = $schema->resultset($class)
                    ->search({ id => $id })->first;

        if ($item) {
            %result = (
                status => 'ok',
                order => { 
                    $item->get_columns
                }
            );   
        } else {
            %result = (
                status => 'ok',
                order => undef
            );
        }
    } catch {
        $c->app->log->debug("Can't read $class id: $id: $@");
        %result = (status => 'FAILED', error => $@);
    }

    return $c->render(json => \%result);
}

sub _delete {
    my $self = shift;
    my ($id, $class, $c) = @_;

    my %result;
    try {
        my $item = $schema->resultset($class)->search({ id => $id })->first;

        if ($item) {
            $item->delete;
            %result = (status => 'ok');
        } else {
            die "No such $class, id: $id";
        }
    } catch {
        $c->app->log->debug("Can't delete $class id: $id: $@");
        %result = (status => 'FAILED', error => $@);
    }

    return $c->render(json => \%result);
}

sub _update {
    my $self = shift;
    my ($id, $class, $c) = @_;

    my %result;
    try {
        my $customer = $schema->resultset($class)
            ->search({ id => $id })->first;
        if ($customer) {
            $customer->update($c->req->json);
            
            %result = (status => 'ok');
        } else {
            die "No such customer $class, id: $id";
        }
    } catch {
        $c->app->log->debug("Can't update $class id: $id: $@");
        %result = (status => 'FAILED', error => $@);
    }

    return $c->render(json => \%result);
}

1;