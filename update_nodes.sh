#!/bin/bash

# script to automate updating the "jenkins" repository
# which contains our build script and list of build targets

# define our servers
CHEESECAKE="5.9.122.72"
CUPCAKE="176.9.50.101"
MASTER="144.76.14.135"

# variable definition
USERNAME=jenkins
HOSTS="${MASTER} ${CHEESECAKE} ${CUPCAKE}"
KEY_FILE="/var/lib/jenkins/.ssh/common"

# function to update the git repository from upstream
update_git() {
	cd /home/build/jenkins-android-6.0
	git fetch origin
	git clean -fd
	git reset --hard remotes/origin/android-6.0
}

# update the slaves over ssh
for HOSTNAME in ${HOSTS}; do
	ssh -i ${KEY_FILE} -l ${USERNAME} ${HOSTNAME} "$(typeset -f); update_git" || ssh -i ${KEY_FILE} -l ${USERNAME} localhost "$(typeset -f); update_git"
done
