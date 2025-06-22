# Infrastructure as Code (IaaC) - Terraform Projekte

Dieses Repository enthält zwei verschiedene Versionen von Infrastructure as Code (IaaC) Projekten, die mit Terraform für Microsoft Azure entwickelt wurden.

## Projektstruktur

```
Abgabe/
├── IaaC_v3/          # Version 3 - Mit Load Balancer
└── IaaC_v5/          # Version 5 - Ohne Load Balancer
```

## Versionen im Vergleich

### IaaC_v3 - Mit Load Balancer
- **Hauptmerkmal**: Enthält einen Azure Load Balancer für Lastverteilung
- **Komponenten**:
  - Resource Group
  - Netzwerk (VNet, Subnets, VPN Gateway)
  - Virtual Machines
  - **Load Balancer** (für Traffic Distribution)
  - Security (Network Security Groups)
  - File Share

### IaaC_v5 - Ohne Load Balancer
- **Hauptmerkmal**: Vereinfachte Architektur ohne Load Balancer
- **Komponenten**:
  - Resource Group
  - Netzwerk (VNet, Subnets, VPN Gateway)
  - Virtual Machines
  - Security (Network Security Groups)
  - File Share

## Hauptunterschiede

| Feature | IaaC_v3 | IaaC_v5 |
|---------|---------|---------|
| Load Balancer | ✅ Enthalten | ❌ Nicht enthalten |
| Traffic Distribution | ✅ Automatisch | ❌ Manuell erforderlich |
| Komplexität | Höher | Niedriger |
| Kosten | Höher (LB-Gebühren) | Niedriger |
| Skalierbarkeit | ✅ Hoch | ⚠️ Begrenzt |

## Verwendung

### Voraussetzungen
- Terraform installiert
- Azure CLI konfiguriert
- Gültige Azure-Credentials

### Deployment

Für IaaC_v3:
```bash
cd IaaC_v3
terraform init
terraform plan
terraform apply
```

Für IaaC_v5:
```bash
cd IaaC_v5
terraform init
terraform plan
terraform apply
```

## Konfiguration

Beide Versionen verwenden die gleichen Variablen in `terraform.tfvars`:
- `project_name`: Name des Projekts
- `environment`: Umgebung (dev, staging, prod)
- `location`: Azure-Region
- `vm_count`: Anzahl der VMs
- `vm_size`: VM-Größe
- `admin_username`: Administrator-Benutzername
- `admin_password`: Administrator-Passwort

## Wann welche Version verwenden?

### IaaC_v3 verwenden wenn:
- Hohe Verfügbarkeit erforderlich ist
- Traffic auf mehrere VMs verteilt werden soll
- Automatische Failover-Funktionalität benötigt wird
- Produktionsumgebungen mit hohen Anforderungen

### IaaC_v5 verwenden wenn:
- Einfache Testumgebungen benötigt werden
- Kosten minimiert werden sollen
- Keine Lastverteilung erforderlich ist
- Entwicklungsumgebungen mit geringen Anforderungen

## Sicherheitshinweise

- Passwörter sollten in einer sicheren Umgebung gespeichert werden
- VPN-Gateway-Konfiguration sollte entsprechend den Sicherheitsrichtlinien angepasst werden
- Network Security Groups sind in beiden Versionen konfiguriert

## Support

Bei Fragen oder Problemen wenden Sie sich an das Entwicklungsteam. 