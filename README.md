# Docker Setup for 7 Days to Die

Run a Dedicated 7 Days to Die server on a Linx host under its own Linux
account.

These instructions include setting up a Linux user with the appropriate
permissions such that the server running in the container can appropriately
share things like the Save files and read things like the Mods. This is
necessary because of the way the default `steamcmd` server is configured and
was a good practice for me on setting up some amount of isolation between the
host and the container.

## Setup the Linux User

Create the user:

```
sudo useradd sdtd
```

Add them to the docker group, so that they can create containers:

```
sudo usermod -a -G docker sdtd
```

Switch to the user:

```
su sdtd
cd
```

## Setup the Environment

Install Git; clone this repo:

```
git clone https://github.com/jojenki/sdtd-server
```

Create the directories:

```
mkdir Save
mkdir Mods
```

Edit the `serverconfig.xml` file, specifically **be sure to set a password if
desired.**

IMPORTANT: At some point, you will need to do a 1-time setup of port
forwarding on your router. I recommend making sure your local computer can
connect to your local server first and that all of the desired administration
settings are good to go before opening up the ports.

## Run the Server

Set the `UID_V` and `GID_V` values; these are your new user's UID and GID and
will make sure that the resulting container runs as your Linux user and that
the files in the container that are owned by the `steam` container user are
accessible to your Linux user:

```
export UID_V=$(id -u)
export GID_V=$(id -g)
```

Start the server:

```
docker compose up -d
```

## Setup Administrator Priviledges

If this is the first time running the server, it will populate the `Save/`
directory with several files and folders, including a `serveradmin.xml` file.

1. Make sure the save files have been created by starting the server and
connecting to it with any computer for the first time.
2. Stop the server.
3. Edit the `serveradmin.xml` file in the `Save/` directory.
4. Start the server.

## Stop the Server

```
docker compose down sdtd-server-1
```

## Update the Server

The save files are in the `Save/` directory, so we can safely destroy the old
container and create a new one:

```
docker compose down sdtd-server-1
docker container rm sdtd-server-1
docker image rm sdtd-server
docker compose up -d --build --force-recreate
```
