# Emissor de NFS-e Nacional (github.com/miguel-nascimento/emissor-nfse-nacional, private; fork of
# gabrielbuzziv/emissor-nfse-nacional): issues NFS-e straight on the government API with the company's A1
# certificate. Claude Code runs it as an MCP server (`emissor-nfse-mcp`, stdio): nothing listens on the network.
# Each nota's PDF and XML go to iCloud Drive/notas-fiscais; the SQLite database is in ~/.local/share/emissor-nfse.
#
# An export always takes both values from Miguel: BRL received and CAD billed.
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

  age.secrets = lib.optionalAttrs hasCertificate {
    nfse-certificate = secret "nfse-certificate";
    nfse-certificate-password = secret "nfse-certificate-password";
  };

  services.emissor-nfse = {
    enable = true;
    # Igaraçu do Tietê is not on the government's test environment, so there is no testing there
    environment = "production";
    issuer = {
      # MIGUEL GOMES DO NASCIMENTO LTDA, ME in the Simples, Igaraçu do Tietê/SP
      cnpj = "46255572000112";
      cityCode = "3520004";
      simplesOption = "3";
      # From the Oct 2026 nota's XML (pTotTribSN)
      simplesTotalTaxPercent = "5.30";
    };
    certificateFile = config.age.secrets.nfse-certificate.path or "";
    certificatePasswordFile = config.age.secrets.nfse-certificate-password.path or "";
    dataDir = "/Users/${user}/.local/share/emissor-nfse";
    notasDir = "/Users/${user}/Library/Mobile Documents/com~apple~CloudDocs/notas-fiscais";

    presets.bitcomplete = {
      # Exactly as on the Oct 2026 nota issued on the gov portal: no NIF ("not required")
      taker = {
        noNifReason = "2";
        name = "BITCOMPLETE";
        address = {
          country = "CA";
          postalCode = "ON M6H 1X6";
          city = "Toronto";
          region = "ONTARIO";
          street = "197 Hallam St";
          number = "197";
          district = "Dovercourt";
        };
      };
      serviceCode = "010101";
      nbsCode = "115021000";
      description = "Analise e desenvolvimento de sistemas";
      export = {
        resultCountry = "CA";
        currency = "CAD";
      };
    };
  };
}
