FROM cm2network/steamcmd

# Update the steam UID and GID.
#   This is required to make sure the Volumes are accessible between the host
#   and the container.
#
# See the docker-compose.yml for setting the ARGs.
ARG UID_V
ARG GID_V
USER root
RUN sed -i -e "s/steam:x:1000:1000::\/home\/steam:\/bin\/sh/steam:x:$UID_V:$GID_V::\/home\/steam:\/bin\/sh/g" /etc/passwd
RUN sed -i -e "s/steam:x:1000:/steam:x:$GID_V:/g" /etc/group
# Swallow errors because some directories can't have their UID/GID changed,
# but that's ok.
RUN find / -uid 1000 -exec chown -h $UID_V {} +; exit 0
RUN find / -gid 1000 -exec chgrp -h $GID_V {} +; exit 0

# Switch to the steam user for the rest of the build.
USER steam

# Create the save directory.
# Be sure your config is updated for this SaveGameFolder.
WORKDIR "/home/steam"
RUN mkdir "GameSave"

# Install the game.
WORKDIR /home/steam/steamcmd
RUN ./steamcmd.sh +login anonymous +app_update 294420 +quit

# Copy our local serverconfig.xml into the game's path.
WORKDIR "/home/steam/Steam/steamapps/common/7 Days to Die Dedicated Server"
COPY --chown=$UID_V:$GID_V ["./serverconfig.xml", "/home/steam/Steam/steamapps/common/7 Days to Die Dedicated Server/serverconfig.xml"]

# External Ports
EXPOSE 26900
EXPOSE 26901
EXPOSE 26902
EXPOSE 26903

# Internal Admin Ports
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

# Start the server.
CMD ./startserver.sh -configfile=serverconfig.xml
