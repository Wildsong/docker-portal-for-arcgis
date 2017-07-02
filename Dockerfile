From geoceg/ubuntu-server:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-06-27

# Create the user/group who will own the portal server
# I set them to my own UID/GID so that the VOLUMES will be read/write
RUN groupadd -g 1000 arcgis && \
    useradd -m -r arcgis -g arcgis -u 1000

# Port information: http://server.arcgis.com/en/portal/latest/install/windows/ports-used-by-portal-for-arcgis.htm
EXPOSE 7080 7443

ADD limits.conf /etc/security/limits.conf

ENV HOME=/home/arcgis

# Put your license file and a downloaded copy of the server software
# in the same folder as this Dockerfile
ADD *.prvc /home/arcgis
# "ADD" knows how to unpack the tar file directly into the docker image.
ADD Portal_for_ArcGIS_Linux_10*.tar.gz /home/arcgis
# Change owner so that user "arcgis" can remove installer later.
RUN chown -R arcgis:arcgis $HOME

USER arcgis

# Run the ESRI installer script as user 'arcgis' with these options:
#   -m silent         silent mode: don't pop up windows, we don't have a screen anyway
#   -l yes            You agree to the License Agreement
#   -a license_file   Use "license_file" to add your license. It can be a .ecp or .prvc file.
#   -d dest_dir       Default is /home/arcgis/arcgis/portal
RUN cd $HOME/PortalForArcGIS && \
    ./Setup -m silent --verbose -l yes -a $HOME/*.prvc -d $HOME
RUN rm -rf $HOME/PortalForArcGIS

# Persist Portal for ArcGIS's data on the host's file system.
# Make sure these are writable by arcgis user.
VOLUME [ "$HOME/portal/usr/arcgisportal/content" ]

# Start in the arcgis user's home directory.
WORKDIR ${HOME}

CMD cd portal && ./startportal.sh && tail -f usr/arcgisportal/logs/service.log
