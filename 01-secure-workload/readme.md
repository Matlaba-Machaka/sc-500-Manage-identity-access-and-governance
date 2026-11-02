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


