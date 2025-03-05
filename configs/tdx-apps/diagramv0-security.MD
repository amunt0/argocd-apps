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
            
            ConfidentialSpace["Confidential Space Validation\nconfidential-space.security.cloud.google.com: true"]
        end
        
        subgraph "Google Cloud Security"
            IAM["Identity & Access Management"]
            KMS["Google Cloud KMS"]
            SecretKey["Protected Key Material"]
            
            subgraph "IAM Conditions"
                TDXCondition["Condition: Must be TDX environment"]
                PodCondition["Condition: Must be covalidator pod"]
                SHACondition["Condition: Must match specific SHA"]
            end
        end
    end
    
    User["User/Admin"] --> GKE
    
    GKE --> VPC
    VPC --> TDX
    
    TDX --> Covalidator
    TDX --> Helios
    TDX --> ConfidentialSpace
    
    Covalidator -- "1. Request Key Access" --> IAM
    
    IAM -- "2. Verify TDX environment" --> TDXCondition
    IAM -- "3. Verify pod identity" --> PodCondition
    IAM -- "4. Verify SHA of pod" --> SHACondition
    
    TDXCondition -- "Validation" --> ConfidentialSpace
    
    IAM -- "5. If all conditions pass" --> KMS
    KMS -- "6. Release key" --> Covalidator
    
    KMS -- "Manages" --> SecretKey
    
    classDef gcpInfra fill:#e6f7ff,stroke:#1890ff
    classDef confidential fill:#fff7e6,stroke:#fa8c16
    classDef security fill:#f9f0ff,stroke:#722ed1
    classDef pods fill:#f6ffed,stroke:#52c41a
    
    class GKE,VPC gcpInfra
    class TDX,ConfidentialSpace confidential
    class IAM,KMS,SecretKey,TDXCondition,PodCondition,SHACondition security
    class Covalidator,Helios pods
