# diagram v2

```mermaid
flowchart TD
    subgraph "GCP Infrastructure"
        GKE["GCP Kubernetes Engine"]
        VPC["Virtual Private Cloud"]
        
        subgraph "Confidential Computing"
            TDX["Intel TDX Instance"]
            
            subgraph "TDX Pods"
                Covalidator["Covalidator Pod\n(specific SHA)"]
                Helios["Helios Light Client Pod"]
            end
            
            Gramine["Gramine SGX/TDX\nAttestation Framework"]
            GramineRA["Gramine Remote Attestation"]
        end
        
        subgraph "Lockness Key Management"
            TSS["Threshold Signature Scheme"]
            MPC["Multi-Party Computation"]
            
            subgraph "Lockness Security"
                LocknessCore["Lockness Core"]
                SecretKey["Protected Key Material"]
                
                subgraph "Access Control Conditions"
                    TDXCondition["Condition: Must be TDX environment"]
                    PodCondition["Condition: Must be covalidator pod"]
                    SHACondition["Condition: Must match specific SHA"]
                end
            end
        end
    end
    
    User["User/Admin"] --> GKE
    
    GKE --> VPC
    VPC --> TDX
    
    TDX --> Covalidator
    TDX --> Helios
    TDX --> Gramine
    
    Gramine --> GramineRA
    
    Covalidator -- "1. Request Key Access" --> LocknessCore
    
    GramineRA -- "2. Provide TDX Attestation" --> TDXCondition
    
    LocknessCore -- "3. Verify TDX environment" --> TDXCondition
    LocknessCore -- "4. Verify pod identity" --> PodCondition
    LocknessCore -- "5. Verify SHA of pod" --> SHACondition
    
    LocknessCore -- "6. If all conditions pass" --> TSS
    LocknessCore -- "6. If all conditions pass" --> MPC
    
    TSS -- "7. Partial key shards" --> Covalidator
    MPC -- "7. Secure computation" --> Covalidator
    
    TSS -- "Manages" --> SecretKey
    MPC -- "Protects" --> SecretKey
    
    classDef gcpInfra fill:#e6f7ff,stroke:#1890ff
    classDef confidential fill:#fff7e6,stroke:#fa8c16
    classDef security fill:#f9f0ff,stroke:#722ed1
    classDef pods fill:#f6ffed,stroke:#52c41a
    classDef lockness fill:#ffcccb,stroke:#ff4d4f
    
    class GKE,VPC gcpInfra
    class TDX,Gramine,GramineRA confidential
    class TDXCondition,PodCondition,SHACondition security
    class LocknessCore,TSS,MPC,SecretKey lockness
    class Covalidator,Helios pods
