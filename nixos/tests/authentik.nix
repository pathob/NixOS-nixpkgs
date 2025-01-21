{
  lib,
  ...
}:

let
  port = 9000;
in

{
  name = "authentik";
  meta.maintainers = with lib.maintainers; [ pathob ];

  nodes.machine =
    {
      pkgs,
      ...
    }:

    {
      services.authentik = {
        enable = true;
        secretKey = "verysecretkey";
        postgresql.createLocally = true;
        redis.createLocally = true;
        listen.http.port = port;
      };
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("authentik.service")
    machine.wait_for_open_port(${port})
    machine.succeed("curl --fail http://localhost:${port}")
  '';
}
