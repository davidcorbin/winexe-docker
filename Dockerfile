# https://bitbucket.org/reevertcode/reevert-winexe-waf/src/master/BUILD

FROM debian:10 AS build

WORKDIR /build

RUN apt-get update
RUN apt-get install -y wget locales build-essential git gcc-mingw-w64 comerr-dev libpopt-dev libbsd-dev zlib1g-dev libc6-dev python3-dev libgnutls28-dev devscripts pkg-config autoconf libldap2-dev libtevent-dev libtalloc-dev libacl1-dev libpam0g-dev libarchive-dev git python python-dev
RUN apt-get clean

RUN git clone https://bitbucket.org/reevertcode/reevert-winexe-waf.git
RUN wget https://download.samba.org/pub/samba/stable/samba-4.3.13.tar.gz

WORKDIR /build/reevert-winexe-waf
RUN tar -xf ../samba-4.3.13.tar.gz && mv samba-4.3.13 samba
RUN rm -r source/smb_static
RUN cat patches/fix_smb_static.patch | patch -p1

RUN cat patches/smb2_nognutls_noaddc.patch | patch -p1
RUN cat patches/smb2_add_public_includes_samba_4.3.patch | patch -p1

RUN cat patches/fix_samba_perl.py.patch | patch -p0

WORKDIR /build/reevert-winexe-waf/source
RUN ln -s ../samba/bin/default/smb_static
RUN ./waf --samba-dir=../samba configure build

FROM debian:10-slim
WORKDIR /app
COPY --from=build /build/reevert-winexe-waf/source/build .

ENTRYPOINT [ "/app/winexe-static" ]
