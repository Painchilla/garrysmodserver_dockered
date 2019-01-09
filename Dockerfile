#Use Debian Stretch-slim as base
FROM debian:stretch-slim

##Update Packages and install 32bit gcc, wget and htop.
RUN apt-get update \
    && apt upgrade -y \
    && dpkg --add-architecture i386 \
    && apt-get install -y lib32gcc1 wget htop lib32stdc++6 \
    && apt autoclean \
    && rm -r /var/cache/apt
    

##Install SteamCMD
RUN mkdir /usr/local/steam \
    && cd /usr/local/steam \
    && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xzf steamcmd_linux.tar.gz

##Install Garrysmod
RUN mkdir /srv \
    && /usr/local/steam/steamcmd.sh \
        +login anonymous \
        +force_install_dir /srv/gmod +app_update 4020 \
	    +force_install_dir /srv/content +app_update 232330 \
        +quit

#Expose all needed ports
EXPOSE 27015/udp
EXPOSE 27015/tcp

##CHANGE USER to steam

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

USER steam
ENV HOME /home/steam


#Start Gmod server
#The Entrypoint ensures that the GMod-Server listens on all IP's not just on the Dockercontainers internal address
ENTRYPOINT ["/srv/gmod/srcds_run","-ip","0.0.0.0"]
#The CMD can be modified to run any custom commandline Options
CMD ["-game","garrysmod","+maxplayers","16","+map","gm_flatgrass"]
