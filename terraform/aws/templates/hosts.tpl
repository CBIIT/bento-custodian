[all]
127.0.0.1

[bastion]
${bastion_ip}

[bastion:vars]
ansible_ssh_private_key_file=${key_path}
ansible_ssh_user=${ssh_user}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
