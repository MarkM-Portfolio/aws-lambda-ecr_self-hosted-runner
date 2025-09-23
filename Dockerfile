FROM alpine:3.17 AS verify

RUN apk update && apk add --no-cache curl tar xz

RUN ROOTFS=$(curl -sfOJL -w "amzn2-container-raw-2.0.20240620.0-arm64.tar.xz" "https://amazon-linux-docker-sources.s3.amazonaws.com/amzn2/2.0.20240620.0/amzn2-container-raw-2.0.20240620.0-arm64.tar.xz") \
    && echo 'f69ba26080ba8b0803484e48db8cb4a0e06be5748d2315a3dd183817f1f49d7e  amzn2-container-raw-2.0.20240620.0-arm64.tar.xz' >> /tmp/amzn2-container-raw-2.0.20240620.0-arm64.tar.xz.sha256 \
    && cat /tmp/amzn2-container-raw-2.0.20240620.0-arm64.tar.xz.sha256 \
    && sha256sum -c /tmp/amzn2-container-raw-2.0.20240620.0-arm64.tar.xz.sha256 \
    && mkdir /rootfs \
    && tar -C /rootfs --extract --file "${ROOTFS}"

FROM scratch AS root

COPY --from=verify /rootfs/ /

RUN yum -y update \
    && yum -y groupinstall "Development Tools" \
    && yum -y install gcc openssl11 openssl11-devel bzip2-devel libffi-devel \
    && yum -y install yum-utils wget zip unzip which

WORKDIR /home

# Install Python 3.12
RUN wget "https://www.python.org/ftp/python/3.12.2/Python-3.12.2.tgz" \
    && tar -xzf Python-3.12.2.tgz -C /usr/src \
    && cd /usr/src/Python-3.12.2 && ./configure --enable-optimizations \
    && make -j 8 && make altinstall && cd /home \
    && ln -s /usr/local/bin/python3.12 /usr/bin/python --force \
    && curl "https://bootstrap.pypa.io/get-pip.py" -o get-pip.py \
    && python get-pip.py \
    && rm -rf /usr/src Python-3.12.2.tgz get-pip.py

# # Install Awesume
# RUN pip install awsume \
#     && alias awsume=". awsume"

# # Install AWS CLI
# RUN curl -O "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" \
#     && unzip awscli-exe-linux-aarch64.zip \
#     && ./aws/install \
#     && rm -rf aws awscli-exe-linux-aarch64.zip

# # Install Terraform
# RUN curl -o terraform.zip "https://releases.hashicorp.com/terraform/1.9.1/terraform_1.9.1_linux_arm64.zip" \
#     && unzip terraform.zip \
#     && mv terraform /usr/local/bin \
#     && rm -rf terraform.zip LICENSE.txt

# Install Git
# RUN wget "https://www.kernel.org/pub/software/scm/git/git-2.45.2.tar.gz" \
#     && tar -xzf git-2.45.2.tar.gz \
#     && cd git-2.45.2.tar.gz \
#     && make prefix=/usr/local/git all \
#     && make prefix=/usr/local/git install \
#     && make configure && ./configure --prefix=/us \
#     && make install install-doc install-html install-info \
#     && cd /home && rm -rf git-2.45.2.tar.gz

# Auth GitHub
# RUN wget "https://github.com/cli/cli/releases/download/v2.52.0/gh_2.52.0_linux_arm64.tar.gz" \
#     && tar -xzf gh_2.52.0_linux_arm64.tar.gz \
#     && mv gh_2.52.0_linux_arm64/bin/gh /bin \
#     && rm -rf gh_2.52.0_linux_arm64 gh_2.52.0_linux_arm64.tar.gz \
#     && GET_SECRET=`aws secretsmanager get-secret-value --region eu-west-2 --secret-id github/secret | grep SecretString | awk '{print$2}' | cut -d : -f2 | tr -d '\\\"},'`

# GET_SECRET=`aws secretsmanager get-secret-value --region eu-west-2 --secret-id github/secret | grep SecretString | awk '{print$2}' | cut -d : -f2 | tr -d '\\\"},'`
# echo $GET_SECRET | gh auth login --with-token

# aws sts get-session-token --serial-number iam arn:aws:iam::040572446079:mfa/SapphireAWS --token-code code-from-token
# aws sts assume-role --role-arn arn:aws:iam::264309510997:role/github-oidc --role-session-name actionsrolesession
# aws sts assume-role --role-arn arn:aws:iam::264309510997:role/OrganizationAccountAccessRole --role-session-name actionsrolesession

# aws sts assume-role --role-arn arn:aws:iam::264309510997:user/ServiceAccountUser --role-session-name actionsrolesession
# aws sts get-session-token --serial-number iam arn:aws:iam::264309510997:user/ServiceAccountUser --role-session-name actionsrolesession

# aws sts get-session-token --serial-number arn:aws:iam::264309510997:oidc-provider/token.actions.githubusercontent.com
# aws sts assume-role --role-arn  arn:aws:iam::264309510997:oidc-provider/token.actions.githubusercontent.com --role-session-name actionsrolesessio

# aws sts get-session-token --role-arn arn:aws:iam::264309510997:oidc-provider/token.actions.githubusercontent.com

# aws sts get-session-token --role-arn  arn:aws:iam::264309510997:oidc-provider/token.actions.githubusercontent.com --role-session-name actionsrolesessio

# Configure AWS Profile - CHOICE 2
# RUN ACCT_ID=`awsume -l | grep 264309510997 | awk '{print$1}'` && awsume ${ACCT_ID} \
# || echo -e "\n[dev-automation]\nrole_arn = arn:aws:iam::264309510997:role/OrganizationAccountAccessRole\nregion = eu-west-2\nsource_profile = sapphire-payer" >> ~/.aws/config \
# && awsume dev-automation

# # after install Git = CHOICE 1
# RUN get env.SSH_PRIVATE_KEY
# RUN aws sts assume-role --role-arn arn:aws:iam::264309510997:role/github-oidc --role-session-name actionsrolesession


# Clone Repository
# RUN ls -la /root
# RUN eval `ssh-agent -s` \
#     && ssh-add ~/.ssh/ecr-lambda \
#     && git clone git@github.com:SapphireSystems/self-hosted-runner.git

EXPOSE 8080

# COPY ./github-events.py .

# Copy the application code
COPY github-events.py /var/task/github-events.py

# Set the entry point to the Lambda handler
# CMD ["python", "/var/task/github-events.py"]

# CMD ["bash", "-c", ""]
ENTRYPOINT ["/bin/bash"]
# /usr/bin/python, -m, github-events.lambda_handler

# ENTRYPOINT ["python", "/var/task/github-events.py"]
# CMD ["python", "/var/task/github-events.py"]
# CMD ["python", "github-events.py"]


# FROM node:14-alpine

# ARG APP_DIR=/home/node/epa
# RUN apk add -U tzdata
# RUN cp /usr/share/zoneinfo/Asia/Manila /etc/localtime

# WORKDIR ${APP_DIR}

# RUN mkdir -p ${APP_DIR}/app/node_modules &&\ 
#     mkdir -p ${APP_DIR}/server/node_modules &&\
#     mkdir -p ${APP_DIR}/server/assets

# COPY ./app/package*.json ${APP_DIR}/app

# COPY ./server/package*.json ${APP_DIR}/server

# RUN cd ${APP_DIR}/app; \
#     npm install; \
#     npm ci && npm cache clean --force; \
#     cd ${APP_DIR}/server; \
#     npm ci && npm cache clean --force

# COPY . ${APP_DIR}

# RUN chown -R node:node ${APP_DIR} &&\
#     apk add curl

# USER node

# EXPOSE 8080

# WORKDIR ${APP_DIR}/server

# CMD [ "npm", "run", "start" ]
# # CMD [ "tail", "-f" ] # for debug