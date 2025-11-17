# Wdrożenie Produkcyjnej Infrastruktury EKS w AWS za pomocą Terraform

Ten projekt zawiera kompletny, modułowy i gotowy do produkcji kod Terraform do wdrożenia w pełni funkcjonalnego klastra AWS EKS wraz z niezbędną infrastrukturą sieciową i bezpieczeństwa.

Projekt jest zorganizowany w sposób umożliwiający łatwe zarządzanie wieloma środowiskami (np. `stg` i `prd`) przy użyciu tych samych, reużywalnych modułów.

## Architektura

Infrastruktura jest podzielona na następujące, kluczowe komponenty:

1.  **Sieć (VPC):** Wysokodostępna sieć VPC rozciągnięta na 3 strefy dostępności, z 3 podsieciami publicznymi i 3 prywatnymi. Bramki NAT są również wdrożone w trybie wysokodostępnym (po jednej na każdą strefę).
2.  **Bezpieczeństwo (Security Groups):** Dedykowany moduł zarządza restrykcyjnymi grupami bezpieczeństwa dla Application Load Balancera, płaszczyzny sterowania EKS oraz węzłów roboczych, stosując zasadę najmniejszych uprawnień.
3.  **Klaster (EKS):** Wszechstronny moduł EKS, który dynamicznie tworzy klaster oraz dowolną liczbę grup węzłów (zarówno on-demand, jak i spot) na podstawie przekazanej konfiguracji.
4.  **Tożsamość (IAM):** Moduł IAM zarządza rolami dla usług, takich jak AWS Load Balancer Controller, zgodnie z najlepszymi praktykami (IRSA).
5.  **Load Balancing & SSL (ALB/ACM):** W każdym środowisku automatycznie tworzony jest "Bazowy Ingress", który provisionuje publiczny Application Load Balancer i przypisuje do niego certyfikat SSL.

## Struktura Projektu

```
.
├── environments/
│   ├── prd/              # Konfiguracja środowiska produkcyjnego
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── stg/              # Konfiguracja środowiska stagingowego
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── modules/
│   ├── eks/
│   ├── iam/
│   ├── security_groups/
│   └── vpc/
├── backend.tf            # Wzorzec konfiguracji backendu S3
├── versions.tf           # Wersjonowanie Terraform i dostawców
└── README.md
```

## Jak wdrożyć środowisko?

Poniższe kroki należy wykonać dla każdego środowiska (`stg` lub `prd`).

### Krok 1: Wymagania wstępne

1.  **Zainstaluj Terraform** (wersja `~> 1.5`).
2.  **Skonfiguruj swoje poświadczenia AWS** (np. za pomocą `aws configure`).
3.  **Stwórz bucket S3 i tabelę DynamoDB** do przechowywania stanu Terraform.
4.  **Zaktualizuj plik `backend.tf`** w głównym katalogu, podając nazwy swojego bucketa i tabeli. Pliki `main.tf` w środowiskach automatycznie odziedziczą tę konfigurację.

### Krok 2: Inicjalizacja Terraform

Przejdź do katalogu wybranego środowiska i uruchom `init`.

```bash
cd environments/stg
terraform init
```

### Krok 3: Przegląd planu

Przed wdrożeniem, zawsze sprawdź, jakie zmiany Terraform zamierza wprowadzić.

```bash
terraform plan -var-file="stg.tfvars"
```
*Uwaga: Zaleca się przechowywanie wartości zmiennych, takich jak `domain_name`, w plikach `.tfvars` zamiast modyfikować wartości domyślne.*

### Krok 4: Wdrożenie infrastruktury i walidacja certyfikatu

Uruchom `apply`. Terraform rozpocznie tworzenie zasobów. **Proces zatrzyma się na etapie walidacji certyfikatu ACM i wyświetli dane wyjściowe.**

```bash
terraform apply -var-file="stg.tfvars"
```

Po uruchomieniu `apply`, w wyjściu zobaczysz mapę podobną do tej:

```
Outputs:

acm_validation_records_to_create = {
  "_acb1234567890.example.com." = "_cba0987654321.acm-validations.aws."
}
```

1.  Zaloguj się do swojego dostawcy DNS (np. Cloudflare).
2.  Stwórz **nowy rekord CNAME**.
3.  Jako **nazwę** rekordu, wklej klucz z mapy (np. `_acb1234567890.example.com.`).
4.  Jako **wartość** (cel), wklej wartość z mapy (np. `_cba0987654321.acm-validations.aws.`).
5.  Zapisz rekord.

Terraform będzie automatycznie czekał, aż AWS wykryje ten rekord i pomyślnie zweryfikuje certyfikat. Może to potrwać kilka minut. Po pomyślnej walidacji, `apply` dokończy pracę.

### Krok 5: Niszczenie infrastruktury

Aby usunąć całą infrastrukturę stworzoną dla danego środowiska, uruchom `destroy` z katalogu tego środowiska:

```bash
terraform destroy -var-file="stg.tfvars"
```
