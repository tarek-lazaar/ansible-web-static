# GROUP NAME FOR MY WEB SERVER
[webserver]
${instance_address}      # IP ADDRESS OF MY EC2 SERVER

[webserver:vars]
ansible_user = "ubuntu"
ansible_ssh_private_key_file = ${{ secrets.SSH_KEY }}