#!/bin/bash

projects=(build-openshift build-openshift-pre-prod)

for project in $projects: do
    oc new-project $project
done

oc project build-openshift
oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=docker/openstack-jenkins-slave/
oc policy add-role-to-user edit system:serviceaccount:build-openshift:jenkins -n build-openshift-pre-prod
oc new-build https://github.com/charliejllewellyn/openshift-jenkins-pipeline.git --context-dir=jenkins-pipelines/openstack/
