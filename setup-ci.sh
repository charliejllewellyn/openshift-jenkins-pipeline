#!/bin/bash

echo 'Please enter the password for the openstack CI user (openshift@ukcloud.com)'
read password

NAME='openstack-jenkins-slave'
SOURCE_REPOSITORY_URL='https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git'
SOURCE_REPOSITORY_REF='master'
CONTEXT_DIR='docker/openstack-jenkins-slave/'
PIPELINE_CONTEXT_DIR='jenkins-pipelines/openstack/'


function setup_projects() {
    projects=(build-openshift build-openshift-pre-prod)
    for project in ${projects[@]}; do
        oc new-project $project
    done
    oc policy add-role-to-user edit system:serviceaccount:build-openshift:jenkins -n build-openshift-pre-prod
}

function setup_openstack_jenkins() {

    oc project build-openshift
    oc new-app -f openshift-yaml/template-openstackclient-jenkins-slave.yaml \
        -p NAME=$NAME \
        -p SOURCE_REPOSITORY_URL=$SOURCE_REPOSITORY_URL \
        -p SOURCE_REPOSITORY_REF=$SOURCE_REPOSITORY_REF \
        -p CONTEXT_DIR=$CONTEXT_DIR \
        -p PIPELINE_CONTEXT_DIR=$PIPELINE_CONTEXT_DIR
}

function setup_openshift_pipeline() {
    oc create -f openshift-yaml/openstack_params.yaml
    oc create secret generic openstack --from-literal=username=openshift@ukcloud.com --from-literal=password=$password
    oc create secret generic rhelsubscriptions --from-literal=rhel_org=6468465 --from-literal=rhel_activation_key=openshift
    oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=jenkins-pipelines/openshift/ --name=openshift-build
}

function configure_openshift_githooks() {
    # TODO: Automate webhook creation and updates via the github API
    gitHook=$(oc describe bc ${NAME}-pipeline | grep -A1 'Webhook GitHub' | grep URL | awk '{print $NF}')
    echo "Add a github webhook for the following URL to trigger automated builds of the Jenkins pipeline, $gitHook"
}

setup_projects
setup_openstack_jenkins
setup_openshift_pipeline
configure_openshift_githooks
