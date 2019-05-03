package Theapp::Controller::Customer;
use Mojo::Base 'Mojolicious::Controller';

use Syntax::Keyword::Try;

sub find_customer {
    my $self = shift;
    my ($field, $value) = map { $self->stash($_) } qw/field value/;

    my %result;
    try {
        my %customer = $self->schema->resultset('Customer')->search(
            { $field => $value })->first->get_columns;
        
        %result = (status => 'ok', customer => \%customer);
    } catch {
        $self->app->log->debug("Can't get find: $field $value: $@");
        %result = (status => 'FAILED', error => $@);
    }

    $self->render(json => \%result);
}

sub customers_list {
    my $self = shift;

    my %result;
    try {
        $result{customers} = [ 
            map { 
                { 
                    $_->get_columns
                } 
            } $self->schema->resultset('Customer')->all
        ];
        
        $result{status} = 'ok';
    } catch {
        $self->app->log->debug("Can't get customers: $@");
        %result = (status => 'FAILED', error => $@);
    }

    $self->render(json => \%result);
}

sub create {
    my $self = shift;

    my %result;
    try {
        my $new_customer = $self->schema->resultset('Customer')
            ->create($self->req->json);
        
        %result = (status => 'ok', id => $new_customer->id);
    } catch {
        $self->app->log->debug("Can't create customer: $@");
        %result = (status => 'FAILED', error => $@);
    }

    $self->render(json => \%result);
}

sub delete {
    my $self = shift;

    my $id = $self->stash('id');
    $self->app->_delete($id, 'Customer', $self);
}

sub update {
    my $self = shift;
    
    my $id = $self->stash('id');
    $self->app->_update($id, 'Customer', $self);
}

1;