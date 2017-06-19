# PostgreSQL Dockerfile

This is just a quick Dockerfile you can use to build a container for Postgres. Run `docker build` with cmd.sh in the same folder as the Dockerfile and you're good to go!

Of course, this wouldn't be complete without some environment variables you could set for Postgres. You can optionally pass in one or more, with `docker run -e`.

Variable|Default|Purpose
--------|-------|-------
POSTGRES\_USERNAME|root|Set the name of the created Postgres role
POSTGRES\_PASSWORD||Set the password of the created Postgres role
POSTGRES\_LISTEN\_ADDRESS|0.0.0.0/0|Sets the address that Postgres listens on
POSTGRES\_LISTEN\_PORT|5432|Sets the port that Postgres listens on. Note that you will still have to use -p in `docker run`


