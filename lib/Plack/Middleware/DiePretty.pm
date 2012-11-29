package Plack::Middleware::DiePretty;
use parent 'Plack::Middleware';
use Plack::Util::Accessor qw(template);
use Try::Tiny;
use Template;
use Path::Class;

sub call {
  my ($self, $env) = @_;

  local $SIG{__DIE__} = sub { die @_; };

  my $caught;
  my $res = try { $self->app->($env); } catch { $caught = $_; [ 500, [ 'Content-Type' => 'text/plain; charset=utf-8' ], [ $caught ] ]; };

  my $template = file( $self->template || '/var/www/html/error.html' );

  if ($caught || (ref $res eq 'ARRAY' && $res->[0] == 500)) {
    Template->new({ INCLUDE_PATH => $template->dir })->process($template->basename, { caught => $caught }, \(my $html)) || die $@;
    $res = [ 500, [ 'Content-Type' => 'text/html'], [ $html ] ];
  }
  $res;
}

1;
