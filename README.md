# MCP Server Setup Guide

This guide walks you through setting up and deploying an MCP (Model Context Protocol) server on Google Cloud Run.

## Prerequisites

- Google Cloud SDK (`gcloud`) installed and configured
- Access to a Google Cloud project
- `uv` Python package manager installed
- Gemini CLI installed (for testing)

## MCP Server Setup

### Project Selection

First, select your Google Cloud project:

```bash
gcloud projects list
```

Set your project:

```bash
gcloud config set project [PROJECT_ID]
```

### Enable APIs

Enable the required Google Cloud APIs:

```bash
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com
```

### Create Project Directory

Create a directory for your MCP server:

```bash
mkdir lab
cd lab/
```

### Initialize Python Environment

Use `uv` to initialize a new Python project:

```bash
uv init --description "Example of deploying an MCP server on Cloud Run" --bare --python 3.13
```

**What this does:**
- Uses `uv`, a modern Python package and project manager
- Initializes a new Python project in the current directory
- Creates a `pyproject.toml` file (instead of `requirements.txt`)
- Sets Python 3.13 as the required version
- Sets project metadata like description
- The `--bare` flag creates a clean slate without extra files (like `main.py`, `.venv`, or `README`)

### Add FastMCP Dependency

Add FastMCP as a dependency:

```bash
uv add fastmcp==2.12.4 --no-sync
```

### Create Server

Create `server.py` with the following content:

```python
import asyncio
import logging
import os
from typing import List, Dict, Any
from fastmcp import FastMCP

logger = logging.getLogger(__name__)
logging.basicConfig(format="[%(levelname)s]: %(message)s", level=logging.INFO)

mcp = FastMCP("Zoo Animal MCP Server 🦁🐧🐻")

# Dictionary of animals at the zoo
ZOO_ANIMALS = [
    {
        "species": "lion",
        "name": "Leo",
        "age": 7,
        "enclosure": "The Big Cat Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "lion",
        "name": "Nala",
        "age": 6,
        "enclosure": "The Big Cat Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "lion",
        "name": "Simba",
        "age": 3,
        "enclosure": "The Big Cat Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "lion",
        "name": "King",
        "age": 8,
        "enclosure": "The Big Cat Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "penguin",
        "name": "Waddles",
        "age": 2,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "penguin",
        "name": "Pip",
        "age": 4,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "penguin",
        "name": "Skipper",
        "age": 5,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "penguin",
        "name": "Chilly",
        "age": 3,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "penguin",
        "name": "Pingu",
        "age": 6,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "penguin",
        "name": "Noot",
        "age": 1,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "elephant",
        "name": "Ellie",
        "age": 15,
        "enclosure": "The Pachyderm Sanctuary",
        "trail": "Savannah Heights"
    },
    {
        "species": "elephant",
        "name": "Peanut",
        "age": 12,
        "enclosure": "The Pachyderm Sanctuary",
        "trail": "Savannah Heights"
    },
    {
        "species": "elephant",
        "name": "Dumbo",
        "age": 5,
        "enclosure": "The Pachyderm Sanctuary",
        "trail": "Savannah Heights"
    },
    {
        "species": "elephant",
        "name": "Trunkers",
        "age": 10,
        "enclosure": "The Pachyderm Sanctuary",
        "trail": "Savannah Heights"
    },
    {
        "species": "bear",
        "name": "Smokey",
        "age": 10,
        "enclosure": "The Grizzly Gulch",
        "trail": "Polar Path"
    },
    {
        "species": "bear",
        "name": "Grizzly",
        "age": 8,
        "enclosure": "The Grizzly Gulch",
        "trail": "Polar Path"
    },
    {
        "species": "bear",
        "name": "Barnaby",
        "age": 6,
        "enclosure": "The Grizzly Gulch",
        "trail": "Polar Path"
    },
    {
        "species": "bear",
        "name": "Bruin",
        "age": 12,
        "enclosure": "The Grizzly Gulch",
        "trail": "Polar Path"
    },
    {
        "species": "giraffe",
        "name": "Gerald",
        "age": 4,
        "enclosure": "The Tall Grass Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "giraffe",
        "name": "Longneck",
        "age": 5,
        "enclosure": "The Tall Grass Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "giraffe",
        "name": "Patches",
        "age": 3,
        "enclosure": "The Tall Grass Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "giraffe",
        "name": "Stretch",
        "age": 6,
        "enclosure": "The Tall Grass Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "antelope",
        "name": "Speedy",
        "age": 2,
        "enclosure": "The Tall Grass Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "antelope",
        "name": "Dash",
        "age": 3,
        "enclosure": "The Tall Grass Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "antelope",
        "name": "Gazelle",
        "age": 4,
        "enclosure": "The Tall Grass Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "antelope",
        "name": "Swift",
        "age": 5,
        "enclosure": "The Tall Grass Plains",
        "trail": "Savannah Heights"
    },
    {
        "species": "polar bear",
        "name": "Snowflake",
        "age": 7,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "polar bear",
        "name": "Blizzard",
        "age": 5,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "polar bear",
        "name": "Iceberg",
        "age": 9,
        "enclosure": "The Arctic Exhibit",
        "trail": "Polar Path"
    },
    {
        "species": "walrus",
        "name": "Wally",
        "age": 10,
        "enclosure": "The Walrus Cove",
        "trail": "Polar Path"
    },
    {
        "species": "walrus",
        "name": "Tusker",
        "age": 12,
        "enclosure": "The Walrus Cove",
        "trail": "Polar Path"
    },
    {
        "species": "walrus",
        "name": "Moby",
        "age": 8,
        "enclosure": "The Walrus Cove",
        "trail": "Polar Path"
    },
    {
        "species": "walrus",
        "name": "Flippers",
        "age": 9,
        "enclosure": "The Walrus Cove",
        "trail": "Polar Path"
    }
]

@mcp.tool()
def get_animals_by_species(species: str) -> List[Dict[str, Any]]:
    """
    Retrieves all animals of a specific species from the zoo.
    
    Can also be used to collect the base data for aggregate queries
    of animals of a specific species - like counting the number of penguins
    or finding the oldest lion.
    
    Args:
        species: The species of the animal (e.g., 'lion', 'penguin').
    
    Returns:
        A list of dictionaries, where each dictionary represents an animal
        and contains details like name, age, enclosure, and trail.
    """
    logger.info(f">>> 🛠️ Tool: 'get_animals_by_species' called for '{species}'")
    return [animal for animal in ZOO_ANIMALS if animal["species"].lower() == species.lower()]

@mcp.tool()
def get_animal_details(name: str) -> Dict[str, Any]:
    """
    Retrieves the details of a specific animal by its name.
    
    Args:
        name: The name of the animal.
    
    Returns:
        A dictionary with the animal's details (species, name, age, enclosure, trail)
        or an empty dictionary if the animal is not found.
    """
    logger.info(f">>> 🛠️ Tool: 'get_animal_details' called for '{name}'")
    for animal in ZOO_ANIMALS:
        if animal["name"].lower() == name.lower():
            return animal
    return {}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    logger.info(f"🚀 MCP server started on port {port}")
    asyncio.run(
        mcp.run_async(
            transport="http",
            host="0.0.0.0",
            port=port,
        )
    )
```

### Create Dockerfile

Create a `Dockerfile`:

```dockerfile
# Use the official Python image
FROM python:3.13-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install the project into /app
COPY . /app
WORKDIR /app

# Allow statements and log messages to immediately appear in the logs
ENV PYTHONUNBUFFERED=1

# Install dependencies
RUN uv sync

EXPOSE $PORT

# Run the FastMCP server
CMD ["uv", "run", "server.py"]
```

## Deploy to Cloud Run

Deploy your MCP server to Cloud Run:

```bash
gcloud run deploy zoo-mcp-server \
    --no-allow-unauthenticated \
    --region=asia-south1 \
    --source=. \
    --labels=dev-tutorial=codelab-mcp
```

**Note:** Adjust the `--region` parameter to your preferred region.

## Configure Gemini CLI

### Grant Permissions

Add IAM policy binding to allow yourself to invoke the Cloud Run service:

```bash
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member=user:$(gcloud config get-value account) \
    --role='roles/run.invoker'
```

### Set Environment Variables

Save project number and ID token as environment variables:

```bash
export PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format="value(projectNumber)")
export ID_TOKEN=$(gcloud auth print-identity-token)
```

### Create Gemini Configuration

Create the Gemini configuration directory:

```bash
mkdir -p ~/.gemini
```

Create the Gemini settings file `~/.gemini/settings.json`:

```json
{
    "ide": {
        "hasSeenNudge": true
    },
    "mcpServers": {
        "zoo-remote": {
            "httpUrl": "https://zoo-mcp-server-$PROJECT_NUMBER.europe-west1.run.app/mcp",
            "headers": {
                "Authorization": "Bearer $ID_TOKEN"
            }
        }
    },
    "security": {
        "auth": {
            "selectedType": "cloud-shell"
        }
    }
}
```

**Note:** Make sure to:
- Replace `europe-west1` with your actual Cloud Run region (e.g., `asia-south1` if you used that region)
- Replace `$PROJECT_NUMBER` with your actual project number if the variable isn't expanded automatically
- Replace `$ID_TOKEN` with your actual ID token if the variable isn't expanded automatically

## Test the MCP Server

Start Gemini CLI:

```bash
gemini
```

In the Gemini CLI, navigate to:

```
/mcp
```

### Sample Questions

Try asking questions like:

- "Where can I find penguins?"
- "What animals are in the Savannah Heights trail?"
- "Tell me about Leo the lion"

When prompted, allow all tools from the server "zoo-remote".

## Troubleshooting

- If you encounter authentication errors, ensure your `ID_TOKEN` is up to date (tokens expire after a period of time)
- Make sure the Cloud Run service URL in `settings.json` matches your actual deployment region
- Verify that the IAM policy binding was applied correctly
- Check Cloud Run logs if the server isn't responding: `gcloud run logs read zoo-mcp-server`
