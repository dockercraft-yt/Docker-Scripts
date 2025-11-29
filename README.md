[Deutsch](./README_DE.md) | [English](./README.md)

# 🐳 Docker-Scripts

This repository contains a collection of useful shell scripts for Docker containers, their management and backup processes.  
All scripts were created to automate recurring tasks and simplify container administration.

---

## 📂 Directory structure

```
Docker-Scripts/
│
├── Docker/
│   ├── Docker Container Backup/      # Backup of container data and volumes
│   ├── Docker Container Restore/     # Restore backups
│   ├── Docker Installer/             # Installs Docker, Docker Compose and a user
│   ├── Docker Volume Cleaner/        # Removes unused Docker volumes
│   └── Docker Image Cleaner/         # Removes unused Docker images
│
├── paperless-ngx/             # Backup script for Paperless-ngx
└── vaultwarden/               # Backup script for Vaultwarden

```

---

## ⚙️ Content & Features

### 🧱 Docker
Contains generic scripts for Docker management:

| Folder | Description |
|--------|-------------|
| **Docker Container Backup** | Creates automated backups of container data, including volumes. |
| **Docker Container Restore** | Restores backups from the backup directory. |
| **Docker Image Cleaner** | Cleans up unused images to free disk space. |
| **Docker Installer** | Installs Docker, Docker Compose and creates a "docker" user in the "docker" group. |
| **Docker Volume Cleaner** | Removes unused Docker volumes that unnecessarily consume disk space. |

Each subfolder contains its own `README.md` with usage details.

---

### 📦 Paperless-NGX
Script for automated backup of the **Paperless-NGX** Docker instance (document management system).  
Includes backup of the database and document directory.

📄 [More info in `paperless-ngx/README.md`](./paperless-ngx/README.md)

---

### 🔐 Vaultwarden
Script for **Vaultwarden** (self-hosted password manager).  
Performs full backups of configuration and data directories.

📄 [More info in `vaultwarden/README.md`](./vaultwarden/README.md)

---

## 🧰 Requirements

- Docker (at least version 20.x)
- Bash shell (Linux or WSL on Windows)
- Write permissions for the target backup directory

---

## 🚀 Usage

Clone the repository:

```bash
git clone https://github.com/dockercraft-yt/Docker-Scripts.git
cd Docker-Scripts
```

Example: start a container backup

```bash
cd Docker/Container\ Backup
bash backup.sh
```

Restore a backup:

```bash
cd Docker/Container\ Restore
bash restore.sh
```

---

## 🧾 License

This project is licensed under the **MIT License**.  
See the [`LICENSE`](./LICENSE) file for details.

---

## 📢 Contributing

Pull requests are welcome!  
If you have ideas or improvements, please open an issue or submit a PR.

---

© 2025 [DockerCraft](https://github.com/dockercraft-yt)