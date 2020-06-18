FROM archlinux/base
# Arch tracks changes in their package manager at the same rate as brew on mac does or at least is very close

# This should be arch to get on latest
RUN pacman -Sy --noconfirm aws-cli jq grep git awk unzip kubectl python-pip jq yq curl && \
    rm -rf /var/cache/pacman/

# Install latest terraform
RUN VERSION='0.12.26' && \
    curl -sL "https://releases.hashicorp.com/terraform/$VERSION/terraform_${VERSION}_linux_amd64.zip" -o terraform.zip && \
    unzip terraform.zip && rm terraform.zip && \
    chmod 755 /terraform && \
    mv /terraform /usr/bin/terraform

ADD *.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/*.sh && \
    chown root:root /usr/local/bin/*.sh

RUN useradd terraform && \
    mkdir /home/terraform && \
    chown terraform:terraform /home/terraform

WORKDIR /home/terraform

USER terraform

ENTRYPOINT [ "/usr/local/bin/terraform_plan.sh" ]
