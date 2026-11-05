# condepe: Access the Open Data of the Pernambuco Observatory

A tidy interface to the open data of the Observatory of Pernambuco,
Brazil, published by 'Condepe/Fidem', the State Agency for Planning and
Research (<https://cf.pe.gov.br/observatorio>). Municipal series on
population, economy, public finance, labour, education, health,
security, transport and environment, every source in the same long
format, returned as tibbles. Files are read from the canonical endpoint
with a 'Hugging Face' mirror as fallback, cached on disk per catalogue
version and checked against their published 'SHA-256'. Network failures
are handled gracefully.

## Package options

- `condepe.quiet`: suppress informational messages. Defaults to `TRUE`
  in non-interactive sessions.

- `condepe.cache_dir`: cache location. Defaults to
  `tools::R_user_dir("condepe", "cache")`.

- `condepe.catalog_max_age`: seconds a cached catalogue is trusted
  without asking the server. Defaults to 6 hours.

- `condepe.base_url`, `condepe.mirror_url`: the canonical endpoint and
  the mirror (also `CONDEPE_URL` / `CONDEPE_MIRROR_URL`); an empty
  mirror disables the fallback.

- `condepe.max_tries`, `condepe.timeout`: retry attempts (default 3,
  exponential backoff) and request timeout in seconds (default 60).

## See also

Useful links:

- <https://github.com/StrategicProjects/condepe-r>

- <https://strategicprojects.github.io/condepe-r/>

- <https://cf.pe.gov.br/observatorio>

- Report bugs at <https://github.com/StrategicProjects/condepe-r/issues>

## Author

**Maintainer**: André Leite <leite@castlab.org>
([ORCID](https://orcid.org/0000-0002-4718-9766))

Authors:

- André Leite <leite@castlab.org>
  ([ORCID](https://orcid.org/0000-0002-4718-9766))

- Marcos Wasiliew <marcos.wasiliew@gmail.com>
  ([ORCID](https://orcid.org/0009-0004-4694-3159))

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6249-0920))

- Carlos Amorim <carlos.agaf@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6315-8305))

- Diogo Bezerra <diogo.bezerra@ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-1216-8674))

- Júlia Nascimento Barreto <juliabarreto@gd.seplag.pe.gov.br>
  ([ORCID](https://orcid.org/0009-0004-2851-7770))
