# Lucid Link Audit Trail - Windows Version

This repository contains the Windows-compatible version of the Lucid Link Audit Trail system. It uses Docker Desktop with Hyper-V to monitor and collect audit logs from a Lucid Link mounted drive (L:), sending them to Elasticsearch for analysis and visualization in Kibana.

## Prerequisites

- Windows 10/11
- Docker Desktop with Hyper-V enabled
- Lucid Link drive mounted as L:
- PowerShell

## Setup

1. Clone this repository
2. Run `setup.cmd` to configure the environment
3. Run `start_docker_compose.cmd` to start the stack
4. Access Kibana at http://localhost:5601 (credentials in start_docker_compose.cmd)

## Components

- Elasticsearch: Store and index audit logs
- Kibana: Visualize and analyze audit data
- Fluent Bit: Collect and forward logs from Lucid Link
- Saved Objects: Pre-configured Kibana dashboards and visualizations
