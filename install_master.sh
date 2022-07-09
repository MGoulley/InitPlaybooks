#!/bin/bash
# Variables:
ANSIBLE_USERNAME="ansible"
MASTER_HOSTNAME="mattous.fr"
GIT_PLAYBOOKS_REPO_URL="https://github.com/MGoulley/InitPlaybooks.git"
ANSIBLE_SUDOERS_FILE="/etc/sudoers.d/$ANSIBLE_USERNAME"
ANSIBLE_USER_HOME="/home/$ANSIBLE_USERNAME"
# Main :
echo "[INFO] Update system"
dnf -y update
echo "[INFO] Upgrade system"
dnf -y upgrade
echo "[INFO] Add Dev tools"
dnf -y groupinstall "Development Tools"
echo "[INFO] Install Epel-Repo"
dnf -y install epel-release
echo "[INFO] Install Ansible"
dnf -y install ansible
echo "[INFO] Create Ansible user"
adduser "$ANSIBLE_USERNAME"
echo "[INFO] Add password"
passwd "$ANSIBLE_USERNAME"
echo "[INFO] Generate RSA Key for Ansible"
runuser -l "$ANSIBLE_USERNAME" -c 'ssh-keygen -t rsa -b 4096'
echo "[INFO] Add Ansible user to sudoers"
echo "$ANSIBLE_USERNAME      ALL=(ALL)       NOPASSWD: ALL" > "$ANSIBLE_SUDOERS_FILE"
chmod 440 "$ANSIBLE_SUDOERS_FILE"
chown root:root "$ANSIBLE_SUDOERS_FILE"
echo "[INFO] SSH Link local machine"
runuser -l "$ANSIBLE_USERNAME" -c "ssh-copy-id $ANSIBLE_USERNAME@$MASTER_HOSTNAME"
echo "[INFO] Edit host file"
echo "[ansible-master]" > /etc/ansible/hosts
echo "$MASTER_HOSTNAME ansible_user=$ANSIBLE_USERNAME" >> /etc/ansible/hosts
echo "[INFO] Clone playbooks repository"
runuser -l "$ANSIBLE_USERNAME" -c "git clone $GIT_PLAYBOOKS_REPO_URL $ANSIBLE_USER_HOME/app/"
chown $ANSIBLE_USERNAME:$ANSIBLE_USERNAME "$ANSIBLE_USER_HOME/app/"