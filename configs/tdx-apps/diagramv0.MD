# diagram v0

```mermaid
flowchart TB
    subgraph "Google Cloud Platform"
        subgraph "TDX Secured Environment"
            TDX["TDX VM\n(Protected Workload)"]
            GRPC["gRPC2 Endpoint"]
            CERT["TLS Certificate"]
            
            subgraph "Blockchain Components"
                HELIOS["Helios Light Client"]
                COVAL["Covalidator"]
                
                HELIOS -- "Block Headers\nVerification" --> COVAL
                COVAL -- "State Sync" --> HELIOS
            end
            
            TDX --> GRPC
            CERT -- "Secures" --> GRPC
            TDX -- "Hosts" --> HELIOS
            TDX -- "Hosts" --> COVAL
        end
        
        ATTEST["Google Attestation\nService"]
        
        subgraph "Key Management"
            KMS["Google Cloud KMS"]
            KEYS["TDX-bound\nEncryption Keys"]
            
            KMS -- "Manages" --> KEYS
        end
        
        CFDNS["Cloudflare DNS\n+ DDoS Protection"]
    end
    
    CLIENT["External Client"]
    
    %% Connections
    TDX -- "TD Quote" --> ATTEST
    ATTEST -- "Validates" --> TDX
    ATTEST -- "Attestation Result" --> KMS
    KEYS -- "Conditional Access" --> TDX
    GRPC -- "Secure Communication" --> CLIENT
    CLIENT -- "Service Request" --> CFDNS
    CFDNS -- "Route Request" --> GRPC
    
    %% Styling
    classDef tdx fill:#d4edda,stroke:#28a745,stroke-width:2px
    classDef attestation fill:#fff3cd,stroke:#fd7e14,stroke-width:2px
    classDef kms fill:#f8d7da,stroke:#dc3545,stroke-width:2px
    classDef dns fill:#cce5ff,stroke:#007bff,stroke-width:2px
    classDef client fill:#f8f9fa,stroke:#6c757d,stroke-width:1px
    classDef blockchain fill:#e0cfff,stroke:#6f42c1,stroke-width:2px
    
    class TDX,GRPC,CERT tdx
    class ATTEST attestation
    class KMS,KEYS kms
    class CFDNS dns
    class CLIENT client
    class HELIOS,COVAL blockchain
