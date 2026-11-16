# Emissor de NFS-e Nacional (github.com/gabrielbuzziv/emissor-nfse-nacional, our self-hosted fork): issues NFS-e
# straight on the government API with the company's A1 certificate. One Node process with a SQLite database in
# ~/.local/share/emissor-nfse; Caddy serves it at https://nfse.miguelnascimento.dev (caddy.nix).
#
# It stays off until the certificate is in secrets/ (see secrets/secrets.nix) and the issuer below is filled in.
# Get the API token with `agenix -d nfse-api-token.age` in secrets/.
{
  config,
  lib,
  inputs,
  user,
  ...
}:
let
  secret = name: {
    file = "${inputs.self}/secrets/${name}.age";
    owner = user;
  };
  hasCertificate = builtins.pathExists "${inputs.self}/secrets/nfse-certificate.age";
in
{
  imports = [ inputs.emissor-nfse.darwinModules.default ];

  age.secrets = {
    nfse-api-token = secret "nfse-api-token";
  }
  // lib.optionalAttrs hasCertificate {
    # The .pfx itself: `age -R <(ssh-keygen ... ) -o nfse-certificate.age certificado.pfx`, see secrets/secrets.nix
    nfse-certificate = secret "nfse-certificate";
    nfse-certificate-password = secret "nfse-certificate-password";
  };

  services.emissor-nfse = {
    enable = hasCertificate;
    # "production" once a test nota went through, and after wiping the test notas (README, step 5)
    environment = "restricted";
    issuer = {
      # MIGUEL GOMES DO NASCIMENTO LTDA, ME in the Simples, Igaraçu do Tietê/SP
      cnpj = "46255572000112";
      cityCode = "3520004";
      simplesOption = "3";
      # TODO(miguel): nominal Simples rate of the bracket, from the accountant (Picolli); not on the notas, which are
      # all service exports
      simplesTotalTaxPercent = "";
    };
    port = 8787;
    publicUrl = "https://nfse.miguelnascimento.dev";
    certificateFile = config.age.secrets.nfse-certificate.path or "";
    certificatePasswordFile = config.age.secrets.nfse-certificate-password.path or "";
    apiTokenFile = config.age.secrets.nfse-api-token.path;
    dataDir = "/Users/${user}/.local/share/emissor-nfse";
    logFile = "/Users/${user}/Library/Logs/emissor-nfse.log";
  };
}
