# dbt Project with RDS via Boundary

This dbt project is configured to connect to an AWS RDS database through HashiCorp Boundary for secure access.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Configuration](#configuration)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have the following installed:

1. **Python 3.9+** - [Download Python](https://www.python.org/downloads/)
2. **HashiCorp Boundary CLI** - [Install Boundary](https://developer.hashicorp.com/boundary/tutorials/oss-getting-started/oss-getting-started-install)
3. **Git** - [Download Git](https://git-scm.com/downloads)
4. **Boundary access credentials** - Contact your administrator for:
   - Boundary cluster address
   - Target ID for your RDS instance
   - Authentication credentials

---

## Project Structure

```
dbt_rds_boundary/
├── dbt_project.yml          # Main dbt project configuration
├── profiles.yml             # Database connection profiles
├── packages.yml             # dbt package dependencies
├── requirements.txt         # Python dependencies
├── .env.example             # Environment variables template
├── .gitignore               # Git ignore rules
├── README.md                # This file
├── models/
│   ├── staging/             # Staging models (views)
│   │   ├── sources.yml      # Source definitions
│   │   ├── schema.yml       # Model documentation
│   │   └── stg_*.sql        # Staging models
│   ├── intermediate/        # Intermediate models
│   └── marts/               # Final presentation models (tables)
├── macros/                  # Custom Jinja macros
├── seeds/                   # CSV seed data
├── snapshots/               # SCD Type 2 snapshots
├── analyses/                # Ad-hoc analysis queries
├── tests/                   # Custom data tests
└── scripts/                 # Helper scripts
    ├── start_boundary.ps1   # PowerShell script for Boundary
    └── start_boundary.sh    # Bash script for Boundary
```

---

## Setup Instructions

### Step 1: Create Virtual Environment

```powershell
# Navigate to project directory
cd dbt_rds_boundary

# Create virtual environment
python -m venv venv

# Activate virtual environment (Windows PowerShell)
.\venv\Scripts\Activate.ps1

# For Windows Command Prompt:
# .\venv\Scripts\activate.bat

# For Linux/Mac:
# source venv/bin/activate
```

### Step 2: Install Dependencies

```powershell
# Install Python packages
pip install -r requirements.txt

# Verify dbt installation
dbt --version
```

### Step 3: Configure Environment Variables

```powershell
# Copy the example environment file
Copy-Item .env.example .env

# Edit .env file with your credentials
notepad .env
```

Update the `.env` file with your actual values:

```env
DBT_HOST=127.0.0.1
DBT_PORT=5432
DBT_USER=your_actual_username
DBT_PASSWORD=your_actual_password
DBT_DATABASE=your_database_name
DBT_SCHEMA=public

BOUNDARY_ADDR=https://your-boundary-cluster.example.com
BOUNDARY_TARGET_ID=ttcp_xxxxxxxxxxxx
```

### Step 4: Load Environment Variables

```powershell
# PowerShell - Load environment variables
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#][^=]*)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}

# Verify variables are set
echo $env:DBT_DATABASE
```

### Step 5: Start Boundary Connection

**Open a NEW terminal window** and start the Boundary proxy:

```powershell
# Option 1: Using the helper script
.\scripts\start_boundary.ps1 -TargetId "ttcp_xxxxxxxxxxxx"

# Option 2: Direct Boundary command
boundary connect postgres -target-id ttcp_xxxxxxxxxxxx -listen-port 5432
```

> ⚠️ **Important**: Keep this terminal open! The Boundary proxy must be running while you use dbt.

### Step 6: Install dbt Packages

In your **original terminal** (with the virtual environment activated):

```powershell
# Install dbt package dependencies
dbt deps
```

### Step 7: Test Connection

```powershell
# Test the database connection
dbt debug

# You should see "All checks passed!" if successful
```

---

## Configuration

### profiles.yml

The `profiles.yml` file contains connection configurations. It uses environment variables for sensitive data:

| Variable | Description | Default |
|----------|-------------|---------|
| `DBT_HOST` | Database host (Boundary proxy) | `127.0.0.1` |
| `DBT_PORT` | Database port | `5432` |
| `DBT_USER` | Database username | Required |
| `DBT_PASSWORD` | Database password | Required |
| `DBT_DATABASE` | Database name | Required |
| `DBT_SCHEMA` | Default schema | `public` |

### Moving profiles.yml to Global Location (Recommended for Production)

For better security, move `profiles.yml` to your home directory:

```powershell
# Create .dbt directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "$HOME\.dbt"

# Move profiles.yml
Move-Item profiles.yml "$HOME\.dbt\profiles.yml"
```

---

## Usage

### Common dbt Commands

```powershell
# Check configuration and connection
dbt debug

# Run all models
dbt run

# Run specific model
dbt run --select my_model

# Run models with dependencies
dbt run --select +my_model+

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve

# Run seeds (load CSV data)
dbt seed

# Create snapshots
dbt snapshot

# Full refresh (rebuild tables)
dbt run --full-refresh
```

### Targeting Environments

```powershell
# Development (default)
dbt run

# Staging
dbt run --target staging

# Production
dbt run --target prod
```

### Running with Profiles in Project Directory

If keeping `profiles.yml` in the project:

```powershell
dbt run --profiles-dir .
```

---

## Troubleshooting

### Connection Issues

**Error: "Connection refused"**
- Ensure Boundary proxy is running in another terminal
- Check that the listen port matches `DBT_PORT`

**Error: "Authentication failed"**
- Verify `DBT_USER` and `DBT_PASSWORD` are correct
- Check your Boundary authentication

**Error: "Database does not exist"**
- Verify `DBT_DATABASE` is correct
- Ensure you have access to the database

### Boundary Issues

**Error: "Boundary target not found"**
- Verify `BOUNDARY_TARGET_ID` is correct
- Ensure you're authenticated: `boundary authenticate`

**Error: "Permission denied"**
- Check your Boundary permissions with your administrator
- Ensure your session hasn't expired

### SSL Issues

If you encounter SSL certificate errors:

```yaml
# In profiles.yml, try these sslmode options:
sslmode: prefer      # Try SSL, but allow non-SSL
sslmode: require     # Require SSL (default)
sslmode: verify-ca   # Verify certificate
sslmode: disable     # Disable SSL (not recommended)
```

### Debug Mode

Run dbt with verbose logging:

```powershell
dbt run --debug
```

---

## Additional Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt-postgres Adapter](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup)
- [HashiCorp Boundary Documentation](https://developer.hashicorp.com/boundary/docs)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)

---

## Support

For issues related to:
- **Boundary access**: Contact your infrastructure/security team
- **Database permissions**: Contact your database administrator
- **dbt usage**: Refer to [dbt Discourse](https://discourse.getdbt.com/)
