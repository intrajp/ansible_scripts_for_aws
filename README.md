# ansible_scripts
#
# automate creating aws things.
#
# First you need to install 'python3-boto' and 'python3-boto3' packages.
#
## vpc
# you do this command.
# for prompting the user for the Vault password
#
$ ansible-playbook -vvv -i hosts.inventory vpc.yml --ask-vault-pass

