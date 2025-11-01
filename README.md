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
mkdir mcp

cd mcp/
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

Open a file editor

```bash
cloudshell edit ~/mcp/server.py
```

Create `server.py` with the following content:

```python
import asyncio
import logging
import os
from typing import List, Dict, Any
from fastmcp import FastMCP

logger = logging.getLogger(__name__)
logging.basicConfig(format="[%(levelname)s]: %(message)s", level=logging.INFO)

mcp = FastMCP("GDG MCP Server 🦁🐧🐻")

# Dictionary of Speakers at the GDG Kochi 
GDG_KOCHI = [
    {
        "title": "Registration Starts",
        "time": "09:30 AM - 09:35 AM",
        "speaker": None,
        "role": None,
        "organization": None,
        "duration": None,
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Welcome Note",
        "time": "09:35 AM - 09:40 AM",
        "speaker": "Iqbal P B",
        "role": "Organiser",
        "organization": "GDG Cochin",
        "duration": "5 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Keynote — Artificially intelligent? No, Creative with Google AI Studio",
        "time": "09:40 AM - 10:00 AM",
        "speaker": "Merin K Jacob",
        "role": "Technical Account Manager",
        "organization": "Google",
        "duration": "20 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Keynote — Dont Call Me a Developer: Designing an AI-Accelerated Career",
        "time": "10:05 AM - 10:25 AM",
        "speaker": "Eric Hole",
        "role": "Vice President",
        "organization": "Onix",
        "duration": "20 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Sponsor Talk",
        "time": "10:30 AM - 10:40 AM",
        "speaker": "Dr. Tom M Joseph",
        "role": None,
        "organization": "Jain",
        "duration": "10 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Break",
        "time": "10:50 AM - 11:05 AM",
        "speaker": None,
        "role": None,
        "organization": None,
        "duration": "15 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Ship It Fast: AI Apps with Gemini, Firebase Studio, and $0 Infra",
        "time": "11:35 AM - 12:00 PM",
        "speaker": "Vishnu K S",
        "role": "Senior Cloud Engineer",
        "organization": "DP World",
        "duration": "25 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Building Conversational Agents using ADK, A2A and MCP",
        "time": "12:05 PM - 12:30 PM",
        "speaker": "Nishi Ajmera",
        "role": "Solutions Architect",
        "organization": "Publicis Sapient (UK)",
        "duration": "25 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Run SQL Everywhere: Presto Meets BigQuery and Cloud Storage",
        "time": "12:40 PM - 01:25 PM",
        "speaker": "Saurabh Mahawar",
        "role": "Developer Relations Engineer",
        "organization": "IBM",
        "duration": "45 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Lunch Break",
        "time": "12:40 PM - 01:25 PM",
        "speaker": None,
        "role": None,
        "organization": None,
        "duration": "45 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Production ready AI Agents with Security, Evaluation and Memory",
        "time": "01:25 PM - 01:50 PM",
        "speaker": "Nikhilesh Tayal",
        "role": "Google Developer Expert",
        "organization": "—",
        "duration": "25 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Securing the Google Cloud: AI-Driven Threat Hunting Using Gemini",
        "time": "01:55 PM - 02:20 PM",
        "speaker": "Harisuthan S",
        "role": "Senior Security Engineer",
        "organization": "Renault Nissan Technology",
        "duration": "25 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Lessons from running Go applications in Kubernetes",
        "time": "02:25 PM - 02:50 PM",
        "speaker": "Adarsh K Kumar",
        "role": "Principal Product Engineer",
        "organization": "Rapido",
        "duration": "25 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Orchestrating the Modern Data Stack with Apache Airflow",
        "time": "02:55 PM - 03:20 PM",
        "speaker": "Jeevitha",
        "role": "Staff Software Engineer",
        "organization": "Juniper Networks (HP)",
        "duration": "25 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Building Scalable and Ethical AI Solutions with Gemma",
        "time": "03:25 PM - 03:50 PM",
        "speaker": "Geeta Kakrani",
        "role": "Google Developer Expert",
        "organization": "AI",
        "duration": "25 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Tech Talk — Securing your LLM's",
        "time": "03:55 PM - 04:20 PM",
        "speaker": "Dharmesh Vaya",
        "role": "Senior Solutions Engineer",
        "organization": "Wiz",
        "duration": "25 min",
        "location": "Main Hall",
        "notes": None,
    },
    {
        "title": "Closing Note",
        "time": "04:25 PM - 04:30 PM",
        "speaker": "Malavika",
        "role": "Organiser",
        "organization": "GDG Cochin",
        "duration": "5 min",
        "location": "Main Hall",
        "notes": None,
    },
    # Workshop / parallel track (best-effort)
    {
        "title": "Workshop — How to deploy a secure MCP server on Cloud Run?",
        "time": "02:00 PM",
        "speaker": "Ebin Babu",
        "role": "CNCF Ambassador",
        "organization": "Linux Foundation Projects",
        "duration": None,
        "location": "Workshop",
        "notes": "Parallel workshop track",
    },
]

@mcp.tool()
def search_sessions(query: str) -> List[Dict[str, Any]]:
    """Search GDG Kochi sessions.

    Performs a case-insensitive substring search over session titles and
    speaker names and returns matching session dicts from `GDG_KOCHI`.

    Args:
        query: A search string to match against title or speaker.

    Returns:
        A list of session dictionaries (may be empty).
    """
    logger.info(f">>> 🛠️ Tool: 'search_sessions' called for query='{query}'")
    q = (query or "").strip().lower()
    if not q:
        return []
    results: List[Dict[str, Any]] = []
    for sess in GDG_KOCHI:
        title = (sess.get("title") or "").lower()
        speaker = (sess.get("speaker") or "").lower()
        if q in title or q in speaker:
            results.append(sess)
    return results

@mcp.tool()
def get_session_details(identifier: str) -> Dict[str, Any]:
    """Return a single session's details by exact title or speaker name.

    Tries to match `identifier` exactly (case-insensitive) against the
    session title first, then speaker name. If no exact match is found,
    returns the first partial match. If nothing matches, returns an empty dict.

    Args:
        identifier: Session title or speaker name to look up.

    Returns:
        A session dict or an empty dict when not found.
    """
    logger.info(f">>> 🛠️ Tool: 'get_session_details' called for '{identifier}'")
    if not identifier:
        return {}
    ident = identifier.strip().lower()

    # Exact title match
    for sess in GDG_KOCHI:
        if (sess.get("title") or "").strip().lower() == ident:
            return sess

    # Exact speaker match
    for sess in GDG_KOCHI:
        if (sess.get("speaker") or "").strip().lower() == ident:
            return sess

    # Partial match fallback (title or speaker)
    for sess in GDG_KOCHI:
        title = (sess.get("title") or "").lower()
        speaker = (sess.get("speaker") or "").lower()
        if ident in title or ident in speaker:
            return sess

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
gcloud run deploy gdg-kochi-mcp-server \
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
            "httpUrl": "https://gdg-kochi-mcp-server-$PROJECT_NUMBER.europe-west1.run.app/mcp",
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

- “Show sessions longer than 20 minutes.”
- “Build my personal schedule if I want to attend talks about AI and Security.”
- “Write a 280-character tweet announcing Merin’s keynote.”
- “Create five suggested audience questions for the talk ‘Run SQL Everywhere’.”
- “Which sessions overlap or are parallel (workshops vs main hall)?”
- “Give me a list of all speakers and their organizations.”
- “Which speakers are Google employees?”
- “Who’s speaking at 09:40 AM?”

When prompted, allow all tools from the server "gdg-kochi-remote".

## Troubleshooting

- If you encounter authentication errors, ensure your `ID_TOKEN` is up to date (tokens expire after a period of time)
- Make sure the Cloud Run service URL in `settings.json` matches your actual deployment region
- Verify that the IAM policy binding was applied correctly
- Check Cloud Run logs if the server isn't responding: `gcloud run logs read zoo-mcp-server`
