# Threat-Detections

Threat-Detections is a Detection-as-Code repository designed to manage and deploy security detection logic in a structured, version-controlled manner.

This repository centralizes:

- Suricata IPS detection rules
- Wazuh custom correlation rules and decoders
- Validation scripts
- Deployment automation
- Branch-based promotion workflow (dev → staging → prod)

The goal is to simulate and implement real-world SOC detection engineering practices within an inline IPS + SIEM lab architecture.

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

Before deployment:

- Suricata configuration is validated
- Wazuh rules are syntax-checked

Invalid rules are not promoted to production.

---

## 🧪 Testing Methodology

Rules are validated using:

- Suricata test mode
- XML linting for Wazuh
- Controlled attack simulations from Kali
- Inline IPS drop/alert verification

All detections must be reproducible.

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

Planned improvements:

- CI validation pipeline
- Automated rollback on failure
- MITRE ATT&CK mapping documentation
- Rule performance benchmarking
- Sigma rule integration
- Github + Webhook (ngrok + flask)

---

## 👤 Maintainer

N Pavan Bushan Reddy  
Security Engineer | WAF & Detection Engineering Focus

---

This repository represents a practical implementation of enterprise detection engineering practices within a controlled lab environment.
