use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Theapp');

$t->get_ok("/customers")->status_is(200)->json_is({
    "customers" => [
        {"id" => 1,"name" => "Boris"},
        {"id" => 2,"name" => "James"}
    ],
    "status" => "ok"
});

$t->post_ok("/customers" => {Accept => '*/*'} => json => {name => 'TestCustomer'})
    ->status_is(200)
    ->json_like('/id' => qr/^\d+/);

$t->post_ok("/customers" => {Accept => '*/*'} => json => {name => 'TestCustomer'})
    ->status_is(200)
    ->json_is('/status' => 'FAILED')
    ->json_like('/error' => qr/UNIQUE constraint failed/);

done_testing();
