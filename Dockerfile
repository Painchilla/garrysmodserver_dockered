#Use Debian Stretch-slim as base
FROM debian:stretch-slim

#Set Frontend to noninteractive to stop some errors
ENV DEBIAN_FRONTEND noninteractiv

##Update Packages and install 32bit gcc, wget and htop.
RUN apt-get update \
    && apt upgrade -y \
    && dpkg --add-architecture i386 \
    && apt-get install -y lib32gcc1 wget htop lib32stdc++6 \
    && apt autoclean \
    && rm -r /var/cache/apt
    
##Setup Steam User 
RUN apt install sudo && \
    export uid=1001 gid=1001 && \
    mkdir -p /home/steam && \
    echo "steam:x:${uid}:${gid}:steam,,,:/home/steam:/bin/bash" >> /etc/passwd &&\
    echo "steam:x:${uid}:" >> /etc/group && \
    echo "steam ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/steam && \
    chmod 0440 /etc/sudoers.d/steam && \
    chown ${uid}:${gid} -R /home/steam && \
    chown ${uid}:${gid} -R /srv && \
    apt autoclean && \
    apt autoremove && \
    rm -rf /var/chache/apt
    


##Install SteamCMD
RUN mkdir /usr/local/steam \
    && cd /usr/local/steam \
    && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xzf steamcmd_linux.tar.gz

#Copy Entrypoint-script into container
COPY entrypoint.sh /usr/bin/

#COPY Server.cfg and mount.cfg
COPY *.cfg /srv/gmod/cfg/

##Install Garrysmod
RUN /usr/local/steam/steamcmd.sh \
        +login anonymous \
        +force_install_dir /srv/gmod +app_update 4020 \
	    +force_install_dir /srv/content +app_update 232330 \
        +quit && \
	chown steam:steam /srv -R && \
	chmod +x /usr/bin/entrypoint.sh

#Expose all needed ports
EXPOSE 27015/udp
EXPOSE 27015/tcp

#Setup Volumes to store Steam Workshop-Content over Restarts
VOLUME /srv/gmod/steam_cache
VOLUME /srv/gmod/garrysmod/cache

##CHANGE USER to steam
USER steam
ENV HOME /home/steam
ENV GMOD_MAP gm_construct
ENV GMOD_MAX_PLAYERS 16
ENV GMOD_GAMEMODE sandbox
ENV GMOD_WORKSHOP_COLLECTION false
ENV STEAM_APIKEY false
ENV DEBUG false


#Start Gmod server
#The Entrypoint ensures that the GMod-Server listens on all IP's not just on the Dockercontainers internal address
ENTRYPOINT ["/usr/bin/entrypoint.sh"]