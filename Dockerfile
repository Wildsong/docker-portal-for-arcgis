From geo-ceg/ubuntu-server:latest

LABEL maintainer="b.wilson@geo-ceg.org"

# Create the user/group who will own the server
# I set them to my own UID/GID so that the VOLUMES will be read/write
RUN groupadd -g 1000 arcgis && useradd -m -r arcgis -g arcgis -u 1000

#EXPOSE 80

ADD limits.conf /etc/security/limits.conf

# Put your license file and a downloaded copy of the server software
# in the same folder as this Dockerfile
ADD *.prvc /home/arcgis
# "ADD" knows how to unpack the tar file directly into the docker image.
ADD Portal_for_ArcGIS_Linux_105_*.tar.gz /home/arcgis
# Change owner so that arcgis can rm later.
RUN chown -R arcgis:arcgis /home/arcgis

USER arcgis

# Run the ESRI installer script as user 'arcgis' with these options:
#   -m silent         silent mode: don't pop up windows, we don't have a screen anyway
#   -l yes            You agree to the License Agreement
#   -a license_file   Use "license_file" to add your license. It can be a .ecp or .prvc file.
#   -d dest_dir       Default is /home/arcgis/arcgis/portal
RUN cd ~/PortalForArcGIS && ./Setup -m silent --verbose -l yes -a ~/*.prvc -d ~
#RUN mkdir ~/config-store ~/directories
RUN rm -rf ~/PortalForArcGIS

# Persist Portal for ArcGIS's data on the host's file system. Make sure these are writable.
#VOLUME ["/home/arcgis/config-store", "/home/arcgis/directories"]

CMD ~/server/startserver.sh && tail -f ~/server/framework/etc/service_error.log
