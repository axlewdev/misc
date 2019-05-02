package Theapp::Schema::Result::Order;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table('orders');

__PACKAGE__->add_columns(
    id => { 
        data_type => 'integer',
        is_nullable => 0,
        is_auto_increment => 1
    },
    desc => { 
        data_type => 'varchar', 
        is_nullable => 1 
    },
    customer => {}
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to('customer' => 'Theapp::Schema::Result::Customer');
 
1;