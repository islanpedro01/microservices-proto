# --- Variáveis de Configuração ---
$GITHUB_USERNAME = "islanpedro01"
$GITHUB_EMAIL = "islanpedro.12@hotmail.com"
$SERVICE_NAME = "shipping"
$RELEASE_VERSION = "v1.2.3"


# --- Preparação do Ambiente ---
Write-Host "Instalando ferramentas do Go Protobuf..." -ForegroundColor Cyan
# Este comando funciona igual no Windows e no Linux
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

# Adiciona o diretório bin do GoPath ao PATH desta sessão do terminal.
# PowerShell usa '; ' como separador de PATH, e a variável de ambiente é $env:Path
$goPathBin = Join-Path (go env GOPATH) "bin"
$env:Path += ";$goPathBin"
Write-Host "Caminho do Go ('$goPathBin') adicionado ao PATH temporariamente." -ForegroundColor Green


# --- Geração dos Arquivos a partir do .proto ---
Write-Host "Gerando código-fonte Go a partir dos arquivos .proto..." -ForegroundColor Cyan

# Cria o diretório 'golang', se não existir. O '-Force' evita erro se a pasta já existir.
New-Item -ItemType Directory -Path "golang" -Force | Out-Null

# Comando protoc. PowerShell lida bem com as barras '/' em caminhos.
# As variáveis são referenciadas como $SERVICE_NAME
protoc --go_out=./golang `
 --go_opt=paths=source_relative `
 --go-grpc_out=./golang `
 --go-grpc_opt=paths=source_relative `
 ./${SERVICE_NAME}/*.proto

Write-Host "Arquivos Go gerados com sucesso!" -ForegroundColor Green
Get-ChildItem -Path "./golang/$SERVICE_NAME" # Equivalente ao 'ls -al'


# --- Configuração do Módulo Go ---
Write-Host "Inicializando o módulo Go..." -ForegroundColor Cyan

# Muda para o diretório do serviço gerado
Set-Location -Path "./golang/$SERVICE_NAME"

# Inicializa o go mod. No PowerShell, os erros não param o script por padrão,
# então o '|| true' não é necessário.
go mod init "github.com/$GITHUB_USERNAME/microservices-proto/golang/$SERVICE_NAME"
go mod tidy

Write-Host "Módulo Go configurado em $(Get-Location)." -ForegroundColor Green

# Volta para o diretório raiz do projeto
Set-Location ../../

# --- Comandos do Git (mantidos como comentários) ---
# Se o Git para Windows estiver instalado, estes comandos funcionarão quando descomentados.
# git config --global user.email ${GITHUB_EMAIL}
# git config --global user.name ${GITHUB_USERNAME}
# git add . && git commit -am "proto update"
# git push -u origin HEAD
# git tag -d ch03/listing_3.2/golang/${SERVICE_NAME}/${RELEASE_VERSION}
# git push --delete origin ch03/listing_3.2/golang/${SERVICE_NAME}/${RELEASE_VERSION}
# git tag -fa ch03/listing_3.2/golang/${SERVICE_NAME}/${RELEASE_VERSION} `
#  -m "ch03/listing_3.2/golang/${SERVICE_NAME}/${RELEASE_VERSION}"
# git push origin refs/tags/ch03/listing_3.2/golang/${SERVICE_NAME}/${RELEASE_VERSION}