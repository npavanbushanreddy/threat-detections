# Threat-Detections

**ThreatDetections** is a Git-based detection engineering framework that
implements structured CI/CD practices for managing and deploying
detection rules for:

-   🛡 Suricata (IDS/IPS)
-   📊 Wazuh (SIEM / Correlation Engine)

This project simulates a production-grade detection lifecycle using:

-   Branch promotion strategy (dev → staging → main)
-   Webhook-triggered automation
-   Validation gates before deployment
-   Service health verification
-   systemd-based persistence

The goal is to treat detection rules as engineered code, not manually
edited configurations.

---

## 📐 Architecture Overview

This repository supports the following lab architecture:

Kali (Attacker)  
        ↓  
Suricata (Inline IPS)  
        ↓  
Ubuntu Server (Protected Asset)  
        ↓  
Wazuh Manager (SIEM Correlation)

All detection content in this repository is deployed to the Suricata + Wazuh VM, which acts as both:

- Inline Intrusion Prevention System (IPS)
- Security Information and Event Management (SIEM) platform

## Core Components

-   GitHub Repository -- Centralized rule management
-   Webhook Listener (Flask-based) -- Receives push events
-   update.sh -- Deployment orchestration script
-   Suricata 8.x (IPS mode) -- Network detection engine
-   Wazuh 4.x -- Log-based detection engine
-   systemd Services -- Auto-start & automation control


---

## 🎯 Repository Purpose

This project implements Detection-as-Code principles:

- Version-controlled rule management
- Structured detection lifecycle
- Environment separation using branches
- Automated validation before deployment
- Reproducible detection engineering workflow

This approach mirrors how modern SOC teams and MSSPs manage detection content in production environments.

---

## 📁 Repository Structure

threat-detections/
│
├── suricata/
│ └── rules/ # Custom Suricata IPS rules
│
├── wazuh/
│ ├── rules/ # Custom Wazuh correlation rules
│ └── decoders/ # Custom log decoders
│
├── scripts/ # Deployment and automation scripts
│
├── tests/ # Validation scripts
│
└── docs/ # Architecture and detection documentation


---

## 🌳 Branching Strategy

This repository follows a structured promotion workflow:

| Branch   | Purpose |
|----------|----------|
| dev      | Active rule development and testing |
| staging  | Pre-production validation |
| main     | Production deployment |

### Promotion Flow

dev → staging → main


Rules are tested in `dev`, validated in `staging`, and deployed from `main`.

This simulates enterprise detection engineering pipelines.

---

## 🔐 Detection Engineering Standards

### Suricata Rules

- Custom SID range: 1000000 – 1999999
- Modular rule organization by attack category
- Validation required before promotion

### Wazuh Rules

- Correlate Suricata alerts
- Use structured grouping and severity levels
- XML validation before deployment

---

## ⚙️ Deployment Model

Detection content is deployed to the Suricata VM using:

- Git-based version control
- Branch-aware deployment scripts
- Boot-time repository synchronization
- Optional webhook-triggered updates
- Webhook Listener
  - webhook.py (Flask)
  - receives GitHub push events
  - triggers update.sh
  - runs deploy only on the approved branch (main)

# 🚀 Deployment Workflow

When a push is made to `main`:

1.  GitHub sends a webhook POST request\
2.  webhook.py receives the event\
3.  update.sh is executed\
4.  Deployment proceeds only if validation passes

Before deployment:

- Suricata configuration is validated
- Wazuh rules are deployed and Wazuh service is restarted to verify correctness
  Invalid rules will prevent deployment.

Invalid rules are not promoted to production.

 ⚙ Deployment Script (update.sh)

Deployment is controlled by:

    scripts/update.sh

### What It Does

1.  Pulls latest `main` branch\
2.  Validates Suricata configuration using:\
    `suricata -T -c /etc/suricata/suricata.yaml`\
3.  Reloads Suricata only if validation passes\
4.  Restarts Wazuh Manager\
5.  Verifies Wazuh service health\
6.  Aborts if any validation fails

This prevents broken rules from impacting production.

---

# 🔁 Webhook Automation

A Flask-based webhook listener:

    scripts/webhook.py

### Behavior

-   Listens for GitHub push events\
-   Triggers update.sh\
-   Executes deployment pipeline\
-   Runs as a systemd service\
-   Can be exposed using ngrok (lab setup)

---

# 🛡 Safety Controls Implemented

-   Suricata pre-validation before reload\
-   Wazuh restart + service health verification\
-   systemd auto-start for services\
-   Controlled branch-based deployment

---

## 🧪 Testing Methodology

## Suricata

-   Validate rules using `suricata -T`\
-   Generate traffic from Kali\
-   Verify alerts in `/var/log/suricata/eve.json`

## Wazuh

-   Restart manager\
-   Verify service health\
-   Inspect logs in `/var/ossec/logs/ossec.log`

---

# 🔍 Troubleshooting Commands

Check webhook logs:

    journalctl -u threat-webhook.service -n 50 --no-pager

Check Suricata:

    systemctl status suricata

Check Wazuh:

    systemctl status wazuh-manager

---

# 📊 Current Capabilities

-   Version-controlled detection rules\
-   Branch promotion workflow\
-   Automated production deployment\
-   Suricata validation gate\
-   Wazuh health verification\
-   systemd-based automation

---

## 📊 Objectives

This repository demonstrates:

- Detection lifecycle management
- DevSecOps principles applied to security operations
- SOC content engineering discipline
- Inline IPS rule development
- SIEM correlation logic design

---

## 🚀 Future Enhancements

-   Automatic rollback on failed deployment\
-   Duplicate SID / Rule ID detection\
-   GitHub Actions CI integration\
-   Sigma → Wazuh conversion pipeline\
-   Deployment logging system

---

## 👤 Author

N Pavan Bushan Reddy  
Security Researcher | WAF/WAS | IDS/IPS | SIEM
GitHub: https://github.com/npavanbushanreddy

---

This repository represents a practical implementation of enterprise detection engineering practices within a controlled lab environment.
