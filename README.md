# LucidLink Audit Trail - Windows Version

This repository contains the Windows-compatible version of a docker-compose stack that uses fluent-bit to send audit trail log data to Elasticsearch index. It uses Docker Desktop with Hyper-V to monitor and collect audit logs from a LucidLink mounted drive, sending them to Elasticsearch for analysis and visualization in Kibana.

## Prerequisites

- Windows 10/11 Pro, Enterprise, or Education (required for Hyper-V)
- Docker Desktop for Windows
- Lucid Link drive mounted
- PowerShell
- At least 4GB of available RAM for the Elastic Stack

## Docker Desktop Configuration

This setup has been tested and verified with Docker Desktop running in Hyper-V mode (not WSL2). Follow these steps to configure Docker Desktop:

1. Open Docker Desktop Settings
2. Under "General", ensure "Use the WSL 2 based engine" is **unchecked**
3. Under "Resources" > "File Sharing", add your Lucid Link mount point (L:\) to the list of shared drives
4. Apply changes and wait for Docker Desktop to restart

## Installation

1. Clone this repository:
   ```powershell
   git clone https://github.com/dmcp718/ll-audit-trail-es-windows.git
   cd ll-audit-trail-es-windows
   ```

2. Run the setup script to configure the environment:
   ```powershell
   .\setup.cmd
   ```

3. Start the Elastic Stack:
   ```powershell
   .\start_docker_compose.cmd
   ```

4. Wait for all services to start (this may take a few minutes on first run)

## Accessing the Interface

- **Kibana Dashboard**: http://localhost:5601
  - Username: elastic
  - Password: changeme (default, can be changed in docker-compose.yml)

## Components

- **Elasticsearch**: Database engine that stores and indexes the audit logs
  - Port: 9200
  - Configuration: Default configuration optimized for development environments

- **Kibana**: Web interface for visualizing and analyzing audit data
  - Port: 5601
  - Includes pre-configured dashboards and visualizations

- **Fluent Bit**: Log collector that monitors the Lucid Link audit trail
  - Monitors: L:\.lucid_audit directory
  - Parser: Configured for Lucid Link's JSON log format
  - Buffer: Uses persistent storage to prevent log loss

## Troubleshooting

### Common Issues

1. **Cannot access L: drive from containers**
   - Verify Docker Desktop is in Hyper-V mode
   - Check File Sharing settings in Docker Desktop
   - Ensure L: drive is mounted and accessible from Windows

2. **No logs appearing in Kibana**
   - Check if L:\.lucid_audit directory exists and contains logs
   - Verify Fluent Bit container logs for any errors
   - Ensure Elasticsearch is running and healthy

3. **Docker Desktop fails to start**
   - Verify Hyper-V is enabled in Windows Features
   - Check Windows Event Viewer for Hyper-V related errors

### Checking Service Status

```powershell
docker ps  # List running containers
docker logs fluent-bit  # Check Fluent Bit logs
docker logs elasticsearch-node1  # Check Elasticsearch logs
```

## Management Scripts

- `setup.cmd`: Initial configuration and environment setup
- `start_docker_compose.cmd`: Start the Elastic Stack and Fluent Bit
- `stop_docker_compose.cmd`: Gracefully stop all services
- `import-saved-objects.cmd`: Import pre-configured Kibana dashboards

## Data Persistence

- Elasticsearch data is persisted in a Docker volume
- Fluent Bit's buffer is stored in a separate volume
- Stopping and starting services will not lose data

## Security Notes

- Default passwords are for development only
- Production deployments should:
  - Change default passwords
  - Enable SSL/TLS
  - Implement proper access controls
  - Review and adjust resource limits

## Support

For issues specific to the Windows version, please open an issue in this repository. For general Lucid Link related questions, contact Lucid Link support.
