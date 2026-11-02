# Secure Azure Workload Lab (SC-500)

This project demonstrates how to run a Python application on an Azure Virtual Machine that securely retrieves secrets from an Azure Key Vault and queries Microsoft Graph **without storing any passwords, tokens, or credentials in the code**.

## 🏗️ What Was Built
*   **Azure Key Vault:** Stores our sensitive application database password.
*   **Managed Identity:** A passwordless identity assigned directly to our Azure VM.
*   **Network Firewall:** Key Vault access is locked down so only our specific VM can reach it.
*   **Azure Policy & Locks:** Guardrails that block public IP creation and prevent accidental deletion of our Key Vault.

---

## 🚀 How to Run the Scripts

Log into the Azure VM, open your terminal, install the required packages, and run the validation scripts:

```bash
pip install azure-identity azure-keyvault-secrets requests
```

### 1. Get Secret (`scripts/app.py`)
```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

# Replace with your actual Key Vault URL
VAULT_URL = "https://azure.net"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=VAULT_URL, credential=credential)

try:
    secret = client.get_secret("DatabasePassword")
    print(f"Success! Secret value is: {secret.value}")
except Exception as e:
    print(f"Access Denied: {e}")
```

### 2. Graph Query (`scripts/graph_query.py`)
```python
import requests
from azure.identity import DefaultAzureCredential

credential = DefaultAzureCredential()
token = credential.get_token("https://microsoft.com")
headers = {"Authorization": f"Bearer {token.token}"}

response = requests.get("https://microsoft.com", headers=headers)
print(response.json())
```

---

## 📸 Lab Proof & Screenshots

Here is the visual proof that the lab was successfully built and tested in Azure.

### 🔐 1. Key Vault & Identity Setup
*   **Secret Stored Successfully:** <img width="1910" height="722" alt="image" src="https://github.com/user-attachments/assets/ddfb3873-6128-489f-82cd-ceda73ac10ba" />

*   **Encryption Key Created:** <img width="1910" height="682" alt="image" src="https://github.com/user-attachments/assets/2e926044-17b5-42b2-921f-f6fdd07989a2" />

*   **VM Managed Identity Turned On:** <img width="1920" height="947" alt="image" src="https://github.com/user-attachments/assets/76bdbba5-039f-4f97-b24c-1fd68549fe8d" />

*   **VM Granted Access to Key Vault:** <img width="1277" height="1117" alt="image" src="https://github.com/user-attachments/assets/dba25f5c-475a-4dba-a89c-02d0fb816d47" />


### 🛑 2. Network Hardening & Governance
*   **Key Vault Firewall Enabled:** <img width="1914" height="942" alt="Screenshot 2026-10-30 091027" src="https://github.com/user-attachments/assets/423f2280-4bd1-4a72-8fc9-dedf4ae55022" />

*   **Delete Attempt Blocked by Lock:** <img width="1900" height="352" alt="image" src="https://github.com/user-attachments/assets/af562160-822d-419c-9d78-4c2712734f5d" />

*   **Public IP Blocked by Azure Policy:** <img width="1902" height="481" alt="image" src="https://github.com/user-attachments/assets/f0f00c12-9f96-4dec-8b0e-a73293beb564" />



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



