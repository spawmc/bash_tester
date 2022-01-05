FROM archlinux                                                                                                                                                     
MAINTAINER spawnmc
RUN pacman -Sy git expect wget --noconfirm
RUN wget http://ccrypt.sourceforge.net/download/1.11/ccrypt-1.11.linux-x86_64.tar.gz
RUN tar -zxf ccrypt-1.11.linux-x86_64.tar.gz
RUN rm ccrypt-1.11.linux-x86_64.tar.gz
RUN mkdir -p /usr/local/ccrypt
RUN mv ccrypt-1.11.linux-x86_64 /usr/local/ccrypt/ccrypt
RUN ln -s /usr/local/ccrypt/ccrypt/ccrypt /usr/bin/ccrypt
RUN chmod +x /usr/bin/ccrypt
