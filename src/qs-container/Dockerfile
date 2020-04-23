FROM ubuntu:19.10

RUN apt update -y \
&& apt install build-essential git cmake sudo -y \
&& git clone https://github.com/eschkufz/cascade.git \
&& cd cascade \
&& ./setup --silent \
&& export SUDO_FORCE_REMOVE=yes \
&& apt remove sudo -y \
&& apt remove cmake -y \
&& apt remove git -y \
&& apt remove build-essential -y \
&& apt autoremove -y \
&& apt clean -y

RUN mkdir quartus

VOLUME quartus
