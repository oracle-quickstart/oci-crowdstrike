- become: yes
  hosts: all
  name: falcon-install
  tasks:
    - name: run echo command
      command: /bin/echo hello world
    - name: Download file with check (sha256)
      get_url:
        url: ${falcon_sensor_download_url}
        dest: /home/opc
        checksum: ${falcon_sensor_download_check_sum}
    - name: Install Falcon Sensor
      yum: name="/home/opc/${falcon_sensor_rpm_name}" disable_gpg_check=yes update_cache=yes state=latest
    - name: Set your CID
      command: sudo /opt/CrowdStrike/falconctl -s --cid=${customer_id}
      notify:
        - Restart Falcon Server
  
  handlers:
    - name: Restart Falcon Server
      service: name=falcon-sensor state=restarted enabled=yes