#!/bin/bash

echo 'Please enter the password for the openstack CI user (openshift@ukcloud.com)'
read password

projects=(build-openshift build-openshift-pre-prod)

for project in $projects: do
    oc new-project $project
done

oc project build-openshift
oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=docker/openstack-jenkins-slave/
oc policy add-role-to-user edit system:serviceaccount:build-openshift:jenkins -n build-openshift-pre-prod
oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=jenkins-pipelines/openstack/
oc create -f openstack_params.yaml

oc create secret generic openstack --from-literal=username=openshift@ukcloud.com --from-literal=password=$password

oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=jenkins-pipelines/openshift/ --name=openshift-build
