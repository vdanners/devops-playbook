# 🚀 DevOps Playbook & SRE Toolkit

Welcome to my **DevOps Playbook**. This repository serves as a centralized knowledge base, portfolio, and active toolkit for Cloud Engineering and Site Reliability Engineering (SRE). 

As a professional transitioning from a solid foundation in traditional datacenters to modern cloud environments, I use this repository to document my daily operations, build reusable automations, and practice architecture design.

## 🏗️ Repository Structure

This is a living repository. I am continuously feeding it with new modules, scripts, and documentation based on my daily challenges.

Here is what you will find inside:

### 🧰 `📂 scripts/`
Bash utilities for system administration, database backups, and monitoring. 
* *Principles:* Fail-fast (`set -euo pipefail`), automated error handling, auto-recovery mechanisms, and structured logging.

### ☁️ `📂 terraform/`
Infrastructure as Code (IaC) modules and templates for provisioning secure, highly available, and scalable environments. 
* *Principles:* Modular design, state management, and DRY (Don't Repeat Yourself).

### ⚙️ `📂 ansible/`
Playbooks and roles for configuration management, OS hardening, and automated software provisioning across multiple nodes.

### ☸️ `📂 kubernetes/`
Kubernetes manifests, Helm charts, and GitOps configurations (using ArgoCD) for deploying and managing containerized applications at scale.

### 📚 `📂 docs/`
Standard Operating Procedures (SOPs), architectural diagrams, and troubleshooting playbooks.

---

## 🛠️ Engineering Practices Implemented
To ensure the reliability and quality of this repository, I apply standard DevOps practices directly to it:
* **CI/CD Pipelines:** Automated linting via GitHub Actions (e.g., ShellCheck for Bash scripts) to prevent bad code from reaching the `main` branch.
* **Security:** No hardcoded credentials. All scripts rely on secure local environment variables (`.env`) or secret managers.
* **Semantic Versioning & Commits:** Clean Git history using Conventional Commits.

---

## 👨‍💻 About the Author

**Victor Danner** *Cloud Engineer | DevOps | SRE*

With over 15 years of experience in IT infrastructure, I specialize in bridging the gap between traditional operations and cloud-native technologies. I am passionate about reducing *toil* through automation, building resilient architectures, and fostering a culture of continuous improvement.

📫 **Let's connect:** [LinkedIn Profile](https://www.linkedin.com/in/vdannersg)