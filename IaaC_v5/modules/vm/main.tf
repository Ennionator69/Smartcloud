locals {
  cloud_init = <<-EOT
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - apt-transport-https
      - ca-certificates
      - curl
      - software-properties-common
      - gnupg
      - lsb-release
      - ufw

    write_files:
      - path: /root/startup.sh
        permissions: '0755'
        content: |
          #!/bin/bash
          
          # Datum und Uhrzeit für die Logs
          TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
          LOG_FILE="/root/container_status.log"
          
          # Log-Funktion
          log_message() {
            echo "[$TIMESTAMP] $1" | tee -a $LOG_FILE
          }
          
          log_message "========== Container-Prüfung gestartet =========="
          
          # Install Docker if not already installed
          if ! command -v docker &> /dev/null; then
            log_message "Installing Docker..."
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
            systemctl enable docker
            systemctl start docker
            log_message "Docker wurde installiert."
          else
            log_message "Docker ist bereits installiert."
          fi
          
          # Überprüfen und starten der Container
          log_message "Überprüfe und starte Docker-Container..."
          
          # Datenverzeichnis für Vaultwarden erstellen
          mkdir -p /vw-data
          
          # Funktion zum Starten oder Neustarten eines Containers
          start_container() {
            local name=$1
            local command=$2
            
            log_message "Überprüfe Container $name..."
            
            # Prüfen, ob der Container läuft
            if [ ! "$(docker ps -q -f name=$name)" ]; then
              # Prüfen, ob der Container existiert aber nicht läuft
              if [ "$(docker ps -a -q -f name=$name)" ]; then
                log_message "$name existiert, läuft aber nicht. Entferne alten Container..."
                docker rm -f $name
              fi
              
              # Container erstellen und starten
              log_message "Starte Container $name..."
              eval $command
              if [ $? -eq 0 ]; then
                log_message "$name wurde erfolgreich gestartet."
              else
                log_message "FEHLER: $name konnte nicht gestartet werden."
              fi
            else
              log_message "$name läuft bereits."
            fi
          }
          
          # Container mit den vorgegebenen Befehlen starten
          start_container "nextcloud" "docker run -d --name nextcloud --restart always -p 8081:80 nextcloud:latest"
          start_container "vaultwarden" "docker run -d --name vaultwarden --restart always -p 8080:80 -p 3012:3012 -v /vw-data/:/data/ -e WEBSOCKET_ENABLED=true vaultwarden/server:latest"
          start_container "stirlingpdf" "docker run -d --name stirlingpdf --restart always -p 8082:8080 stirlingtools/stirling-pdf:latest"
          
          # Verify containers are running
          log_message "Aktueller Container-Status:"
          docker ps -a >> $LOG_FILE
          
          # Zusammenfassung erstellen
          RUNNING_COUNT=$(docker ps -q | wc -l)
          TOTAL_COUNT=$(docker ps -a -q | wc -l)
          
          log_message "Zusammenfassung: $RUNNING_COUNT von $TOTAL_COUNT Containern laufen."
          log_message "========== Container-Prüfung abgeschlossen =========="

    runcmd:
      # Configure firewall
      - ufw allow 22/tcp
      - ufw allow 8080/tcp
      - ufw allow 8081/tcp
      - ufw allow 8082/tcp
      - ufw allow 3012/tcp
      - ufw allow 8443/tcp
      - ufw --force enable
      
      # Install Docker
      - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
      - apt-get update
      - apt-get install -y docker-ce docker-ce-cli containerd.io
      - systemctl enable docker
      - systemctl start docker
      
      # Execute startup script to pull images and run containers
      - bash /root/startup.sh > /root/startup.log 2>&1
      
      # Add a cron job to ensure containers are running at boot
      - echo "@reboot root bash /root/startup.sh > /root/startup.log 2>&1" > /etc/cron.d/docker-startup
  EOT
}

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${lower(var.project_name)}-nic-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Verknüpfung der Netzwerkschnittstellen mit der Netzwerksicherheitsgruppe
resource "azurerm_network_interface_security_group_association" "main" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.main[count.index].id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_linux_virtual_machine" "main" {
  count               = var.vm_count
  name                = "${lower(var.project_name)}-vm-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.main[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(local.cloud_init)

  tags = var.tags
} 