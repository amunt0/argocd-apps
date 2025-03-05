# diagram v2 - network

```mermaid
flowchart TD
    subgraph "Central Infrastructure"
        WGManager["Centralized WireGuard\nKey Management"]
        CoreDNS["CoreDNS for Private DNS Resolution"]
        WGMesh["WireGuard Mesh Network"]
        Certbot["Let's Encrypt Certbot\nfor Internal TLS Certificates"]
    end

    subgraph "GCP Environment"
        GCPTDX["Intel TDX Instance"]
        GCPGramine["Gramine SGX/TDX Attestation"]
        GCPKMS["Google Cloud KMS"]
        GCPCovalidator["Covalidator Pod"]
        GCPWG["WireGuard Endpoint"]
        GCPKeys["WireGuard Keys"]
    end

    subgraph "Azure Environment"
        AzureTDX["Intel TDX Instance"]
        AzureGramine["Gramine SGX/TDX Attestation"]
        AzureCovalidator["Covalidator Pod"]
        AzureWG["WireGuard Endpoint"]
        AzureKeys["WireGuard Keys"]
    end

    subgraph "Bare Metal Environment"
        BMTDX["Intel TDX Server"]
        BMGramine["Gramine SGX/TDX Attestation"]
        BMCovalidator["Covalidator Pod"]
        BMWG["WireGuard Endpoint"]
        BMKeys["WireGuard Keys"]
    end

    %% Key Management Flow
    WGManager -- "Generate & Provision Keys" --> GCPKeys
    WGManager -- "Generate & Provision Keys" --> AzureKeys
    WGManager -- "Generate & Provision Keys" --> BMKeys

    %% Network Connections
    GCPKeys --> GCPWG
    AzureKeys --> AzureWG
    BMKeys --> BMWG

    GCPWG <--> WGMesh
    AzureWG <--> WGMesh
    BMWG <--> WGMesh

    WGMesh --> CoreDNS

    %% Certificate Management
    Certbot --> GCPWG
    Certbot --> AzureWG
    Certbot --> BMWG

    %% Environment-specific Flows
    GCPTDX --> GCPCovalidator
    GCPTDX --> GCPGramine
    GCPGramine --> GCPKMS
    GCPKMS --> GCPCovalidator
    GCPCovalidator --> GCPWG

    AzureTDX --> AzureCovalidator
    AzureTDX --> AzureGramine
    AzureCovalidator --> AzureWG
    
    BMTDX --> BMCovalidator
    BMTDX --> BMGramine
    BMCovalidator --> BMWG

    %% Cross-Environment Attestation with Gramine
    GCPGramine -- "Gramine Attestation\nEvidence Exchange" --> AzureGramine
    GCPGramine -- "Gramine Attestation\nEvidence Exchange" --> BMGramine
    AzureGramine -- "Gramine Attestation\nEvidence Exchange" --> BMGramine

    classDef gcp fill:#e6f7ff,stroke:#1890ff
    classDef azure fill:#f0f5ff,stroke:#597ef7
    classDef baremetal fill:#f9f0ff,stroke:#722ed1
    classDef network fill:#f6ffed,stroke:#52c41a
    classDef central fill:#fff7e6,stroke:#fa8c16

    class GCPTDX,GCPGramine,GCPKMS,GCPCovalidator,GCPWG,GCPKeys gcp
    class AzureTDX,AzureGramine,AzureCovalidator,AzureWG,AzureKeys azure
    class BMTDX,BMGramine,BMCovalidator,BMWG,BMKeys baremetal
    class CoreDNS,WGMesh,Certbot network
    class WGManager central
