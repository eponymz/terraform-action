FROM archlinux/base
# Arch tracks changes in their package manager at the same rate as brew on mac does or at least is very close

# This should be arch to get on latest
RUN pacman -Sy --noconfirm aws-cli grep git awk unzip kubectl jq yq curl && \
    rm -rf /var/cache/pacman/

# Download latest terraform zip
# RUN VERSION_REGEX='terraform_[0-9]\.[0-9]{1,2}\.[0-9]{1,2}_linux.*amd64' && \
#     TF_RELEASES="https://releases.hashicorp.com/terraform/index.json" && \
#     LATEST=$(curl -s $TF_RELEASES | jq -r '.versions[].builds[].url' | egrep $VERSION_REGEX | sort -V | tail -1) && \
#     curl -sL $LATEST -o terraform.zip
#############################################################################
# TEMPORARILY HARD CODING TERRAFORM VERSION UNTIL PROPER UPGRADE CAN HAPPEN #
#############################################################################
RUN curl -sL https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip -o terraform.zip

# Unzip terraform release and move to bin path
RUN unzip terraform.zip && rm terraform.zip && \
    chmod 755 /terraform && \
    mv /terraform /usr/bin/terraform

# check the version on output for visibility as to what was installed
RUN terraform version

ADD *.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/*.sh && \
    chown root:root /usr/local/bin/*.sh

ENTRYPOINT [ "/usr/local/bin/terraform_plan.sh" ]
