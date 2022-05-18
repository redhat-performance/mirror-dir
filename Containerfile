FROM registry.fedoraproject.org/fedora-minimal

MAINTAINER Jan Hutar <jhutar@redhat.com>

WORKDIR /usr/src/app

VOLUME /usr/src/app/storage

ENV STORAGE_DIR /usr/src/app/storage

RUN INSTALL_PKGS="bash wget rdfind findutils" \
  && microdnf -y install $INSTALL_PKGS \
  && microdnf clean all

COPY mirror.sh /usr/src/app

USER 1001

CMD bash mirror.sh
