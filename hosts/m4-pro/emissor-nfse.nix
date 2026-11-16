# Emissor de NFS-e Nacional (github.com/miguel-nascimento/emissor-nfse-nacional, private; fork of
# gabrielbuzziv/emissor-nfse-nacional): issues NFS-e straight on the government API with the company's A1
# certificate. Claude Code runs it as an MCP server (`emissor-nfse-mcp`, stdio): nothing listens on the network.
# Each nota's PDF and XML go to iCloud Drive/notas-fiscais; the SQLite database is in ~/.local/share/emissor-nfse.
#
# Until secrets/nfse-certificate.age exists, the `saude` tool says there is no certificate.
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
    # "production" once a test nota went through
    environment = "restricted";
    issuer = {
      # MIGUEL GOMES DO NASCIMENTO LTDA, ME in the Simples, Igaraçu do Tietê/SP
      cnpj = "46255572000112";
      cityCode = "3520004";
      simplesOption = "3";
      # TODO(miguel): the rate on the last nota's XML (consultar_nota_governo once the certificate is in)
      simplesTotalTaxPercent = "";
    };
    certificateFile = config.age.secrets.nfse-certificate.path or "";
    certificatePasswordFile = config.age.secrets.nfse-certificate-password.path or "";
    dataDir = "/Users/${user}/.local/share/emissor-nfse";
    notasDir = "/Users/${user}/Library/Mobile Documents/com~apple~CloudDocs/notas-fiscais";

    presets.bitcomplete = {
      # As on the notas issued on the gov portal (Oct 2026): no NIF ("not required")
      taker = {
        noNifReason = "2";
        name = "BITCOMPLETE";
        address = {
          country = "CA";
          postalCode = "M6H 1X6";
          city = "Toronto";
          region = "ON";
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
