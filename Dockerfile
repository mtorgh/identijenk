FROM jenkins/jenkins:lts

USER root

RUN	apt-get update \
	&& apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common \
	&& apt-get install -y sudo \
	&& curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
	&& add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
	&& apt-get update \
	&& apt-get install -y docker-ce -y docker-ce-cli containerd.io \
	&& rm -rf /var/lib/apt/lists/*

RUN	curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
	&& chmod +x /usr/local/bin/docker-compose \
	&& ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers


USER jenkins

COPY	plugins.txt /usr/share/jenkins/plugins.txt
RUN		/usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt
