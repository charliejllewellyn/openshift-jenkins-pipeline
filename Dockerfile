FROM openshift3/jenkins-slave-base-rhel7:latest

USER root

RUN yum install python-devel gcc -y && \
    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && \
    python get-pip.py && \
    pip install python-openstackclient

USER 1001
