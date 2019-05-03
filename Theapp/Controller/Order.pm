package Theapp::Controller::Order;
use Mojo::Base 'Mojolicious::Controller';

use Syntax::Keyword::Try;

sub create {
    my $self = shift;

    my $customer_id = $self->stash('customer_id');
    my %result;
    try {
        my $new_order = $self->schema->resultset('Customer')
                ->search({ id => $customer_id })
                    ->first
                        ->create_related(
                            orders => $self->req->json
                        );

        %result = (status => 'ok', id => $new_order->id);
    } catch {
        $self->app->log->debug("Can't create order for customer_id: $customer_id: $@");
        %result = (status => 'FAILED', error => $@);
    }

    $self->render(json => \%result);
}

sub read {
    my $self = shift;

    my $id = $self->stash('id');
    $self->app->_read($id, 'Order', $self);
}

sub delete {
    my $self = shift;

    my $id = $self->stash('id');
    $self->app->_delete($id, 'Order', $self);
}

sub update {
    my $self = shift;
    
    my $id = $self->stash('id');
    $self->app->_update($id, 'Order', $self);
}

1;