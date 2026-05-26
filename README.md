# 🛡️ Threat-Detections

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Suricata](https://img.shields.io/badge/Suricata-8.x-red)](https://suricata.io/)
[![Wazuh](https://img.shields.io/badge/Wazuh-4.x-blue)](https://wazuh.com/)
[![MITRE ATT&CK](https://img.shields.io/badge/MITRE%20ATT%26CK-mapped-darkred)](https://attack.mitre.org/)
[![Detection-as-Code](https://img.shields.io/badge/Detection--as--Code-✓-green)](https://github.com/npavanbushanreddy/threat-detections)
[![AWS](https://img.shields.io/badge/AWS-EC2-orange)](https://aws.amazon.com/)
[![Platform](https://img.shields.io/badge/Platform-Ubuntu%2024.04-purple)](https://ubuntu.com/)

> **A Detection-as-Code framework that treats detection rules as engineered code, not manually-edited configurations.**
> Built by a Security Researcher with 4+ years of production WAF & detection engineering experience (Indusface),
> applying the same discipline used to protect 5,000+ customer applications to a personal NDR + SIEM lab.

---

## 👤 Background — Why This Repo Exists

This repository is a personal lab built by **N Pavan Bushan Reddy**, Engineer — Security Research at Indusface Private Limited.

In the day job:
- **4+ years** authoring production WAF detection signatures protecting **5,000+ customer applications**
- **100+ ModSec signatures** developed, **75+ anomaly-based rules** authored
- **99% attack coverage** in BAS platforms (Cymulate, Picus, Nemecida) without DoS/Bot rules
- **90% improvement** in false-positive analysis automation efficiency
- **35% reduction** in successful WAF bypasses through encoding/smuggling evasion research
- Published **zero-day advisories and virtual patches** for Apache OFBiz (CVE-2024-38856), PHP-CGI (CVE-2024-4577), Apache Tomcat (CVE-2025-24813), Zimbra XSS, Hotjar OAuth+XSS, Ivanti Endpoint Manager, and more

**This repo applies the same engineering discipline to Suricata (NDR) + Wazuh (SIEM)** — the open-source detection stack used by leading MDR/MSSP platforms — to demonstrate the full detection content lifecycle outside the ModSec/WAF context.

---

## 🎯 What This Project Demonstrates

An **end-to-end detection engineering pipeline** mirroring how modern SOCs and MSSPs manage detection content at scale:

- ✅ **Git-based version control** of all detection rules — every change traceable
- ✅ **Branch promotion workflow** (`dev` → `staging` → `main`) — production safety
- ✅ **Automated GitHub → AWS deployment** via Flask webhook
- ✅ **Pre-deployment validation gates** (`suricata -T` + Wazuh service health check)
- ✅ **systemd-based service persistence** — survives reboots & crashes
- ✅ **Multi-engine detection** — Suricata (NDR) + Wazuh (SIEM correlation)
- ✅ **End-to-end latency: GitHub push → production rules live in under 10 seconds**

---

## 📐 Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    Developer Workflow                        │
│   git push origin main → GitHub                              │
└─────────────────────┬────────────────────────────────────────┘
                      │  webhook POST (HTTP)
                      ▼
┌──────────────────────────────────────────────────────────────┐
│         AWS EC2 — Detection Sensor (Ubuntu 24.04)            │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Flask webhook listener (systemd, port 5000)           │  │
│  │              │                                         │  │
│  │              ▼                                         │  │
│  │  update.sh — validates → reloads → verifies            │  │
│  │              │                                         │  │
│  │   ┌──────────┴──────────┐                              │  │
│  │   ▼                     ▼                              │  │
│  │  Suricata 8 (NDR)    Wazuh 4.x (SIEM)                  │  │
│  │  ├ ET ruleset         ├ Manager (rule engine)          │  │
│  │  └ Custom rules ──────┤ Indexer (OpenSearch)           │  │
│  │     (symlinked from   ├ Dashboard                      │  │
│  │      this repo)       └ Correlation rules              │  │
│  │                          (symlinked from this repo)    │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

**Attack simulation flow (testing lane):**
```
Mac (attacker) → NGINX reverse proxy → Suricata (inline IDS/IPS)
                                            │
                                            └─► eve.json
                                                  │
                                                  ▼
                                          Wazuh Manager
                                            (correlation)
```

A cross-account WAF (NGINX) sits between Suricata and the protected demo target,
giving full visibility into attack traffic at both the network and edge layers.

---

## 🚀 Deployment Pipeline (Live)

When code is pushed to `main`:

1. **GitHub** sends webhook POST to AWS EC2 (port 5000)
2. **Flask listener** ([`scripts/webhook.py`](scripts/webhook.py), systemd service) receives the event
3. **[`scripts/update.sh`](scripts/update.sh)** orchestrates deployment:
   ```bash
   git pull origin main                                 # fetch latest rules
   suricata -T -c /etc/suricata/suricata.yaml          # validation gate
   systemctl reload suricata                            # apply rules
   systemctl restart wazuh-manager                      # restart SIEM
   systemctl is-active --quiet wazuh-manager           # health check
   ```
4. **Deployment aborts** if any gate fails — broken rules never reach production

**End-to-end latency:** GitHub push → Production deployed in **<10 seconds**.

---

## 📁 Repository Structure

```
threat-detections/
├── suricata/
│   └── rules/                  Custom Suricata detection rules
│       ├── local.rules         Primary custom ruleset (IDS)
│       └── ips-http-drop.rules IPS drop rules
│
├── Wazuh/
│   └── rules/                  Custom Wazuh correlation rules
│       └── local_rules.xml     SIEM correlation & MITRE mapping
│
├── scripts/                    Automation
│   ├── update.sh               Deployment orchestration
│   ├── webhook.py              Flask webhook listener
│   └── stg-main-deployment.sh  Staging → Main promotion helper
│
├── tests/                      Validation & PCAP regression
├── docs/                       Architecture & detection documentation
├── LICENSE
└── README.md
```

---

## 🌳 Branching Strategy

Production-style branch promotion model:

| Branch    | Purpose                              | Deployment   |
|-----------|--------------------------------------|--------------|
| `dev`     | Active rule development & testing    | Manual       |
| `staging` | Pre-production validation            | Manual       |
| `main`    | Production deployment                | ✅ Automated |

### Promotion Flow

```
dev ──► staging ──► main
 │         │          │
 │         │          └──► Webhook → AWS sensor (auto-deploy)
 │         └──► Manual promotion via stg-main-deployment.sh
 └──► Local development & rule regression testing
```

---

## 🔐 Detection Engineering Standards

The discipline applied here is the same used daily in production WAF operations:

### Suricata Rules
- **Custom SID range:** `1000000 – 1999999`
- **Validation:** Every rule must pass `suricata -T` before promotion to `main`
- **Documentation:** Each rule includes `msg`, `classtype`, `metadata`, and `reference:` fields
- **MITRE Mapping:** All custom rules tagged with `mitre_technique_id`
- **Performance:** Sticky buffers + `fast_pattern` for cheap prefilter matching

### Wazuh Rules
- **Rule ID range:** `100000 – 119999`
- **Tiered structure:**
  - **Tier 1:** Mirror individual Suricata alerts with MITRE tags
  - **Tier 2:** Multi-event correlation (e.g. 5x SQLi from same source in 5 min = critical)
  - **Tier 3:** Multi-source correlation (Suricata + auth logs + FIM)
- **Severity:** Standardized 0–16 level mapping
- **MITRE Mapping:** `<mitre><id>T1190</id></mitre>` per rule

---

## ⚙️ Deployment Components

| Component           | Implementation                                              |
|---------------------|-------------------------------------------------------------|
| Repository          | GitHub                                                      |
| Webhook Listener    | Python 3 + Flask, port 5000                                 |
| Deployment Script   | Bash (`update.sh`) with `set -e` strict mode                |
| Service Management  | systemd (`threat-webhook.service`, auto-restart)            |
| Validation Engine   | Suricata's built-in config test (`-T` flag)                 |
| Permission Model    | Restricted sudoers — webhook can only run pre-approved cmds |
| Detection Engines   | Suricata 8 (NDR) + Wazuh 4.x (SIEM)                         |
| Infrastructure      | AWS EC2 (Ubuntu 24.04, c7i-flex.large, gp3 EBS)             |

---

## 🛡️ Safety Controls

- ✅ **Suricata pre-validation** before reload — broken configs cannot reach production
- ✅ **Wazuh restart + health verification** — silent failures are detected
- ✅ **systemd auto-restart** — webhook listener survives crashes
- ✅ **Branch-based deployment** — only `main` triggers production deploy
- ✅ **Restricted sudoers** — webhook executes only specific pre-approved commands

---

## 🧪 Testing Methodology

### Suricata
```bash
# Validate rule syntax (deployment gate)
sudo suricata -T -c /etc/suricata/suricata.yaml

# Replay PCAP through ruleset (regression test)
sudo suricata -r tests/pcaps/<sample>.pcap \
              -S suricata/rules/local.rules \
              -l /tmp/out/ -k none

# Live alert tailing
sudo tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
```

### Wazuh
```bash
# Interactive rule testing
sudo /var/ossec/bin/wazuh-logtest

# Service health
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard

# Alert inspection
sudo tail -f /var/ossec/logs/alerts/alerts.log
```

---

## 📊 MITRE ATT&CK Coverage

Detection content spans multiple tactics:

| Tactic                       | Techniques Targeted                    |
|------------------------------|----------------------------------------|
| TA0043 Reconnaissance        | T1595 (Active Scanning)                |
| TA0001 Initial Access        | T1190 (Exploit Public-Facing App)      |
| TA0002 Execution             | T1059 (Command & Scripting Interpreter)|
| TA0005 Defense Evasion       | Encoding/smuggling bypass detections   |
| TA0006 Credential Access     | T1110 (Brute Force), T1552 (IMDS abuse)|
| TA0007 Discovery             | T1083 (File & Directory Discovery)     |
| TA0011 Command and Control   | T1071 (Application Layer Protocol)     |

---

## 🔍 Troubleshooting

```bash
# Webhook service health
sudo systemctl status threat-webhook.service
sudo tail -f /var/log/threat-webhook.log

# Suricata status & logs
sudo systemctl status suricata
sudo journalctl -u suricata -n 50

# Wazuh stack
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard

# Verify webhook listener is reachable
curl -X POST http://localhost:5000/webhook
```

---

## 🎯 Key Capabilities Demonstrated

| Capability                          | Where in this repo                  |
|-------------------------------------|-------------------------------------|
| Version-controlled detection rules  | All rules tracked in Git            |
| Automated CI/CD for security        | Webhook → validation → deploy       |
| Multi-engine detection              | Suricata (NDR) + Wazuh (SIEM)       |
| MITRE ATT&CK alignment              | `metadata` blocks per rule          |
| DevSecOps applied to SecOps         | Branch promotion + safety gates     |
| Production safety controls          | Validation gates + health checks    |
| Infrastructure-as-Code mindset      | systemd service definitions         |
| Detection content lifecycle         | dev → staging → main promotion      |
| False-positive tuning discipline    | Iterative refinement of rules       |

---

## 🚀 Future Enhancements

- [ ] Automatic rollback on failed deployment
- [ ] Duplicate SID / Rule ID lint check
- [ ] GitHub Actions CI integration (pre-merge validation)
- [ ] Sigma → Wazuh conversion pipeline
- [ ] PCAP regression test harness in CI
- [ ] HMAC signature verification on webhook
- [ ] HTTPS endpoint via Let's Encrypt + nginx
- [ ] Prometheus metrics for deployment success rate
- [ ] Multi-sensor deployment via Ansible

---

## 👤 Author

**N Pavan Bushan Reddy**

Engineer — Security Research at Indusface | WAF & Detection Specialist | Threat Research & BAS Specialist

*4+ years of experience in threat detection, WAF optimization, and breach & attack simulation.
Develops proactive defenses through vulnerability research and security tool tuning.
Leads mitigation initiatives for banking and healthcare clients, reducing risks by 99%+
via custom signatures and threat modeling.*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://www.linkedin.com/in/n-pavan-bushan-reddy/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/npavanbushanreddy)
[![Email](https://img.shields.io/badge/Email-Contact-red?logo=gmail)](mailto:npavanbushanreddy1@gmail.com)

### Skill Areas
**Networking & Security Infrastructure:** Firewalls, WAF, WAS, WAAP, IDS, IPS, VPNs, DNS, OSI, proxies, TCP/IP, CDN, Load balancer, VLAN, Cryptographic fundamentals

**Vulnerability & Compliance Frameworks:** OWASP Top 10 (Web & API), CVSS, CVE

**Security Tooling:** Burp Suite, Nemecida, Cymulate, Picus, AppTrana WAF/WAS, SqlMap, Wireshark, Nmap, Nuclei, Grafana (SQL & Lucene), OpenSearch, Kibana

**Detection Engineering:** ModSec rules & regex, Suricata, Wazuh, anomaly-based detection, false-positive tuning, BAS testing, zero-day virtual patching

### Published Security Research
- 🔍 [**CVE-2024-38856** — Apache OFBiz Pre-Auth RCE Vulnerability](https://www.indusface.com/blog/)
- 🔍 [**CVE-2024-4577** — PHP-CGI RCE Exploitation in Windows Servers](https://www.indusface.com/blog/)
- 🔍 [**CVE-2025-24813** — Apache Tomcat Vulnerability Under Active Exploitation](https://www.indusface.com/blog/)
- 🔍 [**Zimbra Cross-Site Scripting Flaw**](https://www.indusface.com/blog/)
- 🔍 [**Hotjar OAuth+XSS** — Account Takeover Risk for Millions](https://www.indusface.com/blog/)
- 🔍 [**Cryptocurrency Mining via PHP Vulnerabilities**](https://www.indusface.com/blog/)
- 🔍 [**Credential Coercion in Ivanti Endpoint Manager**](https://www.indusface.com/blog/)

### Education
- **PG Diploma — IT Infrastructure, Systems and Security** | C-DAC E-City Bangalore | Sep 2021 – May 2022 | Aggregate: 73.86%
- **B.E — Computer Science Engineering** | East Point College of Engineering & Technology, VTU University | 2016 – 2020

### Certifications
- Introduction to Cybersecurity — SkillUp Online (Credential ID: 3432878)
- Introduction to Cybersecurity — Cisco
- Network Essentials — Cisco

---

## 📜 License

[MIT License](LICENSE) — see LICENSE file for details.

---

> **This repository represents a practical implementation of enterprise detection engineering practices within a controlled lab environment — applying 4+ years of production WAF & detection engineering discipline to open-source NDR + SIEM tooling, demonstrating that detection content should be treated as production-grade code.**
