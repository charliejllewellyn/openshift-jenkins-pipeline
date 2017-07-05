#!/bin/bash

echo 'Please enter the password for the openstack CI user (openshift@ukcloud.com)'
read password

function setup_projects() {
    projects=(build-openshift build-openshift-pre-prod)
    for project in $projects: do
        oc new-project $project
    done
    oc policy add-role-to-user edit system:serviceaccount:build-openshift:jenkins -n build-openshift-pre-prod
}

function setup_openstack_jenkins() {
    oc project build-openshift
    oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=docker/openstack-jenkins-slave/
    oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=jenkins-pipelines/openstack/
}

function setup_openshift_pipeline() {
    oc create -f openstack_params.yaml
    oc create secret generic openstack --from-literal=username=openshift@ukcloud.com --from-literal=password=$password
    oc create secret generic rhelsubscriptions --from-literal=rhel_org=6468465 --from-literal=rhel_activation_key=openshift
    oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=jenkins-pipelines/openshift/ --name=openshift-build
}

function configure_openshift_githooks() {
    # TODO: Automate webhook creation and updates via the github API
    gitHook=$(oc describe bc hopeful | grep -A1 'Webhook GitHub' | grep URL | awk '{print $NF}')
    echo "Add a github webhook for the following URL to trigger automated builds of the Jenkins pipeline, $gitHook"
}

setup_projects
setup_openstack_jenkins
setup_openshift_pipeline
configure_openshift_githooks
