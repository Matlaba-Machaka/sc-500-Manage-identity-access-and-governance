# Secure Azure Workload Lab (SC-500)

This project demonstrates how to run a Python application on an Azure Virtual Machine that securely retrieves secrets from an Azure Key Vault and queries Microsoft Graph **without storing any passwords, tokens, or credentials in the code**.

## 🏗️ What Was Built
*   **Azure Key Vault:** Stores our sensitive application database password.
*   **Managed Identity:** A passwordless identity assigned directly to our Azure VM.
*   **Network Firewall:** Key Vault access is locked down so only our specific VM can reach it.
*   **Azure Policy & Locks:** Guardrails that block public IP creation and prevent accidental deletion of our Key Vault.

---

# Engineering Lessons Learned & Architectural Trade-offs

### 1. The Power of `DefaultAzureCredential`
Using `DefaultAzureCredential` allows the exact same Python script to be executed in local development (using Azure CLI or environment variables) and in production (using Azure Managed Identity) without modifying a single line of code. This dramatically simplifies the CI/CD pipeline and local debugging.

### 2. Network Isolation vs. Management Overhead
Restricting the Azure Key Vault firewall to "Selected Networks" instantly hardens the environment against data exfiltration and external brute-force attacks. However, it requires careful networking planning. If the VM is accessing the Key Vault over the public endpoint, its public outbound IP must be whitelisted. For zero-trust environments, deploying a **Private Endpoint** is the preferred architectural pattern.

### 3. Least Privilege & Admin Consent in Graph API
Enabling Managed Identity grants the VM a security principal in Entra ID, but it has *zero* permissions by default. To make `graph-query.py` function, directory read access (`User.Read.All`) must be granted via PowerShell or the Azure Portal, requiring a global administrator's consent. This demonstrates a clear separation of duties between cloud infrastructure management and identity governance.

### 4. Policy vs. Locks
* **Azure Policy** is proactive and preventive, ensuring misconfigurations (like Public IPs) never make it into the environment.
* **Resource Locks** are reactive shields that safeguard existing state. A `CanNotDelete` lock on the Key Vault ensures that even a highly privileged administrator cannot accidentally wipe out critical application configuration secrets without an intentional, two-step deletion workflow.



