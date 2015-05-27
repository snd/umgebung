hinoki = require 'hinoki'

umgebung = require '../src/umgebung'

module.exports =

  'README.md':
    'default': (test) ->
      hinoki umgebung, (
        envIntPort,
        envBoolEnableEtags,
        envStringDatabaseUrl,
        envFloatCommission,
        maybeEnvStringApiKey,
        maybeEnvIntPoolSize,
        maybeEnvJsonApiCredentials
        env
      ) ->
        test.equal envIntPort, 8080
        test.equal envBoolEnableEtags, true
        test.equal envStringDatabaseUrl, 'postgres://localhost:5432/my_database'
        test.equal envFloatCommission, 0.1
        test.equal maybeEnvStringApiKey, null
        test.equal maybeEnvIntPoolSize, null

        test.deepEqual maybeEnvJsonApiCredentials,
          user: 'foo'
          password: 'bar'

        test.equal env.PORT, '8080'
        test.equal env.ENABLE_ETAGS, 'true'
        test.equal env.DATABASE_URL, 'postgres://localhost:5432/my_database'
        test.equal env.COMMISSION, '0.1'
        test.equal env.API_CREDENTIALS, '{"user": "foo", "password": "bar"}'
        test.done()

    'configured': (test) ->
      env =
        PORT: '9090'
        COMMISSION: '0.1'

      myUmgebung = umgebung.configure
        env: env
        prefix: 'umgebungsVariable'
        maybePrefix: 'vielleicht'
        envDependencyName: 'umgebung'
        typeHandlers:
          zahl: (parsed, value) ->
            result = parseInt value, 10
            if isNaN result
              throw new Error "env var #{parsed.envVarName} must be an integer"
            return result

      hinoki myUmgebung, (
        umgebungsVariableZahlPort
        vielleichtUmgebungsVariableZahlPoolSize
        umgebungsVariableFloatCommission
        umgebung
      ) ->
        test.equal umgebungsVariableZahlPort, 9090
        test.equal vielleichtUmgebungsVariableZahlPoolSize, null
        test.equal umgebungsVariableFloatCommission, 0.1
        test.equal umgebung, env
        test.done()

  'envStringBaseUrl':

    'success': (test) ->
      lifetime =
        env:
          BASE_URL: '/test'
      hinoki(umgebung, lifetime, (envStringBaseUrl) ->
        test.equal envStringBaseUrl, '/test'
        test.done()
      )

    'must be present': (test) ->
      lifetime =
        env: {}
      hinoki(umgebung, lifetime, (envStringBaseUrl) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var BASE_URL must not be blank'
        test.done()

    'must not be blank': (test) ->
      lifetime =
        env:
          BASE_URL: ''
      hinoki(umgebung, lifetime, (envStringBaseUrl) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var BASE_URL must not be blank'
        test.done()

  'maybeEnvStringBaseUrl':

    'null': (test) ->
      lifetime =
        env: {}
      hinoki(umgebung, lifetime, (maybeEnvStringBaseUrl) ->
        test.equal maybeEnvStringBaseUrl, null
        test.done()
      )

    'null (blank)': (test) ->
      lifetime =
        env:
          BASE_URL: ''
      hinoki(umgebung, lifetime, (maybeEnvStringBaseUrl) ->
        test.equal maybeEnvStringBaseUrl, null
        test.done()
      )

    'success': (test) ->
      lifetime =
        env:
          BASE_URL: '/test'
      hinoki(umgebung, lifetime, (maybeEnvStringBaseUrl) ->
        test.equal maybeEnvStringBaseUrl, '/test'
        test.done()
      )

  'envBoolIsActive':

    'true': (test) ->
      lifetime =
        env:
          IS_ACTIVE: 'true'
      hinoki(umgebung, lifetime, (envBoolIsActive) ->
        test.equal envBoolIsActive, true
        test.done()
      )

    'false': (test) ->
      lifetime =
        env:
          IS_ACTIVE: 'false'
      hinoki(umgebung, lifetime, (envBoolIsActive) ->
        test.equal envBoolIsActive, false
        test.done()
      )

    'must be true or false': (test) ->
      lifetime =
        env:
          IS_ACTIVE: 'foo'

      hinoki(umgebung, lifetime, (envBoolIsActive) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var IS_ACTIVE must be \'true\' or \'false\''
        test.done()

  'maybeEnvBoolIsActive':

    'null': (test) ->
      lifetime =
        env: {}
      hinoki(umgebung, lifetime, (maybeEnvBoolIsActive) ->
        test.equal maybeEnvBoolIsActive, null
        test.done()
      )

    'true': (test) ->
      lifetime =
        env:
          IS_ACTIVE: 'true'
      hinoki(umgebung, lifetime, (maybeEnvBoolIsActive) ->
        test.equal maybeEnvBoolIsActive, true
        test.done()
      )

    'false': (test) ->
      lifetime =
        env:
          IS_ACTIVE: 'false'
      hinoki(umgebung, lifetime, (maybeEnvBoolIsActive) ->
        test.equal maybeEnvBoolIsActive, false
        test.done()
      )

    'must be true or false': (test) ->
      lifetime =
        env:
          IS_ACTIVE: 'foo'
      hinoki(umgebung, lifetime, (maybeEnvBoolIsActive) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var IS_ACTIVE must be \'true\' or \'false\''
        test.done()

  'envIntPort':

    'success': (test) ->
      lifetime =
        env:
          PORT: '9000'

      hinoki(umgebung, lifetime, (envIntPort) ->
        test.equal envIntPort, 9000
        test.done()
      )

    'must be an integer': (test) ->
      lifetime =
        env:
          PORT: 'foo'

      hinoki(umgebung, lifetime, (envIntPort) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var PORT must be an integer'
        test.done()

  'maybeEnvIntPort':

    'null': (test) ->
      lifetime =
        env: {}

      hinoki(umgebung, lifetime, (maybeEnvIntPort) ->
        test.equal maybeEnvIntPort, null
        test.done()
      )

    'success': (test) ->
      lifetime =
        env:
          PORT: '9000'

      hinoki(umgebung, lifetime, (maybeEnvIntPort) ->
        test.equal maybeEnvIntPort, 9000
        test.done()
      )

    'must be an integer': (test) ->
      lifetime =
        env:
          PORT: 'foo'

      hinoki(umgebung, lifetime, (maybeEnvIntPort) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var PORT must be an integer'
        test.done()

  'envFloatPi':

    'success': (test) ->
      lifetime =
        env:
          PI: '3.141'

      hinoki(umgebung, lifetime, (envFloatPi) ->
        test.equal envFloatPi, 3.141
        test.done()
      )

    'must be a float': (test) ->
      lifetime =
        env:
          PI: 'foo'

      hinoki(umgebung, lifetime, (envFloatPi) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var PI must be a float'
        test.done()

  'maybeEnvFloatPi':

    'null': (test) ->
      lifetime =
        env: {}

      hinoki(umgebung, lifetime, (maybeEnvFloatPi) ->
        test.equal maybeEnvFloatPi, null
        test.done()
      )

    'success': (test) ->
      lifetime =
        env:
          PI: '3.141'

      hinoki(umgebung, lifetime, (maybeEnvFloatPi) ->
        test.equal maybeEnvFloatPi, 3.141
        test.done()
      )

    'must be a float': (test) ->
      lifetime =
        env:
          PI: 'foo'

      hinoki(umgebung, lifetime, (maybeEnvFloatPi) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var PI must be a float'
        test.done()

  'envJsonConfig':

    'success': (test) ->
      data =
        alpha: 1
        bravo: true
        charlie: "delta"

      lifetime =
        env:
          CONFIG: JSON.stringify(data)

      hinoki(umgebung, lifetime, (envJsonConfig) ->
        test.deepEqual envJsonConfig, data
        test.done()
      )

    'must be json': (test) ->
      lifetime =
        env:
          CONFIG: 'foo'

      hinoki(umgebung, lifetime, (envJsonConfig) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var CONFIG must be json. syntax error `Unexpected token o`'
        test.done()

  'maybeEnvJsonConfig':

    'null': (test) ->
      lifetime =
        env: {}

      hinoki(umgebung, lifetime, (maybeEnvJsonConfig) ->
        test.equal maybeEnvJsonConfig, null
        test.done()
      )

    'success': (test) ->
      data =
        alpha: 1
        bravo: true
        charlie: "delta"

      lifetime =
        env:
          CONFIG: JSON.stringify(data)

      hinoki(umgebung, lifetime, (maybeEnvJsonConfig) ->
        test.deepEqual maybeEnvJsonConfig, data
        test.done()
      )

    'must be json': (test) ->
      lifetime =
        env:
          CONFIG: 'foo'

      hinoki(umgebung, lifetime, (maybeEnvJsonConfig) ->
        test.ok false
      ).catch hinoki.ErrorInFactory, (error) ->
        test.equal error.error.message, 'env var CONFIG must be json. syntax error `Unexpected token o`'
        test.done()

