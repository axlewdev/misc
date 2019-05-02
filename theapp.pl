use Mojolicious::Lite;

use Cwd;
use FindBin;
use lib $FindBin::Bin;
use Syntax::Keyword::Try;
use Theapp::Schema;

# It is DB deploy on the fly.
my $cwd = cwd;
my $db_file = "$cwd/theapp_population.db";
`$cwd/db_populate.pl $db_file`;
my $schema = Theapp::Schema->connect('dbi:SQLite:' . $db_file);
#$schema->deploy;

### Customer

# Find customer by "id" or "name" 
get '/customers/:field/:value' => sub {
    my $c = shift;
    my ($field, $value) = map { $c->stash($_) } qw/field value/;

    my %result;
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

# List of customers
get '/customers' => sub {
    my $c = shift;

    my %result;
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

# Create customer
post '/customers' => sub {
    my $c = shift;

    my %result;
    try {
        my $new_customer = $schema->resultset('Customer')
            ->create($c->req->json);
        
        %result = (status => 'ok', id => $new_customer->id);
    } catch {
        $c->app->log->debug("Can't create customer: $@");
        %result = (status => 'FAILED', error => $@);
    }

    $c->render(json => \%result);
};

# Delete customer
del '/customers/:id' => sub {
    my $c = shift;

    my $id = $c->stash('id');
    _delete($id, 'Customer', $c);
};

# Update customer
patch '/customers/:id' => sub {
    my $c = shift;
    
    my $id = $c->stash('id');
    _update($id, 'Customer', $c);
};

### Order

# Create order, get customer orders
any ['GET', 'POST'] => '/orders/customer/:customer_id' => sub {
    my $c = shift;

    my $req_method = $c->req->method;
    my $customer_id = $c->stash('customer_id');
    my %result;
    try {
        if ($req_method eq 'POST') {
            my $new_order = $schema->resultset('Customer')
                ->search({ id => $customer_id })
                    ->first
                        ->create_related(
                            orders => $c->req->json
                        );

            %result = (status => 'ok', id => $new_order->id);
        
        } elsif ($req_method eq 'GET') {
            $result{orders} = [
                map { { $_->get_columns } } $schema->resultset('Customer')
                    ->search({ id => $customer_id })
                        ->first->orders
            ];
        
            $result{status} = 'ok';
        
        } 
    } catch {
        $c->app->log->debug("Can't create order for customer_id: $customer_id: $@")
            if $req_method eq 'POST';
        $c->app->log->debug("Can't get customer orders for customer_id: $customer_id: $@")
            if $req_method eq 'POST';

        %result = (status => 'FAILED', error => $@);
    }

    $c->render(json => \%result);
};

# Update order
patch '/orders/id/:id' => sub {
    my $c = shift;

    my $id = $c->stash('id');
    _update($id, 'Order', $c);
};

# Delete, read order
any ['DELETE', 'GET'] => '/orders/id/:id' => sub {
    my $c = shift;

    my $id = $c->stash('id');
    my $req_method = $c->req->method;
    if ($req_method eq 'DELETE') {
        _delete($id, 'Order', $c);
    } else {
        _read($id, 'Order', $c);
    }
    
};

sub _read {
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
    my ($id, $class, $c) = @_;

    my %result;
    try {
        $schema->resultset($class)->search({ id => $id })->delete_all;

        %result = (status => 'ok');
    } catch {
        $c->app->log->debug("Can't delete $class id: $id: $@");
        %result = (status => 'FAILED', error => $@);
    }

    return $c->render(json => \%result);
}

sub _update {
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
