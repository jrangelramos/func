FROM registry.access.redhat.com/ubi9/ubi

ARG OCP_VERSION=4.16
ARG GOLANG_VERSION=1.22.4

# Install the oc and kubectl clients
RUN curl -LO https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/candidate-${OCP_VERSION}/openshift-client-linux.tar.gz \
    && tar -xzf openshift-client-linux.tar.gz \
    && chmod +x oc kubectl \
    && mv oc kubectl /usr/local/bin \
    && rm openshift-client-linux.tar.gz

# Install go
RUN curl -L https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz -o go.tar.gz \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

# Reset the goflags to avoid the -mod=vendor flag
ENV GOFLAGS=''
