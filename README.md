# Lucid Link Audit Trail - Windows Version

This repository contains the Windows-compatible version of the Lucid Link Audit Trail system. It uses Docker Desktop with Hyper-V to monitor and collect audit logs from a Lucid Link mounted drive, sending them to Elasticsearch for analysis and visualization in Kibana.

## Prerequisites

- Windows 10/11 Pro, Enterprise, or Education (required for Hyper-V)
- Docker Desktop for Windows
- Lucid Link drive mounted
- PowerShell
- At least 4GB of available RAM for the Elastic Stack

## System Requirements

- Windows 10/11 Pro, Enterprise, or Education (required for Hyper-V)
- Docker Desktop for Windows
- Lucid Link drive mounted (typically as L: drive)
- PowerShell 5.1 or later
- Minimum system requirements:
  - 4GB RAM for Elastic Stack
  - 2GB free disk space
  - Dual-core processor or better

## Docker Desktop Configuration

This setup has been tested and verified with Docker Desktop running in Hyper-V mode (not WSL2). Follow these steps to configure Docker Desktop:

1. Open Docker Desktop Settings
2. Under "General", ensure "Use the WSL 2 based engine" is **unchecked**
3. Under "Resources" > "File Sharing", add your Lucid Link mount point (L:\) to the list of shared drives
4. Apply changes and wait for Docker Desktop to restart

## Installation

⚠️ **Important: Administrator Rights Required**
All setup and service management commands must be run from an Administrator PowerShell prompt:
1. Right-click on PowerShell
2. Select "Run as Administrator"
3. Navigate to the project directory

1. Clone this repository:
   ```powershell
   git clone https://github.com/dmcp718/ll-audit-trail-es-windows.git
   cd ll-audit-trail-es-windows
   ```

2. Start Elasticsearch and Kibana:
   ```powershell
   .\start_docker_compose.cmd
   ```

3. Wait about 30 seconds for Elasticsearch to be ready. You can check the status at http://localhost:9200

4. Run the setup script with your Lucid Link mount point:
   ```powershell
   # Run as Administrator
   .\setup.cmd --fsmount "L:"
   ```

5. Start the Fluent Bit service:
   ```powershell
   # Run as Administrator
   .\start-service.cmd
   ```

## Accessing the Interface

- **Kibana Dashboard**: http://localhost:5601
  - Username: elastic
  - Password: changeme (default, can be changed in docker-compose.yml)

## Components

- **Elasticsearch**: Database engine that stores and indexes the audit logs
  - Version: 8.17.0
  - Port: 9200
  - Memory: Configured for 512MB heap size
  - Configuration: Single-node deployment with security features disabled for development

- **Kibana**: Web interface for visualizing and analyzing audit data
  - Version: 8.17.0
  - Port: 5601
  - Includes pre-configured dashboards and visualizations
  - Runs as non-root user for enhanced security

- **Fluent Bit**: Log collector that monitors the Lucid Link audit trail
  - Monitors: L:\.lucid_audit directory recursively
  - Parser: Custom JSON parser for Lucid Link audit format
  - Buffer: Uses persistent SQLite database (C:\fluent-bit\db\logs.db)
  - Features:
    - Automatic timestamp parsing (Unix microseconds to ISO 8601)
    - Path and offset tracking
    - Reliable delivery with retry mechanism
    - Elasticsearch output with 2MB buffer

## Configuration Files

- `fs-audit-trail.conf.template`: Main Fluent Bit configuration
  - Defines input, filter, and output plugins
  - Configures log parsing and forwarding rules
  - Sets buffer and retry parameters

- `json-parser.conf`: Custom parser configuration
  - Defines JSON parsing rules for audit logs
  - Handles timestamp conversion from Unix microseconds
  - Supports nested JSON parsing

- `docker-compose.yml`: Container orchestration
  - Defines service configurations
  - Sets up networking and volumes
  - Configures resource limits

- `kibana.yml`: Kibana configuration
  - Sets up Kibana server options
  - Configures Elasticsearch connection

## Data Flow

1. Lucid Link generates audit logs in JSON format
2. Fluent Bit monitors the audit directory for new log files
3. Logs are parsed using a two-stage process:
   - First parse: Outer JSON structure
   - Second parse: Nested JSON in log field
4. Timestamps are converted from Unix microseconds to ISO 8601 format
5. Processed logs are buffered and forwarded to Elasticsearch
6. Kibana visualizes the data through pre-configured dashboards

## Resource Management

- **Elasticsearch**:
  - Memory: Limited to 512MB heap size
  - Data persistence: Uses named volume
  - System limits: Configured for optimal performance

- **Kibana**:
  - Runs as non-root user
  - Mounts configuration as read-only
  - Auto-imports saved objects on startup

- **Fluent Bit**:
  - Efficient log parsing
  - Persistent buffer storage
  - Configurable flush intervals
  - Retry mechanism for reliability

## Fluent Bit Database

Fluent Bit uses a SQLite database to store information about the logs it has processed. This database is used to keep track of the following:

* File offsets for the tail input plugin
* Last read position for each log file
* Ensure no logs are missed between service restarts

The database is stored at `C:\fluent-bit\db\logs.db`. If you need to reset the log processing:

1. Stop the Fluent Bit service:
   ```powershell
   .\stop-service.cmd
   ```
2. Delete the database file:
   ```powershell
   Remove-Item C:\fluent-bit\db\logs.db
   ```
3. Start the service:
   ```powershell
   .\start-service.cmd
   ```

## Troubleshooting

### Common Issues

1. **Cannot access mounted drive from Fluent Bit**
   - Verify drive is mounted and accessible
   - Check path in setup.cmd matches your mount point
   - Ensure proper permissions on the audit directory

2. **No logs appearing in Kibana**
   - Check Fluent Bit service status: `sc query fluent-bit`
   - View service logs in Event Viewer
   - Verify audit logs exist in the monitored directory
   - Check Elasticsearch is running: `curl http://localhost:9200`

3. **Incorrect timestamps in Kibana**
   - Verify log format matches expected Unix microseconds
   - Check json-parser.conf configuration
   - Ensure Lua timestamp conversion is working

4. **"Access is denied" errors during setup**
   - Run PowerShell as Administrator
   - Check Windows service permissions
   - Verify user has rights to manage services

### Service Management

Always use the provided scripts to manage services:

```powershell
# Start/stop Fluent Bit service
.\start-service.cmd
.\stop-service.cmd

# Start/stop Elastic Stack
.\start_docker_compose.cmd
.\stop_docker_compose.cmd

# Reset Fluent Bit database
.\stop-service.cmd
Remove-Item C:\fluent-bit\db\logs.db
.\start-service.cmd
```

## Data Persistence

- Elasticsearch data is persisted in a Docker volume
- Fluent Bit's buffer is stored at C:\fluent-bit\db\logs.db
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
