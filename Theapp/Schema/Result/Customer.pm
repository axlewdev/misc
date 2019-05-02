package Theapp::Schema::Result::Customer;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table('customers');

__PACKAGE__->add_columns(
    id => { 
        data_type => 'integer',
        is_nullable => 0,
        is_auto_increment => 1
    },
    name => { 
        data_type => 'varchar', 
        is_nullable => 0,
        is_indexed => 1
    }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint( ['name'] );

__PACKAGE__->has_many('orders' => 'Theapp::Schema::Result::Order');
 
1;