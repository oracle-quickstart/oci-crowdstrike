Host *
  IgnoreUnknown UseKeychain
  StrictHostKeyChecking no
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ${private_key_path}
  UserKnownHostsFile=/dev/null

Host ${destination_private_ip}
  User ${destination_ssh_user}
  HostName ${destination_private_ip}
  Port 22
  ProxyJump ${bastion_username}@${bastion_hostname}
  LocalForward 2242 localhost:22