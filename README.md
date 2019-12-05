# ansible_scripts

automate aws things.

First you need to install 'python3-boto' and 'python3-boto3' packages.

create 'ansible_access_key' and 'ansible_secret_key' by ansible-vault.
Read instruction in group_vars/project.ansibled.yml

## vpc

execute this command.
prompt the user for the Vault password
```
$ ansible-playbook -vvv -i hosts.inventory vpc.yml --ask-vault-pass
```

# use clear text file for vault password
```
$ ansible-playbook -vvv -i hosts.inventory vpc.yml --ask-password-file </path/to/password-file>
```

## ec2
# working now...

See Also
https://github.com/tomwwright/ansibled
fixed some...
https://medium.com/@tomwwright/automating-with-ansible-building-a-vpc-c252944d3d2e


