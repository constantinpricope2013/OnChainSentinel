


Schemas is 



```mermaid
flowchart LR
    %% ========= INGESTION =========

    subgraph Users
    A[Web3 Wallets]
    B[dApps]
    C[CEX<br/>(Centralized Exchanges)]
    end

    D[Blockchain<br/>Explorers]

    subgraph Blockchain
    N1[(ETH Node)]
    N2[(TRON Node)]
    N3[(Polygon Node)]
    end

    subgraph Ingestion["Cloud Run — Multi-chain collectors"]
    IC1[ETH Parser → raw unified tx schema]
    IC2[TRON Parser → raw unified tx schema]
    IC3[Polygon Parser → raw unified tx schema]
    end

    Users -->|trigger tx| Blockchain
    Blockchain -->|blocks, receipts, traces| N1 & N2 & N3

    N1 --> IC1
    N2 --> IC2
    N3 --> IC3

    IC1 --> RT(raw_tx)
    IC2 --> RT
    IC3 --> RT

    %% ========= STREAMING TOPICS =========
    RT((raw_tx))
    RTX((risk_tx))
    RA((risk_address))
    HTX((history_tx))
    ALERT((risk_alerts))

    %% ========= CORE PROCESSING =========

    subgraph FirstPass["Local Risk Scoring (Cloud Run or Flink)"]
    RTRA[Raw transaction risk analyzer<br/>(heuristics + ML)]
    end

    RT --> RTRA --> RTX

    subgraph Aggregation["Address Risk Aggregation (Flink/Dataflow)"]
    ARA[address_risk_aggregator<br/>(rolling windows)]
    end

    RTX --> ARA --> RA

    %% ========= STATE & HISTORY =========

    subgraph State["Persistent Storage"]
    BT[(Bigtable<br/>address state store)]
    BQ[(BigQuery<br/>transaction risk history)]
    end

    RA -->|write updated state| BT
    RTX -->|append| BQ

    %% ========= STATE UPDATER (missing before) =========

    subgraph Stabilization["Risk State Updater (MISSING BEFORE)"]
    RSU[risk_state_updater<br/>decay, cooldown, dedup, convergence]
    end

    RA --> RSU --> BT

    %% ========= HISTORY LOOKUP =========

    subgraph HistoryBuilder["History risk tx producer"]
    HRP[Fetch tx history for flagged addresses<br/>(only if needed)]    
    end

    RA -->|if risk HIGH or risk changed significantly| HRP --> HTX
    HTX --> BT

    %% ========= GEMINI RECURSIVE ANALYSIS =========

    subgraph GeminiBlock["Gemini Behavioral Reasoning Layer"]
    GEM[Gemini<br/>risk reasoning + narrative]
    Dedup[Cooldown & dedup guard<br/>avoid infinite recursion]
    end

    %% explicit flow:
    BT -->|read state & recent history| GEM -->|behavior risk result| Dedup --> RSU

    %% ========= API EXPOSURE =========

    subgraph APILayer["Risk API Exposure"]
    APIGW[API Gateway]
    RAPI[Risk API (Cloud Run)]
    end

    Users -->|query risk| APIGW --> RAPI --> BT
    D -->|explorer queries| APIGW
    C -->|CEX risk lookups| APIGW
    B -->|dApp risk checks| APIGW

    %% ========= OUTPUT CONSUMERS =========

    subgraph Outputs["Consumers & Intelligence Outputs"]
    UI[Risk Dashboard (Looker Studio)]
    SOC[SIEM / Alerts / Compliance ops]
    ENDPOINTS[Wallets, Bridges, Custodians]
    end

    RA -->|Medium/High| ALERT --> SOC
    RA --> UI
    APIGW --> ENDPOINTS
```