flowchart TD
    subgraph "Central Infrastructure"
        WGManager["Centralized WireGuard\nKey Management"]
        CoreDNS["CoreDNS for Private DNS Resolution"]
        WGMesh["WireGuard Mesh Network"]
        Certbot["Let's Encrypt Certbot\nfor Internal TLS Certificates"]
    end

    subgraph "Lockness Distributed Key Management"
        LocknessCore["Lockness Core"]
        MPC["Multi-Party Computation (MPC)"]
        TSS["Threshold Signature Scheme (TSS)"]
        ConsensusModule["Validator Consensus Module\n(5-of-20 Approval Threshold)"]
        KeyShards["Distributed Key Shards"]
    end

    subgraph "GCP Environment"
        GCPTDX["Intel TDX Instance"]
        GCPGramine["Gramine SGX/TDX Attestation"]
        GCPCovalidator["Covalidator Pod"]
        GCPMPC["MPC Node"]
        GCPWG["WireGuard Endpoint"]
        GCPKeys["WireGuard Keys"]
    end

    subgraph "Azure Environment"
        AzureTDX["Intel TDX Instance"]
        AzureGramine["Gramine SGX/TDX Attestation"]
        AzureCovalidator["Covalidator Pod"]
        AzureMPC["MPC Node"]
        AzureWG["WireGuard Endpoint"]
        AzureKeys["WireGuard Keys"]
    end

    subgraph "Bare Metal Environment"
        BMTDX["Intel TDX Server"]
        BMGramine["Gramine SGX/TDX Attestation"]
        BMCovalidator["Covalidator Pod"]
        BMMPC["MPC Node"]
        BMWG["WireGuard Endpoint"]
        BMKeys["WireGuard Keys"]
    end

    subgraph "New Validator Joining Flow"
        NewTDX["New TDX Instance"]
        NewGramine["Gramine Attestation"]
        NewCovalidator["New Covalidator"]
        JoinRequest["Join Request"]
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

    %% Lockness MPC Connections
    LocknessCore -- "Distributed Key Management" --> MPC
    MPC -- "Threshold Signing" --> TSS
    TSS -- "Key Shards Distribution" --> KeyShards
    MPC -- "Validator Approval Logic" --> ConsensusModule

    %% Environment-specific Flows
    GCPTDX --> GCPCovalidator
    GCPTDX --> GCPGramine
    GCPCovalidator --> GCPMPC
    GCPMPC <-- "Key Shard" --> KeyShards
    GCPCovalidator --> GCPWG

    AzureTDX --> AzureCovalidator
    AzureTDX --> AzureGramine
    AzureCovalidator --> AzureMPC
    AzureMPC <-- "Key Shard" --> KeyShards
    AzureCovalidator --> AzureWG
    
    BMTDX --> BMCovalidator
    BMTDX --> BMGramine
    BMCovalidator --> BMMPC
    BMMPC <-- "Key Shard" --> KeyShards
    BMCovalidator --> BMWG

    %% Cross-Environment Attestation with Gramine
    GCPGramine -- "Attestation Evidence" --> MPC
    AzureGramine -- "Attestation Evidence" --> MPC
    BMGramine -- "Attestation Evidence" --> MPC

    %% New Validator Joining Process
    NewTDX --> NewGramine
    NewGramine --> NewCovalidator
    NewCovalidator --> JoinRequest
    JoinRequest --> ConsensusModule
    ConsensusModule -- "5-of-20 Approval Required" --> WGManager
    NewGramine -- "Attestation Evidence" --> ConsensusModule

    classDef gcp fill:#e6f7ff,stroke:#1890ff
    classDef azure fill:#f0f5ff,stroke:#597ef7
    classDef baremetal fill:#f9f0ff,stroke:#722ed1
    classDef network fill:#f6ffed,stroke:#52c41a
    classDef central fill:#fff7e6,stroke:#fa8c16
    classDef lockness fill:#ffcccb,stroke:#ff4d4f
    classDef newNode fill:#f5fffa,stroke:#3cb371

    class GCPTDX,GCPGramine,GCPCovalidator,GCPMPC,GCPWG,GCPKeys gcp
    class AzureTDX,AzureGramine,AzureCovalidator,AzureMPC,AzureWG,AzureKeys azure
    class BMTDX,BMGramine,BMCovalidator,BMMPC,BMWG,BMKeys baremetal
    class CoreDNS,WGMesh,Certbot,WGManager central
    class LocknessCore,MPC,TSS,ConsensusModule,KeyShards lockness
    class NewTDX,NewGramine,NewCovalidator,JoinRequest newNode
