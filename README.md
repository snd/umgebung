# umgebung

[![NPM Package](https://img.shields.io/npm/v/umgebung.svg?style=flat)](https://www.npmjs.org/package/umgebung)
[![Build Status](https://travis-ci.org/snd/umgebung.svg?branch=master)](https://travis-ci.org/snd/umgebung/branches)
[![Dependencies](https://david-dm.org/snd/umgebung.svg)](https://david-dm.org/snd/umgebung)

<!--
write a description that doesn't include hinoki
-->

**a [hinoki](https://github.com/snd/hinoki) source for environment variables**

just from the dependency name

used by [fragments](https://github.com/snd/fragments).

```
npm install url-pattern
```

<!--
`umgebung` is a [hinoki](https://github.com/snd/hinoki) source.
(if you don't know what that means read this).

a source is simply a function that takes a name and returns a factory.
a factory 
-->

provided these [env vars](.env) are set in your shell:

``` bash
PORT=8080
ENABLE_ETAGS=true
DATABASE_URL="postgres://localhost:5432/my_database"
COMMISSION=0.1
API_CREDENTIALS='{"user": "foo", "password": "bar"}'
```

then with [umgebung](https://github.com/snd/umgebung) and the
[hinoki](https://github.com/snd/hinoki) dependency injection system you can
ask for env-vars by their name in your code:

``` javascript
var hinoki = require('hinoki');
var umgebung = require('umgebung');

hinoki(umgebung, function(
  envIntPort,
  envBoolEnableEtags,
  envStringDatabaseUrl,
  envFloatCommision,
  maybeEnvStringApiKey,
  maybeEnvIntPoolSize,
  maybeEnvJsonApiCredentials
  env
) {
  assert(envIntPort === 8080);
  assert(envBoolEnableEtags === true);
  assert(envStringDatabaseUrl === 'postgres://localhost:5432/my_database');
  assert(envFloatCommission === 0.1);
  assert(maybeEnvStringApiKey === null);
  assert(maybeEnvIntPoolSize === null);

  assert(maybeEnvJsonApiCredentials.user === 'foo');
  assert(maybeEnvJsonApiCredentials.password === 'bar');

  assert(env.PORT === '8080');
  assert(env.ENABLE_ETAGS === 'true');
  assert(env.DATABASE_URL === 'postgres://localhost:5432/my_database');
  assert(env.COMMISSION === '0.1');
  assert(env.API_CREDENTIALS === '{"user": "foo", "password": "bar"}');
});
```

you get the idea:

[umgebung](https://github.com/snd/umgebung) parses
type and env-var name from dependency-names (function arguments), looks them up on `process.env`
and converts them to the specified type.

unless names start with `maybe` it throws an error if no such env-var is present or it is blank.
types `Int`, `Bool`, `Float` and `Json` throw if the env-var can't be parsed.

what comes after the the type is converted from camelcase to underscore-delimited-uppercase
and looked up on `process.env`.

you can add your own types, change the `env` prefix and much more:

``` javascript
var myUmgebung = umgebung.configure({
  // you can provide the env to use (defaults to `process.env`)
  env: {
    PORT: '9090',
    COMMISSION: '0.1'
  },
  // you can change the prefixes
  prefix: 'umgebungsVariable',
  maybePrefix: 'vielleicht',
  // you can change the name of the dependency where the whole `env`
  // (see above) is provided (defaults to `'env'`)
  envDependencyName: 'umgebung'
  // you can add your own types
  typeHandlers: {
    zahl: function(parsed, value) {
      var result = parseInt(value, 10);
      if (isNaN(result)) {
        throw new Error('env var ' + parsed.envVarName + 'must be an integer');
      }
      return result;
    }
  }
});

hinoki(myUmgebung, function(
  umgebungsVariableZahlPort,
  vielleichtUmgebungsVariableZahlPoolSize,
  umgebungsVariableFloatCommission,
  umgebung
) {
  assert(umgebungsVariableZahlPort === 9090);
  assert(vielleichtUmgebungsVariableZahlPoolSize === null);
  assert(umgebungsVariableFloatCommission === 0.1);

  assert(umgebung.PORT === '9090');
  assert(umgebung.COMISSION === '0.1');
});
```

## [license: MIT](LICENSE)
