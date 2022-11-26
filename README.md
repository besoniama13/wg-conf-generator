# wg-conf-generator (Wireguard Configurations Generator)

A script that generates [Wireguard](https://www.wireguard.com) configuration files.

### Usage

#### [`gen.env`](gen.env)

```
PublicKey = <server_pub_key>
DNS = <dns>
Endpoint = <server_endpoint>
```

#### [`gen.sh`](gen.sh)

> `gen.sh` takes two arguments ( `name` and `ip_address`)
and
when executing the `gen.sh`, make sure that you set the `gen.env` first.
 ```sh
./gen.sh <name> <ip_address>
```

#### [`gen.users.csv`](gen.users.csv)

> The format of this file is pretty straight forward.
```
name,ip_address
```

#### [`gen.run`](gen.run)

> Make sure that you configured the `gen.users.csv` before running this script.

```sh
./gen
```
