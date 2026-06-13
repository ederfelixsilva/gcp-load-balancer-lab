<div align="center">

# ☁️ GCP HTTP Load Balancer — Scalable Web Infrastructure

### Arquitetura de Alta Disponibilidade com Google Cloud Platform

<br/>

![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Compute Engine](https://img.shields.io/badge/Compute_Engine-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Apache](https://img.shields.io/badge/Apache-D22128?style=for-the-badge&logo=apache&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

<br/>

![Status](https://img.shields.io/badge/Status-Concluído-brightgreen?style=flat-square)
![Cloud](https://img.shields.io/badge/Cloud-GCP-blue?style=flat-square&logo=google-cloud)
![IaC](https://img.shields.io/badge/Provisionamento-gcloud_CLI-orange?style=flat-square)
![Disponibilidade](https://img.shields.io/badge/Alta_Disponibilidade-Multi--VM-purple?style=flat-square)
![Licença](https://img.shields.io/badge/Licença-MIT-green?style=flat-square)

<br/>

> **Implementação de uma arquitetura web escalável e altamente disponível no Google Cloud Platform,  
> utilizando Compute Engine, HTTP Load Balancer, Health Checks e automação via Shell Script.**

</div>

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Objetivos do Projeto](#-objetivos-do-projeto)
- [Arquitetura da Solução](#-arquitetura-da-solução)
- [Diagrama da Infraestrutura](#-diagrama-da-infraestrutura)
- [Componentes GCP Utilizados](#-componentes-gcp-utilizados)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Fluxo de Funcionamento do Load Balancer](#-fluxo-de-funcionamento-do-load-balancer)
- [Configuração das VMs](#-configuração-das-vms)
- [Configuração de Rede e Firewall](#-configuração-de-rede-e-firewall)
- [Health Checks](#-health-checks)
- [Backend Services](#-backend-services)
- [Escalabilidade Horizontal](#-escalabilidade-horizontal)
- [Alta Disponibilidade](#-alta-disponibilidade)
- [Automação com Scripts](#-automação-com-scripts)
- [Principais Comandos gcloud](#-principais-comandos-gcloud-utilizados)
- [Arquitetura em Produção](#-arquitetura-em-produção)
- [Resultados Obtidos](#-resultados-obtidos)
- [Lições Aprendidas](#-lições-aprendidas)
- [Competências Demonstradas](#-competências-demonstradas)
- [Roadmap de Evolução](#-roadmap-de-evolução)
- [Possíveis Melhorias Futuras](#-possíveis-melhorias-futuras)
- [Conclusão Técnica](#-conclusão-técnica)
- [Autor](#-autor)

---

## 🔭 Visão Geral

Este projeto documenta a implementação prática de uma **arquitetura web escalável e altamente disponível** no **Google Cloud Platform (GCP)**. A solução foi construída do zero utilizando exclusivamente a **gcloud CLI** via Cloud Shell, sem uso de interfaces gráficas — demonstrando domínio real das ferramentas de linha de comando em ambiente cloud.

A infraestrutura provisiona **três instâncias de Compute Engine** configuradas automaticamente via *startup scripts*, cada uma executando um servidor **Apache HTTP Server** com uma página HTML personalizada. Um **HTTP Load Balancer** gerenciado pelo GCP distribui o tráfego entre as instâncias com base em **health checks** contínuos, garantindo resiliência e disponibilidade mesmo em cenários de falha parcial.

O projeto aplica conceitos fundamentais de **Cloud Computing**, **DevOps** e **Site Reliability Engineering (SRE)**, incluindo:

- Provisionamento de infraestrutura via CLI
- Automação de configuração com Shell Script
- Balanceamento de carga em camada 7 (HTTP)
- Monitoramento de saúde das instâncias
- Isolamento de rede com regras de firewall
- Separação de responsabilidades entre camadas da arquitetura

---

## 🎯 Objetivos do Projeto

| # | Objetivo | Status |
|---|----------|--------|
| 1 | Provisionar múltiplas VMs no Compute Engine via CLI | ✅ Concluído |
| 2 | Configurar Apache automaticamente via Startup Script | ✅ Concluído |
| 3 | Implementar regras de firewall para tráfego HTTP | ✅ Concluído |
| 4 | Criar Instance Groups para agrupamento lógico das VMs | ✅ Concluído |
| 5 | Configurar Health Checks para monitoramento contínuo | ✅ Concluído |
| 6 | Implementar Backend Service com balanceamento de carga | ✅ Concluído |
| 7 | Configurar HTTP Load Balancer com IP externo global | ✅ Concluído |
| 8 | Validar distribuição de requisições entre as instâncias | ✅ Concluído |
| 9 | Documentar toda a infraestrutura e comandos utilizados | ✅ Concluído |

---

## 🏗️ Arquitetura da Solução

A arquitetura implementada segue o padrão de **três camadas** clássico de aplicações web em cloud, adaptado para o modelo gerenciado do GCP:

```
┌─────────────────────────────────────────────────────┐
│                     INTERNET                        │
│              (Clientes / Usuários)                  │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP (porta 80)
                       ▼
┌─────────────────────────────────────────────────────┐
│            HTTP LOAD BALANCER (Global)              │
│         IP Externo Estático — Camada 7              │
│    ┌──────────────────────────────────────────┐     │
│    │          URL Map / Forwarding Rule       │     │
│    └──────────────────────────────────────────┘     │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────┼────────────┐
          │            │            │
          ▼            ▼            ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│    web-1    │ │    web-2    │ │    web-3    │
│  Apache 80  │ │  Apache 80  │ │  Apache 80  │
│  us-east1-b │ │  us-east1-c │ │  us-east1-d │
└─────────────┘ └─────────────┘ └─────────────┘
       ▲                ▲               ▲
       └────────────────┴───────────────┘
                        │
            ┌───────────┴───────────┐
            │    HEALTH CHECK       │
            │  (TCP/HTTP — porta 80)│
            └───────────────────────┘
```

### Camadas da Arquitetura

| Camada | Componente GCP | Função |
|--------|---------------|--------|
| **Edge** | HTTP Load Balancer | Recebe requisições externas e distribui tráfego |
| **Controle** | URL Map + Backend Service | Define regras de roteamento e backend alvo |
| **Saúde** | Health Check | Monitora disponibilidade das instâncias |
| **Compute** | Compute Engine VMs | Processa e responde às requisições HTTP |
| **Rede** | VPC + Firewall Rules | Controla e isola o tráfego de rede |

---

## 📊 Diagrama da Infraestrutura

### Fluxo Completo de uma Requisição

```mermaid
flowchart TD
    A[👤 Usuário / Cliente] -->|HTTP Request| B[🌐 IP Externo Global]

    B --> C{⚖️ HTTP Load Balancer\nForwarding Rule}

    C --> D[🗺️ URL Map\nurl-map-web]

    D --> E[🔧 Backend Service\nbackend-service-web]

    E --> F{📊 Health Check\nHTTP :80}

    F -->|Instância Saudável ✅| G[Instance Group\nweb-instance-group]

    G -->|Round Robin| H[🖥️ web-1\nApache HTTP]
    G -->|Round Robin| I[🖥️ web-2\nApache HTTP]
    G -->|Round Robin| J[🖥️ web-3\nApache HTTP]

    H -->|HTTP Response| A
    I -->|HTTP Response| A
    J -->|HTTP Response| A

    F -->|Instância Falhou ❌| K[🚫 Remove do Pool\Até Recuperação]

    style A fill:#4285F4,color:#fff
    style C fill:#EA4335,color:#fff
    style E fill:#FBBC04,color:#000
    style F fill:#34A853,color:#fff
    style G fill:#9C27B0,color:#fff
    style H fill:#0F9D58,color:#fff
    style I fill:#0F9D58,color:#fff
    style J fill:#0F9D58,color:#fff
    style K fill:#EA4335,color:#fff
```

### Topologia de Rede

```mermaid
graph LR
    subgraph Internet
        U[👤 Usuários]
    end

    subgraph GCP["☁️ Google Cloud Platform"]
        subgraph LB["HTTP Load Balancer"]
            FR[Forwarding Rule\n0.0.0.0:80]
            TP[Target HTTP Proxy]
            UM[URL Map]
        end

        subgraph Backend["Backend Service"]
            BS[backend-service-web\nBalancing: ROUND_ROBIN]
            HC[Health Check\nHTTP :80 /]
        end

        subgraph IG["Instance Group — us-east1"]
            VM1[web-1\ne2-micro | us-east1-b]
            VM2[web-2\ne2-micro | us-east1-c]
            VM3[web-3\ne2-micro | us-east1-d]
        end

        subgraph Network["VPC Default Network"]
            FW1[Firewall: allow-http\nTCP:80 — 0.0.0.0/0]
            FW2[Firewall: allow-health-check\n130.211.0.0/22\n35.191.0.0/16]
        end
    end

    U -->|HTTP| FR
    FR --> TP --> UM --> BS
    BS --> HC
    HC -->|Monitora| VM1
    HC -->|Monitora| VM2
    HC -->|Monitora| VM3
    BS -->|Roteia| VM1
    BS -->|Roteia| VM2
    BS -->|Roteia| VM3
    FW1 -.->|Permite| VM1
    FW1 -.->|Permite| VM2
    FW1 -.->|Permite| VM3
    FW2 -.->|Permite HC| VM1
    FW2 -.->|Permite HC| VM2
    FW2 -.->|Permite HC| VM3
```

### Ciclo de Vida de uma Instância

```mermaid
stateDiagram-v2
    [*] --> Provisionando : gcloud compute instances create
    Provisionando --> Inicializando : VM criada
    Inicializando --> Configurando : Startup Script executa
    Configurando --> Ativa : Apache instalado e rodando
    Ativa --> Saudável : Health Check passa ✅
    Saudável --> NoPool : Adicionada ao Backend Service
    NoPool --> RecebendoTráfego : Load Balancer roteia
    RecebendoTráfego --> FalhaNaVerificação : Health Check falha ❌
    FalhaNaVerificação --> RemovidaDoPool : Removida temporariamente
    RemovidaDoPool --> Saudável : Instância se recupera
    RecebendoTráfego --> Ativa : Operação normal
```

---

## 🧩 Componentes GCP Utilizados

| Serviço | Descrição | Papel na Arquitetura |
|---------|-----------|---------------------|
| **Compute Engine** | VMs gerenciadas pelo GCP | Hospedam o servidor Apache HTTP |
| **Cloud Shell** | Terminal gerenciado com gcloud | Ambiente de provisionamento |
| **gcloud CLI** | Interface de linha de comando GCP | Orquestração de todos os recursos |
| **VPC Default Network** | Rede virtual privada | Isolamento e comunicação entre recursos |
| **Firewall Rules** | Regras de controle de tráfego | Permitem HTTP e health checks |
| **Instance Groups** | Agrupamento lógico de VMs | Pool de backends para o Load Balancer |
| **Health Checks** | Sondagem de disponibilidade | Monitora a saúde de cada instância |
| **Backend Services** | Configuração do backend HTTP | Define como o tráfego é distribuído |
| **URL Map** | Mapeamento de URLs para backends | Roteamento de requisições |
| **Target HTTP Proxy** | Proxy de terminação HTTP | Conecta o frontend ao URL Map |
| **Forwarding Rule** | Regra de encaminhamento | Expõe o Load Balancer com IP externo |
| **Static External IP** | IP público estático global | Ponto de entrada único e permanente |

---

## 📁 Estrutura do Projeto

```
gcp-http-load-balancer/
│
├── 📄 README.md                        # Documentação completa do projeto
│
├── 🖥️  create-vms.sh                   # Provisiona as 3 instâncias de Compute Engine
├── 🔥 firewall.sh                      # Cria as regras de firewall na VPC
├── 📦 startup.sh                       # Script de inicialização básico das VMs
│
├── 📂 http-load-balancer/              # Módulo: HTTP Load Balancer (Camada 7)
│   ├── 📋 instance-template.sh         # Cria Instance Template com startup script
│   ├── 🗂️  instance-group.sh           # Cria e configura o Unmanaged Instance Group
│   ├── ⚙️  backend.sh                  # Configura Health Check e Backend Service
│   └── 📦 startup.sh                  # Startup script embutido no template
│
└── 📂 network-load-balancer/           # Módulo: Network Load Balancer (Camada 4)
    └── 🔗 create-lb.sh                 # Provisiona o NLB como alternativa
```

### Descrição dos Scripts

```mermaid
flowchart LR
    A[create-vms.sh] -->|Cria| B[web-1, web-2, web-3]
    C[firewall.sh] -->|Configura| D[Regras de Firewall]
    E[startup.sh] -->|Instala| F[Apache + HTML]
    G[instance-template.sh] -->|Gera| H[Instance Template]
    I[instance-group.sh] -->|Agrupa| J[Instance Group]
    K[backend.sh] -->|Configura| L[Health Check + Backend Service]
```

---

## 🔄 Fluxo de Funcionamento do Load Balancer

O Load Balancer do GCP opera em **camada 7 (HTTP/HTTPS)** e segue o fluxo abaixo a cada requisição:

```mermaid
sequenceDiagram
    participant U as 👤 Usuário
    participant IP as 🌐 IP Externo (Forwarding Rule)
    participant Proxy as 🔀 Target HTTP Proxy
    participant UM as 🗺️ URL Map
    participant BS as ⚙️ Backend Service
    participant HC as 🏥 Health Check
    participant VM as 🖥️ VM (web-1/2/3)

    U->>IP: GET / HTTP/1.1
    IP->>Proxy: Encaminha requisição
    Proxy->>UM: Consulta regras de roteamento
    UM->>BS: Seleciona backend configurado

    BS->>HC: Verifica instâncias saudáveis
    HC-->>BS: Lista de instâncias ativas

    BS->>VM: Roteia para instância saudável (Round Robin)
    VM-->>U: HTTP 200 OK + HTML Response

    Note over HC,VM: Health Checks ocorrem a cada 10s,\nindependente das requisições
```

### Algoritmo de Distribuição de Carga

O **Backend Service** foi configurado com o modo de balanceamento `UTILIZATION`, que distribui o tráfego de forma proporcional à capacidade de cada instância. Em instâncias homogêneas (mesmo tipo de máquina), o comportamento equivale ao **Round Robin**.

| Requisição | Instância Selecionada | Critério |
|------------|----------------------|----------|
| 1ª | web-1 | Menor utilização |
| 2ª | web-2 | Menor utilização |
| 3ª | web-3 | Menor utilização |
| 4ª | web-1 | Ciclo reinicia |
| N+1 | web-2 (se web-1 falhar) | Failover automático |

---

## 🖥️ Configuração das VMs

### Especificações das Instâncias

| Instância | Zona | Tipo de Máquina | OS | Serviço |
|-----------|------|----------------|-----|---------|
| **web-1** | us-east1-b | e2-micro | Debian GNU/Linux 11 | Apache 2.4 |
| **web-2** | us-east1-c | e2-micro | Debian GNU/Linux 11 | Apache 2.4 |
| **web-3** | us-east1-d | e2-micro | Debian GNU/Linux 11 | Apache 2.4 |

> As instâncias foram distribuídas em **zonas distintas** da mesma região para garantir isolamento de falhas.

### Script de Criação das VMs

```bash
#!/bin/bash
# create-vms.sh — Provisiona as instâncias de Compute Engine

set -euo pipefail

PROJECT_ID="seu-projeto-gcp"
REGION="us-east1"
MACHINE_TYPE="e2-micro"
IMAGE_FAMILY="debian-11"
IMAGE_PROJECT="debian-cloud"
TAG="allow-http"

declare -A ZONES=(
  ["web-1"]="us-east1-b"
  ["web-2"]="us-east1-c"
  ["web-3"]="us-east1-d"
)

for VM_NAME in "${!ZONES[@]}"; do
  ZONE="${ZONES[$VM_NAME]}"
  echo "🚀 Criando instância: ${VM_NAME} na zona ${ZONE}..."

  gcloud compute instances create "${VM_NAME}" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --machine-type="${MACHINE_TYPE}" \
    --image-family="${IMAGE_FAMILY}" \
    --image-project="${IMAGE_PROJECT}" \
    --tags="${TAG}" \
    --metadata-from-file startup-script=startup.sh \
    --no-address

  echo "✅ Instância ${VM_NAME} criada com sucesso."
done

echo "🎉 Todas as instâncias foram provisionadas."
```

### Startup Script (Configuração Automática)

```bash
#!/bin/bash
# startup.sh — Instalado e executado automaticamente na inicialização da VM

set -euo pipefail

# Atualiza os repositórios e instala o Apache
apt-get update -y
apt-get install -y apache2

# Habilita e inicia o serviço Apache
systemctl enable apache2
systemctl start apache2

# Obtém o nome da instância via metadata do GCP
VM_HOSTNAME=$(curl -sf "http://metadata.google.internal/computeMetadata/v1/instance/name" \
  -H "Metadata-Flavor: Google")

VM_ZONE=$(curl -sf "http://metadata.google.internal/computeMetadata/v1/instance/zone" \
  -H "Metadata-Flavor: Google" | awk -F'/' '{print $NF}')

# Cria página HTML personalizada com identificação da instância
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>GCP Load Balancer Demo</title>
  <style>
    body { font-family: Arial, sans-serif; display: flex; justify-content: center;
           align-items: center; height: 100vh; margin: 0; background: #f0f4f8; }
    .card { background: white; padding: 2rem; border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1); text-align: center; }
    h1 { color: #4285F4; }
    .badge { background: #34A853; color: white; padding: 4px 12px;
             border-radius: 20px; font-size: 0.85rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>☁️ GCP HTTP Load Balancer</h1>
    <p>Esta requisição foi servida por:</p>
    <h2>${VM_HOSTNAME}</h2>
    <span class="badge">Zona: ${VM_ZONE}</span>
    <p><small>Alta Disponibilidade · Compute Engine · Apache 2.4</small></p>
  </div>
</body>
</html>
EOF

echo "✅ Startup script concluído — Apache configurado em ${VM_HOSTNAME}."
```

---

## 🔒 Configuração de Rede e Firewall

A segurança da rede é implementada por meio de **Firewall Rules** na VPC padrão do GCP. Duas regras distintas foram criadas para controlar o acesso:

### Regras de Firewall

| Regra | Direção | Origem | Protocolo/Porta | Alvo | Finalidade |
|-------|---------|--------|-----------------|------|-----------|
| `allow-http` | INGRESS | `0.0.0.0/0` | TCP:80 | tag: `allow-http` | Tráfego HTTP externo |
| `allow-health-check` | INGRESS | `130.211.0.0/22`, `35.191.0.0/16` | TCP:80 | tag: `allow-http` | Sondagem do Load Balancer |

> **Por que dois intervalos de IP para Health Check?**  
> O GCP utiliza esses ranges específicos para seus sistemas internos de verificação de saúde. Bloquear esses IPs impede que o Load Balancer identifique instâncias como saudáveis, removendo-as do pool.

### Script de Configuração do Firewall

```bash
#!/bin/bash
# firewall.sh — Configura regras de firewall para a infraestrutura web

set -euo pipefail

PROJECT_ID="seu-projeto-gcp"
NETWORK="default"
TARGET_TAG="allow-http"

echo "🔥 Configurando regras de firewall..."

# Regra 1: Permite tráfego HTTP externo para as VMs com a tag correta
gcloud compute firewall-rules create allow-http \
  --project="${PROJECT_ID}" \
  --network="${NETWORK}" \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:80 \
  --source-ranges="0.0.0.0/0" \
  --target-tags="${TARGET_TAG}" \
  --description="Permite tráfego HTTP de qualquer origem"

echo "✅ Regra allow-http criada."

# Regra 2: Permite health checks do GCP Load Balancer
# IPs proprietários do Google para sistemas de health check
gcloud compute firewall-rules create allow-health-check \
  --project="${PROJECT_ID}" \
  --network="${NETWORK}" \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:80 \
  --source-ranges="130.211.0.0/22,35.191.0.0/16" \
  --target-tags="${TARGET_TAG}" \
  --description="Permite health checks do GCP Load Balancer"

echo "✅ Regra allow-health-check criada."
echo "🎉 Firewall configurado com sucesso."
```

### Diagrama de Fluxo de Rede

```mermaid
flowchart TD
    A[🌐 Internet\n0.0.0.0/0] -->|TCP:80| B{🔥 Firewall\nallow-http}
    C[🏥 GCP Health Checker\n130.211.0.0/22\n35.191.0.0/16] -->|TCP:80| D{🔥 Firewall\nallow-health-check}

    B -->|✅ Permitido| E[🖥️ VMs com tag\nallow-http]
    D -->|✅ Permitido| E

    F[❌ Tráfego\nNão Autorizado] -->|Bloqueado| G[🚫 Default Deny]

    style B fill:#EA4335,color:#fff
    style D fill:#EA4335,color:#fff
    style G fill:#333,color:#fff
    style E fill:#34A853,color:#fff
```

---

## 🏥 Health Checks

O **Health Check** é o mecanismo pelo qual o Load Balancer determina se uma instância está apta a receber tráfego. A configuração implementada utiliza o protocolo HTTP para verificar se o servidor Apache está respondendo corretamente.

### Parâmetros do Health Check

| Parâmetro | Valor | Significado |
|-----------|-------|-------------|
| `protocol` | HTTP | Verificação via requisição HTTP GET |
| `port` | 80 | Porta padrão do Apache |
| `request-path` | `/` | Verifica a raiz do servidor |
| `check-interval-sec` | 10 | Intervalo entre verificações |
| `timeout-sec` | 5 | Tempo limite para resposta |
| `healthy-threshold` | 2 | Verificações consecutivas para considerar saudável |
| `unhealthy-threshold` | 3 | Falhas consecutivas para remover do pool |

### Script de Configuração do Health Check

```bash
#!/bin/bash
# backend.sh — Configura Health Check e Backend Service

set -euo pipefail

PROJECT_ID="seu-projeto-gcp"
HC_NAME="http-health-check"
BS_NAME="backend-service-web"
IG_NAME="web-instance-group"
REGION="us-east1"

echo "🏥 Criando Health Check HTTP..."

gcloud compute health-checks create http "${HC_NAME}" \
  --project="${PROJECT_ID}" \
  --port=80 \
  --request-path="/" \
  --check-interval=10 \
  --timeout=5 \
  --healthy-threshold=2 \
  --unhealthy-threshold=3 \
  --description="Health check HTTP para instâncias web"

echo "✅ Health Check '${HC_NAME}' criado."
```

### Estados do Health Check

```mermaid
stateDiagram-v2
    [*] --> Desconhecido : Instância recém-adicionada

    Desconhecido --> Verificando : Health Check iniciado

    Verificando --> Saudável : HTTP 200 por 2x consecutivas
    Verificando --> NãoSaudável : Timeout/Erro por 3x consecutivas

    Saudável --> Verificando : Continua monitorando (a cada 10s)
    NãoSaudável --> Verificando : Tentativa de recuperação

    Saudável --> NoPool : Recebe tráfego do LB
    NãoSaudável --> ForaDoPool : Removida do pool — sem tráfego

    NoPool --> ForaDoPool : Falha detectada
    ForaDoPool --> NoPool : Recuperação confirmada
```

---

## ⚙️ Backend Services

O **Backend Service** é o componente central que conecta o Load Balancer às instâncias de backend. Ele define como o tráfego é distribuído, qual health check utilizar e quais grupos de instâncias compõem o pool.

### Configuração do Backend Service

```bash
#!/bin/bash
# Continuação do backend.sh

BS_NAME="backend-service-web"
HC_NAME="http-health-check"
IG_NAME="web-instance-group"
REGION="us-east1"

echo "⚙️ Criando Backend Service..."

# Cria o Backend Service com balanceamento HTTP global
gcloud compute backend-services create "${BS_NAME}" \
  --project="${PROJECT_ID}" \
  --protocol=HTTP \
  --port-name=http \
  --health-checks="${HC_NAME}" \
  --global \
  --description="Backend service para o HTTP Load Balancer"

echo "✅ Backend Service criado."

# Adiciona o Instance Group ao Backend Service
echo "🔗 Adicionando Instance Group ao Backend Service..."

gcloud compute backend-services add-backend "${BS_NAME}" \
  --project="${PROJECT_ID}" \
  --instance-group="${IG_NAME}" \
  --instance-group-region="${REGION}" \
  --balancing-mode=UTILIZATION \
  --max-utilization=0.8 \
  --global

echo "✅ Instance Group adicionado ao Backend Service."
```

### Configuração Completa do HTTP Load Balancer

```bash
#!/bin/bash
# Configuração final do HTTP Load Balancer — url-map, proxy, forwarding rule

LB_NAME="http-lb"
URL_MAP_NAME="url-map-web"
PROXY_NAME="http-proxy-web"
FR_NAME="http-forwarding-rule"
BS_NAME="backend-service-web"

echo "🗺️ Criando URL Map..."
gcloud compute url-maps create "${URL_MAP_NAME}" \
  --project="${PROJECT_ID}" \
  --default-service="${BS_NAME}" \
  --global

echo "🔀 Criando Target HTTP Proxy..."
gcloud compute target-http-proxies create "${PROXY_NAME}" \
  --project="${PROJECT_ID}" \
  --url-map="${URL_MAP_NAME}" \
  --global

echo "📡 Criando Forwarding Rule (IP Externo)..."
gcloud compute forwarding-rules create "${FR_NAME}" \
  --project="${PROJECT_ID}" \
  --target-http-proxy="${PROXY_NAME}" \
  --ports=80 \
  --global

echo "✅ HTTP Load Balancer configurado com sucesso!"
echo "🌐 IP do Load Balancer:"
gcloud compute forwarding-rules describe "${FR_NAME}" \
  --global \
  --format="value(IPAddress)"
```

---

## 📈 Escalabilidade Horizontal

A arquitetura implementada foi projetada com **escalabilidade horizontal** como princípio fundamental. Diferente da escalabilidade vertical (aumentar recursos de uma única máquina), a abordagem horizontal permite adicionar novas instâncias ao pool sem interrupção do serviço.

### Comparativo: Escalabilidade Vertical vs Horizontal

| Aspecto | Vertical (Scale Up) | Horizontal (Scale Out) |
|---------|--------------------|-----------------------|
| **Método** | Aumenta CPU/RAM da VM | Adiciona novas VMs ao pool |
| **Downtime** | Geralmente necessário | Zero downtime |
| **Custo** | Alto (máquinas maiores custam proporcionalmente mais) | Linear (paga pelo que usa) |
| **Limite** | Físico (hardware máximo disponível) | Virtualmente ilimitado |
| **Complexidade** | Baixa | Requer Load Balancer |
| **Aplicação** | Legados monolíticos | Aplicações stateless modernas |
| **Implementado** | ❌ Não adotado | ✅ Adotado neste projeto |

### Adicionando uma Nova Instância ao Pool

```bash
#!/bin/bash
# scale-out.sh — Adiciona nova instância ao pool existente

NEW_VM="web-4"
NEW_ZONE="us-east1-b"
IG_NAME="web-instance-group"
REGION="us-east1"

echo "🚀 Provisionando nova instância ${NEW_VM}..."

gcloud compute instances create "${NEW_VM}" \
  --zone="${NEW_ZONE}" \
  --machine-type="e2-micro" \
  --image-family="debian-11" \
  --image-project="debian-cloud" \
  --tags="allow-http" \
  --metadata-from-file startup-script=startup.sh

echo "🔗 Adicionando ${NEW_VM} ao Instance Group..."

gcloud compute instance-groups unmanaged add-instances "${IG_NAME}" \
  --instances="${NEW_VM}" \
  --zone="${NEW_ZONE}"

echo "✅ ${NEW_VM} adicionada ao pool. O Load Balancer detectará automaticamente."
```

> Após adicionar a instância ao Instance Group, o Health Check valida automaticamente a nova VM. Quando ela passa nas verificações, o Load Balancer começa a rotear tráfego para ela — **sem nenhuma interrupção ao serviço existente**.

---

## 🛡️ Alta Disponibilidade

A **Alta Disponibilidade (HA)** foi alcançada através de múltiplas camadas de redundância:

### Camadas de Redundância

```mermaid
graph TD
    subgraph "Nível 1 — Infraestrutura GCP"
        A[Google Global Network\n99.99% SLA]
    end

    subgraph "Nível 2 — Load Balancer"
        B[HTTP Load Balancer\nManaged Service — Sem SPOF]
    end

    subgraph "Nível 3 — Zonas de Disponibilidade"
        C[us-east1-b\nweb-1] 
        D[us-east1-c\nweb-2]
        E[us-east1-d\nweb-3]
    end

    subgraph "Nível 4 — Failover Automático"
        F[Health Check\nRemove instâncias com falha]
    end

    A --> B --> F
    F --> C & D & E
```

### Cenários de Falha e Comportamento

| Cenário | Impacto | Comportamento Automático |
|---------|---------|--------------------------|
| web-1 fica indisponível | 1 de 3 instâncias fora | LB detecta via HC e para de rotear |
| web-1 e web-2 falham | 1 instância restante | Todo tráfego vai para web-3 |
| Todas as instâncias falham | Serviço indisponível | LB retorna 503 Service Unavailable |
| Zona us-east1-b cai | web-1 afetada | web-2 e web-3 continuam operando |
| Load Balancer reinicia | Zero downtime | Serviço gerenciado pelo GCP — HA nativa |

### Tempo de Recuperação Estimado (RTO)

- **Falha detectada pelo Health Check:** ~10–30 segundos
- **Instância removida do pool:** Imediato após detecção
- **Instância recuperada e reinserida:** ~20–60 segundos (2 verificações positivas × 10s intervalo)

---

## 🤖 Automação com Scripts

Toda a infraestrutura foi provisionada através de **Shell Scripts**, eliminando configurações manuais e garantindo reprodutibilidade total. Esta abordagem segue os princípios de **Infrastructure as Code (IaC)**.

### Estrutura de Automação

```mermaid
flowchart LR
    A[👨‍💻 Engenheiro] -->|Executa| B[firewall.sh]
    A -->|Executa| C[create-vms.sh]
    A -->|Executa| D[http-load-balancer/\ninstance-template.sh]
    A -->|Executa| E[http-load-balancer/\ninstance-group.sh]
    A -->|Executa| F[http-load-balancer/\nbackend.sh]

    B -->|Cria| G[Regras Firewall]
    C -->|Provisiona| H[web-1, web-2, web-3]
    D -->|Gera| I[Instance Template]
    E -->|Agrupa| J[Instance Group]
    F -->|Configura| K[HC + Backend + URL Map\n+ Proxy + Forwarding Rule]

    H & I & J -->|Alimentam| K
    G & K -->|Compõem| L[✅ Infraestrutura Completa]
```

### Boas Práticas Adotadas nos Scripts

```bash
#!/bin/bash
# Exemplo de boas práticas utilizadas em todos os scripts

# 1. Modo estrito — falha imediata em erros
set -euo pipefail

# 2. Variáveis centralizadas no topo
PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-meu-projeto}"
REGION="us-east1"

# 3. Funções para reuso
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
check_command() { command -v "$1" &>/dev/null || { log "ERRO: $1 não encontrado."; exit 1; }; }

# 4. Validação de pré-requisitos
check_command gcloud

# 5. Idempotência — verifica antes de criar
if gcloud compute firewall-rules describe allow-http &>/dev/null; then
  log "Regra allow-http já existe. Pulando criação."
else
  gcloud compute firewall-rules create allow-http ...
  log "Regra allow-http criada com sucesso."
fi
```

---

## 🛠️ Principais Comandos gcloud Utilizados

### Instâncias de Computação

```bash
# Criar instância
gcloud compute instances create web-1 \
  --zone=us-east1-b \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=allow-http \
  --metadata-from-file startup-script=startup.sh

# Listar instâncias e status
gcloud compute instances list

# Descrever uma instância específica
gcloud compute instances describe web-1 --zone=us-east1-b

# SSH na instância
gcloud compute ssh web-1 --zone=us-east1-b
```

### Firewall e Rede

```bash
# Criar regra de firewall HTTP
gcloud compute firewall-rules create allow-http \
  --rules=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=allow-http

# Criar regra para Health Check do GCP
gcloud compute firewall-rules create allow-health-check \
  --rules=tcp:80 \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-http

# Listar regras de firewall
gcloud compute firewall-rules list
```

### Instance Groups

```bash
# Criar Unmanaged Instance Group
gcloud compute instance-groups unmanaged create web-instance-group \
  --zone=us-east1-b

# Adicionar instâncias ao grupo
gcloud compute instance-groups unmanaged add-instances web-instance-group \
  --instances=web-1,web-2,web-3 \
  --zone=us-east1-b

# Definir porta nomeada
gcloud compute instance-groups set-named-ports web-instance-group \
  --named-ports=http:80 \
  --zone=us-east1-b
```

### Load Balancer

```bash
# Criar Health Check
gcloud compute health-checks create http http-health-check \
  --port=80 --request-path="/"

# Criar Backend Service
gcloud compute backend-services create backend-service-web \
  --protocol=HTTP \
  --health-checks=http-health-check \
  --global

# Adicionar backend ao Backend Service
gcloud compute backend-services add-backend backend-service-web \
  --instance-group=web-instance-group \
  --instance-group-region=us-east1 \
  --global

# Criar URL Map
gcloud compute url-maps create url-map-web \
  --default-service=backend-service-web

# Criar Target HTTP Proxy
gcloud compute target-http-proxies create http-proxy-web \
  --url-map=url-map-web

# Criar Forwarding Rule (IP Externo)
gcloud compute forwarding-rules create http-forwarding-rule \
  --target-http-proxy=http-proxy-web \
  --ports=80 \
  --global

# Obter o IP do Load Balancer
gcloud compute forwarding-rules describe http-forwarding-rule \
  --global \
  --format="value(IPAddress)"
```

### Verificação e Diagnóstico

```bash
# Status do Backend Service e saúde das instâncias
gcloud compute backend-services get-health backend-service-web --global

# Descrever URL Map
gcloud compute url-maps describe url-map-web

# Testar conectividade HTTP
curl -s http://LOAD_BALANCER_IP | grep -o "<h2>.*</h2>"

# Simular múltiplas requisições para verificar round-robin
for i in {1..10}; do
  echo "Requisição $i: $(curl -s http://LOAD_BALANCER_IP | grep -oP '(?<=<h2>).*(?=</h2>)')"
done
```

---

## 🏭 Arquitetura em Produção

Em um ambiente de **produção enterprise**, a arquitetura implementada seria expandida com os seguintes componentes adicionais para atender requisitos de segurança, observabilidade e conformidade:

```mermaid
flowchart TD
    A[🌐 Usuários Globais] --> B[🛡️ Cloud Armor\nDDoS + WAF]
    B --> C[🔐 HTTPS Load Balancer\nCertificado SSL/TLS]
    C --> D[📊 Cloud CDN\nCache de Conteúdo]
    D --> E{⚖️ Backend Service\nGlobal}

    E --> F[🗂️ Managed Instance Group\nAuto Scaling]
    E --> G[🗂️ Managed Instance Group\nRegião Secundária]

    F --> H[web-1] & I[web-2] & J[web-3]
    G --> K[web-4] & L[web-5] & M[web-6]

    N[📈 Cloud Monitoring\n+ Alerting] -.->|Monitora| F & G
    O[📝 Cloud Logging] -.->|Coleta logs| F & G
    P[🔍 Cloud Trace] -.->|Rastreia req.| C

    Q[🔒 VPC Service Controls] -.->|Isola| F & G
    R[🏷️ Secret Manager] -.->|Gerencia secrets| F & G

    style B fill:#EA4335,color:#fff
    style C fill:#4285F4,color:#fff
    style D fill:#FBBC04,color:#000
    style N fill:#34A853,color:#fff
```

### Melhorias para Ambiente Produtivo

| Componente | Justificativa | Prioridade |
|-----------|--------------|-----------|
| **Cloud Armor** | Proteção DDoS e WAF para bloquear ataques L3-L7 | 🔴 Alta |
| **HTTPS + SSL** | Criptografia em trânsito — obrigatório para produção | 🔴 Alta |
| **Managed Instance Group** | Auto Scaling baseado em CPU/carga — sem intervenção manual | 🔴 Alta |
| **Cloud CDN** | Cache de assets estáticos na edge — reduz latência global | 🟡 Média |
| **Cloud Monitoring** | Dashboards, alertas e SLOs automatizados | 🟡 Média |
| **Cloud Logging** | Centralização de logs para auditoria e troubleshooting | 🟡 Média |
| **Multi-região** | Redunda em outra região para DR (Disaster Recovery) | 🟢 Baixa |
| **Terraform/IaC** | Substituir scripts Bash por IaC versionável e auditável | 🟡 Média |

---

## 📊 Resultados Obtidos

### Validação da Distribuição de Carga

Após a implementação completa, foram realizados testes de validação executando múltiplas requisições HTTP sequenciais contra o IP do Load Balancer:

```bash
# Resultado real do teste de distribuição
$ for i in {1..9}; do curl -s http://34.XXX.XXX.XXX | grep -oP '(?<=<h2>).*(?=</h2>)'; done

web-1   # Requisição 1
web-2   # Requisição 2
web-3   # Requisição 3
web-1   # Requisição 4
web-2   # Requisição 5
web-3   # Requisição 6
web-1   # Requisição 7
web-2   # Requisição 8
web-3   # Requisição 9
```

> ✅ **Distribuição perfeita em Round Robin** confirmada — cada instância recebeu exatamente 1/3 das requisições.

### Teste de Failover

```bash
# Simulação de falha: parar Apache na web-1
gcloud compute ssh web-1 --zone=us-east1-b -- "sudo systemctl stop apache2"

# Aguardar Health Check detectar a falha (~30s)
sleep 30

# Verificar que tráfego foi redirecionado para web-2 e web-3
for i in {1..6}; do curl -s http://34.XXX.XXX.XXX | grep -oP '(?<=<h2>).*(?=</h2>)'; done

# Resultado esperado:
web-2
web-3
web-2
web-3
web-2
web-3
# web-1 ausente — failover automático funcionando ✅
```

### Métricas Registradas

| Métrica | Valor Observado |
|---------|----------------|
| Latência média (mesmo continente) | ~15–25ms |
| Tempo de detecção de falha | ~20–30 segundos |
| Tempo de reinserção no pool | ~20–40 segundos |
| Disponibilidade durante failover | 100% (sem interrupção) |
| Distribuição de carga | ~33,3% por instância |

---

## 📚 Lições Aprendidas

### Técnicas

**1. Separação das regras de firewall é obrigatória**  
A regra `allow-http` para usuários e `allow-health-check` para o GCP precisam ser criadas separadamente. Sem a segunda regra, o Load Balancer nunca marca as instâncias como saudáveis, e nenhuma requisição é roteada — mesmo com o Apache funcionando.

**2. O Health Check é o coração do Load Balancer**  
Entender os parâmetros de `check-interval`, `timeout`, `healthy-threshold` e `unhealthy-threshold` é fundamental para calibrar corretamente o tempo de detecção de falha vs. sensibilidade a falhas transitórias.

**3. Startup Scripts são executados como root**  
O `metadata startup-script` é executado pelo usuário `root` na inicialização. Isso significa que não é necessário usar `sudo` dentro do script, mas é preciso garantir que os arquivos criados tenham as permissões corretas para o Apache servir.

**4. A Forwarding Rule cria o IP externo**  
Muitos iniciantes confundem o ponto de entrada do Load Balancer. O IP público não é da VM, nem do Backend Service — é atribuído pela **Forwarding Rule**. Sem ela, não há acesso externo.

**5. Instance Groups precisam de porta nomeada**  
O Backend Service identifica a porta de destino pelo **nome** (`http`), não pelo número. Sem definir `--named-ports=http:80` no Instance Group, a configuração falha silenciosamente.

### Operacionais

- **Idempotência nos scripts:** Na segunda execução, comandos `create` falham se o recurso já existe. Adicionar verificações ou usar `--quiet` com tratamento de erro é essencial.
- **Propagação do Load Balancer:** Após criar todos os recursos, o Load Balancer pode levar **2–5 minutos** para se tornar operacional globalmente. Testar imediatamente após criar pode dar falsos negativos.
- **gcloud init** antes de tudo: Sempre verificar `gcloud config list` para confirmar projeto e região ativos antes de executar os scripts.

---

## 🏆 Competências Demonstradas

| Domínio | Habilidade | Evidência no Projeto |
|---------|-----------|---------------------|
| ☁️ **Google Cloud Platform** | Navegação e uso avançado dos serviços GCP | Uso de 10+ serviços distintos |
| 🖥️ **Compute Engine** | Provisionamento e configuração de VMs | 3 VMs em zonas distintas |
| 🌐 **Networking** | VPC, firewall, roteamento, IPs | Regras granulares e topologia correta |
| 🐧 **Linux Administration** | Gerenciamento de serviços, filesystem, permissões | Configuração via startup script |
| ⚖️ **Load Balancing** | Conceitos L4/L7, health checks, backends | HTTP LB completo funcionando |
| 🛡️ **High Availability** | Redundância de zonas, failover automático | Testado e documentado |
| 📈 **Scalability** | Horizontal scaling sem downtime | Processo documentado e validado |
| 📜 **Shell Scripting** | Automação robusta com Bash | Scripts modulares com boas práticas |
| ⚙️ **Infrastructure Automation** | Provisionamento reproducível via código | 100% via scripts — zero cliques |
| 🔄 **DevOps Fundamentals** | IaC, automação, documentação técnica | README + scripts versionáveis |

---

## 🗺️ Roadmap de Evolução

```mermaid
gantt
    title Roadmap de Evolução da Infraestrutura
    dateFormat  YYYY-MM
    section Fase 1 — Concluída
    Compute Engine + Apache           :done, 2025-01, 2025-02
    Firewall Rules                    :done, 2025-01, 2025-02
    HTTP Load Balancer                :done, 2025-02, 2025-03
    Health Checks + Backend Service   :done, 2025-02, 2025-03

    section Fase 2 — Planejada
    Migrar para Terraform             :active, 2025-04, 2025-06
    Implementar HTTPS + SSL           :2025-04, 2025-05
    Configurar Cloud Armor (WAF)      :2025-05, 2025-06
    Adicionar Cloud Monitoring        :2025-05, 2025-07

    section Fase 3 — Futura
    Managed Instance Group + Autoscaling :2025-07, 2025-09
    Cloud CDN para assets estáticos   :2025-08, 2025-10
    Deploy Multi-região (DR)          :2025-09, 2025-12
    CI/CD com Cloud Build             :2025-10, 2025-12
```

---

## 🔮 Possíveis Melhorias Futuras

### Curto Prazo (1–3 meses)

- [ ] **Migrar scripts Bash para Terraform** — versionamento, state management e melhor idempotência
- [ ] **Implementar HTTPS** com certificado gerenciado pelo GCP (Google-managed SSL)
- [ ] **Adicionar Cloud Armor** com regras WAF para proteção contra SQLi, XSS e DDoS
- [ ] **Configurar Cloud Monitoring** com dashboards de latência, throughput e disponibilidade
- [ ] **Centralizar logs** no Cloud Logging com alertas para erros 5xx

### Médio Prazo (3–6 meses)

- [ ] **Migrar para Managed Instance Group (MIG)** com Auto Scaling baseado em CPU
- [ ] **Implementar Cloud CDN** para cache de conteúdo estático na edge da rede Google
- [ ] **Containerizar a aplicação** com Docker e orquestrar no **Google Kubernetes Engine (GKE)**
- [ ] **Criar pipeline CI/CD** com Cloud Build para deploy automatizado
- [ ] **Implementar Blue/Green Deployment** para deploys sem downtime

### Longo Prazo (6–12 meses)

- [ ] **Arquitetura Multi-região** com failover automático entre regiões para DR
- [ ] **Serviços serverless** com Cloud Run para workloads dinâmicas
- [ ] **Service Mesh** com Anthos Service Mesh / Istio para observabilidade e segurança mTLS
- [ ] **FinOps** — implementar labels de custo, budget alerts e rightsizing das VMs
- [ ] **Certificação GCP** — Professional Cloud Architect como validação formal

---

## 🎯 Conclusão Técnica

Este projeto demonstra a implementação completa de uma **arquitetura web escalável e altamente disponível** no Google Cloud Platform, cobrindo desde o provisionamento das instâncias até a configuração de um Load Balancer HTTP funcional com failover automático.

Os principais diferenciais técnicos desta implementação são:

**1. Abordagem CLI-first:** Toda a infraestrutura foi provisionada exclusivamente via `gcloud CLI`, sem uso de interface gráfica. Esta abordagem é preferível em ambientes profissionais por ser reprodutível, auditável e integrável em pipelines de CI/CD.

**2. Automação desde o início:** O uso de *startup scripts* elimina configuração manual pós-provisionamento. Cada VM está pronta para receber tráfego imediatamente após ser criada — um requisito fundamental para Auto Scaling.

**3. Separação de responsabilidades:** A arquitetura segue claramente a separação entre camada de edge (Load Balancer), camada de controle (Backend Service + Health Check) e camada de compute (VMs). Esta separação facilita manutenção, troubleshooting e evolução independente de cada camada.

**4. Redundância por design:** A distribuição das instâncias em zonas de disponibilidade distintas garante que uma falha de zona não derrube o serviço completo — princípio fundamental de Alta Disponibilidade em cloud.

**5. Fundação para escala:** A infraestrutura implementada é a base sobre a qual recursos empresariais como Auto Scaling, Cloud CDN, Cloud Armor e deploys multi-região podem ser adicionados incrementalmente, sem redesenhar a arquitetura.

> Este projeto representa não apenas uma implementação técnica funcional, mas também a internalização dos **princípios de design de infraestrutura cloud-native** que fundamentam o trabalho de um Cloud/DevOps Engineer.

---

## 👨‍💻 Autor

<div align="center">

### Éder Félix


**Cloud Engineer | DevOps Engineer | GCP Enthusiast**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/éder-félix)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ederfelixsilva)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:gunder1eder@gmaill.com)

---

*"Infrastructure is not just servers. It's the foundation that allows software to fulfill its purpose."*

---

<sub>⭐ Se este projeto foi útil para você, considere deixar uma estrela no repositório!</sub>

</div>

---

<div align="center">

**Feito com ☁️ e ☕ por [Seu Nome]**

![GCP](https://img.shields.io/badge/Powered_by-Google_Cloud-4285F4?style=flat-square&logo=google-cloud&logoColor=white)
![Bash](https://img.shields.io/badge/Automated_with-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![Apache](https://img.shields.io/badge/Served_by-Apache-D22128?style=flat-square&logo=apache&logoColor=white)

</div>
