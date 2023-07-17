FROM fedora:latest

LABEL MAINTAINER Richard Lochner, Clone Research Corp. <lochner@clone1.com> \
      org.label-schema.name = "sftp-server" \
      org.label-schema.description = "sftp server" \
      org.label-schema.vendor = "Clone Research Corp" \
      org.label-schema.usage = "https://github.com/lochnerr/sftp-server" \
      org.label-schema.vcs-url = "https://github.com/lochnerr/sftp-server.git"

# This argument should be changed in the build.
ARG PASSWORD="xyzzy!@2345"

RUN dnf -y install --nodocs \
        openssh-server \
        procps-ng \
        passwd \
 && dnf -y clean all \
  # Empty the yum cache.
 && rm -rf /var/cache/dnf \
 && rm -rf /var/cache/yum \
 # Create a user “sftp” and group “sftp”
 && groupadd sftp \
 && useradd -ms /bin/bash -g sftp sftp \
  # Create sftp directory in home
 && mkdir -p /home/sftp/.ssh \
  # make a chroot directory for the server.  
 && mkdir -p /var/sftp/files \
  # Change ownership and mods.
 && chown sftp:sftp /home/sftp/.ssh \
 && chmod 0755 /var/sftp \
  # Generate host keys for server
 && ssh-keygen -A \
  # Set password.
 && passwd -uf sftp \
 && echo "$PASSWORD" | passwd --stdin sftp \
 && true

# Set the configuration for the
COPY 90-sftp.conf /etc/ssh/sshd_config.d/

# Expose the ssh port.
EXPOSE 22/tcp

# The persistent volume for the sftp data.
VOLUME /var/sftp

# Run the ssh daemon.
CMD ["/usr/sbin/sshd","-De"]

# Set the build labels.
# Do this last to allow build cacheing during development.
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date = $BUILD_DATE \
      org.label-schema.vcs-ref = $VCS_REF

